import XCTest
@testable import RBACalc

final class StatsCalculatorTests: XCTestCase {

    var calculator: StatsCalculator!

    override func setUp() {
        super.setUp()
        calculator = StatsCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    func test1V_Basic() {
        let values: [Double] = [85, 90, 78, 92, 88]
        let result = calculator.calculate1V(values)

        XCTAssertEqual(result.n, 5)
        XCTAssertEqual(result.mean, 86.6, accuracy: 0.1)
        XCTAssertEqual(result.sampleStdDev, 5.77, accuracy: 0.1)
        XCTAssertEqual(result.populationStdDev, 5.16, accuracy: 0.1)
        XCTAssertEqual(result.sum, 433, accuracy: 0.5)
        XCTAssertEqual(result.sumOfSquares, 37557, accuracy: 0.5)
    }

    func test1V_Simple() {
        let values: [Double] = [10, 20, 30, 40, 50]
        let result = calculator.calculate1V(values)

        XCTAssertEqual(result.n, 5)
        XCTAssertEqual(result.mean, 30, accuracy: 0.01)
        XCTAssertEqual(result.sum, 150, accuracy: 0.01)
        XCTAssertEqual(result.sumOfSquares, 5500, accuracy: 0.01)
        XCTAssertEqual(result.populationStdDev, 14.14, accuracy: 0.1)
        XCTAssertEqual(result.sampleStdDev, 15.81, accuracy: 0.1)
    }

    func testLinearRegression() {
        let x: [Double] = [1, 2, 3, 4, 5]
        let y: [Double] = [1, 2, 3, 5, 8]

        let result = calculator.fitRegression(type: .linear, x: x, y: y)

        XCTAssertEqual(result.intercept, -1.1, accuracy: 0.1)
        XCTAssertEqual(result.slope, 1.7, accuracy: 0.1)
        XCTAssertEqual(result.correlation, 0.96, accuracy: 0.05)
    }

    func testPredict() {
        let x: [Double] = [1, 2, 3, 4, 5]
        let y: [Double] = [1, 2, 3, 5, 8]

        let reg = calculator.fitRegression(type: .linear, x: x, y: y)

        let yPred = calculator.predict(regression: reg, xValue: 6)
        XCTAssertNotNil(yPred)
        XCTAssertEqual(yPred!, 9.1, accuracy: 0.1)

        let xPred = calculator.predictInverse(regression: reg, yValue: 10)
        XCTAssertNotNil(xPred)
        XCTAssertEqual(xPred!, 6.53, accuracy: 0.1)
    }

    func testEmptyData() {
        let result = calculator.calculate1V([])
        XCTAssertEqual(result.n, 0)
    }

    func test2V_Correlation() {
        let x: [Double] = [1, 2, 3, 4, 5]
        let y: [Double] = [2, 4, 5, 4, 5]

        let result = calculator.calculate2V(x: x, y: y)

        XCTAssertEqual(result.x.n, 5)
        XCTAssertEqual(result.y.n, 5)
    }
}
