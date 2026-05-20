import XCTest
@testable import RBACalc

final class DepreciationCalculatorTests: XCTestCase {

    var calculator: DepreciationCalculator!

    override func setUp() {
        super.setUp()
        calculator = DepreciationCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    func testSL_Basic() {
        var input = DepreciationInput()
        input.method = .SL
        input.cost = 10000
        input.salvage = 1000
        input.lif = 5
        input.startModule = 1
        input.year = 3

        let result = calculator.calculate(input)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.depreciation)), 1800.0, accuracy: 0.5)
        XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.bookValue)), 4600.0, accuracy: 1.0)
        XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.remainingValue)), 3600.0, accuracy: 1.0)
    }

    func testSYD_Basic() {
        var input = DepreciationInput()
        input.method = .SYD
        input.cost = 10000
        input.salvage = 1000
        input.lif = 5
        input.startModule = 1
        input.year = 2

        let result = calculator.calculate(input)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.depreciation)), 2400.0, accuracy: 1.0)
        XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.bookValue)), 4600.0, accuracy: 5.0)
    }

    func testDB_Basic() {
        var input = DepreciationInput()
        input.method = .DB
        input.cost = 10000
        input.salvage = 1000
        input.lif = 5
        input.startModule = 1
        input.year = 3

        let result = calculator.calculate(input)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.depreciation)), 1440.0, accuracy: 5.0)
        XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.bookValue)), 2160.0, accuracy: 10.0)
    }

    func testDBX_Basic() {
        var input = DepreciationInput()
        input.method = .DBX
        input.cost = 10000
        input.salvage = 1000
        input.lif = 5
        input.startModule = 1
        input.year = 3
        input.factor = 150

        let result = calculator.calculate(input)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.depreciation)), 1470.0, accuracy: 5.0)
    }

    func testInvalid_SalvageExceedsCost() {
        var input = DepreciationInput()
        input.cost = 1000
        input.salvage = 2000

        let result = calculator.calculate(input)
        XCTAssertNotNil(result.errorMessage)
    }

    func testAllMethods() {
        for method in DepreciationMethod.allCases {
            var input = DepreciationInput()
            input.method = method
            input.cost = 10000
            input.salvage = 1000
            input.lif = 5
            input.year = 2

            let result = calculator.calculate(input)
            XCTAssertNil(result.errorMessage, "\(method.displayName) calculation failed")
        }
    }
}
