import CoreData
import Foundation

/// Role: persistent day canvas. UI never sees this type.
@objc(CanvasRecord)
public final class CanvasRecord: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var daykey: Int32
    @NSManaged public var sealedAt: Date?
    @NSManaged public var clearedAt: Date?
    @NSManaged public var layers: NSOrderedSet
    @NSManaged public var fullMark: FullMarkRecord?
    @NSManaged public var abandons: NSSet
}

/// Role: one ring layer row. Cascade owned by the canvas.
@objc(RingLayerRecord)
public final class RingLayerRecord: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var index: Int32
    @NSManaged public var durationSeconds: Int32
    @NSManaged public var paceMillis: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var isSeed: Bool
    @NSManaged public var canvas: CanvasRecord?
}

/// Role: seventh-ring seal row. Presence of sealedAt on the canvas is the write gate.
@objc(FullMarkRecord)
public final class FullMarkRecord: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var daykey: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var canvas: CanvasRecord?
}

/// Role: mid-cycle abandon row. Does not add a layer.
@objc(AbandonMarkRecord)
public final class AbandonMarkRecord: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var daykey: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var phaseRaw: String
    @NSManaged public var canvas: CanvasRecord?
}
