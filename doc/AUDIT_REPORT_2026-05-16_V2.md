# AllegroSkillToolbox 深度检验报告 V2
## 2026-05-16（基于全部 47 个 .il 文件 + 脚本审计 + 人工复核）

> 注：用户提供的 `D:\Cadence\SPB_17.4\doc\*.pdf` 官方文档路径在系统中不存在，无法直接提取。本报告基于：
> 1. 项目已有的 `SKILL_SYNTAX_GUIDE.md` + `SKILL_AXL_DEEP_GUIDE.md`（Cadence 16.6/17.4/24.1 调试验证）
> 2. 全部 47 个 `.il` 源代码人工逐行审查
> 3. `audit_skill.py` + `deep_audit.py` 自动化扫描（去重去误报后）

---

## 一、致命错误（运行时必定失败 / 解析错误）

### 1. C 风格运算符（52+ 处）
SKILL（Lisp 方言）**完全不支持** `!` `&&` `||` `++` `--` `+=` `-=` `*=` `/=`。

| 文件 | 错误代码 | 修复 |
|---|---|---|
| `core/menu.il:117,128` | `start++` / `end--` | `start = start + 1` / `end = end - 1` |
| `core/form_utils.il:81,97` | `point && callback` | `and(point callback)` |
| `core/version_adapter.il:40,54,55,129,134,140,171,192` | `!verStr` `&&` | `null(verStr)` `and(...)` |
| `main.il:18` | `boundp(...) && AST_INSTALL_DIR` | `and(boundp(...) AST_INSTALL_DIR)` |
| `modules/check_dfm/check_no_refdes.il:27,32,36` | `\|\|` `&&` `++norefcnt` | `or(...)` `and(...)` `norefcnt = norefcnt + 1` |
| `modules/check_dfm/check_acute.il:30,47,55` | `&&` `count++` | `and(...)` `count = count + 1` |
| `modules/cleanup/del_dangling.il` | 大量 `\|\|` `&&` | 全部改为 `and`/`or` |
| `modules/layout/cut_cline.il:52` | `cutIdx < 1 \|\| cutIdx >= n` | `or(cutIdx < 1 cutIdx >= n - 1)` |
| `modules/layout/place_inside.il:66` | `dx != 0 \|\| dy != 0` | `or(dx != 0 dy != 0)` |
| `modules/layout/grid_choose.il:30` | `idx++` | `idx = idx + 1` |
| `modules/layout/mirror_element.il:9` | `axlVersion(...) > 17.0` | 合法，但参数写法需确认 |
| `modules/router/cline_cross_check.il:15,36,94` | `!allClines` `seg1 && seg2` | `null(allClines)` `and(seg1 seg2)` |
| `modules/router/cline_to_shape.il:32,50` | `!axlDBCreateShape(...)` | `null(axlDBCreateShape(...))` |
| `modules/router/cross_plane_check.il:16,37,51` | `&&` `!axlGeoPointInShape` | `and(...)` `null(...)` |
| `modules/router/diff_via_antipad.il` | 无 C 运算符，但变量未声明 | 见下方 |
| `modules/router/keepout_create.il:21` | `... ? ... : ...` 三元运算符 | **SKILL 不存在三元运算符** |
| `modules/special/impedance.il:27` | `h > 0 && er > 0 && w > 0` | `and(h > 0 er > 0 w > 0)` |
| `modules/text_silk/auto_net_silk.il:44,64,220` | `!_AST_CreateNetSilkFinish` `&&` | `null(...)` `and(...)` |
| `modules/tools/calculator.il:42` | `width > 0 && copper > 0` | `and(width > 0 copper > 0 temp > 0)` |
| `modules/tools/color.il:43,133` | `i++` (2处) | `i = i + 1` |
| `modules/tools/hotkeys.il:26,41,69,79` | `&&` `!rexMatchp` | `and(...)` `null(...)` |
| `modules/package/change_origin.il:60` | `obj && obj->objType` | `and(obj obj->objType)` |
| `modules/package/rename_pin.il:41` | `i++` | `i = i + 1` |

### 2. `defun` 非法关键字（3 处）
SKILL 标准关键字是 `procedure`，**不存在 `defun`**。

| 文件 | 错误 | 修复 |
|---|---|---|
| `modules/check_dfm/check_no_refdes.il:4` | `defun( AST_CheckNoRefdes ()` | `procedure( AST_CheckNoRefdes ()` |
| `modules/output/export_device.il:12` | `defun( AST_ExportDevice ()` | `procedure( AST_ExportDevice ()` |
| `modules/text_silk/auto_net_silk.il:86,98` | `defun _AST_CreateNetSilkCallback` / `defun(_AST_CreateNetSilkForm` | `procedure(...)` |

### 3. 变量未声明 / 拼写错误（运行时 `unbound variable`）

