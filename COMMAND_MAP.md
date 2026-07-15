# Allegro SKILL Toolbox - Command Map

## 功能分类与命令对照表

### 布局 (Placement)
| 命令 | 功能 | 来源 |
|------|------|------|
| `place_by_sch` | 按原理图分页放置 | EDA365 |
| `auto_balance` | 自动平衡布局 | EDA365 |
| `L` | 单层/多层切换 | AXL-SKILL |

### 显示 (Display)
| 命令 | 功能 | 来源 |
|------|------|------|
| `FYCOL` | 颜色设置 | FANYI |

### 检查 (Check)
| 命令 | 功能 | 来源 |
|------|------|------|
| `ch_cross` | 检查位号交叉 | EDA365 |
| `Check_No_Refdes` | 检查无位号 | FANYI/EDA365 |
| `ch_text_overlap` | 检查文字重叠 | EDA365 |
| `ch_refdeslocate` | RefDes位置调整 | EDA365 |
| `ch_ref` | RefDes旋转调整 | EDA365 |

### 文本 (Text)
| 命令 | 功能 | 来源 |
|------|------|------|
| `Rename_Ref_Des` | 批量修改RefDes | EDA365 |
| `silkutils` | AutoSilk工具集 | EDA365 |
| `text_center_rout` | 快速文本居中 | EDA365 |
| `assembly` | 添加装配图位号 | EDA365 |

### 过孔 (Via)
| 命令 | 功能 | 来源 |
|------|------|------|
| `replace_via` | 替换/更新过孔 | EDA365 |
| `update_via` | 更新过孔 | EDA365 |
| `cvia` | 修改过孔网络 | EDA365 |

### 焊盘 (Pad)
| 命令 | 功能 | 来源 |
|------|------|------|
| `create_pad` | 创建焊盘 | EDA365 |

### 转换 (Conversion)
| 命令 | 功能 | 来源 |
|------|------|------|
| `brd_pads` | BRD转PADS | EDA365 |

### 输出 (Output)
| 命令 | 功能 | 来源 |
|------|------|------|
| `film_reorder` | Film重排序 | EDA365 |
| `ljj_camout` | CAM输出 | EDA365 |
| `ljj_camzip` | CAM打包 | EDA365 |
| `Quick_ExportARK` | 一键导出Gerber | EDA365 |

### 搜索 (Search)
| 命令 | 功能 | 来源 |
|------|------|------|
| `SearchStar` | 搜索器件/网络 | EDA365 |

## 使用说明

1. 将所有 .il 文件放入 Allegro 的 skill 目录
2. 在 allegro.ilinit 中添加加载命令
3. 重启 Allegro 即可使用
