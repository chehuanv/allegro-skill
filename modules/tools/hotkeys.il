;; ============================================================
;; 文件名: hotkeys.il
;; 功能说明: 通用工具 - 快捷键管理模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 辅助工具-热键管理 - AllegroSkillToolbox的多模式热键管理器
;; 文件路径 : modules/tools/hotkeys.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    hotkeys.il
; Category:  tools
; Purpose:   Multi-mode hotkey manager for AllegroSkillToolbox
; Commands:  AST_Tools_Hotkeys, AST_HotkeyMode_*, AST_HotkeyList
; Source:    P2 framework — new capability
;--------------------------------------------------------------------------

axlCmdRegister("AST_Tools_Hotkeys"    'AST_Tools_Hotkeys    ?cmdType "general")  ;; 注册热键管理器命令
axlCmdRegister("AST_HotkeyMode_default"  'AST_HotkeyMode_default  ?cmdType "general")
axlCmdRegister("AST_HotkeyMode_layout"   'AST_HotkeyMode_layout   ?cmdType "general")
axlCmdRegister("AST_HotkeyMode_router"   'AST_HotkeyMode_router   ?cmdType "general")
axlCmdRegister("AST_HotkeyMode_check"    'AST_HotkeyMode_check    ?cmdType "general")
axlCmdRegister("AST_HotkeyMode_text"     'AST_HotkeyMode_text     ?cmdType "general")
axlCmdRegister("AST_HotkeyList"          'AST_HotkeyList          ?cmdType "general")

defvar(_AST_HotkeyMode "default")  ;; 定义全局变量(仅首次赋值)
defvar(_AST_HotkeyTable nil)  ;; 定义全局变量(仅首次赋值)
defvar(_AST_HotkeyGlobal nil)  ;; 定义全局变量(仅首次赋值)

;------------------------------------------------------------------------
; Load hotkey config from file
;------------------------------------------------------------------------
;;=========================================================================
;; 热键管理主函数
;; 功能说明: AllegroSkillToolbox的多模式热键管理器
;; 支持模式: default(默认)、layout(布局)、router(布线)、check(检查)、text(丝印)
;; 命令列表:
;;   AST_Tools_Hotkeys         - 打开热键管理器
;;   AST_HotkeyMode_default    - 切换到默认模式
;;   AST_HotkeyMode_layout     - 切换到布局模式
;;   AST_HotkeyMode_router     - 切换到布线模式
;;   AST_HotkeyMode_check      - 切换到检查模式
;;   AST_HotkeyMode_text       - 切换到丝印模式
;;   AST_HotkeyList            - 显示当前热键绑定
;; 使用方式: 在Allegro命令行输入对应命令执行
;;=========================================================================

procedure( AST_LoadHotkeys()
    prog((cfgFile port line)  ;; 开始局部变量作用域块
        unless(and(boundp('AST_GLOBAL) AST_GLOBAL)  ;; 条件为假时执行
            axlMsgPut("AST_GLOBAL not initialized. Cannot load hotkeys.")  ;; 输出消息到Allegro命令窗口
            return(nil)  ;; 从当前函数返回
        )
        cfgFile = strcat(AST_GLOBAL->ConfigPath "/hotkeys.cfg")  ;; 连接字符串
        unless(isFile(cfgFile)  ;; 检查指定路径是否为文件
            axlMsgPut("Hotkey config not found: %s" cfgFile)  ;; 输出消息到Allegro命令窗口
            return(nil)  ;; 从当前函数返回
        )
        _AST_HotkeyTable = makeTable('hotkeyTable nil)  ;; 创建哈希表(table)用于键值存储
        _AST_HotkeyGlobal = nil
        
        port = infile(cfgFile)  ;; 打开输入文件用于读取
        while(gets(line port)
            line = AST_StringTrim(line)
            when(and(line null(rexMatchp("^#" line)) null(rexMatchp("^$" line)))  ;; 正则表达式匹配检查
                _AST_ParseHotkeyLine(line)
            )
        )
        close(port)  ;; 关闭文件端口
        axlMsgPut("Hotkeys loaded. Current mode: %s" _AST_HotkeyMode)  ;; 输出消息到Allegro命令窗口
    )
)

procedure( _AST_ParseHotkeyLine(line)
    prog((mode key cmd pos1 pos2 rest cmdPart)  ;; 开始局部变量作用域块
        line = AST_StringTrim(line)
        when(line == "" return(nil))  ;; 条件为真时执行
        
        pos1 = strindex(line "::")
        unless(pos1 return(nil))  ;; 条件为假时执行
        
        mode = AST_StringTrim(substring(line 1 pos1 - 1))
        rest = AST_StringTrim(substring(line pos1 + 2 strlen(line)))
        
        pos2 = strindex(rest "=")
        unless(pos2 return(nil))  ;; 条件为假时执行
        
        key = AST_StringTrim(substring(rest 1 pos2 - 1))
        cmdPart = AST_StringTrim(substring(rest pos2 + 1 strlen(rest)))
        
        ; Strip surrounding quotes
        when(strlen(cmdPart) >= 2  ;; 条件为真时执行
            when(and(substring(cmdPart 1 1) == "\""   ;; 条件为真时执行
                 substring(cmdPart strlen(cmdPart) strlen(cmdPart)) == "\""
                cmdPart = substring(cmdPart 2 strlen(cmdPart) - 1)
            ))
        )
        cmd = cmdPart
        
        when(mode == "__global__"  ;; 条件为真时执行
            _AST_HotkeyGlobal = cons(list(key cmd) _AST_HotkeyGlobal)  ;; 将元素添加到列表头部
        else
            when(null(_AST_HotkeyTable[mode])  ;; 条件为真时执行
                _AST_HotkeyTable[mode] = nil
            )
            _AST_HotkeyTable[mode] = cons(list(key cmd) _AST_HotkeyTable[mode])  ;; 将元素添加到列表头部
        )
    )
)

;------------------------------------------------------------------------
; Apply hotkeys for a given mode
;------------------------------------------------------------------------
procedure( AST_ApplyHotkeys(mode)
    let((bindings)  ;; 绑定局部变量
        ; Clear previous mode-specific keys (optional — Allegro funckeys persist)
        ; Apply new mode bindings
        bindings = _AST_HotkeyTable[mode]
        when(bindings  ;; 条件为真时执行
            foreach(pair bindings  ;; 遍历列表中的每个元素
                key = car(pair)  ;; 取列表第一个元素
                cmd = cadr(pair)  ;; 取列表第二个元素
                sprintf(expr "funckey %s %s" key cmd)  ;; 格式化字符串
                ;; 注意: axlShell 调用后所有 dbid 会失效，后续操作需重新获取
    axlShell(expr)  ;; 执行Allegro shell命令
            )
        )
        ; Always apply global bindings
        foreach(pair _AST_HotkeyGlobal  ;; 遍历列表中的每个元素
            key = car(pair)  ;; 取列表第一个元素
            cmd = cadr(pair)  ;; 取列表第二个元素
            sprintf(expr "funckey %s %s" key cmd)  ;; 格式化字符串
            ;; 注意: axlShell 调用后所有 dbid 会失效，后续操作需重新获取
    axlShell(expr)  ;; 执行Allegro shell命令
        )
        _AST_HotkeyMode = mode
        axlMsgPut("Hotkey mode switched to: %s" mode)  ;; 输出消息到Allegro命令窗口
    )
)

;------------------------------------------------------------------------
; Mode switch commands
;------------------------------------------------------------------------
procedure( AST_HotkeyMode_default() AST_ApplyHotkeys("default"))
procedure( AST_HotkeyMode_layout()  AST_ApplyHotkeys("layout"))
procedure( AST_HotkeyMode_router()  AST_ApplyHotkeys("router"))
procedure( AST_HotkeyMode_check()   AST_ApplyHotkeys("check"))
procedure( AST_HotkeyMode_text()    AST_ApplyHotkeys("text"))

;------------------------------------------------------------------------
; List current bindings
;------------------------------------------------------------------------
procedure( AST_HotkeyList()
    let((bindings)  ;; 绑定局部变量
        axlMsgPut("=== Current hotkey mode: %s ===" _AST_HotkeyMode)  ;; 输出消息到Allegro命令窗口
        bindings = _AST_HotkeyTable[_AST_HotkeyMode]
        when(bindings  ;; 条件为真时执行
            foreach(pair bindings  ;; 遍历列表中的每个元素
                axlMsgPut("  %s -> %s" car(pair) cadr(pair))  ;; 输出消息到Allegro命令窗口
            )
        )
        axlMsgPut("=== Global bindings ===")  ;; 输出消息到Allegro命令窗口
        foreach(pair _AST_HotkeyGlobal  ;; 遍历列表中的每个元素
            axlMsgPut("  %s -> %s" car(pair) cadr(pair))  ;; 输出消息到Allegro命令窗口
        )
    )
)

;------------------------------------------------------------------------
; Main entry — load and apply default
;------------------------------------------------------------------------
procedure( AST_Tools_Hotkeys()
    AST_LoadHotkeys()
    AST_ApplyHotkeys("default")
)
