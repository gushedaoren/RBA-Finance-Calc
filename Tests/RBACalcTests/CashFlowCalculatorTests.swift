import XCTest
@testable import RBACalc

final class CashFlowCalculatorTests: XCTestCase {

    var calculator: CashFlowCalculator!

    override func setUp() {
        super.setUp()
        calculator = CashFlowCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    func testBasicNPV() {
        var input = CashFlowInput()
        input.cf0 = -7000
        input.cashFlows = [
            CashFlowItem(amount: 3000, frequency: 1),
            CashFlowItem(amount: 5000, frequency: 4),
            CashFlowItem(amount: 4000, frequency: 1)
        ]
        input.discountRate = 20

        do {
            let npv = try calculator.calculateNPV(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: npv)), 7266.44, accuracy: 1.0)
        } catch {
            XCTFail("NPV: \(error)")
        }
    }

    func testBasicIRR() {
        var input = CashFlowInput()
        input.cf0 = -7000
        input.cashFlows = [
            CashFlowItem(amount: 3000, frequency: 1),
            CashFlowItem(amount: 5000, frequency: 4),
            CashFlowItem(amount: 4000, frequency: 1)
        ]
        input.discountRate = 20

        do {
            let irr = try calculator.calculateIRR(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: irr)), 52.71, accuracy: 0.5)
        } catch {
            XCTFail("IRR: \(error)")
        }
    }

    func testBasicNFV() {
        var input = CashFlowInput()
        input.cf0 = -7000
        input.cashFlows = [
            CashFlowItem(amount: 3000, frequency: 1),
            CashFlowItem(amount: 5000, frequency: 4),
            CashFlowItem(amount: 4000, frequency: 1)
        ]
        input.discountRate = 20

        do {
            let nfv = try calculator.calculateNFV(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: nfv)), 21697.47, accuracy: 5.0)
        } catch {
            XCTFail("NFV: \(error)")
        }
    }

    func testPaybackPeriod() {
        var input = CashFlowInput()
        input.cf0 = -7000
        input.cashFlows = [
            CashFlowItem(amount: 3000, frequency: 1),
            CashFlowItem(amount: 5000, frequency: 4),
            CashFlowItem(amount: 4000, frequency: 1)
        ]
        input.discountRate = 20

        do {
            let pb = try calculator.calculatePB(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: pb)), 2.0, accuracy: 0.1)
        } catch {
            XCTFail("PB: \(error)")
        }
    }

    func testDiscountedPayback() {
        var input = CashFlowInput()
        input.cf0 = -7000
        input.cashFlows = [
            CashFlowItem(amount: 3000, frequency: 1),
            CashFlowItem(amount: 5000, frequency: 4),
            CashFlowItem(amount: 4000, frequency: 1)
        ]
        input.discountRate = 20

        do {
            let dpb = try calculator.calculateDPB(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: dpb)), 2.6, accuracy: 0.2)
        } catch {
            XCTFail("DPB: \(error)")
        }
    }

    func testMIRR() {
        var input = CashFlowInput()
        input.cf0 = -7000
        input.cashFlows = [
            CashFlowItem(amount: 3000, frequency: 1),
            CashFlowItem(amount: 5000, frequency: 4),
            CashFlowItem(amount: 4000, frequency: 1)
        ]
        input.discountRate = 20

        do {
            let mod = try calculator.calculateMIRR(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: mod)), 35.12, accuracy: 1.0)
        } catch {
            XCTFail("MIRR: \(error)")
        }
    }

    func testSimpleInvestment() {
        var input = CashFlowInput()
        input.cf0 = -10000
        input.cashFlows = [
            CashFlowItem(amount: 3000, frequency: 1),
            CashFlowItem(amount: 4000, frequency: 1),
            CashFlowItem(amount: 5000, frequency: 1)
        ]
        input.discountRate = 10

        do {
            let npv = try calculator.calculateNPV(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: npv)), -355.25, accuracy: 1.0)
        } catch {
            XCTFail("Simple NPV: \(error)")
        }
    }

    func testCalculateAll() {
        var input = CashFlowInput()
        input.cf0 = -7000
        input.cashFlows = [
            CashFlowItem(amount: 3000, frequency: 1),
            CashFlowItem(amount: 5000, frequency: 4),
            CashFlowItem(amount: 4000, frequency: 1)
        ]
        input.discountRate = 20

        let result = calculator.calculateAll(input)
        XCTAssertNotNil(result.npv)
        XCTAssertNotNil(result.irr)
        XCTAssertNotNil(result.nfv)
        XCTAssertNotNil(result.pb)
        XCTAssertNotNil(result.dpb)
        XCTAssertNotNil(result.mod)
    }
}
