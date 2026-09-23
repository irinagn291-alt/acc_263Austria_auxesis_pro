import CoreData
import Foundation

/// Role: NSManagedObjectModel built in code. No .xcdatamodeld so the schema cannot drift.
enum AuxSchema {
    /// Holds the one compiled model. NSManagedObjectModel is not Sendable; it is
    /// created once and never mutated after `makeModel()` returns.
    private final class Box: @unchecked Sendable {
        let model: NSManagedObjectModel
        init() {
            model = AuxSchema.makeModel()
        }
    }

    private static let box = Box()

    static func model() -> NSManagedObjectModel {
        box.model
    }

    private static func makeModel() -> NSManagedObjectModel {
        let canvas = entity("CanvasRecord", CanvasRecord.self)
        let layer = entity("RingLayerRecord", RingLayerRecord.self)
        let full = entity("FullMarkRecord", FullMarkRecord.self)
        let abandon = entity("AbandonMarkRecord", AbandonMarkRecord.self)

        canvas.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("daykey", .integer32AttributeType, defaultValue: 0),
            attribute("sealedAt", .dateAttributeType, optional: true),
            attribute("clearedAt", .dateAttributeType, optional: true),
            toMany("layers", destination: layer, ordered: true),
            toOne("fullMark", destination: full, optional: true),
            toMany("abandons", destination: abandon, ordered: false),
        ]
        layer.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("index", .integer32AttributeType, defaultValue: 0),
            attribute("durationSeconds", .integer32AttributeType, defaultValue: 60),
            attribute("paceMillis", .integer32AttributeType, defaultValue: 1000),
            attribute("createdAt", .dateAttributeType),
            attribute("isSeed", .booleanAttributeType, defaultValue: false),
            toOne("canvas", destination: canvas, optional: true),
        ]
        full.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("daykey", .integer32AttributeType, defaultValue: 0),
            attribute("createdAt", .dateAttributeType),
            toOne("canvas", destination: canvas, optional: true),
        ]
        abandon.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("daykey", .integer32AttributeType, defaultValue: 0),
            attribute("createdAt", .dateAttributeType),
            attribute("phaseRaw", .stringAttributeType, defaultValue: "guided"),
            toOne("canvas", destination: canvas, optional: true),
        ]

        pair(canvas.relationship("layers"), layer.relationship("canvas"), delete: .cascadeDeleteRule)
        pair(canvas.relationship("fullMark"), full.relationship("canvas"), delete: .cascadeDeleteRule)
        pair(canvas.relationship("abandons"), abandon.relationship("canvas"), delete: .cascadeDeleteRule)

        canvas.uniquenessConstraints = [["daykey"], ["id"]]
        layer.uniquenessConstraints = [["id"]]
        full.uniquenessConstraints = [["daykey"], ["id"]]
        abandon.uniquenessConstraints = [["id"]]

        let model = NSManagedObjectModel()
        model.entities = [canvas, layer, full, abandon]
        return model
    }

    private static func entity(_ name: String, _ type: NSManagedObject.Type) -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = NSStringFromClass(type)
        return entity
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        if let defaultValue {
            attribute.defaultValue = defaultValue
        }
        return attribute
    }

    private static func toOne(
        _ name: String,
        destination: NSEntityDescription,
        optional: Bool
    ) -> NSRelationshipDescription {
        let relation = NSRelationshipDescription()
        relation.name = name
        relation.destinationEntity = destination
        relation.minCount = optional ? 0 : 1
        relation.maxCount = 1
        relation.isOptional = optional
        relation.deleteRule = .nullifyDeleteRule
        return relation
    }

    private static func toMany(
        _ name: String,
        destination: NSEntityDescription,
        ordered: Bool
    ) -> NSRelationshipDescription {
        let relation = NSRelationshipDescription()
        relation.name = name
        relation.destinationEntity = destination
        relation.minCount = 0
        relation.maxCount = 0
        relation.isOptional = true
        relation.isOrdered = ordered
        relation.deleteRule = .nullifyDeleteRule
        return relation
    }

    private static func pair(
        _ left: NSRelationshipDescription,
        _ right: NSRelationshipDescription,
        delete: NSDeleteRule = .nullifyDeleteRule
    ) {
        left.inverseRelationship = right
        right.inverseRelationship = left
        if delete == .cascadeDeleteRule {
            left.deleteRule = .cascadeDeleteRule
            right.deleteRule = .nullifyDeleteRule
        }
    }
}

private extension NSEntityDescription {
    func relationship(_ name: String) -> NSRelationshipDescription {
        propertiesByName[name] as? NSRelationshipDescription ?? NSRelationshipDescription()
    }
}
