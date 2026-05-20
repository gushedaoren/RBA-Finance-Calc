//
//  CashFlowCalculator.swift
//  RBA-Finance-Calc
//
//  Cash flow analysis: NPV, IRR, NFV, PB, DPB, MIRR.

import Foundation

enum CashFlowError: Error, LocalizedError {
    case noCashFlows
    case irrNotConverging
    case multipleIRR
    case noIRRFound
    case invalidDiscountRate
    case paybackNeverOccurs

    var errorDescription: String? {
        switch self {
        case .noCashFlows: return "No cash flows entered"
        case .irrNotConverging: return "IRR calculation did not converge"
        case .multipleIRR: return "Multiple IRR solutions found"
        case .noIRRFound: return "No IRR found - check cash flow pattern"
        case .invalidDiscountRate: return "Invalid discount rate"
        case .paybackNeverOccurs: return "Payback never occurs"
        }
    }
}

public class CashFlowCalculator {

    public init() {}

    public func calculateNPV(_ input: CashFlowInput) throws -> Decimal {
        guard input.hasValidCashFlows else {
            throw CashFlowError.noCashFlows
        }

        var npv = input.cf0
        var period = 0
        let i = input.discountRate / 100

        for item in input.cashFlows {
            for _ in 0..<item.frequency {
                period += 1
                let discountFactor = decimalPower(1 + i, Decimal(period))
                npv += item.amount / discountFactor
            }
        }

        return npv
    }

    public func calculateIRR(_ input: CashFlowInput) throws -> Decimal {
        guard input.hasValidCashFlows else {
            throw CashFlowError.noCashFlows
        }

        let initialGuesses: [Double] = [0.1, 0.05, 0.2, -0.1, 0.5, 1.0]

        for guess in initialGuesses {
            if let irr = newtonRaphsonIRR(input, initialGuess: guess) {
                return irr
            }
        }

        if let irr = bisectionIRR(input) {
            return irr
        }

        throw CashFlowError.noIRRFound
    }

    public func calculateNFV(_ input: CashFlowInput) throws -> Decimal {
        let npv = try calculateNPV(input)
        let totalPeriods = input.totalPeriods
        let i = input.discountRate / 100
        return npv * decimalPower(1 + i, Decimal(totalPeriods))
    }

    public func calculatePB(_ input: CashFlowInput) throws -> Decimal {
        guard input.hasValidCashFlows else {
            throw CashFlowError.noCashFlows
        }

        var cumulativeCF = input.cf0
        var period = 0

        if cumulativeCF >= 0 { return 0 }

        for item in input.cashFlows {
            for _ in 0..<item.frequency {
                period += 1
                let prevCumulative = cumulativeCF
                cumulativeCF += item.amount

                if cumulativeCF >= 0 {
                    if item.amount != 0 {
                        let fraction = abs(prevCumulative) / abs(item.amount)
                        return Decimal(period - 1) + fraction
                    } else {
                        continue
                    }
                }
            }
        }

        throw CashFlowError.paybackNeverOccurs
    }

    public func calculateDPB(_ input: CashFlowInput) throws -> Decimal {
        guard input.hasValidCashFlows else {
            throw CashFlowError.noCashFlows
        }

        let i = input.discountRate / 100
        var cumulativeDCF = input.cf0
        var period = 0

        if cumulativeDCF >= 0 { return 0 }

        for item in input.cashFlows {
            for _ in 0..<item.frequency {
                period += 1
                let discountFactor = decimalPower(1 + i, Decimal(period))
                let dcf = item.amount / discountFactor
                let prevCumulative = cumulativeDCF
                cumulativeDCF += dcf

                if cumulativeDCF >= 0 {
                    if dcf != 0 {
                        let fraction = abs(prevCumulative) / abs(dcf)
                        return Decimal(period - 1) + fraction
                    } else {
                        continue
                    }
                }
            }
        }

        throw CashFlowError.paybackNeverOccurs
    }

