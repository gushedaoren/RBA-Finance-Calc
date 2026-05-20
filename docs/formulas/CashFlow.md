# Cash Flow (现金流) 计算公式

> **版本**: v1.0  
> **日期**: 2026-05-17  
> **参考**: TI BA II Plus Professional 官方手册

---

## 1. 核心变量

### 1.1 输入参数

| 变量 | 描述 | 范围 |
|------|------|------|
| CF0 | 初始现金流 (通常为负，即投资) | -9,999,999,999 ~ 9,999,999,999 |
| C01-C24 | 后续现金流 (最多24组) | -9,999,999,999 ~ 9,999,999,999 |
| F01-F24 | 每组现金流发生次数 | 1 ~ 9,999 |
| I | 折现率 (%) | 0 ~ 9,999.9999 |

**注意**：TI BA II Plus 标准版支持最多 24 组现金流，Professional 版相同。

---

### 1.2 输出参数

| 输出 | 描述 | 版本 |
|------|------|------|
| NPV | 净现值 (Net Present Value) | 标准版 + Pro |
| IRR | 内部收益率 (Internal Rate of Return) | 标准版 + Pro |
| NFV | 净终值 (Net Future Value) | **Pro 仅** |
| PB | 回收期 (Payback Period - 简单) | **Pro 仅** |
| DPB | 折现回收期 (Discounted Payback Period) | **Pro 仅** |
| MOD | 修正内部收益率 (Modified IRR) | **Pro 仅** |

---

## 2. NPV (净现值) 计算

### 2.1 基本公式

```
NPV = CF0 + Σ [CFj / (1+i)^tj]

其中：
- CF0 = 初始现金流（通常为负）
- CFj = 第 j 组现金流
- i = 折现率 = I / 100
- tj = 第 j 组现金流发生的期数
- Fj = 第 j 组现金流的发生次数
```

### 2.2 详细展开

```
NPV = CF0 
    + C01/(1+i)^1 + C01/(1+i)^2 + ... + C01/(1+i)^F01
    + C02/(1+i)^(F01+1) + ... + C02/(1+i)^(F01+F02)
    + ...
    + Cn/(1+i)^(ΣF01..F(n-1)+1) + ... + Cn/(1+i)^(ΣF01..Fn)
```

### 2.3 简化公式（相同现金流）

当同一组现金流发生多次时：

```
CFj 发生 Fj 次，从第 t_start 期到第 t_end 期：

现值 = CFj × [(1+i)^(-t_start) + (1+i)^(-t_start-1) + ... + (1+i)^(-t_end)]
     = CFj × (1+i)^(-t_start) × [1 - (1+i)^(-Fj)] / i
```

### 2.4 实现示例

```swift
func calculateNPV(cf0: Decimal, cashFlows: [(amount: Decimal, frequency: Int)], 
                  discountRate: Decimal) -> Decimal {
    var npv = cf0
    var period = 0
    let i = discountRate / 100
    
    for (amount, frequency) in cashFlows {
        for _ in 0..<frequency {
            period += 1
            npv += amount / decimalPower(1 + i, Decimal(period))
        }
    }
    
    return npv
}
```

---

## 3. IRR (内部收益率) 计算

### 3.1 定义

IRR 是使 NPV = 0 的折现率：

```
CF0 + Σ [CFj / (1+IRR)^tj] = 0
```

### 3.2 求解方法：牛顿-拉夫森迭代

```
定义函数：
f(i) = CF0 + Σ [CFj / (1+i)^tj]

求导数：
f'(i) = -Σ [tj × CFj / (1+i)^(tj+1)]

迭代公式：
i_new = i_old - f(i_old) / f'(i_old)
```

### 3.3 初始值选择策略

```
策略 1：简单估计
IRR_0 = (ΣCFj + CF0) / |CF0|  // 粗略估计

策略 2：二分法寻找区间
先在 [-0.9, 10.0] 范围内寻找 f(i) 符号变化的区间
然后使用二分法 + 牛顿法结合

策略 3：多重初始值
尝试多个初始值：0.1, 0.5, 1.0, 2.0, 5.0
选择收敛最快的解
```

### 3.4 收敛条件

```
|NPV| < 1e-10  // NPV 接近 0
或
|i_new - i_old| < 1e-13  // 利率变化极小
```

### 3.5 特殊情况处理

**情况 1：无解**
- 现金流符号变化少于 1 次（Descartes 符号法则）
- 提示："无法计算 IRR"

