//
//  Decimal+Calculations.swift
//  RBA-Finance-Calc
//
//  High-precision Decimal math extensions - avoids IEEE 754 floating point errors.

import Foundation

extension Decimal {

    // MARK: - Power

    static func power(_ base: Decimal, _ exponent: Decimal) -> Decimal {
        if exponent == 0 { return 1 }
        if exponent == 1 { return base }
        if base == 0 { return 0 }
        if base == 1 { return 1 }

        let roundDown = NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let intExp = NSDecimalNumber(decimal: exponent).rounding(accordingToBehavior: roundDown).decimalValue
        if exponent == intExp {
            let intVal = Int(truncating: NSDecimalNumber(decimal: intExp))
            return powerInteger(base, intVal)
        }

        let doubleBase = NSDecimalNumber(decimal: base).doubleValue
        let doubleExp = NSDecimalNumber(decimal: exponent).doubleValue
        return Decimal(pow(doubleBase, doubleExp))
    }

    private static func powerInteger(_ base: Decimal, _ exp: Int) -> Decimal {
        if exp == 0 { return 1 }
        if exp == 1 { return base }
        if exp < 0 { return 1 / powerInteger(base, -exp) }

        var result: Decimal = 1
        var base = base
        var exp = exp

        while exp > 0 {
            if exp & 1 == 1 {
                result = result * base
            }
            base = base * base
            exp >>= 1
        }

        return result
    }

    // MARK: - Square Root

    static func sqrt(_ value: Decimal) -> Decimal {
        if value < 0 { return Decimal.nan }
        if value == 0 { return 0 }
        if value == 1 { return 1 }

        var x = value / 2
        var prev: Decimal = 0
        let tolerance: Decimal = 1e-28

        while Decimal.abs(x - prev) > tolerance {
            prev = x
            x = (x + value / x) / 2
        }

        return x
    }

    // MARK: - Natural Logarithm

    static func ln(_ value: Decimal) -> Decimal {
        if value <= 0 { return Decimal.nan }
        if value == 1 { return 0 }

        let y = (value - 1) / (value + 1)
        var yPow = y
        var result: Decimal = 0
        let tolerance: Decimal = 1e-28
        var term: Decimal = 0

        for n in 1..<200 {
            term = yPow / Decimal(n)
            result += term
            yPow *= y * y

            if Decimal.abs(term) < tolerance {
                break
            }
        }

        return 2 * result
    }

    // MARK: - Log Base 10

    static func log10(_ value: Decimal) -> Decimal {
        return Decimal.ln(value) / Decimal.ln(10)
    }

    // MARK: - Exponential e^x

    static func exp(_ value: Decimal) -> Decimal {
        if value == 0 { return 1 }

        var result: Decimal = 1
        var term: Decimal = 1
        let tolerance: Decimal = 1e-28

        for n in 1..<200 {
            term *= value / Decimal(n)
            result += term

            if Decimal.abs(term) < tolerance {
                break
            }
        }

        return result
    }

    // MARK: - Trigonometric (radians)

    static func sin(_ x: Decimal) -> Decimal {
        let pi = Decimal.pi
        var normalized = x
        let twoPi = 2 * pi
        let divided = normalized / twoPi
        let roundDown = NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let floored = NSDecimalNumber(decimal: divided).rounding(accordingToBehavior: roundDown).decimalValue
        normalized = normalized - twoPi * floored

        if normalized > pi {
            normalized -= twoPi
        } else if normalized < -pi {
            normalized += twoPi
        }

        var result: Decimal = normalized
        var term: Decimal = normalized
        var xPow = normalized * normalized
        let tolerance: Decimal = 1e-28

        for n in 1..<200 {
            term *= -xPow / (Decimal(2 * n) * Decimal(2 * n + 1))
            result += term

            if Decimal.abs(term) < tolerance {
                break
            }
        }

        return result
    }

    static func cos(_ x: Decimal) -> Decimal {
        return Decimal.sin(Decimal.pi / 2 - x)
    }

    static func tan(_ x: Decimal) -> Decimal {
        let s = Decimal.sin(x)
        let c = Decimal.cos(x)
        if c == 0 { return Decimal.nan }
        return s / c
    }

    // MARK: - Inverse Trigonometric

    static func asin(_ x: Decimal) -> Decimal {
        if x < -1 || x > 1 { return Decimal.nan }
        if x == 1 { return Decimal.pi / 2 }
        if x == -1 { return -Decimal.pi / 2 }
        if x == 0 { return 0 }

        var result: Decimal = x
        var term: Decimal = x
        var xPow = x * x
        let tolerance: Decimal = 1e-28

        for n in 1..<200 {
            term *= xPow * Decimal(2 * n - 1) * Decimal(2 * n - 1) /
                    (Decimal(2 * n) * Decimal(2 * n + 1))
            result += term

            if Decimal.abs(term) < tolerance {
                break
            }
        }

        return result
    }

