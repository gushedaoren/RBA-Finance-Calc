# RBA Financial Calculator Core

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-blue.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()

> Open-source financial calculation engine matching **TI BA II Plus** with 100% accuracy.
> Powered by Swift `Decimal` (28-digit precision) — no floating point errors.

---

## 📱 Get the Full App

<a href="https://apps.apple.com/app/id1545331477">
  <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" height="60">
</a>

This library is the **calculation engine only**. For the complete iOS app with TI-style UI,
haptic feedback, exam-optimized workflow, and all 12 worksheets:

**→ [RBA 金融计算器 on App Store](https://apps.apple.com/app/1545331477)**

---

## Features

| Module | Functions | Description |
|--------|-----------|-------------|
| **TVM** | N, I/Y, PV, PMT, FV, Amortization | Time Value of Money |
| **Cash Flow** | NPV, IRR, NFV, PB, DPB, MIRR | Investment analysis |
| **Bond** | Price, Yield, Accrued Interest, Duration | Bond valuation |
| **Depreciation** | SL, SYD, DB, DBX | Asset depreciation |
| **Statistics** | 1-Var, 2-Var, Regression (LIN/Ln/EXP/PWR) | Statistical analysis |
| **Basic Calc** | CHN/AOS modes, +−×÷ | Chain & algebraic |
| **Scientific** | sin/cos/tan, ln/log, x², √, nPr/nCr, etc. | Scientific functions |

## Why This Exists

Existing TI BA II Plus alternatives on App Store have critical bugs:

| Problem | Impact |
|---------|--------|
| 2.8/5 average rating | Users can't trust results |
| Decimal input fails | Can't enter `0.5` or `4.5` |
| Negative cash blocked | Cash flow analysis broken |
| TVM results wrong | Exam answers incorrect |
| 4+ years without updates | Abandoned software |

This library guarantees accuracy with **Swift Decimal** (28 significant digits) and
**200+ test cases** extracted from the official TI BA II Plus manual.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/gushedaoren/RBA-Finance-Calc.git", from: "1.0.0")
]
```

Or add via Xcode: **File → Add Package Dependencies →** paste the URL above.

## Usage

### TVM (Time Value of Money)

```swift
import RBACalc

let tvm = TVMCalculator()
var input = TVMInput()
input.n = 360        // 30 years × 12
input.iy = 6.5       // 6.5% annual rate
input.pv = 500000    // loan amount
input.fv = 0         // paid off
input.py = 12        // 12 payments/year
input.cy = 12        // 12 compounding/year

let pmt = try tvm.calculatePMT(input)
// PMT = -3,160.34 (monthly payment)
```

### Cash Flow (NPV & IRR)

```swift
import RBACalc

let cf = CashFlowCalculator()
var input = CashFlowInput()
input.cf0 = -1000
input.cashFlows = [
    CashFlowItem(amount: 300, frequency: 1),
    CashFlowItem(amount: 400, frequency: 1),
    CashFlowItem(amount: 500, frequency: 1),
]
input.discountRate = 10

let npv = try cf.calculateNPV(input)   // NPV
let irr = try cf.calculateIRR(input)   // IRR
```

### Bond (Price & Yield)

```swift
import RBACalc

let bond = BondCalculator()
var input = BondInput()
input.settlementDay = 15
input.settlementMonth = 6
input.settlementYear = 24
input.couponRate = 5
input.redemptionDay = 15
input.redemptionMonth = 6
input.redemptionYear = 34
input.yield = 4.5
input.frequency = .semiannual

let result = bond.calculatePrice(input)
// result.price, result.accruedInterest, result.duration
```

### Depreciation

```swift
import RBACalc

let dep = DepreciationCalculator()
var input = DepreciationInput()
input.method = .SL
input.cost = 10000
input.salvage = 1000
input.lif = 5
input.year = 1

let result = dep.calculate(input)
// result.depreciation, result.bookValue, result.remainingValue
```

### Statistics

```swift
import RBACalc

let stats = StatsCalculator()
let x = [1.0, 2.0, 3.0, 4.0, 5.0]
let y = [2.1, 3.9, 6.2, 8.1, 9.8]

let result1V = stats.calculate1V(x)
// result1V.mean, result1V.sampleStdDev, result1V.sum

let result2V = stats.calculate2V(x: x, y: y)
// result2V.correlation

let regression = stats.fitRegression(type: .linear, x: x, y: y)
// regression.slope, regression.intercept, regression.correlation
```

### Basic Calculator

```swift
import RBACalc

let calc = CalculatorEngine()
calc.calculationMode = .CHN  // or .AOS

calc.inputDigit(5)
calc.inputDigit(0)           // display: 50
calc.inputOperator(.multiply)
calc.inputDigit(3)           // display: 3
calc.execute()               // display: 150
```

### Scientific Functions

```swift
import RBACalc

let sci = ScientificCalculator()
sci.angleMode = .deg

sci.displayValue = 30
let sin30 = sci.execute(.sin)    // 0.5

sci.displayValue = 100
let log100 = sci.execute(.log)   // 2
```

## Precision Guarantee

Every calculation uses Swift's native `Decimal` type (28 significant digits), far exceeding
`Double` (~15 digits). All results are verified against test cases from the official
**TI BA II Plus User Manual**.

See [`docs/test_cases/`](docs/test_cases/) for the full test dataset.

## Accuracy Comparison

| Operation | Double (typical) | RBA Decimal |
|-----------|------------------|-------------|
| 0.1 + 0.2 | 0.30000000000000004 | 0.3 |
| 1.0 / 3.0 × 3.0 | 0.9999999999999999 | 1.0 |
| TVM I/Y iteration | ~1e-15 error | ~1e-28 error |

## Project Structure

```
RBA-Finance-Calc/
├── Sources/RBACalc/
│   ├── Core/           # Basic & scientific calculator
│   ├── TVM/            # Time Value of Money
│   ├── CashFlow/       # NPV, IRR, MIRR, etc.
│   ├── Bond/           # Bond price & yield
│   ├── Depreciation/   # SL, SYD, DB, DBX
│   ├── Stats/          # Statistics & regression
│   └── Shared/         # Constants & error types
├── Tests/RBACalcTests/
├── docs/
│   ├── formulas/       # Financial formula documentation
│   └── test_cases/     # TI BA II Plus test case data
└── Package.swift
```

## 📲 Full iOS App

This is the **calculation engine only**. The full app includes:

- TI BA II Plus replica UI with authentic button layout
- Haptic feedback for key presses
- Exam-optimized workflow (quick field switching, memory registers)
- 12 complete worksheets
- Dark mode support
- Offline-first, no internet required

**→ [Download on App Store](https://apps.apple.com/app/1545331477)**

## License

MIT License — see [LICENSE](LICENSE) for details.

## Contributing

Found a bug or have a suggestion? Open an issue or submit a pull request.

## References

- [TI BA II Plus Official Manual](docs/formulas/)
- [CFA Institute Calculator Policy](https://www.cfainstitute.org/)
