import XCTest
import UIKit
import Static


// From: https://www.raizlabs.com/dev/2017/02/xctest-optional-unwrapping/
struct UnexpectedNilError: Error {}
func AssertNotNilAndUnwrap<T>(_ variable: T?, message: String = "Unexpected nil variable", file: StaticString = #file, line: UInt = #line) throws -> T {
    guard let variable = variable else {
        XCTFail(message, file: file, line: line)
        throw UnexpectedNilError()
    }
    return variable
}

class DataSourceTests: XCTestCase {

    // MARK: - Properties

    let tableView = UITableView()
    let dataSource = DataSource()


    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()
        dataSource.tableView = tableView
    }


    // MARK: - Tests

    func testNumberOfThings() {
        XCTAssertEqual(0, tableView.numberOfSections)

        dataSource.sections = [
            Section(rows: [Row(text: "Row")]),
            Section(rows: [Row(text: "Row"), Row(text: "Row")])
        ]
        XCTAssertEqual(2, tableView.numberOfSections)
        XCTAssertEqual(1, tableView.numberOfRows(inSection: 0))
        XCTAssertEqual(2, tableView.numberOfRows(inSection: 1))

        dataSource.sections = [
            Section(rows: [Row(text: "Your"), Row(text: "Boat")]),
            Section(rows: [Row(text: "Gently"), Row(text: "Down"), Row(text: "The"), Row(text: "Stream")]),
            Section(rows: [Row(text: "Merrily"), Row(text: "Merrily")])
        ]
        XCTAssertEqual(3, tableView.numberOfSections)
        XCTAssertEqual(2, tableView.numberOfRows(inSection: 0))
        XCTAssertEqual(4, tableView.numberOfRows(inSection: 1))
        XCTAssertEqual(2, tableView.numberOfRows(inSection: 2))

        dataSource.sections = []
        XCTAssertEqual(0, tableView.numberOfSections)
    }

    func testCellForRowAtIndexPath() throws {
        dataSource.sections = [
            Section(rows: [
                Row(text: "Merrily", detailText: "merrily", accessory: .disclosureIndicator)
            ])
        ]
        
        // The follwing line can return nil in test code since the cell may not be visible (my speculation)
        // let cell = try AssertNotNilAndUnwrap(tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
        // So, instead, we use the datasource cellForRowAt: call to test the code
        let cell = try AssertNotNilAndUnwrap(dataSource.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)))
        XCTAssertEqual("Merrily", cell.textLabel!.text!)
        XCTAssertEqual("merrily", cell.detailTextLabel!.text!)
        XCTAssertEqual(UITableViewCellAccessoryType.disclosureIndicator, cell.accessoryType)
    }

    func testExtremityTitles() {
        dataSource.sections = [
            Section(header: "Head", rows: [Row(text: "and")], footer: "shoulders"),
            Section(header: "Knees", rows: [Row(text: "and")]),
            Section(rows: [Row(text: "and")], footer: "toes")
        ]

        XCTAssertEqual("Head", dataSource.tableView(tableView, titleForHeaderInSection: 0)!)
        XCTAssertEqual("shoulders", dataSource.tableView(tableView, titleForFooterInSection: 0)!)
        XCTAssertEqual("Knees", dataSource.tableView(tableView, titleForHeaderInSection: 1)!)
        XCTAssertEqual("toes", dataSource.tableView(tableView, titleForFooterInSection: 2)!)
    }

    func testExtremityViews() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        dataSource.sections = [
            Section(header: .view(header), footer: .view(footer))
        ]

        XCTAssertEqual(header, dataSource.tableView(tableView, viewForHeaderInSection: 0)!)
        XCTAssertEqual(100, dataSource.tableView(tableView, heightForHeaderInSection: 0))
        XCTAssertEqual(footer, dataSource.tableView(tableView, viewForFooterInSection: 0)!)
        XCTAssertEqual(44, dataSource.tableView(tableView, heightForFooterInSection: 0))
    }

    func testHighlight() {
        dataSource.sections = [
            Section(rows: [Row(text: "Cookies")])
        ]
        XCTAssertFalse(dataSource.tableView(tableView, shouldHighlightRowAt: IndexPath(row: 0, section: 0)))

        dataSource.sections = [
            Section(rows: [Row(text: "Cupcakes", selectionAction: {})])
        ]
        XCTAssertTrue(dataSource.tableView(tableView, shouldHighlightRowAt: IndexPath(row: 0, section: 0)))
    }

    func testSelection() {
        let expectation = self.expectation(description: "Selected")
        let selection = {
            expectation.fulfill()
        }

        dataSource.sections = [
            Section(rows: [Row(text: "Button", selectionAction: selection)])
        ]
        dataSource.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAccessorySelection() {
        let expectation = self.expectation(description: "Accessory Selected")
        let selection = {
            expectation.fulfill()
        }

        let accessory = Row.Accessory.detailButton(selection)

        dataSource.sections = [
            Section(rows: [Row(text: "Banana Cream Pie", accessory: accessory)])
        ]

        dataSource.tableView(tableView, accessoryButtonTappedForRowWith: IndexPath(row: 0, section: 0))
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testChangeTableView() {
        XCTAssertEqual(dataSource, tableView.dataSource as? DataSource)
        XCTAssertEqual(dataSource, tableView.delegate as? DataSource)

        let tableView2 = UITableView()
        dataSource.tableView = tableView2

        XCTAssertNil(tableView.dataSource)
        XCTAssertNil(tableView.delegate)
        XCTAssertEqual(dataSource, tableView2.dataSource as? DataSource)
        XCTAssertEqual(dataSource, tableView2.delegate as? DataSource)
    }
}
