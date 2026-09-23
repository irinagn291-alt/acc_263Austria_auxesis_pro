import CoreData
import Foundation

/// Role: one NSPersistentContainer, owned by the composition root.
///
/// NSPersistentContainer is safe for viewContext, newBackgroundContext, and performBackgroundTask.
/// This wrapper never vends managed objects across isolation domains.
final class AuxStack: @unchecked Sendable {
    let container: NSPersistentContainer
    let warning: StoreWarning?

    init(container: NSPersistentContainer, warning: StoreWarning?) {
        self.container = container
        self.warning = warning
    }

    static func open(inMemory: Bool) async throws -> AuxStack {
        let container = NSPersistentContainer(name: "Auxesis", managedObjectModel: AuxSchema.model())
        let description = NSPersistentStoreDescription()
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            description.url = try diskURL()
        }
        description.type = NSSQLiteStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        var warning: StoreWarning?
        if await load(container) != nil {
            destroy(container)
            if let again = await load(container) {
                throw again
            }
            warning = .recreated
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return AuxStack(container: container, warning: warning)
    }

    nonisolated func performBackground(_ work: @escaping @Sendable (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(work)
    }

    func performView(_ work: @escaping @Sendable (NSManagedObjectContext) -> Void) {
        container.viewContext.perform {
            work(self.container.viewContext)
        }
    }

    private static func diskURL() throws -> URL {
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = root.appendingPathComponent("Auxesis", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("canvas.sqlite")
    }

    private static func load(_ container: NSPersistentContainer) async -> AuxStoreError? {
        await withCheckedContinuation { continuation in
            container.loadPersistentStores { _, error in
                continuation.resume(returning: error == nil ? nil : .loadFailed)
            }
        }
    }

    private static func destroy(_ container: NSPersistentContainer) {
        let coordinator = container.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            let url = store.url
            try? coordinator.remove(store)
            guard let url, url.isFileURL, url.path != "/dev/null" else { continue }
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + "-shm"))
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + "-wal"))
        }
    }
}
