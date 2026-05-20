import XCTest
@testable import RBACalc

final class BondCalculatorTests: XCTestCase {

    var calculator: BondCalculator!

    override func setUp() {
        super.setUp()
        calculator = BondCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    func testStandardBond() {
        var input = BondInput()
        input.settlementMonth = 6; input.settlementDay = 12; input.settlementYear = 6
        input.couponRate = 7
        input.redemptionMonth = 12; input.redemptionDay = 31; input.redemptionYear = 7
        input.redemptionValue = 100
        input.yield = 8
        input.dayBasis = .ACT
        input.frequency = .semiannual

        let result = calculator.calculatePrice(input)
        XCTAssertNil(result.errorMessage)
        if let price = result.price {
            XCTAssertGreaterThan(NSDecimalNumber(decimal: price).doubleValue, 90)
            XCTAssertLessThan(NSDecimalNumber(decimal: price).doubleValue, 100)
        }
        if let ai = result.accruedInterest {
            XCTAssertGreaterThan(NSDecimalNumber(decimal: ai).doubleValue, 0)
        }
    }

    func testZeroCouponBond() {
        var input = BondInput()
        input.settlementMonth = 1; input.settlementDay = 1; input.settlementYear = 20
        input.couponRate = 0
        input.redemptionMonth = 1; input.redemptionDay = 1; input.redemptionYear = 25
        input.redemptionValue = 100
        input.yield = 5
        input.dayBasis = .ACT
        input.frequency = .semiannual

        let result = calculator.calculatePrice(input)
        XCTAssertNil(result.errorMessage)
        if let ai = result.accruedInterest {
            XCTAssertEqual(NSDecimalNumber(decimal: ai).doubleValue, 0, accuracy: 0.01)
        }
    }

    func testPremiumBond() {
        var input = BondInput()
        input.settlementMonth = 1; input.settlementDay = 1; input.settlementYear = 20
        input.couponRate = 10
        input.redemptionMonth = 1; input.redemptionDay = 1; input.redemptionYear = 25
        input.redemptionValue = 100
        input.yield = 8
        input.dayBasis = ._360
        input.frequency = .semiannual

        let result = calculator.calculatePrice(input)
        XCTAssertNil(result.errorMessage)
        if let price = result.price {
            XCTAssertEqual(NSDecimalNumber(decimal: price).doubleValue, 108.11, accuracy: 2.0)
        }
    }

    func testCalculateYield() {
        var input = BondInput()
        input.settlementMonth = 6; input.settlementDay = 12; input.settlementYear = 6
        input.couponRate = 7
        input.redemptionMonth = 12; input.redemptionDay = 31; input.redemptionYear = 7
        input.redemptionValue = 100
        input.price = 98.56
        input.dayBasis = .ACT
        input.frequency = .semiannual

        let result = calculator.calculateYield(input)
        XCTAssertNil(result.errorMessage)
        if let y = result.yield {
            XCTAssertEqual(NSDecimalNumber(decimal: y).doubleValue, 8.0, accuracy: 2.0)
        }
    }
}
