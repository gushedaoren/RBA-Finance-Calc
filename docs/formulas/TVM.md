# TVM (货币时间价值) 计算公式

> **版本**: v1.0  
> **日期**: 2026-05-17  
> **参考**: TI BA II Plus 官方手册

---

## 1. 核心变量

| 变量 | 描述 | 范围 |
|------|------|------|
| N | 总期数 (Number of periods) | 1 ~ 999,999.99 |
| I/Y | 年利率 (Interest rate per year) | 0 ~ 999,999.99 % |
| PV | 现值 (Present Value) | -999,999,999.99 ~ 999,999,999.99 |
| PMT | 年金 (Payment) | -999,999,999.99 ~ 999,999,999.99 |
| FV | 终值 (Future Value) | -999,999,999.99 ~ 999,999,999.99 |
| P/Y | 每年付款次数 (Payments per Year) | 1 ~ 999,999.99 |
| C/Y | 每年复利次数 (Compounding periods per Year) | 1 ~ 999,999.99 |

---

## 2. 基础公式

### 2.1 期利率计算

```
i = (I/Y) / (100 × C/Y)
```

其中：
- `i` = 期利率
- `I/Y` = 年利率（百分比）
- `C/Y` = 每年复利次数

**示例**：
- 年利率 6%，每月复利 → i = 6 / (100 × 12) = 0.005
- 年利率 5.5%，每季度复利 → i = 5.5 / (100 × 4) = 0.01375

---

### 2.2 TVM 标准方程

#### END 模式（期末支付）

```
PV × (1+i)^N + PMT × [(1+i)^N - 1] / i + FV = 0
```

#### BGN 模式（期初支付）

```
PV × (1+i)^N + PMT × (1+i) × [(1+i)^N - 1] / i + FV = 0
```

**关键差异**：
- BGN 模式中，每期支付发生在期初，因此 PMT 需要额外乘以 `(1+i)`
- 其他条件相同时，BGN 模式的 PMT 绝对值会小于 END 模式

---

## 3. 各变量求解公式

### 3.1 已知 PV, PMT, FV, i → 求 N

```
当 PMT = 0 时：
N = ln(FV / PV) / ln(1+i)

当 PMT ≠ 0 时：
令 A = PV + FV
令 B = PMT / i

END 模式：
N = ln[(B - FV) / (B + PV)] / ln(1+i)

BGN 模式：
N = ln[(B × (1+i) - FV) / (B × (1+i) + PV)] / ln(1+i)
```

---

### 3.2 已知 N, PV, PMT, FV → 求 I/Y

**方法**：牛顿-拉夫森迭代法

```
定义函数 f(i) = PV × (1+i)^N + PMT × [(1+i)^N - 1] / i + FV

求导数 f'(i)：
f'(i) = N × PV × (1+i)^(N-1) + PMT × [N × (1+i)^(N-1) × i - ((1+i)^N - 1)] / i²

迭代公式：
i_new = i_old - f(i_old) / f'(i_old)

初始值建议：
i_0 = (FV + N × PMT + PV) / (N × PV)  // 粗略估计

收敛条件：
|f(i)| < 1e-13  // 精度要求
```

**注意事项**：
- 需要处理 i = 0 的特殊情况
- 最大迭代次数限制（建议 100 次）
- 可能存在多个解或无解的情况

---

### 3.3 已知 N, I/Y, PMT, FV → 求 PV

```
令 v = 1 / (1+i)^N  // 折现因子

END 模式：
PV = -FV × v - PMT × (1 - v) / i

BGN 模式：
PV = -FV × v - PMT × (1+i) × (1 - v) / i
```

---

### 3.4 已知 N, I/Y, PV, FV → 求 PMT

```
令 v = 1 / (1+i)^N

END 模式：
PMT = -(PV + FV × v) × i / (1 - v)

BGN 模式：
PMT = -(PV + FV × v) × i / [(1 - v) × (1+i)]
```

---

### 3.5 已知 N, I/Y, PV, PMT → 求 FV

```
END 模式：
FV = -PV × (1+i)^N - PMT × [(1+i)^N - 1] / i

BGN 模式：
FV = -PV × (1+i)^N - PMT × (1+i) × [(1+i)^N - 1] / i
```

---

## 4. 摊销计算 (Amortization)

### 4.1 输入参数

| 参数 | 描述 |
|------|------|
| P1 | 起始期数 |
| P2 | 结束期数 |
| BAL | P2期结束后的剩余本金余额 |
| PRN | P1-P2期间偿还的本金总额 |
| INT | P1-P2期间支付的利息总额 |

### 4.2 计算公式

#### 单期本金偿还

```
PRN_k = PMT + BAL_(k-1) × i
```

其中：
- `PRN_k` = 第 k 期偿还的本金
- `BAL_(k-1)` = 第 k-1 期结束后的余额

