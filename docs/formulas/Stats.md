# Statistics (统计) 计算公式

> **版本**: v1.0  
> **日期**: 2026-05-17  
> **参考**: TI BA II Plus 官方手册

---

## 1. 统计模式

| 模式 | 描述 | 用途 |
|------|------|------|
| 1-V | 单变量统计 | 描述性统计 |
| 2-V | 双变量统计 | 相关性分析 |
| LIN | 线性回归 | Y = a + bX |
| Ln | 对数回归 | Y = a + b·ln(X) |
| EXP | 指数回归 | Y = a·e^(bX) |
| PWR | 幂函数回归 | Y = a·X^b |

---

## 2. 单变量统计 (1-V)

### 2.1 输入数据

```
X1, X2, X3, ..., Xn
```

### 2.2 统计量

| 统计量 | 符号 | 公式 |
|--------|------|------|
| 样本数 | n | 计数 |
| 均值 | x̄ | ΣX / n |
| 总体标准差 | σx | √[Σ(X - x̄)² / n] |
| 样本标准差 | Sx | √[Σ(X - x̄)² / (n-1)] |
| 总和 | ΣX | ΣXi |
| 平方和 | ΣX² | ΣXi² |
| 最小值 | minX | min(Xi) |
| 最大值 | maxX | max(Xi) |

### 2.3 计算公式

**均值**：

```
x̄ = (X1 + X2 + ... + Xn) / n
```

**总体标准差**：

```
σx = √[(ΣXi² - (ΣXi)²/n) / n]
```

**样本标准差**：

```
Sx = √[(ΣXi² - (ΣXi)²/n) / (n-1)]
```

### 2.4 示例

```
数据: 10, 20, 30, 40, 50

n = 5
ΣX = 150
ΣX² = 100 + 400 + 900 + 1600 + 2500 = 5500

x̄ = 150 / 5 = 30

σx = √[(5500 - 150²/5) / 5] = √[(5500 - 4500) / 5] = √200 = 14.14

Sx = √[(5500 - 4500) / 4] = √250 = 15.81
```

---

## 3. 双变量统计 (2-V)

### 3.1 输入数据

```
(X1, Y1), (X2, Y2), ..., (Xn, Yn)
```

### 3.2 统计量

**X 变量**：

| 统计量 | 符号 | 公式 |
|--------|------|------|
| 均值 | x̄ | ΣX / n |
| 总体标准差 | σx | √[Σ(X - x̄)² / n] |
| 样本标准差 | Sx | √[Σ(X - x̄)² / (n-1)] |
| 总和 | ΣX | ΣXi |
| 平方和 | ΣX² | ΣXi² |

**Y 变量**：

| 统计量 | 符号 | 公式 |
|--------|------|------|
| 均值 | ȳ | ΣY / n |
| 总体标准差 | σy | √[Σ(Y - ȳ)² / n] |
| 样本标准差 | Sy | √[Σ(Y - ȳ)² / (n-1)] |
| 总和 | ΣY | ΣYi |
| 平方和 | ΣY² | ΣYi² |

**联合统计量**：

| 统计量 | 符号 | 公式 |
|--------|------|------|
| 乘积和 | ΣXY | ΣXiYi |
| 协方差 | Cov(X,Y) | Σ(Xi - x̄)(Yi - ȳ) / n |
| 相关系数 | r | Cov(X,Y) / (σx × σy) |

### 3.3 相关系数公式

```
r = [n×ΣXY - ΣX×ΣY] / √[(n×ΣX² - (ΣX)²) × (n×ΣY² - (ΣY)²)]
```

---

## 4. 线性回归 (LIN)

### 4.1 模型

```
Y = a + bX
```

### 4.2 参数计算

**斜率 b**：

```
b = [n×ΣXY - ΣX×ΣY] / [n×ΣX² - (ΣX)²]
```

**截距 a**：

```
a = ȳ - b×x̄
```

**相关系数 r**：

```
r = [n×ΣXY - ΣX×ΣY] / √[(n×ΣX² - (ΣX)²) × (n×ΣY² - (ΣY)²)]
```

### 4.3 预测

```
给定 X，预测 Y：
Y' = a + bX

给定 Y，预测 X：
X' = (Y - a) / b
```

### 4.4 示例

