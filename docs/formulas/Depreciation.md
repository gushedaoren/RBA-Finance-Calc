# Depreciation (折旧) 计算公式

> **版本**: v1.0  
> **日期**: 2026-05-17  
> **参考**: TI BA II Plus Professional 官方手册

---

## 1. 折旧方法概述

| 方法 | 缩写 | 全称 | 适用场景 |
|------|------|------|----------|
| 直线法 | SL | Straight Line | 均匀折旧 |
| 年数总和法 | SYD | Sum-of-the-Years'-Digits | 加速折旧 |
| 双倍余额递减法 | DB | Declining Balance | 加速折旧 |
| 固定余额递减法 | DBX | Variable Declining Balance | 灵活加速折旧 |
| 剩余寿命直线法 | SLF | Remaining Life Straight Line | **Pro 仅** |
| 剩余寿命双倍法 | DBF | Remaining Life Declining Balance | **Pro 仅** |

---

## 2. 通用输入参数

| 参数 | 描述 | 范围 |
|------|------|------|
| LIF | 资产使用寿命（年） | 1 ~ 999 |
| M01 | 第一年折旧月份 (1-12) | 1 ~ 12 |
| CST | 资产成本 | 0 ~ 999,999,999.99 |
| SAL | 残值 | 0 ~ CST |
| YR | 当前折旧年度 | 1 ~ LIF |
| FACT | 折旧因子（DB/DBX 方法） | 0 ~ 999.99 |

---

## 3. 直线法 (SL)

### 3.1 原理

每年折旧额相等。

### 3.2 公式

**完整年度**：

```
DEP = (CST - SAL) / LIF
```

**第一年（部分年度）**：

```
DEP_1 = (CST - SAL) / LIF × (12 - M01 + 1) / 12
```

**最后一年（部分年度）**：

```
DEP_last = (CST - SAL) / LIF × M01 / 12
```

### 3.3 账面价值

```
RBV_k = CST - Σ(DEP_i) for i = 1 to k
```

### 3.4 示例

```
CST = 10000, SAL = 1000, LIF = 5, M01 = 1

年折旧额 = (10000 - 1000) / 5 = 1800

第1年: DEP = 1800, RBV = 8200
第2年: DEP = 1800, RBV = 6400
第3年: DEP = 1800, RBV = 4600
第4年: DEP = 1800, RBV = 2800
第5年: DEP = 1800, RBV = 1000
```

---

## 4. 年数总和法 (SYD)

### 4.1 原理

加速折旧，早期折旧额高，后期递减。

### 4.2 公式

**年数总和**：

```
SYD = LIF × (LIF + 1) / 2
```

**第 k 年折旧额**：

```
DEP_k = (CST - SAL) × (LIF - k + 1) / SYD
```

**第一年（部分年度）**：

```
DEP_1 = (CST - SAL) × LIF / SYD × (12 - M01 + 1) / 12
```

### 4.3 示例

```
CST = 10000, SAL = 1000, LIF = 5

SYD = 5 × 6 / 2 = 15

第1年: DEP = 9000 × 5/15 = 3000, RBV = 7000
第2年: DEP = 9000 × 4/15 = 2400, RBV = 4600
第3年: DEP = 9000 × 3/15 = 1800, RBV = 2800
第4年: DEP = 9000 × 2/15 = 1200, RBV = 1600
第5年: DEP = 9000 × 1/15 = 600, RBV = 1000
```

---

## 5. 双倍余额递减法 (DB)

### 5.1 原理

加速折旧，折旧率为直线法的两倍（200%）。

### 5.2 公式

**折旧率**：

```
r = 2 / LIF  (双倍直线折旧率)
```

**第 k 年折旧额**：

```
DEP_k = RBV_(k-1) × r

但需满足：
DEP_k ≤ RBV_(k-1) - SAL

如果 DEP_k > RBV_(k-1) - SAL，则：
DEP_k = RBV_(k-1) - SAL
```

**第一年（部分年度）**：

```
DEP_1 = CST × r × (12 - M01 + 1) / 12
```

### 5.3 账面价值递推

```
RBV_k = RBV_(k-1) × (1 - r)
```

### 5.4 示例

```
CST = 10000, SAL = 1000, LIF = 5

r = 2/5 = 0.4

第1年: DEP = 10000 × 0.4 = 4000, RBV = 6000
第2年: DEP = 6000 × 0.4 = 2400, RBV = 3600
第3年: DEP = 3600 × 0.4 = 1440, RBV = 2160
第4年: DEP = 2160 × 0.4 = 864, RBV = 1296
第5年: DEP = 1296 - 1000 = 296, RBV = 1000
```

---

## 6. 固定余额递减法 (DBX)

### 6.1 原理

与 DB 类似，但折旧因子可自定义（不一定是 200%）。

### 6.2 公式

**折旧率**：

```
r = FACT / LIF

其中 FACT 为折旧因子（如 150, 175, 200 等）
```

**第 k 年折旧额**：

```
DEP_k = RBV_(k-1) × r

约束条件：
DEP_k ≤ RBV_(k-1) - SAL
```

### 6.3 示例

```
CST = 10000, SAL = 1000, LIF = 5, FACT = 150

r = 150/100 / 5 = 0.3

第1年: DEP = 10000 × 0.3 = 3000, RBV = 7000
第2年: DEP = 7000 × 0.3 = 2100, RBV = 4900
第3年: DEP = 4900 × 0.3 = 1470, RBV = 3430
第4年: DEP = 3430 × 0.3 = 1029, RBV = 2401
第5年: DEP = 2401 - 1000 = 1401, RBV = 1000
```