#### 单期利息支付

```
INT_k = PMT - PRN_k
```

#### 累计计算

```
PRN = Σ(PRN_k) for k = P1 to P2
INT = Σ(INT_k) for k = P1 to P2
BAL = BAL_P2
```

### 4.3 余额递推公式

```
BAL_0 = PV  // 初始余额
BAL_k = BAL_(k-1) - PRN_k = BAL_(k-1) × (1+i) + PMT
```

---

## 5. P/Y 与 C/Y 不一致的处理

### 5.1 概念说明

- **P/Y** (Payments per Year): 每年付款次数
- **C/Y** (Compounding periods per Year): 每年复利次数

**常见场景**：
- 月供，按月复利：P/Y = 12, C/Y = 12
- 月供，按季度复利：P/Y = 12, C/Y = 4
- 季度付款，按年复利：P/Y = 4, C/Y = 1

### 5.2 有效期利率计算

```
年利率：I/Y
每年复利次数：C/Y
每年付款次数：P/Y

有效期利率：
i_eff = (1 + I/Y / (100 × C/Y))^(C/Y / P/Y) - 1
```

**示例**：
- I/Y = 8%, P/Y = 12, C/Y = 4
- i_eff = (1 + 0.08/4)^(4/12) - 1 = 1.02^(1/3) - 1 ≈ 0.0066227

### 5.3 修正后的 TVM 方程

使用 `i_eff` 替代 `i` 代入标准 TVM 方程。

---

## 6. 边界情况处理

### 6.1 i = 0 的情况

当利率为 0 时，TVM 方程简化为：

```
END 模式：
PV + N × PMT + FV = 0

BGN 模式：
PV + N × PMT + FV = 0  // 相同
```

求解：
```
PV = -FV - N × PMT
PMT = -(PV + FV) / N
FV = -PV - N × PMT
N = -(PV + FV) / PMT
```

### 6.2 N = 0 的情况

```
PV + FV = 0
即 FV = -PV
```

### 6.3 PMT = 0 的情况

简化为复利公式：
```
FV = -PV × (1+i)^N
PV = -FV / (1+i)^N
N = ln(-FV/PV) / ln(1+i)
```

---

## 7. 数值精度要求

### 7.1 使用 Decimal 类型

```swift
import Foundation

// 使用 Decimal 而非 Double
var pv: Decimal = 75000.0
var rate: Decimal = 0.005  // 期利率

// 高精度幂运算
func decimalPower(_ base: Decimal, _ exponent: Decimal) -> Decimal {
    return Decimal(pow(Double(truncating: base as NSNumber), 
                      Double(truncating: exponent as NSNumber)))
}
```

### 7.2 精度标准

- **显示精度**：小数点后 2 位（金额）或 9 位（利率）
- **计算精度**：至少 13 位有效数字
- **收敛精度**：|f(i)| < 1e-13

---

## 8. 验证测试用例

### 用例 1：基本房贷计算

```
输入：
N = 360 (30年 × 12月)
I/Y = 5.5
PV = 75000
FV = 0
P/Y = 12
C/Y = 12
模式 = END

期望输出：
PMT = -425.84
```

### 用例 2：BGN 模式

```
输入：
N = 20
I/Y = 0.5
PV = -5000
FV = 0
P/Y = 4
C/Y = 4
模式 = BGN

期望输出：
PMT = -1279.82
```

### 用例 3：P/Y ≠ C/Y

```
输入：
N = 120
I/Y = 0.5
PV = 25000
FV = 25000
P/Y = 12
C/Y = 4
模式 = BGN

期望输出：
PMT = -203.13
```

### 用例 4：摊销表

```
基于用例1，计算 P1=1, P2=12：

期望输出：
BAL = 73,847.02  // 第12期末余额
PRN = 1,152.98   // 第1-12期偿还本金
INT = 3,957.10   // 第1-12期支付利息
```

---

## 9. 实现建议

### 9.1 数据结构

```swift
struct TVMData {
    var n: Decimal?
    var iy: Decimal?
    var pv: Decimal?
    var pmt: Decimal?
    var fv: Decimal?
    var py: Decimal = 12
    var cy: Decimal = 12
    var isBGN: Bool = false
}
```

### 9.2 计算流程

```
1. 验证输入参数（至少已知 3 个）
2. 计算期利率 i
3. 根据缺失变量选择对应公式
4. 执行计算（注意精度）
5. 验证结果（代入原方程检验）
6. 返回结果
```

### 9.3 错误处理

- 参数不足时提示 "需要至少输入 3 个变量"
- IRR 迭代不收敛时提示 "无法计算利率"
- 结果超出范围时提示 "结果超出有效范围"

---

## 10. 参考资料

- TI BA II Plus 官方手册（第 32-45 页）
- 《金融数学》- 利息理论章节
- CFA Level 1 - Fixed Income 章节
