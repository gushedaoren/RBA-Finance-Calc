//
//  BondCalculator.swift
//  RBA-Finance-Calc
//
//  Bond price, yield, accrued interest, and duration calculations.

import Foundation

public class BondCalculator {

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()

    public init() {}

    public func calculatePrice(_ input: BondInput) -> BondResult {
        var result = BondResult()

        guard let yld = input.yield else {
            result.errorMessage = "Yield not provided"
            return result
        }

        let ai = calculateAccruedInterest(input)
        result.accruedInterest = ai

        let cpn = NSDecimalNumber(decimal: input.couponRate).doubleValue
        let yldDbl = NSDecimalNumber(decimal: yld).doubleValue
        let rv = NSDecimalNumber(decimal: input.redemptionValue).doubleValue
        let freq = Double(input.frequency.rawValue)
        let c = cpn / freq
        let r = yldDbl / 100.0 / freq

        let (dsc, e) = dayCountFractions(input)
        let dscRatio = dsc / e
        let totalPeriods = numberOfPeriods(input)

        var price: Double

        if cpn == 0 {
            price = rv / pow(1 + r, Double(totalPeriods) - 1 + dscRatio)
        } else if dscRatio == 0 || abs(dscRatio) < 0.001 {
            price = c * (1 - 1 / pow(1 + r, Double(totalPeriods))) / r
            price += rv / pow(1 + r, Double(totalPeriods))
        } else {
            price = c * (1 - 1 / pow(1 + r, Double(totalPeriods))) / r
            price += rv / pow(1 + r, Double(totalPeriods))
            price /= pow(1 + r, dscRatio)
        }

        result.price = Decimal(string: String(format: "%.4f", price)) ?? Decimal(price)
        return result
    }

    public func calculateYield(_ input: BondInput) -> BondResult {
        var result = BondResult()

        guard let pri = input.price else {
            result.errorMessage = "Price not provided"
            return result
        }

        let cpn = NSDecimalNumber(decimal: input.couponRate).doubleValue
        let targetPrice = NSDecimalNumber(decimal: pri).doubleValue
        let rv = NSDecimalNumber(decimal: input.redemptionValue).doubleValue
        let freq = Double(input.frequency.rawValue)

        var yldGuess = cpn
        if yldGuess <= 0 { yldGuess = 5 }

        let maxIter = 100
        let tolerance = 1e-10

        for _ in 0..<maxIter {
            let r = yldGuess / 100.0 / freq
            let (dsc, e) = dayCountFractions(input)
            let dscRatio = dsc / e
            let totalPeriods = numberOfPeriods(input)

            var calcPrice: Double
            let c = cpn / freq

            if cpn == 0 {
                calcPrice = rv / pow(1 + r, Double(totalPeriods) - 1 + dscRatio)
            } else if dscRatio == 0 || abs(dscRatio) < 0.001 {
                calcPrice = c * (1 - 1 / pow(1 + r, Double(totalPeriods))) / r
                calcPrice += rv / pow(1 + r, Double(totalPeriods))
            } else {
                calcPrice = c * (1 - 1 / pow(1 + r, Double(totalPeriods))) / r
                calcPrice += rv / pow(1 + r, Double(totalPeriods))
                calcPrice /= pow(1 + r, dscRatio)
            }

            let error = calcPrice - targetPrice
            if abs(error) < tolerance {
                result.yield = Decimal(string: String(format: "%.4f", yldGuess)) ?? Decimal(yldGuess)
                return result
            }

            let h = max(1e-8, abs(yldGuess) * 1e-8)
            let rH = (yldGuess + h) / 100.0 / freq

            var calcPriceH: Double
            if cpn == 0 {
                calcPriceH = rv / pow(1 + rH, Double(totalPeriods) - 1 + dscRatio)
            } else if dscRatio == 0 || abs(dscRatio) < 0.001 {
                calcPriceH = c * (1 - 1 / pow(1 + rH, Double(totalPeriods))) / rH
                calcPriceH += rv / pow(1 + rH, Double(totalPeriods))
            } else {
                calcPriceH = c * (1 - 1 / pow(1 + rH, Double(totalPeriods))) / rH
                calcPriceH += rv / pow(1 + rH, Double(totalPeriods))
                calcPriceH /= pow(1 + rH, dscRatio)
            }

            let derivative = (calcPriceH - calcPrice) / (h / 100.0 / freq)
            if abs(derivative) < 1e-15 { break }

            let step = error / derivative
            yldGuess -= step
            if yldGuess < -5 || yldGuess > 100 { break }
        }

        result.errorMessage = "Yield calculation did not converge"
        return result
    }

    public func calculateAccruedInterest(_ input: BondInput) -> Decimal? {
        let cpn = NSDecimalNumber(decimal: input.couponRate).doubleValue
        if cpn == 0 { return 0 }

        let freq = Double(input.frequency.rawValue)
        let c = cpn / freq
        let (dsc, e) = dayCountFractions(input)
        let aiDbl = c * (e - dsc) / e

        return Decimal(string: String(format: "%.4f", aiDbl)) ?? Decimal(aiDbl)
    }