---

## 7. 剩余寿命直线法 (SLF) - Pro 仅

### 7.1 原理

根据剩余寿命动态调整折旧额。

### 7.2 公式

```
DEP_k = (RBV_(k-1) - SAL) / (LIF - k + 1)
```

### 7.3 示例

```
CST = 10000, SAL = 1000, LIF = 5

第1年: DEP = (10000 - 1000) / 5 = 1800, RBV = 8200
第2年: DEP = (8200 - 1000) / 4 = 1800, RBV = 6400
第3年: DEP = (6400 - 1000) / 3 = 1800, RBV = 4600
第4年: DEP = (4600 - 1000) / 2 = 1800, RBV = 2800
第5年: DEP = (2800 - 1000) / 1 = 1800, RBV = 1000
```

**注意**：此例中 SLF 与 SL 结果相同，因为 RBV 线性递减。

---

## 8. 剩余寿命双倍法 (DBF) - Pro 仅

### 8.1 原理

结合 DB 和 SL，当 DB 折旧额小于 SL 时，切换到 SL。

### 8.2 公式

```
DEP_DB = RBV_(k-1) × 2 / LIF
DEP_SL = (RBV_(k-1) - SAL) / (LIF - k + 1)

DEP_k = max(DEP_DB, DEP_SL)

约束：
DEP_k ≤ RBV_(k-1) - SAL
```

### 8.3 示例

```
CST = 10000, SAL = 1000, LIF = 5

第1年:
  DEP_DB = 10000 × 0.4 = 4000
  DEP_SL = 9000 / 5 = 1800
  DEP = 4000, RBV = 6000

第2年:
  DEP_DB = 6000 × 0.4 = 2400
  DEP_SL = 5000 / 4 = 1250
  DEP = 2400, RBV = 3600

第3年:
  DEP_DB = 3600 × 0.4 = 1440
  DEP_SL = 2600 / 3 = 867
  DEP = 1440, RBV = 2160

第4年:
  DEP_DB = 2160 × 0.4 = 864
  DEP_SL = 1160 / 2 = 580
  DEP = 864, RBV = 1296

第5年:
  DEP = 1296 - 1000 = 296, RBV = 1000
```

---

## 9. 部分年度处理

### 9.1 第一年部分年度

```
实际使用月数 = 12 - M01 + 1

折旧比例 = 实际使用月数 / 12

DEP_1 = DEP_full_year × 折旧比例
```

### 9.2 最后一年部分年度

如果第一年不是完整年度，最后一年也需要调整：

```
DEP_last = DEP_full_year × M01 / 12
```

### 9.3 示例

```
CST = 10000, SAL = 1000, LIF = 5, M01 = 7 (7月开始)

第一年（7-12月，6个月）：
DEP_1 = 1800 × 6/12 = 900

完整年份（第2-5年）：
DEP = 1800

最后一年（1-6月，6个月）：
DEP_6 = 1800 × 6/12 = 900
```

---

## 10. 输出参数

| 参数 | 描述 |
|------|------|
| DEP | 当年折旧额 |
| RBV | 当前账面价值 (Remaining Book Value) |
| RDV | 剩余可折旧价值 (Remaining Declining Value) = RBV - SAL |

---

## 11. 验证测试用例

### 用例 1：直线法

```
输入：
CST = 10000, SAL = 1000, LIF = 5, M01 = 1, YR = 3

期望输出：
DEP = 1800
RBV = 4600
RDV = 3600
```

### 用例 2：年数总和法

```
输入：
CST = 10000, SAL = 1000, LIF = 5, YR = 2

期望输出：
DEP = 2400
RBV = 4600
RDV = 3600
```

### 用例 3：双倍余额递减法

```
输入：
CST = 10000, SAL = 1000, LIF = 5, YR = 3

期望输出：
DEP = 1440
RBV = 2160
RDV = 1160
```

### 用例 4：部分年度

```
输入：
CST = 10000, SAL = 1000, LIF = 5, M01 = 7, YR = 1

期望输出（直线法）：
DEP = 900
RBV = 9100
RDV = 8100
```

---

## 12. 实现建议

### 12.1 数据结构

```swift
struct DepreciationData {
    var method: DepreciationMethod
    var cost: Decimal
    var salvage: Decimal
    var life: Int
    var startMonth: Int = 1
    var year: Int
    var factor: Decimal = 200  // for DB/DBX
}

enum DepreciationMethod {
    case SL
    case SYD
    case DB
    case DBX
    case SLF  // Pro only
    case DBF  // Pro only
}
```

### 12.2 计算器类

```swift
class DepreciationCalculator {
    func calculate(_ data: DepreciationData) -> DepreciationResult {
        switch data.method {
        case .SL:
            return calculateSL(data)
        case .SYD:
            return calculateSYD(data)
        case .DB:
            return calculateDB(data)
        case .DBX:
            return calculateDBX(data)
        case .SLF:
            return calculateSLF(data)
        case .DBF:
            return calculateDBF(data)
        }
    }
}

struct DepreciationResult {
    var depreciation: Decimal
    var bookValue: Decimal
    var remainingValue: Decimal
}
```

---

## 13. 参考资料

- TI BA II Plus Professional 官方手册（第 66-72 页）
- 《会计学原理》- 固定资产折旧章节
- MACRS Depreciation - IRS Publication 946
