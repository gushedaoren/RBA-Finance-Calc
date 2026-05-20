//
//  DepreciationModel.swift
//  RBA-Finance-Calc

import Foundation

public enum DepreciationMethod: Int, CaseIterable {
    case SL
    case SYD
    case DB
    case DBX

    public var displayName: String {
        switch self {
        case .SL: return "SL"
        case .SYD: return "SYD"
        case .DB: return "DB"
        case .DBX: return "DBX"
        }
    }
}

public struct DepreciationInput {
    public var method: DepreciationMethod = .SL
    public var cost: Decimal = 0
    public var salvage: Decimal = 0
    public var lif: Int = 1
    public var startModule: Int = 1
    public var year: Int = 1
    public var factor: Decimal = 200

    public init() {}

    public var baseDepreciable: Decimal {
        if cost <= salvage { return 0 }
        return cost - salvage
    }
}

public struct DepreciationResult {
    public var depreciation: Decimal = 0
    public var bookValue: Decimal = 0
    public var remainingValue: Decimal = 0
    public var errorMessage: String?

    public init() {}
}
