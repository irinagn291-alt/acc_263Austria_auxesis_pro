import AuxCanvasCore
import CoreData
import Foundation

/// Role: a day row for the Practices sheet. Sealed and partial canvases, never a managed object.
public struct PracticeDay: Hashable, Sendable, Equatable {
    public var dayKey: DayKey
    public var ringCount: Int
    public var isSealed: Bool
    public var durations: [Int]

    public init(dayKey: DayKey, ringCount: Int, isSealed: Bool, durations: [Int]) {
        self.dayKey = dayKey
        self.ringCount = ringCount
        self.isSealed = isSealed
        self.durations = durations
    }

    public init(_ canvas: AuxCanvasStrata) {
        dayKey = canvas.dayKey
        ringCount = canvas.ringCount
        isSealed = canvas.isSealed
        durations = canvas.rings.map(\.duration.seconds)
    }
}

/// Role: FRC on CanvasRecord, daykey descending, daykey as section. Maps to PracticeDay.
/// Created on the view context queue. Delegate callbacks stay on that queue.
/// The model is confined to that queue after init.
public final class PracticesResultsController: NSObject, NSFetchedResultsControllerDelegate, @unchecked Sendable {
    public private(set) var days: [PracticeDay] = []
    public var onChange: (@Sendable () -> Void)?

    private let frc: NSFetchedResultsController<CanvasRecord>

    public init(context: NSManagedObjectContext) {
        let request = NSFetchRequest<CanvasRecord>(entityName: "CanvasRecord")
        request.fetchBatchSize = 20
        request.sortDescriptors = [
            NSSortDescriptor(key: "daykey", ascending: false),
            NSSortDescriptor(key: "id", ascending: true),
        ]
        frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "daykey",
            cacheName: nil
        )
        super.init()
        frc.delegate = self
    }

    public func performFetch() throws {
        try frc.performFetch()
        refresh()
    }

    public var sectionCount: Int {
        frc.sections?.count ?? 0
    }

    public func sectionDayKey(at section: Int) -> DayKey? {
        guard let name = frc.sections?[section].name, let raw = Int32(name) else { return nil }
        return DayKey(raw: raw)
    }

    public func days(in section: Int) -> [PracticeDay] {
        let rows = (frc.sections?[section].objects as? [CanvasRecord]) ?? []
        return rows.compactMap { row in
            guard let canvas = try? CanvasRecordFold.strata(from: row) else { return nil }
            return PracticeDay(canvas)
        }
    }

    public func day(section: Int, row: Int) -> PracticeDay? {
        let rows = days(in: section)
        guard rows.indices.contains(row) else { return nil }
        return rows[row]
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        refresh()
        onChange?()
    }

    private func refresh() {
        let rows = frc.fetchedObjects ?? []
        days = rows.compactMap { row in
            guard let canvas = try? CanvasRecordFold.strata(from: row) else { return nil }
            return PracticeDay(canvas)
        }
    }
}
