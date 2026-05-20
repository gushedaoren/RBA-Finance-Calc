//
//  ScientificCalculator.swift
//  RBA-Finance-Calc
//
//  Scientific function calculator - trig, log, power, etc.

import Foundation

// MARK: - Scientific Function

public enum ScientificFunction {
    case square
    case squareRoot
    case reciprocal
    case factorial
    case ln
    case log
    case exp
    case sin
    case cos
    case tan
    case asin
    case acos
    case atan
    case sinh
    case cosh
    case tanh
    case asinh
    case acosh
    case atanh
    case nPr
    case nCr

    public var displayName: String {
        switch self {
        case .square: return "x²"
        case .squareRoot: return "√"
        case .reciprocal: return "1/x"
        case .factorial: return "x!"
        case .ln: return "ln"
        case .log: return "log"
        case .exp: return "eˣ"
        case .sin: return "sin"
        case .cos: return "cos"
        case .tan: return "tan"
        case .asin: return "sin⁻¹"
        case .acos: return "cos⁻¹"
        case .atan: return "tan⁻¹"
        case .sinh: return "sinh"
        case .cosh: return "cosh"
        case .tanh: return "tanh"
        case .asinh: return "sinh⁻¹"
        case .acosh: return "cosh⁻¹"
        case .atanh: return "tanh⁻¹"
        case .nPr: return "nPr"
        case .nCr: return "nCr"
        }
    }
}

// MARK: - Scientific Error

public enum ScientificError: Error, CustomStringConvertible {
    case negativeSqrt
    case divisionByZero
    case factNegative
    case factTooLarge
    case domainError
    case invalidNPr

    public var description: String {
        switch self {
        case .negativeSqrt: return "Error: Negative sqrt"
        case .divisionByZero: return "Error: Division by 0"
        case .factNegative: return "Error: Negative factorial"
        case .factTooLarge: return "Error: Overflow"
        case .domainError: return "Error: Domain error"
        case .invalidNPr: return "Error: Invalid nPr"
        }
    }
}

// MARK: - Scientific Calculator

public class ScientificCalculator {

    public var angleMode: AngleMode = .deg
    public var displayValue: Decimal = 0
    public var errorMessage: String?

    public init() {}

    // MARK: - Execute

    public func execute(_ function: ScientificFunction, value: Decimal? = nil) -> Decimal? {
        resetError()

        let input = value ?? displayValue

        guard input.isNaN == false else {
            setScientificError(.domainError)
            return nil
        }

        var result: Decimal

        switch function {
        case .square:
            result = input * input
            displayValue = result

        case .squareRoot:
            guard input >= 0 else {
                setScientificError(.negativeSqrt)
                return nil
            }
            result = Decimal.sqrt(input)
            displayValue = result

        case .reciprocal:
            guard input != 0 else {
                setScientificError(.divisionByZero)
                return nil
            }
            result = 1 / input
            displayValue = result

        case .factorial:
            guard input >= 0 && input == NSDecimalNumber(decimal: input).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)).decimalValue else {
                setScientificError(.domainError)
                return nil
            }
            let n = Int(truncating: input as NSNumber)
            guard n <= 170 else {
                setScientificError(.factTooLarge)
                return nil
            }
            result = Decimal.factorial(n)
            displayValue = result

        case .ln:
            guard input > 0 else {
                setScientificError(.domainError)
                return nil
            }
            result = Decimal.ln(input)
            displayValue = result

        case .log:
            guard input > 0 else {
                setScientificError(.domainError)
                return nil
            }
            result = Decimal.log10(input)
            displayValue = result

        case .exp:
            result = Decimal.exp(input)
            displayValue = result

        case .sin:
            let radians = angleMode.toRadians(input)
            result = Decimal.sin(radians)
            displayValue = result

        case .cos:
            let radians = angleMode.toRadians(input)
            result = Decimal.cos(radians)
            displayValue = result

        case .tan:
            let radians = angleMode.toRadians(input)
            result = Decimal.tan(radians)
            if result.isNaN {
                setScientificError(.domainError)
                return nil
            }
            displayValue = result

        case .asin:
            guard input >= -1 && input <= 1 else {
                setScientificError(.domainError)
                return nil
            }
            result = Decimal.asin(input)
            result = angleMode.fromRadians(result)
            displayValue = result

        case .acos:
            guard input >= -1 && input <= 1 else {
                setScientificError(.domainError)
                return nil
            }
            result = Decimal.acos(input)
            result = angleMode.fromRadians(result)
            displayValue = result

        case .atan:
            result = Decimal.atan(input)
            result = angleMode.fromRadians(result)
            displayValue = result

        case .sinh:
            result = Decimal.sinh(input)
            displayValue = result

        case .cosh:
            result = Decimal.cosh(input)
            displayValue = result

        case .tanh:
            result = Decimal.tanh(input)
            displayValue = result

        case .asinh:
            result = Decimal.asinh(input)
            displayValue = result

        case .acosh:
            guard input >= 1 else {
                setScientificError(.domainError)
                return nil
            }
            result = Decimal.acosh(input)
            displayValue = result

        case .atanh:
            guard input > -1 && input < 1 else {
                setScientificError(.domainError)
                return nil
            }
            result = Decimal.atanh(input)
            displayValue = result

        case .nPr, .nCr:
            return nil
        }

        return result
    }

    public func executeNPr(n: Int, r: Int) -> Decimal? {
        guard n >= 0 && r >= 0, r <= n else {
            setScientificError(.invalidNPr)
            return nil
        }
        let result = Decimal.nPr(n, r)
        displayValue = result
        return result
    }

    public func executeNCr(n: Int, r: Int) -> Decimal? {
        guard n >= 0 && r >= 0, r <= n else {
            setScientificError(.invalidNPr)
            return nil
        }
        let result = Decimal.nCr(n, r)
        displayValue = result
        return result
    }

    // MARK: - Constants

    public func inputPi() {
        displayValue = Decimal.pi
    }

    public func inputE() {
        displayValue = Decimal.e
    }

    // MARK: - Error

    private func resetError() {
        errorMessage = nil
    }

    private func setScientificError(_ error: ScientificError) {
        errorMessage = error.description
    }
}
