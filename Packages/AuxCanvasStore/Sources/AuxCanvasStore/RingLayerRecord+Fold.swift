import AuxCanvasCore
import CoreData
import Foundation

/// Role: maps RingLayerRecord rows to Ring values. Sort is index then id.
enum RingLayerRecordFold {
    static func rings(from canvas: CanvasRecord) throws -> [Ring] {
        let rows = ((canvas.layers.array as? [RingLayerRecord]) ?? []).sorted {
            if $0.index != $1.index { return $0.index < $1.index }
            return $0.id.uuidString < $1.id.uuidString
        }
        return try rows.map(ring(from:))
    }

    static func ring(from row: RingLayerRecord) throws -> Ring {
        guard let duration = RoundDuration(seconds: Int(row.durationSeconds)) else {
            throw AuxStoreError.bentRow
        }
        return Ring(
            index: Int(row.index),
            duration: duration,
            pace: PaceHold(millis: Int(row.paceMillis)),
            createdAt: row.createdAt,
            isSeed: row.isSeed
        )
    }

    static func insert(_ layer: RingLayer, on canvas: CanvasRecord, in context: NSManagedObjectContext) {
        let row = RingLayerRecord(context: context)
        row.id = UUID()
        row.index = Int32(layer.index)
        row.durationSeconds = Int32(layer.duration.seconds)
        row.paceMillis = Int32(layer.pace.millis)
        row.createdAt = layer.createdAt
        row.isSeed = layer.isSeed
        row.canvas = canvas
        let existing = NSMutableOrderedSet(orderedSet: canvas.layers)
        existing.add(row)
        canvas.layers = existing
    }
}
