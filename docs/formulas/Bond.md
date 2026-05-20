# Bond (债券) 计算公式

> **版本**: v1.0  
> **日期**: 2026-05-17  
> **参考**: TI BA II Plus Professional 官方手册

---

## 1. 核心变量

### 1.1 输入参数

| 变量 | 描述 | 格式 |
|------|------|------|
| SDT | 结算日期 (Settlement Date) | mm.ddyy 或 dd.mmyy |
| CPN | 票面利率 (Coupon Rate) | % |
| RDT | 到期日期 (Redemption Date) | mm.ddyy 或 dd.mmyy |
| RV | 赎回价值 (Redemption Value) | % 面值，默认 100 |
| YLD | 到期收益率 (Yield to Maturity) | % |
| PRI | 债券价格 (Price) | 每 $100 面值 |

### 1.2 设置参数

| 参数 | 选项 | 默认 |
|------|------|------|
| 计息基准 (Day Basis) | ACT / 360 | ACT |
| 复利频率 | 2/Y (半年) / 1/Y (年) | 2/Y |

---

### 1.3 输出参数

| 输出 | 描述 | 版本 |
|------|------|------|
| PRI | 债券价格 (每 $100 面值) | 标准版 + Pro |
| AI | 应计利息 (Accrued Interest) | 标准版 + Pro |
| DUR | 修正久期 (Modified Duration) | **Pro 仅** |

---

## 2. 日期处理

### 2.1 日期格式

**美国格式 (US)**：`mm.ddyy`
- 示例：`6.122006` = 2006年6月12日

**欧洲格式 (EU)**：`dd.mmyy`
- 示例：`12.062006` = 2006年6月12日

### 2.2 日期转换

```swift
func parseBondDate(_ input: String, format: DateFormat) -> Date {
    let parts = input.split(separator: ".")
    
    if format == .US {
        let month = Int(parts[0])!
        let day = Int(parts[1].prefix(2))!
        let year = Int(parts[1].suffix(2))!
        return Date(year: 2000 + year, month: month, day: day)
    } else {
        let day = Int(parts[0])!
        let month = Int(parts[1].prefix(2))!
        let year = Int(parts[1].suffix(2))!
        return Date(year: 2000 + year, month: month, day: day)
    }
}
```

### 2.3 计息天数计算

#### ACT (实际天数)

```
ACT/360:
天数 = 实际天数
年基准 = 360

ACT/365:
天数 = 实际天数
年基准 = 365
```

#### 30/360 (每月按30天)

```
天数 = 360 × (Y2 - Y1) + 30 × (M2 - M1) + (D2 - D1)

其中：
- Y, M, D = 年、月、日
- 如果 D1 = 31，则 D1 = 30
- 如果 D2 = 31 且 D1 = 30，则 D2 = 30
```

---

## 3. 债券定价公式

### 3.1 基本概念

**息票周期**：
- 半年复利 (2/Y)：每 6 个月支付一次利息
- 年复利 (1/Y)：每年支付一次利息

**关键时间点**：
- 结算日 (SDT)：债券交易的日期
- 到期日 (RDT)：债券到期偿还的日期
- 上一付息日：结算日之前最近的付息日
- 下一付息日：结算日之后最近的付息日

### 3.2 时间计算

```
DSC = 从结算日到下一付息日的天数
N = 从结算日到到期日的完整息票周期数
E = 当前息票周期的总天数
```

**示例**：
- 结算日：2006-06-12
- 到期日：2007-12-31
- 上一付息日：2006-06-01（假设）
- 下一付息日：2006-12-01

```
DSC = 2006-12-01 - 2006-06-12 = 172 天
E = 2006-12-01 - 2006-06-01 = 183 天
N = 从 2006-12-01 到 2007-12-31 的完整周期数 = 2
```

### 3.3 债券价格公式

#### 标准公式

```
PRI = [C/r × (1 - 1/(1+r)^N) + 100/(1+r)^N] × 1/(1+r)^(DSC/E) - AI

其中：
- C = 票面利率 / 100 × 面值 / 息票频率
- r = 到期收益率 / 100 / 息票频率
- N = 完整息票周期数
- DSC = 结算日到下一付息日的天数
- E = 当前息票周期总天数
- AI = 应计利息
```

#### 分步计算

**步骤 1：计算息票金额**

```
C = CPN / 100 × 100 / 息票频率

示例：CPN = 7%, 半年复利
C = 7 / 100 × 100 / 2 = 3.5
```

**步骤 2：计算期收益率**

```
r = YLD / 100 / 息票频率

示例：YLD = 8%, 半年复利
r = 8 / 100 / 2 = 0.04
```

**步骤 3：计算完整现金流现值**

```
PV_coupons = C × [1 - 1/(1+r)^N] / r
PV_principal = 100 / (1+r)^N
```

**步骤 4：折现到结算日**

```
折现因子 = 1 / (1+r)^(DSC/E)
PV_total = (PV_coupons + PV_principal) × 折现因子
```

**步骤 5：扣除应计利息**

```
PRI = PV_total - AI
```

---

## 4. 应计利息 (AI) 计算

### 4.1 定义

应计利息 = 从上一付息日到结算日的利息

### 4.2 计算公式

```
AI = C × (E - DSC) / E

其中：
- C = 息票金额
- E = 当前息票周期总天数
- DSC = 结算日到下一付息日的天数
- (E - DSC) = 上一付息日到结算日的天数
```

### 4.3 示例

```
CPN = 7%, 半年复利
结算日 = 2006-06-12
上一付息日 = 2006-06-01
下一付息日 = 2006-12-01

C = 3.5
E = 183 天 (2006-06-01 到 2006-12-01)
DSC = 172 天 (2006-06-12 到 2006-12-01)
应计天数 = 183 - 172 = 11 天

AI = 3.5 × 11 / 183 = 0.21
```

