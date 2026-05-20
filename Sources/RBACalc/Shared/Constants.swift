//
//  Constants.swift
//  RBA-Finance-Calc
//
//  High-precision financial calculation engine matching TI BA II Plus.

import Foundation

// MARK: - Display Constants

struct DisplayConstants {
    static let maxDigits = 13
    static let maxInputLength = 15
    static let minDisplay = Decimal(1e-9)
    static let sciNotationThreshold: Decimal = 1e12
    static let sciNotationLowThreshold: Decimal = 1e-8
}

// MARK: - Precision Constants

struct PrecisionConstants {
    static let calculationScale: Int16 = 28
    static let defaultDisplayPlaces = 0
    static let iterationTolerance: Decimal = 1e-20
    static let maxIterations = 200
}

// MARK: - TVM Constants

struct TVMConstants {
    static let nMin: Decimal = 1
    static let nMax: Decimal = 999999.99
    static let iyMin: Decimal = 0
    static let iyMax: Decimal = 999999.99
    static let amountMin: Decimal = -999_999_999.99
    static let amountMax: Decimal = 999_999_999.99
    static let frequencyMin: Decimal = 1
    static let frequencyMax: Decimal = 999999.99
}

// MARK: - Cash Flow Constants

struct CashFlowConstants {
    static let maxCashFlowGroups = 9
    static let maxFrequency = 999
    static let cfRangeMin: Decimal = -999_999_999.99
    static let cfRangeMax: Decimal = 999_999_999.99
}

// MARK: - Error Types

public enum RBACalculationError: Error, CustomStringConvertible {
    case divisionByZero
    case outOfRange
    case insufficientInputs
    case noSolution
    case invalidDate
    case negativeSqrt
    case convergenceFailed
    case invalidInput

    public var description: String {
        switch self {
        case .divisionByZero: return "Error: Division by 0"
        case .outOfRange: return "Error: Out of range"
        case .insufficientInputs: return "Need at least 3 inputs"
        case .noSolution: return "Error: No solution"
        case .invalidDate: return "Error: Invalid date"
        case .negativeSqrt: return "Error: Negative sqrt"
        case .convergenceFailed: return "Error: No convergence"
        case .invalidInput: return "Error: Invalid input"
        }
    }
}

// MARK: - Calculation Mode

public enum CalculationMode {
    case CHN
    case AOS

    public var displayName: String {
        switch self {
        case .CHN: return "CHN"
        case .AOS: return "AOS"
        }
    }
}

// MARK: - Payment Timing

public enum PaymentTiming {
    case END
    case BGN

    public var displayName: String {
        switch self {
        case .END: return "END"
        case .BGN: return "BGN"
        }
    }
}

// MARK: - Date Format

public enum DateFormat {
    case US
    case EU
}

// MARK: - Number Format

public enum NumberFormat {
    case US
    case EU
}

// MARK: - Day Basis

public enum DayBasis {
    case ACT
    case _360
}

// MARK: - Bond Frequency

public enum BondFrequency {
    case _1Y
    case _2Y
}
