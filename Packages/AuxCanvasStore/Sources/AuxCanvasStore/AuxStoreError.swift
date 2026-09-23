import Foundation

/// Role: recoverable store faults. Never fatalError on a shipping path.
public enum AuxStoreError: Error, Equatable, Sendable {
    case loadFailed
    case saveFailed
    case canvasSealed
    case bentRow
    case cancelled
}

/// Role: surfaced when the SQLite file had to be rebuilt.
public enum StoreWarning: Sendable, Equatable {
    case recreated
}
