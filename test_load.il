;; ============================================================
;; 文件名: test_load.il
;; 功能说明: 测试加载脚本，用于验证工具箱安装
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 测试加载脚本 - 用于在Allegro命令行快速加载调试
;; 文件路径 : test_load.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Quick Test Loader for AllegroSkillToolbox
; Usage: In Allegro Command window, type:
;        skill load("D:/Users/Lenovo/Desktop/kimi-cli/AllegroSkillToolbox/test_load.il")
;--------------------------------------------------------------------------

; Add toolbox path to skill search path
setSkillPath(cons("D:/Users/Lenovo/Desktop/kimi-cli/AllegroSkillToolbox" getSkillPath()))  ;; 将元素添加到列表头部

; Load main framework
load("AllegroSkillToolbox/main.il")

; Optional: load Chinese command aliases
; load("AllegroSkillToolbox/config/chinese_cmd_map.cfg")

; After loading, toolbox menu appears under "AllegroSkillToolbox"
; Commands available:
;   AST_About           - Show version info
;   AST_Reload          - Reload all modules
;   AST_HotkeyList      - Show current hotkey bindings
;   AST_Uninstall       - Remove from allegro.ilinit
