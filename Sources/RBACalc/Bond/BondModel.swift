//
//  BondModel.swift
//  RBA-Finance-Calc

import Foundation

public enum BondDayBasis: Int, CaseIterable {
    case ACT
    case _360

    public var displayName: String {
        switch self {
        case .ACT: return "ACT"
        case ._360: return "360"
        }
    }
}

public enum CompoundFrequency: Int, CaseIterable {
    case semiannual = 2
    case annual = 1

    public var displayName: String {
        switch self {
        case .semiannual: return "2/Y"
        case .annual: return "1/Y"
        }
    }
}

public struct BondInput {
    public var settlementDay: Int = 1
    public var settlementMonth: Int = 1
    public var settlementYear: Int = 2020
    public var couponRate: Decimal = 0
    public var redemptionDay: Int = 1
    public var redemptionMonth: Int = 1
    public var redemptionYear: Int = 2025
    public var redemptionValue: Decimal = 100
    public var yield: Decimal?
    public var price: Decimal?
    public var dayBasis: BondDayBasis = .ACT
    public var frequency: CompoundFrequency = .semiannual

    public init() {}
}

public struct BondResult {
    public var price: Decimal?
    public var accruedInterest: Decimal?
    public var duration: Decimal?
    public var yield: Decimal?
    public var errorMessage: String?

    public init() {}
}