```
数据: (1,2), (2,4), (3,5), (4,4), (5,5)

n = 5
ΣX = 15, ΣY = 20
ΣX² = 55, ΣY² = 86
ΣXY = 1×2 + 2×4 + 3×5 + 4×4 + 5×5 = 66

b = (5×66 - 15×20) / (5×55 - 15²) = (330 - 300) / (275 - 225) = 30/50 = 0.6

a = 4 - 0.6×3 = 4 - 1.8 = 2.2

回归方程: Y = 2.2 + 0.6X

r = (330 - 300) / √[(275 - 225) × (86 - 80)] = 30 / √[50 × 6] = 30 / 17.32 = 0.87
```

---

## 5. 对数回归 (Ln)

### 5.1 模型

```
Y = a + b × ln(X)
```

### 5.2 转换方法

令 X' = ln(X)，则转换为线性回归：

```
Y = a + bX'
```

### 5.3 计算步骤

1. 计算 X' = ln(X) for all data points
2. 对 (X', Y) 进行线性回归
3. 得到 a 和 b

### 5.4 预测

```
Y' = a + b × ln(X)
X' = exp((Y - a) / b)
```

---

## 6. 指数回归 (EXP)

### 6.1 模型

```
Y = a × e^(bX)
```

### 6.2 转换方法

两边取对数：

```
ln(Y) = ln(a) + bX
```

令 Y' = ln(Y)，a' = ln(a)，则：

```
Y' = a' + bX
```

### 6.3 计算步骤

1. 计算 Y' = ln(Y) for all data points
2. 对 (X, Y') 进行线性回归
3. 得到 a' 和 b
4. a = exp(a')

### 6.4 预测

```
Y' = a × exp(bX)
X' = [ln(Y) - ln(a)] / b
```

---

## 7. 幂函数回归 (PWR)

### 7.1 模型

```
Y = a × X^b
```

### 7.2 转换方法

两边取对数：

```
ln(Y) = ln(a) + b × ln(X)
```

令 X' = ln(X)，Y' = ln(Y)，a' = ln(a)，则：

```
Y' = a' + bX'
```

### 7.3 计算步骤

1. 计算 X' = ln(X)，Y' = ln(Y) for all data points
2. 对 (X', Y') 进行线性回归
3. 得到 a' 和 b
4. a = exp(a')

### 7.4 预测

```
Y' = a × X^b
X' = (Y / a)^(1/b)
```

---

## 8. 验证测试用例

### 用例 1：单变量统计

```
数据: 85, 90, 78, 92, 88

期望输出：
n = 5
x̄ = 86.6
Sx = 5.77
σx = 5.16
ΣX = 433
ΣX² = 37557
```

### 用例 2：线性回归

```
数据: (1,1), (2,2), (3,3), (4,5), (5,8)

期望输出：
a = -1.1
b = 1.7
r = 0.96
回归方程: Y = -1.1 + 1.7X
```

### 用例 3：预测

```
基于用例2：

预测 X = 6:
Y' = -1.1 + 1.7×6 = 9.1

预测 Y = 10:
X' = (10 + 1.1) / 1.7 = 6.53
```

---

## 9. 实现建议

### 9.1 数据结构

```swift
struct StatsData {
    var xValues: [Decimal]
    var yValues: [Decimal]?
    var regressionType: RegressionType = .none
}

enum RegressionType {
    case none  // 1-V
    case linear
    case logarithmic
    case exponential
    case power
}
```

### 9.2 计算器类

```swift
class StatsCalculator {
    func calculate1V(_ xValues: [Decimal]) -> Stats1VResult
    func calculate2V(_ xValues: [Decimal], _ yValues: [Decimal]) -> Stats2VResult
    func fitLinearRegression(_ data: [(x: Decimal, y: Decimal)]) -> RegressionResult
    func predict(regression: RegressionResult, x: Decimal) -> Decimal
    func predictInverse(regression: RegressionResult, y: Decimal) -> Decimal
}

struct Stats1VResult {
    var n: Int
    var mean: Decimal
    var sampleStdDev: Decimal
    var populationStdDev: Decimal
    var sum: Decimal
    var sumOfSquares: Decimal
    var min: Decimal
    var max: Decimal
}

struct RegressionResult {
    var intercept: Decimal  // a
    var slope: Decimal      // b
    var correlation: Decimal  // r
    var type: RegressionType
}
```

---

## 10. 参考资料

- TI BA II Plus 官方手册（第 73-82 页）
- 《统计学》- 描述性统计与回归分析
- CFA Level 1 - Quantitative Methods 章节
