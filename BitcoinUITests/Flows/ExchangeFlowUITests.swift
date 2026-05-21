import XCTest

final class ExchangeFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainFlowOpensDetailAndShowsAssets() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiScenario", "ui_success"]
        app.launch()

        let firstCell = app.otherElements["exchange_cell_89"].firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 3))
        firstCell.tap()

        XCTAssertTrue(app.staticTexts["exchange_detail_title"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["exchange_assets_list"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["exchange_asset_1"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testErrorStateShowsRetryButton() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiScenario", "ui_error"]
        app.launch()

        XCTAssertTrue(app.otherElements["exchanges_list_error"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["retry_button"].exists)
    }

    @MainActor
    func testEmptyStateIsShown() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiScenario", "ui_empty"]
        app.launch()

        XCTAssertTrue(app.otherElements["exchanges_list_empty"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["retry_button"].exists)
    }
}
