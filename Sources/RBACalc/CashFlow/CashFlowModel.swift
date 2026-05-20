//
//  CashFlowModel.swift
//  RBA-Finance-Calc

import Foundation

public struct CashFlowItem {
    public var amount: Decimal
    public var frequency: Int

    public init(amount: Decimal, frequency: Int) {
        self.amount = amount
        self.frequency = frequency
    }
}

public struct CashFlowInput {
    public var cf0: Decimal = 0
    public var cashFlows: [CashFlowItem] = []
    public var discountRate: Decimal = 0

    public var totalPeriods: Int {
        return cashFlows.reduce(0) { $0 + $1.frequency }
    }

    public var hasValidCashFlows: Bool {
        return !cashFlows.isEmpty
    }

    public init() {}

    public mutating func addCashFlow() {
        cashFlows.append(CashFlowItem(amount: 0, frequency: 1))
    }

    public mutating func removeCashFlow(at index: Int) {
        if index >= 0 && index < cashFlows.count {
            cashFlows.remove(at: index)
        }
    }

    public mutating func updateCashFlow(at index: Int, amount: Decimal? = nil, frequency: Int? = nil) {
        if index >= 0 && index < cashFlows.count {
            if let amount = amount {
                cashFlows[index].amount = amount
            }
            if let frequency = frequency {
                cashFlows[index].frequency = frequency
            }
        }
    }
}

public struct CashFlowResult {
    public var npv: Decimal?
    public var irr: Decimal?
    public var nfv: Decimal?
    public var pb: Decimal?
    public var dpb: Decimal?
    public var mod: Decimal?
    public var errorMessage: String?

    public init() {}
}
