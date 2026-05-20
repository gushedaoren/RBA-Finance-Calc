//
//  DepreciationCalculator.swift
//  RBA-Finance-Calc
//
//  Depreciation calculations: SL, SYD, DB, DBX.

import Foundation

public class DepreciationCalculator {

    public init() {}

    public func calculate(_ input: DepreciationInput) -> DepreciationResult {
        guard validate(input) else {
            return DepreciationResult(errorMessage: "Incorrect input")
        }

        switch input.method {
        case .SL:  return calculateSL(input)
        case .SYD: return calculateSYD(input)
        case .DB:  return calculateDB(input)
        case .DBX: return calculateDBX(input)
        }
    }

    private func validate(_ input: DepreciationInput) -> Bool {
        guard input.cost >= 0, input.salvage >= 0 else { return false }
        guard input.salvage <= input.cost else { return false }
        guard input.lif >= 1 else { return false }
        guard input.year >= 1, input.year <= input.lif else { return false }
        guard input.startModule >= 1, input.startModule <= 12 else { return false }
        if input.method == .DBX {
            guard input.factor > 0, input.factor <= 999 else { return false }
        }
        return true
    }

    private func toDecimal(_ v: Double) -> Decimal {
        return Decimal(string: String(format: "%.15g", v)) ?? 0
    }

    private func calculateSL(_ input: DepreciationInput) -> DepreciationResult {
        let depreciable = input.baseDepreciable
        let fullAnnual = depreciable / Decimal(input.lif)
        var depYear = fullAnnual

        if input.startModule != 1 {
            if input.year == 1 {
                depYear = fullAnnual * Decimal(12 - input.startModule + 1) / 12
            } else if input.year == input.lif {
                depYear = fullAnnual * Decimal(input.startModule - 1) / 12
            }
        }

        var cumulative: Decimal = 0
        for y in 1...input.year {
            if input.startModule == 1 {
                cumulative += fullAnnual
            } else if y == 1 {
                cumulative += fullAnnual * Decimal(12 - input.startModule + 1) / 12
            } else if y == input.lif {
                cumulative += fullAnnual * Decimal(input.startModule - 1) / 12
            } else {
                cumulative += fullAnnual
            }
        }

        let bv = max(input.cost - cumulative, input.salvage)
        let rdv = max(input.cost - cumulative - input.salvage, 0)
        let actualDep = min(depYear, rdv)

        return DepreciationResult(depreciation: actualDep, bookValue: bv - actualDep, remainingValue: rdv - actualDep)
    }

    private func calculateSYD(_ input: DepreciationInput) -> DepreciationResult {
        let depreciable = input.baseDepreciable
        let sydTotal = Decimal(input.lif) * Decimal(input.lif + 1) / 2
        var depYear = depreciable * Decimal(input.lif - input.year + 1) / sydTotal

        if input.startModule != 1 {
            if input.year == 1 { depYear *= Decimal(12 - input.startModule + 1) / 12 }
            else if input.year == input.lif { depYear *= Decimal(input.startModule - 1) / 12 }
        }

        var cumulative: Decimal = 0
        for y in 1...input.year {
            let yDep = depreciable * Decimal(input.lif - y + 1) / sydTotal
            if input.startModule == 1 {
                cumulative += yDep
            } else if y == 1 {
                cumulative += yDep * Decimal(12 - input.startModule + 1) / 12
            } else if y == input.lif {
                cumulative += yDep * Decimal(input.startModule - 1) / 12
            } else {
                cumulative += yDep
            }
        }

        let bv = max(input.cost - cumulative, input.salvage)
        let rdv = max(input.cost - cumulative - input.salvage, 0)
        let actualDep = min(depYear, rdv)

        return DepreciationResult(depreciation: actualDep, bookValue: bv - actualDep, remainingValue: rdv - actualDep)
    }

    private func calculateDB(_ input: DepreciationInput) -> DepreciationResult {
        let rate = 2.0 / Double(input.lif)

        var cumulative: Decimal = 0
        for y in 1...input.year {
            let bvStart = input.cost - cumulative
            var dep = toDecimal(NSDecimalNumber(decimal: bvStart).doubleValue * rate)
            if y == 1 && input.startModule != 1 {
                dep *= Decimal(12 - input.startModule + 1) / 12
            }
            let maxDep = min(dep, bvStart - input.salvage)
            cumulative += maxDep
            if cumulative >= input.cost - input.salvage { break }
        }

        var prevCumulative: Decimal = 0
        if input.year > 1 {
            for y in 1..<input.year {
                let bvStart = input.cost - prevCumulative
                var dep = toDecimal(NSDecimalNumber(decimal: bvStart).doubleValue * rate)
                if y == 1 && input.startModule != 1 {
                    dep *= Decimal(12 - input.startModule + 1) / 12
                }
                let maxDep = min(dep, bvStart - input.salvage)
                prevCumulative += maxDep
                if prevCumulative >= input.cost - input.salvage { break }
            }
        }

        let yearDep = min(cumulative - prevCumulative, max(0, input.cost - cumulative))
        let bv = max(input.cost - cumulative, input.salvage)
        let rdv = max(bv - input.salvage, 0)

        return DepreciationResult(depreciation: yearDep, bookValue: bv - yearDep, remainingValue: rdv - yearDep)
    }

    private func calculateDBX(_ input: DepreciationInput) -> DepreciationResult {
        let rate = NSDecimalNumber(decimal: input.factor).doubleValue / 100.0 / Double(input.lif)

        var cumulative: Decimal = 0
        for y in 1...input.year {
            let bvStart = input.cost - cumulative
            var dep = toDecimal(NSDecimalNumber(decimal: bvStart).doubleValue * rate)
            if y == 1 && input.startModule != 1 {
                dep *= Decimal(12 - input.startModule + 1) / 12
            }
            let maxDep = min(dep, bvStart - input.salvage)
            cumulative += maxDep
            if cumulative >= input.cost - input.salvage { break }
        }

        var prevCumulative: Decimal = 0
        if input.year > 1 {
            for y in 1..<input.year {
                let bvStart = input.cost - prevCumulative
                var dep = toDecimal(NSDecimalNumber(decimal: bvStart).doubleValue * rate)
                if y == 1 && input.startModule != 1 {
                    dep *= Decimal(12 - input.startModule + 1) / 12
                }
                let maxDep = min(dep, bvStart - input.salvage)
                prevCumulative += maxDep
                if prevCumulative >= input.cost - input.salvage { break }
            }
        }

        let yearDep = min(cumulative - prevCumulative, max(0, input.cost - cumulative))
        let bv = max(input.cost - cumulative, input.salvage)
        let rdv = max(bv - input.salvage, 0)

        return DepreciationResult(depreciation: yearDep, bookValue: bv - yearDep, remainingValue: rdv - yearDep)
    }
}
