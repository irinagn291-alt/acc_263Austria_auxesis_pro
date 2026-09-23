import AuxCanvasCore
import CoreData
import Foundation

/// Role: maps a CanvasRecord to AuxCanvasStrata. Never hands a managed object to the UI.
enum CanvasRecordFold {
    static func strata(from row: CanvasRecord) throws -> AuxCanvasStrata {
        let dayKey = DayKey(raw: row.daykey)
        let rings = try RingLayerRecordFold.rings(from: row)
        var canvas = AuxCanvasStrata(
            dayKey: dayKey,
            phase: .idle,
            rings: rings,
            clearedAt: row.clearedAt
        )
        if let seal = row.fullMark {
            canvas.fullMark = FullMark(dayKey: DayKey(raw: seal.daykey), createdAt: seal.createdAt)
        } else if row.sealedAt != nil {
            canvas.fullMark = FullMark(dayKey: dayKey, createdAt: row.sealedAt ?? Date())
        }
        return canvas
    }

    static func upsert(dayKey: DayKey, in context: NSManagedObjectContext) throws -> CanvasRecord {
        if let existing = try canvas(dayKey: dayKey, in: context) {
            return existing
        }
        let row = CanvasRecord(context: context)
        row.id = UUID()
        row.daykey = dayKey.raw
        row.sealedAt = nil
        row.clearedAt = nil
        row.layers = NSOrderedSet()
        row.abandons = NSSet()
        return row
    }

    static func canvas(dayKey: DayKey, in context: NSManagedObjectContext) throws -> CanvasRecord? {
        let request = NSFetchRequest<CanvasRecord>(entityName: "CanvasRecord")
        request.fetchBatchSize = 20
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "daykey == %d", dayKey.raw)
        request.sortDescriptors = [
            NSSortDescriptor(key: "daykey", ascending: true),
            NSSortDescriptor(key: "id", ascending: true),
        ]
        return try context.fetch(request).first
    }

    static func allCanvases(in context: NSManagedObjectContext) throws -> [CanvasRecord] {
        let request = NSFetchRequest<CanvasRecord>(entityName: "CanvasRecord")
        request.fetchBatchSize = 20
        request.sortDescriptors = [
            NSSortDescriptor(key: "daykey", ascending: false),
            NSSortDescriptor(key: "id", ascending: true),
        ]
        return try context.fetch(request)
    }

    static func save(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            throw AuxStoreError.saveFailed
        }
    }
}