    public func calculateDuration(_ input: BondInput) -> Decimal? {
        guard let yld = input.yield else { return nil }

        let priceResult = calculatePrice(input)
        guard let pri = priceResult.price, NSDecimalNumber(decimal: pri).doubleValue > 0 else {
            return nil
        }

        let priDbl = NSDecimalNumber(decimal: pri).doubleValue
        let delta = 0.0001

        var inputUp = input
        inputUp.yield = yld + (Decimal(string: String(format: "%.10g", delta)) ?? 0)
        let priceUp = calculatePrice(inputUp).price ?? 0
        let priUpDbl = NSDecimalNumber(decimal: priceUp).doubleValue

        var inputDown = input
        inputDown.yield = max(0, yld - (Decimal(string: String(format: "%.10g", delta)) ?? 0))
        let priceDown = calculatePrice(inputDown).price ?? 0
        let priDownDbl = NSDecimalNumber(decimal: priceDown).doubleValue

        let dur = (priDownDbl - priUpDbl) / (2 * priDbl * delta)
        return Decimal(string: String(format: "%.4f", dur)) ?? Decimal(dur)
    }

    // MARK: - Date helpers

    private func dayCountFractions(_ input: BondInput) -> (dsc: Double, e: Double) {
        let sdt = dateFrom(day: input.settlementDay, month: input.settlementMonth, year: input.settlementYear)
        let rdt = dateFrom(day: input.redemptionDay, month: input.redemptionMonth, year: input.redemptionYear)
        let freqMonths = 12 / input.frequency.rawValue
        let prevCoupon = previousCouponDate(from: sdt, redemption: rdt, monthsPerPeriod: freqMonths)
        let nextCoupon = nextCouponDate(from: sdt, redemption: rdt, monthsPerPeriod: freqMonths)

        switch input.dayBasis {
        case .ACT:
            let e = actualDaysBetween(prevCoupon, nextCoupon)
            let dsc = actualDaysBetween(sdt, nextCoupon)
            return (Double(dsc), Double(e))
        case ._360:
            let e = days360Between(prevCoupon, nextCoupon)
            let dsc = days360Between(sdt, nextCoupon)
            return (Double(dsc), Double(e))
        }
    }

    private func numberOfPeriods(_ input: BondInput) -> Int {
        let sdt = dateFrom(day: input.settlementDay, month: input.settlementMonth, year: input.settlementYear)
        let rdt = dateFrom(day: input.redemptionDay, month: input.redemptionMonth, year: input.redemptionYear)
        let freqMonths = 12 / input.frequency.rawValue
        let nextCoupon = nextCouponDate(from: sdt, redemption: rdt, monthsPerPeriod: freqMonths)

        var count = 0
        var current = nextCoupon
        while current <= rdt {
            count += 1
            if let next = calendar.date(byAdding: .month, value: freqMonths, to: current) {
                current = next
            } else { break }
        }
        return max(count, 1)
    }

    private func dateFrom(day: Int, month: Int, year: Int) -> Date {
        var comps = DateComponents()
        comps.day = day
        comps.month = month
        comps.year = year + 2000
        return calendar.date(from: comps) ?? Date()
    }

    private func previousCouponDate(from date: Date, redemption: Date, monthsPerPeriod: Int) -> Date {
        var prev = redemption
        while prev > date {
            guard let earlier = calendar.date(byAdding: .month, value: -monthsPerPeriod, to: prev) else { break }
            prev = earlier
        }
        return prev
    }

    private func nextCouponDate(from date: Date, redemption: Date, monthsPerPeriod: Int) -> Date {
        let prev = previousCouponDate(from: date, redemption: redemption, monthsPerPeriod: monthsPerPeriod)
        return calendar.date(byAdding: .month, value: monthsPerPeriod, to: prev) ?? prev
    }

    private func actualDaysBetween(_ from: Date, _ to: Date) -> Int {
        return calendar.dateComponents([.day], from: from, to: to).day ?? 0
    }

    private func days360Between(_ from: Date, _ to: Date) -> Int {
        let comp1 = calendar.dateComponents([.day, .month, .year], from: from)
        let comp2 = calendar.dateComponents([.day, .month, .year], from: to)
        var d1 = comp1.day ?? 1
        let m1 = comp1.month ?? 1
        let y1 = comp1.year ?? 2000
        var d2 = comp2.day ?? 1
        let m2 = comp2.month ?? 1
        let y2 = comp2.year ?? 2000
        if d1 == 31 { d1 = 30 }
        if d2 == 31 && d1 == 30 { d2 = 30 }
        return 360 * (y2 - y1) + 30 * (m2 - m1) + (d2 - d1)
    }
}
