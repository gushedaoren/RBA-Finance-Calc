//
//  StatsCalculator.swift
//  RBA-Finance-Calc
//
//  Statistics: 1-variable, 2-variable, and regression analysis.

import Foundation

public class StatsCalculator {

    public init() {}

    public func calculate1V(_ values: [Double]) -> Stats1VResult {
        guard !values.isEmpty else { return Stats1VResult() }

        let n = values.count
        let sum = values.reduce(0, +)
        let sumSq = values.reduce(0) { $0 + $1 * $1 }
        let mean = sum / Double(n)
        let min = values.min() ?? 0
        let max = values.max() ?? 0

        let variance = (sumSq - sum * sum / Double(n)) / Double(n)
        let popStdDev = sqrt(variance)
        let sampleStdDev = n > 1 ? sqrt(variance * Double(n) / Double(n - 1)) : 0

        return Stats1VResult(
            n: n, mean: mean,
            sampleStdDev: sampleStdDev,
            populationStdDev: popStdDev,
            sum: sum, sumOfSquares: sumSq,
            min: min, max: max,
            xValues: values
        )
    }

    public func calculate2V(x: [Double], y: [Double]) -> Stats2VResult {
        guard x.count == y.count, !x.isEmpty else { return Stats2VResult() }

        let xStats = calculate1V(x)
        let yStats = calculate1V(y)
        let n = x.count

        let sumXY = zip(x, y).reduce(0) { $0 + $1.0 * $1.1 }
        let cov = sumXY / Double(n) - xStats.mean * yStats.mean

        let corr: Double
        if xStats.populationStdDev * yStats.populationStdDev > 0 {
            corr = cov / (xStats.populationStdDev * yStats.populationStdDev)
        } else {
            corr = 0
        }

        return Stats2VResult(
            x: xStats, y: yStats,
            sumXY: sumXY, covariance: cov,
            correlation: corr
        )
    }

    public func fitRegression(type: RegressionType, x: [Double], y: [Double]) -> RegressionResult {
        var result = RegressionResult()
        result.type = type

        guard x.count == y.count, x.count >= 2 else { return result }

        var xTransformed: [Double]
        var yTransformed: [Double]

        switch type {
        case .linear:
            xTransformed = x
            yTransformed = y
        case .logarithmic:
            xTransformed = x.map { log($0) }
            yTransformed = y
        case .exponential:
            xTransformed = x
            yTransformed = y.map { log(max($0, 1e-10)) }
        case .power:
            xTransformed = x.map { log(max($0, 1e-10)) }
            yTransformed = y.map { log(max($0, 1e-10)) }
        }

        let n = xTransformed.count
        let sumX = xTransformed.reduce(0, +)
        let sumY = yTransformed.reduce(0, +)
        let sumXX = xTransformed.reduce(0) { $0 + $1 * $1 }
        let sumYY = yTransformed.reduce(0) { $0 + $1 * $1 }
        let sumXY = zip(xTransformed, yTransformed).reduce(0) { $0 + $1.0 * $1.1 }

        let denom = Double(n) * sumXX - sumX * sumX
        guard denom != 0 else { return result }

        let slope = (Double(n) * sumXY - sumX * sumY) / denom
        let intercept = (sumY - slope * sumX) / Double(n)

        let corrNumer = Double(n) * sumXY - sumX * sumY
        let corrDenom = sqrt((Double(n) * sumXX - sumX * sumX) * (Double(n) * sumYY - sumY * sumY))
        let correlation = corrDenom != 0 ? corrNumer / corrDenom : 0

        switch type {
        case .linear:
            result.intercept = intercept
            result.slope = slope
        case .logarithmic:
            result.intercept = intercept
            result.slope = slope
        case .exponential:
            result.intercept = exp(intercept)
            result.slope = slope
        case .power:
            result.intercept = exp(intercept)
            result.slope = slope
        }

        result.correlation = correlation
        return result
    }

    public func predict(regression: RegressionResult, xValue: Double) -> Double? {
        switch regression.type {
        case .linear:
            return regression.intercept + regression.slope * xValue
        case .logarithmic:
            guard xValue > 0 else { return nil }
            return regression.intercept + regression.slope * log(xValue)
        case .exponential:
            return regression.intercept * exp(regression.slope * xValue)
        case .power:
            guard xValue > 0 else { return nil }
            return regression.intercept * pow(xValue, regression.slope)
        }
    }

    public func predictInverse(regression: RegressionResult, yValue: Double) -> Double? {
        guard regression.slope != 0 else { return nil }

        switch regression.type {
        case .linear:
            return (yValue - regression.intercept) / regression.slope
        case .logarithmic:
            let x = (yValue - regression.intercept) / regression.slope
            return exp(x)
        case .exponential:
            guard regression.intercept > 0 else { return nil }
            return (log(yValue) - log(regression.intercept)) / regression.slope
        case .power:
            guard regression.intercept > 0 else { return nil }
            return exp((log(yValue) - log(regression.intercept)) / regression.slope)
        }
    }
}
