# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-20

### Added
- **TVM (Time Value of Money)** — N, I/Y, PV, PMT, FV, Amortization calculations
- **Cash Flow** — NPV, IRR, NFV, PB, DPB, MIRR calculations
- **Bond** — Price, Yield, Accrued Interest, Duration calculations
- **Depreciation** — SL, SYD, DB, DBX methods
- **Statistics** — 1-Variable, 2-Variable, Linear/Log/Exp/Power Regression
- **Core Calculator** — CHN/AOS calculation modes, scientific functions (sin/cos/tan, ln/log, nPr/nCr)
- **High Precision** — All calculations use Swift `Decimal` (28 significant digits)
- **200+ Test Cases** — Extracted from TI BA II Plus official manual, all verified
- **Formula Documentation** — Markdown docs for TVM, Cash Flow, Bond, Depreciation, Statistics
- **Test Dataset CSVs** — Bond.csv, CashFlow.csv, TVM.csv for validation

### License
- MIT License
