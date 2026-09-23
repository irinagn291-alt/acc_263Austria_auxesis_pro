import XCTest
@testable import Auxesis

final class ReviewScreenKeysTests: XCTestCase {
    func test_parsesTodayLogGoalsSettingsAndStrata() {
        XCTAssertEqual(ReviewScreenKeys.parse(arguments: ["-ReviewScreen", "today"]), .today)
        XCTAssertEqual(ReviewScreenKeys.parse(arguments: ["-ReviewScreen", "log"]), .log)
        XCTAssertEqual(ReviewScreenKeys.parse(arguments: ["-ReviewScreen", "goals"]), .goals)
        XCTAssertEqual(ReviewScreenKeys.parse(arguments: ["-ReviewScreen", "settings"]), .settings)
        XCTAssertEqual(ReviewScreenKeys.parse(arguments: ["-ReviewScreen", "strata"]), .strata)
    }

    func test_unknownOrMissingIsNil() {
        XCTAssertNil(ReviewScreenKeys.parse(arguments: []))
        XCTAssertNil(ReviewScreenKeys.parse(arguments: ["-ReviewScreen"]))
        XCTAssertNil(ReviewScreenKeys.parse(arguments: ["-ReviewScreen", "home"]))
        XCTAssertNil(ReviewScreenKeys.parse(arguments: ["today"]))
    }

    func test_readsTheArgumentAfterTheFlagOnly() {
        let parsed = ReviewScreenKeys.parse(arguments: ["Auxesis", "-ReviewScreen", "log", "extra"])
        XCTAssertEqual(parsed, .log)
        XCTAssertNotEqual(parsed, .today)
        XCTAssertNotEqual(parsed, .goals)
    }

    func test_currentReadsProcessInfo() {
        let fromInfo = ReviewScreenKeys.current(from: ProcessInfo.processInfo)
        let parsed = ReviewScreenKeys.parse(arguments: ProcessInfo.processInfo.arguments)
        XCTAssertEqual(fromInfo, parsed)
    }
}
