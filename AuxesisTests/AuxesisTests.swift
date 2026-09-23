import XCTest
@testable import Auxesis

/// Placeholder import smoke. Domain cases live in AuxCanvasCoreTests and AuxCanvasStoreTests.
final class AuxesisTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: AuxesisApp.self), "AuxesisApp")
        XCTAssertEqual(AuxesisClient.userAgent, "Auxesis/1.0 (iOS; +https://auxesis-ring.pro)")
    }
}
