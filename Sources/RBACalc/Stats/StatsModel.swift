//
//  StatsModel.swift
//  RBA-Finance-Calc

import Foundation

public struct Stats1VResult {
    public var n: Int = 0
    public var mean: Double = 0
    public var sampleStdDev: Double = 0
    public var populationStdDev: Double = 0
    public var sum: Double = 0
    public var sumOfSquares: Double = 0
    public var min: Double = 0
    public var max: Double = 0
    public var xValues: [Double] = []

    public init() {}
}

public struct Stats2VResult {
    public var x: Stats1VResult = Stats1VResult()
    public var y: Stats1VResult = Stats1VResult()
    public var sumXY: Double = 0
    public var covariance: Double = 0
    public var correlation: Double = 0

    public init() {}
}

public enum RegressionType: Int, CaseIterable {
    case linear
    case logarithmic
    case exponential
    case power

    public var displayName: String {
        switch self {
        case .linear: return "LIN"
        case .logarithmic: return "Ln"
        case .exponential: return "EXP"
        case .power: return "PWR"
        }
    }
}

public struct RegressionResult {
    public var intercept: Double = 0
    public var slope: Double = 0
    public var correlation: Double = 0
    public var type: RegressionType = .linear

    public init() {}
}

public struct StatsResult {
    public var oneV: Stats1VResult?
    public var twoV: Stats2VResult?
    public var regression: RegressionResult?
    public var errorMessage: String?

    public init() {}
}
