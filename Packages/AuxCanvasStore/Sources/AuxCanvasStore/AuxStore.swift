import AuxCanvasCore
import CoreData
import Foundation

/// Role: the only seam between the fold and Core Data. UI never touches rows.
public actor AuxStore {
    private let stack: AuxStack
    /// Ephemeral phase lives here. Disk only stores rings, seals, and marks.
    private var live: [DayKey: AuxCanvasStrata] = [:]

    public var warning: StoreWarning? { stack.warning }

    init(stackAlreadyOpen stack: AuxStack) {
        self.stack = stack
    }

    public static func open(inMemory: Bool) async throws -> AuxStore {
        let stack = try await AuxStack.open(inMemory: inMemory)
        return AuxStore(stackAlreadyOpen: stack)
    }

    public func canvas(for dayKey: DayKey) async throws -> AuxCanvasStrata {
        try Task.checkCancellation()
        return try await runOnView { context in
            guard let row = try CanvasRecordFold.canvas(dayKey: dayKey, in: context) else {
                return AuxCanvasStrata.empty(dayKey: dayKey)
            }
            return try CanvasRecordFold.strata(from: row)
        }
    }

    public func seedIfNeeded(dayKey: DayKey, at date: Date) async throws -> AuxCanvasStrata {
        try Task.checkCancellation()
        let seeded = try await runOnBackground { context in
            if let row = try CanvasRecordFold.canvas(dayKey: dayKey, in: context) {
                let current = try CanvasRecordFold.strata(from: row)
                if !current.rings.isEmpty {
                    return current
                }
            }
            let seeded = AuxCanvasStrata.seeded(dayKey: dayKey, at: date)
            let row = try CanvasRecordFold.upsert(dayKey: dayKey, in: context)
            if row.sealedAt != nil {
                throw AuxStoreError.canvasSealed
            }
            if let layer = seeded.rings.first {
                RingLayerRecordFold.insert(RingLayer.from(layer), on: row, in: context)
            }
            try CanvasRecordFold.save(context)
            return try CanvasRecordFold.strata(from: row)
        }
        live[dayKey] = seeded
        return seeded
    }

    @discardableResult
    public func apply(
        _ event: CanvasEvent,
        on dayKey: DayKey,
        at date: Date
    ) async throws -> FoldResult {
        try Task.checkCancellation()
        let starting = live[dayKey]
        let folded = try await runOnView { context in
            let row = try CanvasRecordFold.upsert(dayKey: dayKey, in: context)
            if row.sealedAt != nil {
                let sealed = try CanvasRecordFold.strata(from: row)
                if Self.isWrite(event) {
                    throw AuxStoreError.canvasSealed
                }
                return FoldResult.refused(sealed, .canvasSealed)
            }
            let stored = try CanvasRecordFold.strata(from: row)
            var current = starting ?? stored
            current.rings = stored.rings
            current.fullMark = stored.fullMark
            current.clearedAt = stored.clearedAt
            let result = CanvasFold.apply(event, to: current, at: date)
            if result.refusal != nil {
                return result
            }
            try Self.persist(result, onto: row, in: context)
            try CanvasRecordFold.save(context)
            let persisted = try CanvasRecordFold.strata(from: row)
            var next = result.canvas
            next.rings = persisted.rings
            next.fullMark = persisted.fullMark
            next.clearedAt = persisted.clearedAt
            return FoldResult(
                canvas: next,
                writtenLayer: result.writtenLayer,
                fullMark: result.fullMark ?? next.fullMark,
                abandon: result.abandon
            )
        }
        if folded.refusal == nil {
            live[dayKey] = folded.canvas
        }
        return folded
    }

    public func practicesController() async throws -> PracticesResultsController {
        try Task.checkCancellation()
        return try await runOnView { context in
            let feed = PracticesResultsController(context: context)
            try feed.performFetch()
            return feed
        }
    }

    public func practices() async throws -> [PracticeDay] {
        try Task.checkCancellation()
        return try await runOnView { context in
            try CanvasRecordFold.allCanvases(in: context).map { row in
                PracticeDay(try CanvasRecordFold.strata(from: row))
            }
        }
    }

    public func stats(now: Date, calendar: Calendar) async throws -> AuxStats {
        try Task.checkCancellation()
        return try await runOnView { context in
            let canvases = try CanvasRecordFold.allCanvases(in: context).map {
                try CanvasRecordFold.strata(from: $0)
            }
            return StatsAggregator.assemble(canvases: canvases, now: now, calendar: calendar)
        }
    }

    public func resetAllData() async throws {
        try Task.checkCancellation()
        try await runOnBackground { context in
            let names = ["AbandonMarkRecord", "FullMarkRecord", "RingLayerRecord", "CanvasRecord"]
            for name in names {
                let request = NSFetchRequest<NSManagedObject>(entityName: name)
                request.fetchBatchSize = 20
                request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
                for row in try context.fetch(request) {
                    context.delete(row)
                }
            }
            try CanvasRecordFold.save(context)
        }
        live.removeAll()
    }

    private static func isWrite(_ event: CanvasEvent) -> Bool {
        if case .completeExhale = event { return true }
        return false
    }

    private static func persist(
        _ result: FoldResult,
        onto row: CanvasRecord,
        in context: NSManagedObjectContext
    ) throws {
        if let layer = result.writtenLayer {
            if row.sealedAt != nil {
                throw AuxStoreError.canvasSealed
            }
            RingLayerRecordFold.insert(layer, on: row, in: context)
        }
        if let full = result.fullMark {
            row.sealedAt = full.createdAt
            if row.fullMark == nil {
                let mark = FullMarkRecord(context: context)
                mark.id = UUID()
                mark.daykey = full.dayKey.raw
                mark.createdAt = full.createdAt
                mark.canvas = row
                row.fullMark = mark
            }
        }
        if let abandon = result.abandon {
            let mark = AbandonMarkRecord(context: context)
            mark.id = UUID()
            mark.daykey = abandon.dayKey.raw
            mark.createdAt = abandon.createdAt
            mark.phaseRaw = abandon.leftPhase.rawValue
            mark.canvas = row
        }
        if result.canvas.isClear {
            row.clearedAt = result.canvas.clearedAt ?? Date()
        }
    }

    private func runOnView<T: Sendable>(
        _ work: @escaping @Sendable (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            stack.performView { context in
                Self.finish(work, context: context, continuation: continuation)
            }
        }
    }

    private func runOnBackground<T: Sendable>(
        _ work: @escaping @Sendable (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            stack.performBackground { context in
                context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                Self.finish(work, context: context, continuation: continuation)
            }
        }
    }

    private static func finish<T: Sendable>(
        _ work: (NSManagedObjectContext) throws -> T,
        context: NSManagedObjectContext,
        continuation: CheckedContinuation<T, Error>
    ) {
        do {
            try Task.checkCancellation()
            let value = try work(context)
            continuation.resume(returning: value)
        } catch is CancellationError {
            continuation.resume(throwing: AuxStoreError.cancelled)
        } catch let fault as AuxStoreError {
            continuation.resume(throwing: fault)
        } catch {
            continuation.resume(throwing: AuxStoreError.saveFailed)
        }
    }
}