    static func acos(_ x: Decimal) -> Decimal {
        return Decimal.pi / 2 - Decimal.asin(x)
    }

    static func atan(_ x: Decimal) -> Decimal {
        if x == 0 { return 0 }
        if x == 1 { return Decimal.pi / 4 }
        if x == -1 { return -Decimal.pi / 4 }

        if Decimal.abs(x) > 1 {
            return Decimal(x < 0 ? -1 : 1) * Decimal.pi / 2 - Decimal.atan(1 / x)
        }

        var result: Decimal = x
        var term: Decimal = x
        var xPow = x * x
        let tolerance: Decimal = 1e-28

        for n in 1..<200 {
            term *= -xPow
            let denominator = Decimal(2 * n + 1)
            if denominator == 0 { continue }
            term /= denominator
            result += term

            if Decimal.abs(term) < tolerance {
                break
            }
        }

        return result
    }

    static func atan2(y: Decimal, x: Decimal) -> Decimal {
        if x == 0 {
            if y > 0 { return Decimal.pi / 2 }
            if y < 0 { return -Decimal.pi / 2 }
            return 0
        }

        var angle = Decimal.atan(y / x)

        if x < 0 {
            if y >= 0 {
                angle += Decimal.pi
            } else {
                angle -= Decimal.pi
            }
        }

        return angle
    }

    // MARK: - Hyperbolic

    static func sinh(_ x: Decimal) -> Decimal {
        return (Decimal.exp(x) - Decimal.exp(-x)) / 2
    }

    static func cosh(_ x: Decimal) -> Decimal {
        return (Decimal.exp(x) + Decimal.exp(-x)) / 2
    }

    static func tanh(_ x: Decimal) -> Decimal {
        let eX = Decimal.exp(x)
        let eNegX = Decimal.exp(-x)
        return (eX - eNegX) / (eX + eNegX)
    }

    // MARK: - Inverse Hyperbolic

    static func asinh(_ x: Decimal) -> Decimal {
        return Decimal.ln(x + Decimal.sqrt(x * x + 1))
    }

    static func acosh(_ x: Decimal) -> Decimal {
        if x < 1 { return Decimal.nan }
        return Decimal.ln(x + Decimal.sqrt(x * x - 1))
    }

    static func atanh(_ x: Decimal) -> Decimal {
        if x <= -1 || x >= 1 { return Decimal.nan }
        return Decimal.ln((1 + x) / (1 - x)) / 2
    }

    // MARK: - Factorial

    static func factorial(_ n: Int) -> Decimal {
        if n < 0 { return Decimal.nan }
        if n == 0 || n == 1 { return 1 }

        var result: Decimal = 1
        for i in 2...n {
            result *= Decimal(i)
        }
        return result
    }

    // MARK: - Permutations & Combinations

    static func nPr(_ n: Int, _ r: Int) -> Decimal {
        if r > n || r < 0 { return 0 }
        if r == 0 { return 1 }

        var result: Decimal = 1
        for i in 0..<r {
            result *= Decimal(n - i)
        }
        return result
    }

    static func nCr(_ n: Int, _ r: Int) -> Decimal {
        if r > n || r < 0 { return 0 }
        if r == 0 || r == n { return 1 }

        let r = min(r, n - r)

        var numerator: Decimal = 1
        var denominator: Decimal = 1

        for i in 0..<r {
            numerator *= Decimal(n - i)
            denominator *= Decimal(i + 1)
        }

        return numerator / denominator
    }

    // MARK: - Helpers

    func rounded(_ places: Int) -> Decimal {
        var result = self
        var behavior = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(places), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        result = NSDecimalNumber(decimal: result).rounding(accordingToBehavior: behavior).decimalValue
        return result
    }

    var isNaN: Bool {
        return (self as NSNumber).doubleValue.isNaN
    }

    static func abs(_ value: Decimal) -> Decimal {
        return value < 0 ? -value : value
    }

    static func sign(_ value: Decimal) -> Int {
        if value == 0 { return 0 }
        return value < 0 ? -1 : 1
    }
}

// MARK: - Math Constants

extension Decimal {
    static let pi: Decimal = 3.141592653589793238462643383279502884197
    static let e: Decimal = 2.718281828459045235360287471352662497757
    static let goldenRatio: Decimal = 1.618033988749894848204586834365638117720
}

// MARK: - Angle Mode

public enum AngleMode {
    case deg
    case rad

    public func toRadians(_ value: Decimal) -> Decimal {
        switch self {
        case .deg:
            return value * Decimal.pi / 180
        case .rad:
            return value
        }
    }

    public func fromRadians(_ value: Decimal) -> Decimal {
        switch self {
        case .deg:
            return value * 180 / Decimal.pi
        case .rad:
            return value
        }
    }
}