**情况 2：多解**
- 现金流符号变化多次
- 选择最接近合理范围的解（通常 0% ~ 100%）

**情况 3：不收敛**
- 超过最大迭代次数（建议 100 次）
- 尝试不同的初始值或使用二分法

### 3.6 实现示例

```swift
func calculateIRR(cf0: Decimal, cashFlows: [(amount: Decimal, frequency: Int)]) -> Decimal? {
    var irr: Decimal = 0.1  // 初始猜测 10%
    let maxIterations = 100
    let tolerance: Decimal = 1e-10
    
    for _ in 0..<maxIterations {
        let npv = calculateNPV(cf0: cf0, cashFlows: cashFlows, discountRate: irr)
        
        if abs(npv) < tolerance {
            return irr * 100  // 转换为百分比
        }
        
        let derivative = calculateNPVDerivative(cf0: cf0, cashFlows: cashFlows, rate: irr)
        
        if derivative == 0 {
            break  // 避免除零
        }
        
        irr = irr - npv / derivative
        
        // 边界检查
        if irr < -0.99 || irr > 100 {
            break  // 超出合理范围
        }
    }
    
    return nil  // 未收敛
}
```

---

## 4. NFV (净终值) 计算

### 4.1 定义

NFV 是所有现金流在最后一期的终值之和：

```
NFV = NPV × (1+i)^N

其中：
- N = 总期数 = ΣFj
- i = 折现率
```

### 4.2 直接计算公式

```
NFV = CF0 × (1+i)^N 
    + Σ [CFj × (1+i)^(N - tj)]

即：每笔现金流按其距离最后一期的期数进行复利计算
```

### 4.3 实现示例

```swift
func calculateNFV(cf0: Decimal, cashFlows: [(amount: Decimal, frequency: Int)], 
                  discountRate: Decimal) -> Decimal {
    let npv = calculateNPV(cf0: cf0, cashFlows: cashFlows, discountRate: discountRate)
    let totalPeriods = cashFlows.reduce(0) { $0 + $1.frequency }
    let i = discountRate / 100
    
    return npv * decimalPower(1 + i, Decimal(totalPeriods))
}
```

---

## 5. PB (回收期) 计算

### 5.1 定义

简单回收期：不考虑货币时间价值，累计现金流由负转正的时点。

### 5.2 计算方法

```
步骤：
1. 计算累计现金流
2. 找到累计现金流从负变正的期数 k
3. 线性插值计算精确时点

公式：
PB = k - 1 + |累计CF_(k-1)| / CF_k

其中：
- k = 累计现金流首次为正的期数
- 累计CF_(k-1) = 第 k-1 期的累计现金流（负值）
- CF_k = 第 k 期的现金流（正值）
```

### 5.3 示例

```
CF0 = -7000
C01 = 3000 (F01=1)
C02 = 5000 (F02=4)

累计现金流：
期0: -7000
期1: -7000 + 3000 = -4000
期2: -4000 + 5000 = 1000  ← 首次为正

PB = 1 + |-4000| / 5000 = 1 + 0.8 = 1.8 年
```

### 5.4 特殊情况

- 如果累计现金流始终为负 → PB = 无穷大（无法回收）
- 如果累计现金流始终为正 → PB = 0（无需回收）

---

## 6. DPB (折现回收期) 计算

### 6.1 定义

折现回收期：考虑货币时间价值，累计折现现金流由负转正的时点。

### 6.2 计算方法

```
步骤：
1. 计算每期折现现金流：DCFj = CFj / (1+i)^tj
2. 计算累计折现现金流
3. 找到累计折现现金流从负变正的期数 k
4. 线性插值计算精确时点

公式：
DPB = k - 1 + |累计DCF_(k-1)| / DCF_k
```

### 6.3 示例

```
CF0 = -7000, I = 20%

折现现金流：
期0: -7000
期1: 3000/1.2^1 = 2500, 累计 = -4500
期2: 5000/1.2^2 = 3472, 累计 = -1028
期3: 5000/1.2^3 = 2894, 累计 = 1866  ← 首次为正

DPB = 2 + |-1028| / 2894 = 2 + 0.36 = 2.36 年
```

---

## 7. MOD (修正内部收益率) 计算

### 7.1 定义

MIRR 解决了 IRR 的多个问题：
- 假设负现金流以融资利率再投资
- 假设正现金流以再投资率复利增长

### 7.2 计算公式

