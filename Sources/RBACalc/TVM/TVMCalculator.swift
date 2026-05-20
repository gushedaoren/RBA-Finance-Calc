//
//  TVMCalculator.swift
//  RBA-Finance-Calc
//
//  Time Value of Money calculator matching TI BA II Plus.

import Foundation

public struct AmortizationResult {
    public var p1: Decimal
    public var p2: Decimal
    public var bal: Decimal
    public var prn: Decimal
    public var `int`: Decimal
}

public class TVMCalculator {

    public init() {}

    public func calculatePeriodRate(iy: Decimal, cy: Decimal, py: Decimal) -> Decimal {
        let nominalRate = iy / 100
        let compoundingRate = nominalRate / cy
        let exponent = cy / py
        return Decimal.power(1 + compoundingRate, exponent) - 1
    }

    public func calculatePMT(_ input: TVMInput) throws -> Decimal {
        guard let n = input.n,
              let iy = input.iy,
              let pv = input.pv,
              let fv = input.fv else {
            throw RBACalculationError.insufficientInputs
        }

        let i = calculatePeriodRate(iy: iy, cy: input.cy, py: input.py)

        if i == 0 {
            return -(pv + fv) / n
        }

        let v = Decimal.power(1 + i, n)
        let numerator = -(pv * v + fv) * i
        let denominator: Decimal

        if input.isBGN {
            denominator = (v - 1) * (1 + i) / i
        } else {
            denominator = v - 1
        }

        guard denominator != 0 else {
            throw RBACalculationError.noSolution
        }

        return numerator / denominator
    }

    public func calculatePV(_ input: TVMInput) throws -> Decimal {
        guard let n = input.n,
              let iy = input.iy,
              let pmt = input.pmt,
              let fv = input.fv else {
            throw RBACalculationError.insufficientInputs
        }

        let i = calculatePeriodRate(iy: iy, cy: input.cy, py: input.py)

        if i == 0 {
            return -fv - n * pmt
        }

        let v = Decimal.power(1 + i, -n)
        let pvInterest = -fv * v

        if pmt == 0 {
            return pvInterest
        }

        let factor = (1 - v) / i
        let pvAnnuity: Decimal
        if input.isBGN {
            pvAnnuity = -pmt * (1 + i) * factor
        } else {
            pvAnnuity = -pmt * factor
        }

        return pvInterest + pvAnnuity
    }

    public func calculateFV(_ input: TVMInput) throws -> Decimal {
        guard let n = input.n,
              let iy = input.iy,
              let pv = input.pv,
              let pmt = input.pmt else {
            throw RBACalculationError.insufficientInputs
        }

        let i = calculatePeriodRate(iy: iy, cy: input.cy, py: input.py)

        if i == 0 {
            return -pv - n * pmt
        }

        let v = Decimal.power(1 + i, n)
        let fvInterest = -pv * v

        if pmt == 0 {
            return fvInterest
        }

        let factor = (v - 1) / i
        let fvAnnuity: Decimal
        if input.isBGN {
            fvAnnuity = -pmt * (1 + i) * factor
        } else {
            fvAnnuity = -pmt * factor
        }

        return fvInterest + fvAnnuity
    }

    public func calculateN(_ input: TVMInput) throws -> Decimal {
        guard let iy = input.iy,
              let pv = input.pv,
              let fv = input.fv else {
            throw RBACalculationError.insufficientInputs
        }

        let i = calculatePeriodRate(iy: iy, cy: input.cy, py: input.py)

        if i == 0 {
            guard let pmt = input.pmt, pmt != 0 else {
                throw RBACalculationError.noSolution
            }
            return -(pv + fv) / pmt
        }

        if let pmt = input.pmt, pmt == 0 {
            let ratio = -fv / pv
            guard ratio > 0 else {
                throw RBACalculationError.invalidInput
            }
            return Decimal.ln(ratio) / Decimal.ln(1 + i)
        }

        guard let pmt = input.pmt else {
            throw RBACalculationError.insufficientInputs
        }

        let factor = input.isBGN ? (1 + i) : 1
        let a = pmt * factor / i
        let b = a - fv
        let c = a + pv

        guard b > 0 && c > 0 else {
            throw RBACalculationError.noSolution
        }

        let ratio = b / c
        guard ratio > 0 else {
            throw RBACalculationError.noSolution
        }

        return Decimal.ln(ratio) / Decimal.ln(1 + i)
    }

    public func calculateIY(_ input: TVMInput) throws -> Decimal {
        guard let n = input.n,
              let pv = input.pv,
              let fv = input.fv,
              let pmt = input.pmt else {
            throw RBACalculationError.insufficientInputs
        }

        if pmt == 0 {
            let ratio = -fv / pv
            guard ratio > 0 else {
                throw RBACalculationError.invalidInput
            }
            let i = Decimal.power(ratio, 1 / n) - 1
            let iy = i * 100 * (input.cy / input.py)
            return iy
        }

        var iy: Decimal = initialGuessIY(n: n, pv: pv, pmt: pmt, fv: fv)
        let tolerance: Decimal = 1e-13
        let maxIterations = PrecisionConstants.maxIterations
        let delta: Decimal = 0.001

        for _ in 0..<maxIterations {
            let i = Decimal.power(1 + iy / 100 / input.cy, input.cy / input.py) - 1
            let v = Decimal.power(1 + i, n)
            let factor = input.isBGN ? (1 + i) : 1
            let f = pv * v + pmt * factor * (v - 1) / i + fv

            if Decimal.abs(f) < tolerance {
                return iy
            }

            let iPlus = Decimal.power(1 + (iy + delta) / 100 / input.cy, input.cy / input.py) - 1
            let vPlus = Decimal.power(1 + iPlus, n)
            let fPlus = pv * vPlus + pmt * factor * (vPlus - 1) / iPlus + fv
            let df = (fPlus - f) / delta

            guard df != 0 else {
                iy = iy + delta / 2
                continue
            }

            iy = iy - f / df
            iy = max(0, min(10000, iy))
        }

        throw RBACalculationError.convergenceFailed
    }

    public func calculateAmortization(_ input: TVMInput, p1: Int, p2: Int) throws -> AmortizationResult {
        guard let iy = input.iy,
              let pv = input.pv,
              let pmt = input.pmt else {
            throw RBACalculationError.insufficientInputs
        }

        guard p1 >= 1, p2 >= p1 else {
            throw RBACalculationError.invalidInput
        }

        let i = calculatePeriodRate(iy: iy, cy: input.cy, py: input.py)
        var balance = pv
        var prnTotal: Decimal = 0
        var intTotal: Decimal = 0

        for k in 1...p2 {
            let interest = balance * i
            let principalPayment = pmt + interest
            balance = balance - principalPayment

            if k >= p1 {
                prnTotal += principalPayment
                intTotal += interest
            }
        }

        return AmortizationResult(
            p1: Decimal(p1),
            p2: Decimal(p2),
            bal: balance,
            prn: prnTotal,
            int: intTotal
        )
    }

    private func initialGuessIY(n: Decimal, pv: Decimal, pmt: Decimal, fv: Decimal) -> Decimal {
        let totalReturn = (fv - pv - n * pmt) / (n * pv)
        var guess = totalReturn * 100
        if guess <= 0 { guess = 5 }
        guess = max(0.001, min(1000, guess))
        return guess
    }
}