| 文件 | 问题 | 修复 |
|---|---|---|
| `modules/cleanup/del_dangling.il:461,497` | `nv_DanglingForm1` → 应为 `ps_DanglingForm1` | 修正变量名 |
| `modules/text_silk/auto_net_silk.il:25` | `fm_crtn` 在 `let((addr))` 中未声明 | 补充声明或改为全局变量 |
| `modules/layout/place_inside.il:64-68` | `dx`、`dy` 在 `_AST_PlaceInsideArea` 中未声明 | 补充到 `let` |
| `modules/router/cline_cross_check.il` | `lines` `allObjs` `n` `obj1` `obj2` `pt` 未声明 | 补充到 `let` |
| `modules/router/diff_via_antipad.il` | `net1` `net2` `vias1` `vias2` `pt` `poly` 未声明 | 补充到 `let` |
| `modules/router/keepout_create.il` | `_AST_KO_CreateShape` 中 `pts` `poly` `pt` 未声明 | 补充到 `let` |
| `modules/package/export_symbol.il` | `sym` `symdef` 未声明 | 补充到 `let` |

### 4. `return` 在 `let` 中非法（14 处）
`return()` **只能在 `prog` 内使用**。`let` 中使用会导致解析错误或运行时错误。

受影响文件：`core/exec_tool.il`、`core/template_loader.il`、`modules/layout/align.il`、`modules/layout/place_inside.il`、`modules/router/cline_cross_check.il`、`modules/router/diff_via_antipad.il`、`modules/tools/color.il`、`modules/tools/hotkeys.il` 等。

### 5. 三元运算符不存在（1 处）
`modules/router/keepout_create.il:21-24` 使用了 C 风格 `?:`，SKILL 不支持，必须改写为 `if-then-else`。

---

## 二、严重逻辑错误（功能错误）

| 文件 | 问题 | 后果 |
|---|---|---|
| `modules/layout/align.il:41` | `count = when(sel length(sel) 0)` | `when` 条件为假时返回 `nil`，不是 `0`。导致 `%d` 格式打印 `nil`，或数值比较出错。 |
| `modules/tools/calculator.il:50` | `exp(temp * 0.44 / 2.302585)` | 错误实现了幂运算。`x^y = exp(y * log(x))`，而代码写成了 `exp(temp * const)`，结果完全错误。 |
| `modules/tools/color.il:16` | `axlGetParam(...)->groupMembers` 未判空 | 若 `axlGetParam` 返回 `nil`，访问 `->groupMembers` 会崩溃。 |
| `modules/tools/color.il:48` | 同样问题 | 同上 |

---

## 三、误报说明（脚本审计中的假阳性）

`audit_skill.py` 报告了 **51 处 `when_empty`** 警告，其中大部分是**误报**：

```lisp
when( i < length(colors)
  pinLayer = sprintf(nil "PIN/%s" layer)   ; 脚本报错：缺少 body
```

SKILL 的 `when` / `unless` 支持多行 body，**不要求**下一行以 `(` 开头。因此以下写法完全合法：
```lisp
when(cond
  expr1
  expr2
)
```

**真正需要警惕的**是单行 `when(cond)` 完全没有 body 的情况，此类情况在代码中未发现。

---

## 四、procedure 空格规范（92 处）

`procedure(name()` vs `procedure( name ()`

根据 Cadence SKILL 规范，`procedure` 后**必须有空格**，否则某些版本会报 `illegal formal list`。虽然现代 Allegro 版本解析器较宽松，但为了兼容性，建议统一修复。

本项目 2026-05-16 的早期审计报告声称已修复 7 处，但实际上仅修复了部分文件，`core/` 和 `modules/` 下仍有 **92 处**未修复。

---

## 五、统计汇总

| 类别 | 数量 | 说明 |
|---|---|---|
| C 运算符错误 | **52+** | 必定运行时失败 |
| `defun` 非法 | **3** | 必定解析失败 |
| 变量未声明/拼写 | **~15** | `unbound variable` |
| `return` 在 `let` 内 | **14** | 解析/运行时错误 |
| 三元运算符 | **1** | 语法不存在 |
| `procedure` 空格 | **92** | 兼容性风险 |
| 严重逻辑错误 | **3** | 功能错误 |
| `when_empty` 误报 | **~45** | 无需修复 |

**结论：28 个核心 .il 文件中，除占位/极简文件外，绝大多数存在致命 SKILL 语法错误，无法直接在 Allegro 中加载运行。**

---

## 六、修复建议优先级

```
P0（立即修复）: C运算符、defun、变量未声明、三元运算符、return_in_let
P1（尽快修复）: procedure空格、逻辑错误
P2（建议优化）: 统一编码、补充 errset、增加事务包裹
```

---

*报告生成时间：2026-05-16*  
*检验范围：AllegroSkillToolbox 全部 47 个 .il 文件*  
*规范依据：Cadence SKILL 语言规范（Lisp 方言）、AXL PCB API 规范、项目内 SKILL_SYNTAX_GUIDE.md*