---

## 5. 修正久期 (DUR) 计算

### 5.1 定义

修正久期衡量债券价格对收益率变化的敏感度：

```
DUR = - (1/PRI) × d(PRI)/d(YLD)
```

### 5.2 计算公式

```
DUR = Macaulay Duration / (1 + r)

Macaulay Duration = [Σ(t × CFt / (1+r)^t)] / PRI

其中：
- t = 现金流发生的期数
- CFt = 第 t 期的现金流（息票或本金）
- r = 期收益率
```

### 5.3 实现方法

**数值微分法**（推荐）：

```
DUR ≈ [PRI(YLD - Δ) - PRI(YLD + Δ)] / (2 × PRI × Δ)

其中：
- Δ = 0.01% (收益率的小变化)
- PRI(YLD - Δ) = 收益率降低后的价格
- PRI(YLD + Δ) = 收益率升高后的价格
```

**示例**：

```
YLD = 8%
PRI(8%) = 98.56
PRI(7.99%) = 98.58
PRI(8.01%) = 98.54

DUR = (98.58 - 98.54) / (2 × 98.56 × 0.0001) = 2.03
```

---

## 6. 反向计算：已知价格求收益率

### 6.1 问题定义

已知 PRI, CPN, SDT, RDT，求 YLD。

### 6.2 求解方法：牛顿-拉夫森迭代

```
定义函数：
f(YLD) = PRI_calculated(YLD) - PRI_given

求导数（数值微分）：
f'(YLD) = [f(YLD + Δ) - f(YLD - Δ)] / (2 × Δ)

迭代公式：
YLD_new = YLD_old - f(YLD_old) / f'(YLD_old)
```

### 6.3 初始值选择

```
YLD_0 = CPN  // 票面利率作为初始猜测
```

### 6.4 收敛条件

```
|PRI_calculated - PRI_given| < 0.0001
```

---

## 7. 验证测试用例

### 用例 1：基本债券定价

```
输入：
SDT = 6.122006 (2006-06-12)
CPN = 7%
RDT = 12.312007 (2007-12-31)
RV = 100
YLD = 8%
计息基准 = 30/360
复利频率 = 2/Y

期望输出：
PRI = 98.56
AI = 3.15
DUR = 1.44
```

### 用例 2：零息债券

```
输入：
SDT = 1.012020 (2020-01-01)
CPN = 0%
RDT = 1.012025 (2025-01-01)
YLD = 5%
计息基准 = ACT/360
复利频率 = 2/Y

期望输出：
PRI = 78.35
AI = 0.00
DUR = 5.00
```

### 用例 3：溢价债券

```
输入：
SDT = 1.012020
CPN = 10%
RDT = 1.012025
YLD = 8%
计息基准 = 30/360
复利频率 = 2/Y

期望输出：
PRI = 108.11
AI = 0.00
DUR = 4.03
```

### 用例 4：已知价格求收益率

```
输入：
SDT = 6.122006
CPN = 7%
RDT = 12.312007
PRI = 98.56

期望输出：
YLD = 8.00%
```

---

## 8. 特殊情况处理

### 8.1 短期债券（N = 0）

当结算日和到期日之间没有完整息票周期时：

```
PRI = (100 + C) / (1 + r × DSC/E) - AI
```

### 8.2 最后一个息票周期

当 N = 0 且即将到期时：

```
PRI = (100 + C) / (1 + r × DSC/E) - AI
```

### 8.3 应计利息超过息票金额

当结算日在付息日之后很久时，应计利息可能接近或超过息票金额。

处理：正常计算，PRI 可能为负（理论上）。

---

## 9. 实现建议

### 9.1 数据结构

```swift
struct BondData {
    var settlementDate: Date
    var couponRate: Decimal  // 百分比
    var redemptionDate: Date
    var redemptionValue: Decimal = 100
    var yieldToMaturity: Decimal?  // 百分比
    var price: Decimal?  // 每 $100 面值
    
    var dayBasis: DayBasis = .ACT360
    var compoundFrequency: CompoundFrequency = .semiannual
}

enum DayBasis {
    case ACT360
    case ACT365
    case thirty360
}

enum CompoundFrequency {
    case semiannual  // 2/Y
    case annual      // 1/Y
}
```

### 9.2 计算器类

```swift
class BondCalculator {
    func calculatePrice(_ data: BondData) -> Decimal
    func calculateYield(_ data: BondData) -> Decimal
    func calculateAccruedInterest(_ data: BondData) -> Decimal
    func calculateDuration(_ data: BondData) -> Decimal
}
```

### 9.3 日期工具

```swift
extension Date {
    func days(to other: Date, basis: DayBasis) -> Int {
        switch basis {
        case .ACT360, .ACT365:
            return calendar.dateComponents([.day], from: self, to: other).day!
        case .thirty360:
            return calculate30_360(to: other)
        }
    }
}
```

---

## 10. 数值精度

### 10.1 精度要求

- PRI：小数点后 2 位
- AI：小数点后 2 位
- DUR：小数点后 2 位
- YLD：小数点后 2 位（百分比）

### 10.2 Decimal 使用

```swift
// 使用 Decimal 避免浮点误差
let coupon = Decimal(couponRate) / 100 * 100 / 2
let rate = Decimal(yield) / 100 / 2
```

---

## 11. 参考资料

- TI BA II Plus Professional 官方手册（第 56-65 页）
- 《固定收益证券》- 债券定价章节
- CFA Level 1 - Fixed Income 章节
- Bond Pricing Formula - Investopedia
