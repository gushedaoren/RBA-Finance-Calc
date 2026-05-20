//
//  CalculatorEngine.swift
//  RBA-Finance-Calc
//
//  Core calculation engine supporting CHN and AOS modes.

import Foundation

// MARK: - Operator Type

enum OperatorType: Equatable {
    case plus
    case minus
    case multiply
    case divide
    case none

    var symbol: String {
        switch self {
        case .plus: return "+"
        case .minus: return "-"
        case .multiply: return "×"
        case .divide: return "÷"
        case .none: return ""
        }
    }

    var precedence: Int {
        switch self {
        case .plus, .minus: return 1
        case .multiply, .divide: return 2
        case .none: return 0
        }
    }
}

// MARK: - Calculator State

enum CalculatorState {
    case ready
    case inputting
    case result
    case error
    case afterOperator
}

// MARK: - Calculator Engine

public class CalculatorEngine {

    // MARK: - Properties

    public var displayValue: Decimal = 0
    public var isInputting = false
    public var state: CalculatorState = .ready
    var previousValue: Decimal?
    var currentOperator: OperatorType = .none
    private var pendingOperator: OperatorType = .none
    private var hasDecimal: Bool = false
    private var decimalDigits: Int = 0

    public var calculationMode: CalculationMode = .CHN
    public var errorMessage: String?

    // MARK: - Init

    public init() {}

    // MARK: - Digit Input

    public func inputDigit(_ digit: Int) {
        resetError()

        switch state {
        case .ready, .result, .afterOperator:
            hasDecimal = false
            decimalDigits = 0
            displayValue = Decimal(digit)
            isInputting = true
            state = .inputting

        case .inputting:
            if hasDecimal {
                decimalDigits += 1
                let decimalValue = Decimal(digit) / Decimal.power(10, Decimal(decimalDigits))
                displayValue = displayValue + decimalValue
            } else if displayValue == 0 {
                displayValue = Decimal(digit)
            } else {
                displayValue = displayValue * 10 + Decimal(digit)
            }

            let str = String(describing: displayValue)
            if str.count > DisplayConstants.maxInputLength {
                displayValue = Decimal(string: String(str.prefix(DisplayConstants.maxInputLength))) ?? displayValue
            }

        case .error:
            reset()
            inputDigit(digit)

        default:
            break
        }
    }

    public func inputDecimal() {
        resetError()

        switch state {
        case .ready, .result, .afterOperator:
            displayValue = 0
            isInputting = true
            state = .inputting
            hasDecimal = true
            decimalDigits = 0

        case .inputting:
            if !hasDecimal {
                hasDecimal = true
                decimalDigits = 0
            }

        case .error:
            reset()
            inputDecimal()

        default:
            break
        }
    }

    public func toggleSign() {
        resetError()
        if displayValue == 0 { return }
        displayValue = -displayValue
    }

    // MARK: - Operators

    public func inputOperator(_ op: OperatorType) {
        resetError()

        switch calculationMode {
        case .CHN:
            inputOperatorCHN(op)
        case .AOS:
            inputOperatorAOS(op)
        }

        state = .afterOperator
    }

    private func inputOperatorCHN(_ op: OperatorType) {
        if currentOperator != .none && isInputting {
            executeOperation(currentOperator)
        } else if previousValue == nil {
            previousValue = displayValue
        }
        currentOperator = op
        isInputting = false
        state = .result
    }

    private func inputOperatorAOS(_ op: OperatorType) {
        if pendingOperator != .none && isInputting {
            if op.precedence <= pendingOperator.precedence {
                executeOperation(pendingOperator)
                pendingOperator = op
            } else {
                currentOperator = op
            }
        } else if currentOperator != .none && isInputting {
            if op.precedence > currentOperator.precedence {
                pendingOperator = op
            } else {
                executeOperation(currentOperator)
                pendingOperator = .none
                currentOperator = op
            }
        } else if !isInputting {
            currentOperator = op
        }
        isInputting = false
    }

    // MARK: - Execute

    private func executeOperation(_ op: OperatorType) {
        guard let prev = previousValue else {
            previousValue = displayValue
            return
        }

        let result: Decimal
        switch op {
        case .plus:
            result = prev + displayValue
        case .minus:
            result = prev - displayValue
        case .multiply:
            result = prev * displayValue
        case .divide:
            if displayValue == 0 {
                setError(.divisionByZero)
                return
            }
            result = prev / displayValue
        case .none:
            return
        }

        displayValue = result
        previousValue = result
        state = .result
    }

    public func execute() {
        resetError()

        switch calculationMode {
        case .CHN:
            if currentOperator != .none {
                executeOperation(currentOperator)
                currentOperator = .none
            }
        case .AOS:
            if pendingOperator != .none && currentOperator != .none {
                executeOperation(currentOperator)
                executeOperation(pendingOperator)
                pendingOperator = .none
                currentOperator = .none
            } else if pendingOperator != .none {
                executeOperation(pendingOperator)
                pendingOperator = .none
                currentOperator = .none
            } else if currentOperator != .none {
                executeOperation(currentOperator)
                currentOperator = .none
            }
        }

        isInputting = false
        state = .result
    }

    // MARK: - Clear

    public func clearEntry() {
        displayValue = 0
        isInputting = false
        state = .ready
        hasDecimal = false
        decimalDigits = 0
        previousValue = nil
        currentOperator = .none
        pendingOperator = .none
        errorMessage = nil
    }

    public func clearAll() {
        displayValue = 0
        previousValue = nil
        currentOperator = .none
        state = .ready
        isInputting = false
        hasDecimal = false
        decimalDigits = 0
        errorMessage = nil
    }

    public func reset() {
        displayValue = 0
        previousValue = nil
        currentOperator = .none
        state = .ready
        isInputting = false
        hasDecimal = false
        decimalDigits = 0
    }

    public func backspace() {
        guard isInputting && state == .inputting else { return }

        let str = String(describing: displayValue)
        if str.count <= 1 {
            displayValue = 0
            isInputting = false
        } else {
            let newStr = String(str.dropLast())
            displayValue = Decimal(string: newStr) ?? 0
        }
    }

    // MARK: - Error

    private func resetError() {
        errorMessage = nil
        if state == .error {
            state = .ready
        }
    }

    private func setError(_ error: RBACalculationError) {
        errorMessage = error.description
        state = .error
    }
}