    public func calculateMIRR(_ input: CashFlowInput) throws -> Decimal {
        guard input.hasValidCashFlows else {
            throw CashFlowError.noCashFlows
        }

        let i = input.discountRate / 100
        let totalPeriods = input.totalPeriods
        var positiveFV: Decimal = 0
        var negativePV: Decimal = 0
        var period = 0

        if input.cf0 > 0 {
            positiveFV += input.cf0 * decimalPower(1 + i, Decimal(totalPeriods))
        } else {
            negativePV += input.cf0
        }

        for item in input.cashFlows {
            for _ in 0..<item.frequency {
                period += 1
                if item.amount > 0 {
                    positiveFV += item.amount * decimalPower(1 + i, Decimal(totalPeriods - period))
                } else {
                    negativePV += item.amount / decimalPower(1 + i, Decimal(period))
                }
            }
        }

        if negativePV == 0 || positiveFV == 0 {
            throw CashFlowError.noIRRFound
        }

        let ratio = positiveFV / abs(negativePV)
        let exponent = 1.0 / Double(totalPeriods)
        let ratioDouble = NSDecimalNumber(decimal: ratio).doubleValue
        let mirr = pow(ratioDouble, exponent) - 1.0

        return Decimal(mirr) * 100
    }

    public func calculateAll(_ input: CashFlowInput) -> CashFlowResult {
        var result = CashFlowResult()

        do { result.npv = try calculateNPV(input) } catch {
            result.errorMessage = "NPV: \(error.localizedDescription)"
        }
        do { result.irr = try calculateIRR(input) } catch {
            if result.errorMessage == nil {
                result.errorMessage = "IRR: \(error.localizedDescription)"
            }
        }
        do { result.nfv = try calculateNFV(input) } catch {}
        do { result.pb = try calculatePB(input) } catch {}
        do { result.dpb = try calculateDPB(input) } catch {}
        do { result.mod = try calculateMIRR(input) } catch {}

        return result
    }

    // MARK: - Private IRR helpers

    private func newtonRaphsonIRR(_ input: CashFlowInput, initialGuess: Double) -> Decimal? {
        var rate = initialGuess
        let maxIterations = 100
        let tolerance: Double = 1e-10

        for _ in 0..<maxIterations {
            let npv = calculateNPVAtRate(input, rate: rate)
            if abs(npv) < tolerance {
                return Decimal(rate * 100)
            }
            let derivative = calculateNPVDerivative(input, rate: rate)
            if abs(derivative) < 1e-15 { return nil }
            rate = rate - npv / derivative
            if rate < -0.99 || rate > 10.0 { return nil }
        }

        if abs(calculateNPVAtRate(input, rate: rate)) < tolerance {
            return Decimal(rate * 100)
        }
        return nil
    }

    private func bisectionIRR(_ input: CashFlowInput) -> Decimal? {
        var low = -0.99
        var high = 10.0
        let maxIterations = 200
        let tolerance: Double = 1e-10

        let fLow = calculateNPVAtRate(input, rate: low)
        let fHigh = calculateNPVAtRate(input, rate: high)
        if fLow * fHigh > 0 { return nil }

        for _ in 0..<maxIterations {
            let mid = (low + high) / 2.0
            let fMid = calculateNPVAtRate(input, rate: mid)
            if abs(fMid) < tolerance { return Decimal(mid * 100) }
            if fLow * fMid < 0 {
                high = mid
            } else {
                low = mid
            }
            if abs(high - low) < tolerance {
                return Decimal(((low + high) / 2.0) * 100)
            }
        }
        return nil
    }

    private func calculateNPVAtRate(_ input: CashFlowInput, rate: Double) -> Double {
        var npv = NSDecimalNumber(decimal: input.cf0).doubleValue
        var period = 0
        for item in input.cashFlows {
            let amount = NSDecimalNumber(decimal: item.amount).doubleValue
            for _ in 0..<item.frequency {
                period += 1
                let discountFactor = pow(1 + rate, Double(period))
                npv += amount / discountFactor
            }
        }
        return npv
    }

    private func calculateNPVDerivative(_ input: CashFlowInput, rate: Double) -> Double {
        var derivative: Double = 0
        var period = 0
        for item in input.cashFlows {
            let amount = NSDecimalNumber(decimal: item.amount).doubleValue
            for _ in 0..<item.frequency {
                period += 1
                let discountFactor = pow(1 + rate, Double(period) + 1)
                derivative -= Double(period) * amount / discountFactor
            }
        }
        return derivative
    }

    private func decimalPower(_ base: Decimal, _ exponent: Decimal) -> Decimal {
        let baseDouble = NSDecimalNumber(decimal: base).doubleValue
        let exponentDouble = NSDecimalNumber(decimal: exponent).doubleValue
        return Decimal(pow(baseDouble, exponentDouble))
    }
}
