
## 第一層：語法樹（AST）是語言的神經骨架

當你寫下這樣一段 Cairo 程式：

```
fn double(x: u32) -> u32 {
    x * 2
}
```

Scarb 呼叫 Cairo 編譯器的第一步，是將這段文字**解析為語法樹（Abstract Syntax Tree）**：

這棵語法樹的邏輯形狀如下：

```
FunctionDef
├── name: "double"
├── params:
│   └── Param(name: "x", type: u32)
├── return_type: u32
└── body:
    └── Return(
        └── BinaryOp(
            ├── Var("x")
            ├── Op(*)
            └── Literal(2)
        )
    )

```

這棵樹是為了讓電腦在每一層都知道：這不是字串，而是**語意節點**。這些節點會被編譯器進一步轉換成一種中繼表示。

## 第二層：CIR（Cairo Intermediate Representation）是語法邏輯的邊界圖

接下來，這棵語法樹會轉換為 CIR，一種控制流導向的語義表示形式：

```
double(x: u32):
    %0 = const 2
    %1 = x * %0
    return %1

```

這像是一種無機體的 assembly，但它不是為了執行，而是為了下一步：**生成 constraint 的參考模板**。

## 第三層：Execution Trace Table 是行為的全息紀錄

**Trace Table** 是 Cairo 的核心哲學所在：每一行程式碼、每一次運算，都會被記錄成一個 **代數矩陣**。舉個例子：

假設你在主函數中呼叫 `double(5)`，那這一整個 trace 可能是這樣的：

|cycle|reg_x|reg_const|reg_mul|pc|opcode|
|---|---|---|---|---|---|
|0|5|2|10|0|MUL|
|1|10|-|-|1|RET|

這張表格是為了讓 prover（證明者）可以將每一步的操作，對應為一條代數等式。

## 第四層：Constraint System 是邏輯等式的宇宙語法

基於上面的 trace，Cairo 會產生以下等式（多項式 constraints）：

```
∀ i: reg_mul(i) = reg_x(i) * reg_const(i)
∀ i: reg_const(i) = 2

```

這些是代數真理。只要這些等式在整個 trace 中都成立，那麼我們就說：

> **「這段程式碼是誠實的，且行為與宣稱一致。」**

這時 Cairo prover 就可以產生一份**可驗證但不洩漏內容**的證明。

## 實際體驗：用工具生成 Cairo trace（使用 cairo-vm）

如果你想**實際看到 trace**，我們可以用以下流程：

### 安裝 cairo-vm（或用線上工具）

你可以在你的終端安裝：
`pip install cairo-lang

在你的專案目錄下建立一個檔案命名為：double.cairo
```
fn double(x: u32) -> u32 {
    x * 2
}

fn main() -> u32 {
    double(5)
}
```

接著執行以下指令來將你的 Cairo 程式轉換成 `.json` 格式：
`cairo-compile double.cairo --output double.json
`
然後執行一段程式：
`cairo-run --program=double.json --print_output --trace_file=trace.bin

這個 trace.bin 就是你剛才看到的行為矩陣，它可以被轉換成一張表或送進 prover 裡。


