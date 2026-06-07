# 编码格式说明 - AllegroSkillToolbox

## 重要提示

本项目所有代码文件统一使用 **GBK (简体中文)** 编码格式保存。

## 为什么使用GBK编码

1. **Cadence Allegro 兼容性**: Allegro SKILL 环境对中文支持以GBK编码最为稳定
2. **中文注释支持**: 确保中文注释和字符串在Allegro中正确显示
3. **团队协作统一**: 避免不同编码导致的乱码问题

## 编辑器配置指南

### VS Code (推荐)

本项目已配置 `.vscode/settings.json`，打开项目后自动使用GBK编码：

- 默认文件编码: GBK
- 自动识别编码: 已关闭（强制使用GBK）

如需手动设置：
1. 打开 VS Code
2. 按 `Ctrl+Shift+P` 打开命令面板
3. 输入 `Preferences: Open User Settings (JSON)`
4. 添加以下配置：

```json
{
    "files.encoding": "gbk",
    "files.autoGuessEncoding": false
}
```

### Notepad++

1. 打开文件
2. 菜单栏: `编码` -> `转为 ANSI 编码` (GBK属于ANSI编码)
3. 保存文件

设置默认编码：
1. `设置` -> `首选项` -> `新建`
2. 编码选择 `ANSI (GBK)`

### Sublime Text

1. 打开文件
2. `File` -> `Set Encoding` -> `Chinese Simplified (GBK)`
3. 保存文件

安装插件支持：
1. 安装 `ConvertToUTF8` 插件
2. 安装 `GBK Encoding Support` 插件

### UltraEdit

1. `高级` -> `设置` -> `文件处理` -> `编码`
2. 默认编码选择 `GBK/GB2312`

### Emacs

在文件头部添加：
```
-*- coding: gbk -*-
```

### Vim

在 `.vimrc` 中添加：
```vim
set fileencodings=gbk,utf-8,gb2312
set fileencoding=gbk
set encoding=gbk
```

## 文件列表

所有以下类型的文件均使用GBK编码：

- `.il` - Allegro SKILL 脚本文件
- `.ilinit` - Allegro 初始化文件
- `.form` - Allegro 表单定义文件
- `.cfg` - 配置文件
- `.py` - Python 脚本
- `.js` - JavaScript 文件
- `.html` - HTML 文件
- `.css` - CSS 文件
- `.json` - JSON 配置文件
- `.xml` - XML 文件
- `.yaml` / `.yml` - YAML 配置文件
- `.md` - Markdown 文档
- `.txt` - 文本文件
- `.sh` - Shell 脚本
- `.bat` / `.cmd` - Windows 批处理文件
- `.ps1` - PowerShell 脚本
- `.sql` - SQL 脚本
- `.c` / `.cpp` / `.h` / `.hpp` - C/C++ 源文件
- `.java` - Java 源文件
- `.cs` - C# 源文件
- `.go` - Go 源文件
- `.rs` - Rust 源文件
- `.php` - PHP 脚本
- `.rb` - Ruby 脚本
- `.swift` - Swift 源文件
- `.kt` - Kotlin 源文件
- `.scala` - Scala 源文件
- `.r` - R 脚本
- `.m` / `.mm` - Objective-C 源文件

## 常见问题

### Q: 打开文件出现乱码怎么办？
A: 请确保编辑器使用 **GBK** 编码打开文件，不要用 UTF-8。

### Q: 如何批量转换文件编码？
A: 使用本项目提供的 Python 脚本或编辑器批量转换功能。

### Q: Git 提交时编码会改变吗？
A: Git 不会修改文件编码，但建议在 `.gitattributes` 中声明编码：
```
*.il text working-tree-encoding=GBK
*.form text working-tree-encoding=GBK
```

### Q: 在Linux/Mac上开发怎么办？
A: 现代Linux和Mac系统都支持GBK编码，只需在编辑器中正确设置即可。

## 技术支持

如有编码相关问题，请联系项目维护团队。

---

**最后更新**: 2025年
**项目**: AllegroSkillToolbox
**编码标准**: GBK (简体中文)
