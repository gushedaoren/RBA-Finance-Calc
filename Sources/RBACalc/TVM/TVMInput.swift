//
//  TVMInput.swift
//  RBA-Finance-Calc

import Foundation

public struct TVMInput {
    public var n: Decimal?
    public var iy: Decimal?
    public var pv: Decimal?
    public var pmt: Decimal?
    public var fv: Decimal?
    public var py: Decimal = 12
    public var cy: Decimal = 12
    public var isBGN: Bool = false

    public init() {}

    public enum Field: Int, CaseIterable {
        case N, IY, PV, PMT, FV, PY, CY, BGN

        public var displayName: String {
            switch self {
            case .N: return "N"
            case .IY: return "I/Y"
            case .PV: return "PV"
            case .PMT: return "PMT"
            case .FV: return "FV"
            case .PY: return "P/Y"
            case .CY: return "C/Y"
            case .BGN: return "BGN"
            }
        }
    }

    public func knownFieldsCount() -> Int {
        var count = 0
        if n != nil { count += 1 }
        if iy != nil { count += 1 }
        if pv != nil { count += 1 }
        if pmt != nil { count += 1 }
        if fv != nil { count += 1 }
        return count
    }

    public func unknownField() -> Field? {
        if n == nil { return .N }
        if iy == nil { return .IY }
        if pv == nil { return .PV }
        if pmt == nil { return .PMT }
        if fv == nil { return .FV }
        return nil
    }
}
