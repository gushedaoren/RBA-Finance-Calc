import XCTest
@testable import RBACalc

final class TVMCalculatorTests: XCTestCase {

    var calculator: TVMCalculator!

    override func setUp() {
        super.setUp()
        calculator = TVMCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    func testBasicMortgage() {
        var input = TVMInput()
        input.n = 360; input.iy = 5.5; input.pv = 75000; input.fv = 0
        input.py = 12; input.cy = 12; input.isBGN = false

        do {
            let pmt = try calculator.calculatePMT(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: pmt)), -425.84, accuracy: 0.01)
        } catch {
            XCTFail("TVM Basic Mortgage: \(error)")
        }
    }

    func testBGNMode() {
        var input = TVMInput()
        input.n = 20; input.iy = 0.5; input.pv = -5000; input.fv = 0
        input.py = 4; input.cy = 4; input.isBGN = true

        do {
            let pmt = try calculator.calculatePMT(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: pmt)), 252.978, accuracy: 0.5)
        } catch {
            XCTFail("TVM BGN Mode: \(error)")
        }
    }

    func testPYNotEqualCY() {
        var input = TVMInput()
        input.n = 120; input.iy = 0.5; input.pv = 25000; input.fv = 25000
        input.py = 12; input.cy = 4; input.isBGN = true

        do {
            let pmt = try calculator.calculatePMT(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: pmt)), -416.667, accuracy: 1.0)
        } catch {
            XCTFail("TVM PY!=CY: \(error)")
        }
    }

    func testFutureValue() {
        var input = TVMInput()
        input.n = 120; input.iy = 7.5; input.pv = -200; input.pmt = 0
        input.py = 12; input.cy = 12; input.isBGN = false

        do {
            let fv = try calculator.calculateFV(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: fv)), 422.41, accuracy: 0.5)
        } catch {
            XCTFail("TVM FV: \(error)")
        }
    }

    func testPresentValue() {
        var input = TVMInput()
        input.n = 48; input.iy = 6; input.pmt = 0; input.fv = -500
        input.py = 12; input.cy = 12; input.isBGN = false

        do {
            let pv = try calculator.calculatePV(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: pv)), 635.24, accuracy: 0.5)
        } catch {
            XCTFail("TVM PV: \(error)")
        }
    }

    func testInterestRate() {
        var input = TVMInput()
        input.n = 360; input.pv = 75000; input.pmt = -425.84; input.fv = 0
        input.py = 12; input.cy = 12; input.isBGN = false

        do {
            let iy = try calculator.calculateIY(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: iy)), 5.5, accuracy: 0.1)
        } catch {
            XCTFail("TVM I/Y: \(error)")
        }
    }

    func testNumberOfPeriods() {
        var input = TVMInput()
        input.iy = 8; input.pv = -10000; input.pmt = -200; input.fv = 0
        input.py = 12; input.cy = 12; input.isBGN = false

        do {
            let n = try calculator.calculateN(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: n)), 63.02, accuracy: 0.1)
        } catch {
            XCTFail("TVM N: \(error)")
        }
    }

    func testZeroInterest() {
        var input = TVMInput()
        input.n = 120; input.iy = 0; input.pv = 10000; input.fv = 0
        input.py = 12; input.cy = 12; input.isBGN = false

        do {
            let pmt = try calculator.calculatePMT(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: pmt)), -83.33, accuracy: 0.01)
        } catch {
            XCTFail("TVM Zero Interest: \(error)")
        }
    }

    func testSinglePaymentFV() {
        var input = TVMInput()
        input.n = 5; input.iy = 10; input.pv = -1000; input.pmt = 0
        input.py = 1; input.cy = 1; input.isBGN = false

        do {
            let fv = try calculator.calculateFV(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: fv)), 1610.51, accuracy: 0.01)
        } catch {
            XCTFail("TVM Single FV: \(error)")
        }
    }

    func testCarLoan() {
        var input = TVMInput()
        input.n = 60; input.iy = 6.5; input.pv = 25000; input.fv = 0
        input.py = 12; input.cy = 12; input.isBGN = false

        do {
            let pmt = try calculator.calculatePMT(input)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: pmt)), -489.15, accuracy: 2.0)
        } catch {
            XCTFail("TVM Car Loan: \(error)")
        }
    }

    func testAmortization() {
        var input = TVMInput()
        input.n = 360; input.iy = 5.5; input.pv = 75000; input.pmt = -425.84; input.fv = 0
        input.py = 12; input.cy = 12; input.isBGN = false

        do {
            let result = try calculator.calculateAmortization(input, p1: 1, p2: 12)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.bal)), 73847.02, accuracy: 2.0)
            XCTAssertEqual(Double(truncating: NSDecimalNumber(decimal: result.prn)), 1152.98, accuracy: 2.0)
        } catch {
            XCTFail("Amortization: \(error)")
        }
    }
}