```
MIRR = [(FV of positive cash flows) / |PV of negative cash flows|]^(1/N) - 1

其中：
- FV of positive cash flows = 正现金流的终值（按再投资率）
- PV of negative cash flows = 负现金流的现值（按融资利率）
- N = 总期数
```

### 7.3 简化假设（TI BA II Plus）

TI 计算器假设：
- 融资利率 = 再投资率 = I（折现率）

因此：

```
MIRR = [Σ(CF+ × (1+i)^(N-t)) / |Σ(CF- / (1+i)^t)|]^(1/N) - 1

其中：
- CF+ = 正现金流
- CF- = 负现金流
```

### 7.4 实现示例

```swift
func calculateMIRR(cf0: Decimal, cashFlows: [(amount: Decimal, frequency: Int)], 
                   reinvestRate: Decimal) -> Decimal {
    var positiveFV: Decimal = 0
    var negativePV: Decimal = 0
    var period = 0
    let i = reinvestRate / 100
    let totalPeriods = cashFlows.reduce(0) { $0 + $1.frequency }
    
    // 处理 CF0
    if cf0 > 0 {
        positiveFV += cf0 * decimalPower(1 + i, Decimal(totalPeriods))
    } else {
        negativePV += cf0
    }
    
    // 处理后续现金流
    for (amount, frequency) in cashFlows {
        for _ in 0..<frequency {
            period += 1
            if amount > 0 {
                positiveFV += amount * decimalPower(1 + i, Decimal(totalPeriods - period))
            } else {
                negativePV += amount / decimalPower(1 + i, Decimal(period))
            }
        }
    }
    
    let mirr = decimalPower(positiveFV / abs(negativePV), 1 / Decimal(totalPeriods)) - 1
    return mirr * 100  // 转换为百分比
}
```

---

## 8. 验证测试用例

### 用例 1：基本 NPV/IRR

```
输入：
CF0 = -7000
C01 = 3000, F01 = 1
C02 = 5000, F02 = 4
C03 = 4000, F03 = 1
I = 20%

期望输出：
NPV = 7266.44
IRR = 52.71%
```

### 用例 2：NFV 计算

```
基于用例1：

期望输出：
NFV = 21697.47
```

### 用例 3：回收期

```
基于用例1：

期望输出：
PB = 2.00 年
DPB = 2.60 年
```

### 用例 4：MIRR

```
基于用例1：

期望输出：
MOD = 35.12%
```

### 用例 5：复杂现金流

```
输入：
CF0 = -10000
C01 = 3000, F01 = 1
C02 = 4000, F02 = 1
C03 = 5000, F03 = 1
I = 10%

期望输出：
NPV = -355.25
IRR = 8.88%
```

---

## 9. 数值精度与性能

### 9.1 精度要求

- NPV：小数点后 2 位
- IRR：小数点后 2 位（百分比）
- PB/DPB：小数点后 2 位
- MIRR：小数点后 2 位（百分比）

### 9.2 性能优化

**IRR 计算**：
- 使用牛顿法 + 二分法混合策略
- 缓存中间计算结果
- 设置合理的最大迭代次数

**NPV 计算**：
- 使用 Decimal 类型避免精度损失
- 对于相同现金流，使用等比数列求和公式

---

## 10. 实现建议

### 10.1 数据结构

```swift
struct CashFlowData {
    var cf0: Decimal = 0
    var cashFlows: [CashFlowItem] = []
    var discountRate: Decimal = 0
    
    var totalPeriods: Int {
        return cashFlows.reduce(0) { $0 + $1.frequency }
    }
}

struct CashFlowItem {
    var amount: Decimal
    var frequency: Int = 1
}
```

### 10.2 计算器类

```swift
class CashFlowCalculator {
    func calculateNPV(_ data: CashFlowData) -> Decimal
    func calculateIRR(_ data: CashFlowData) -> Decimal?
    func calculateNFV(_ data: CashFlowData) -> Decimal
    func calculatePB(_ data: CashFlowData) -> Decimal?
    func calculateDPB(_ data: CashFlowData) -> Decimal?
    func calculateMIRR(_ data: CashFlowData) -> Decimal
}
```

### 10.3 错误处理

- 现金流为空时提示 "请输入现金流"
- IRR 不收敛时提示 "无法计算 IRR，请检查现金流"
- 回收期为无穷时提示 "无法在给定时间内回收投资"

---

## 11. 参考资料

- TI BA II Plus Professional 官方手册（第 46-55 页）
- 《公司理财》- NPV 与 IRR 章节
- CFA Level 1 - Corporate Finance 章节
