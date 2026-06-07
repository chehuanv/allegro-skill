;; ============================================================
;; 文件名: exec_tool.il
;; 功能说明: 工具执行引擎，负责调用各功能模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 外部工具调用 - 在Allegro设计上下文环境中调用外部可执行程序
;; 文件路径 : core/exec_tool.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    exec_tool.il
; Category:  core (framework)
; Purpose:   Call external executables with Allegro design context
; Commands:  AST_ExecTool(toolName @optional args)
;            AST_ExecToolRegister(toolName exePath)
; Source:    P2 framework — new capability
;--------------------------------------------------------------------------

; Registry of external tools: table(toolName -> exePath)
defvar(_AST_ExecToolRegistry nil)  ;; 定义全局变量(仅首次赋值)

defvar(_AST_ExecToolWorkDir nil)  ;; 定义全局变量(仅首次赋值)

procedure( AST_ExecToolInit()
    _AST_ExecToolRegistry = makeTable('execRegistry nil)  ;; 创建哈希表(table)用于键值存储
    _AST_ExecToolWorkDir = axlTempDirectory()  ;; 获取临时目录路径
    
    ; Auto-register known tools from FanySkill bin/
    _AST_ExecToolRegisterKnown()
)

; Register known external tools bundled with FanySkill
procedure( _AST_ExecToolRegisterKnown()
    let((binDir)  ;; 绑定局部变量
        ; Look for FanySkill bin directory near the toolbox
        binDir = strcat(_AST_GetToolboxPath() "/../bin")  ;; 连接字符串
        when(isDir(binDir)  ;; 检查指定路径是否为目录
            ; DFMOpen.exe — DFM analysis tool
            when(isFile(strcat(binDir "/DFMOpen.exe"))  ;; 连接字符串
                _AST_ExecToolRegistry["DFMOpen"] = strcat(binDir "/DFMOpen.exe")  ;; 连接字符串
            )
            ; GhostScript (if bundled)
            when(isFile(strcat(binDir "/gswin64.exe"))  ;; 连接字符串
                _AST_ExecToolRegistry["GhostScript"] = strcat(binDir "/gswin64.exe")  ;; 连接字符串
            )
            when(isFile(strcat(binDir "/gswin32.exe"))  ;; 连接字符串
                _AST_ExecToolRegistry["GhostScript"] = strcat(binDir "/gswin32.exe")  ;; 连接字符串
            )
        )
    )
)

; Public: register a custom external tool
procedure( AST_ExecToolRegister(toolName exePath)
    when(isFile(exePath)  ;; 检查指定路径是否为文件
        _AST_ExecToolRegistry[toolName] = exePath
        axlMsgPut("Registered external tool: %s -> %s" toolName exePath)  ;; 输出消息到Allegro命令窗口
    else
        axlMsgPut("ERROR: Tool not found: %s" exePath)  ;; 输出错误消息到命令窗口
    )
)

; Public: execute a registered tool
;   toolName — key in registry
;   args     — list of string arguments
;   design   — t = pass current .brd path as first arg
; Returns: command output string
procedure( AST_ExecTool(toolName @optional args design)
    prog((exePath cmdLine resultFile cmdStr output)  ;; 开始局部变量作用域块
        exePath = _AST_ExecToolRegistry[toolName]
        unless(exePath  ;; 条件为假时执行
            axlMsgPut("ERROR: Tool not registered: %s" toolName)  ;; 输出错误消息到命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        ; Build command line
        cmdLine = exePath
        when(design  ;; 条件为真时执行
            cmdLine = strcat(cmdLine " \"" axlCurrentDesign() "\"")  ;; 连接字符串
        )
        when(args  ;; 条件为真时执行
            foreach(arg args  ;; 遍历列表中的每个元素
                cmdLine = strcat(cmdLine " \"" arg "\"")  ;; 连接字符串
            )
        )
        
        ; Redirect output to temp file
        resultFile = axlTempFile()
        cmdStr = sprintf(nil "%s > \"%s\" 2>&1" cmdLine resultFile)  ;; 格式化字符串
        
        ; Execute via shell
        ;; 注意: axlShell 调用后所有 dbid 会失效，后续操作需重新获取
    axlShell(cmdStr)  ;; 执行Allegro shell命令
        
        ; Read output
        when(isFile(resultFile)  ;; 检查指定路径是否为文件
            output = AST_ReadLines(resultFile)
            deleteFile(resultFile)
        )
        
        axlMsgPut("Executed: %s" toolName)  ;; 输出消息到Allegro命令窗口
        output
    )
)

; Convenience: run DFMOpen on current design
procedure( AST_ExecDFMOpen()
    AST_ExecTool("DFMOpen" nil t)
)

; Convenience: run GhostScript to convert PostScript to PDF
procedure( AST_ExecGhostScript(psFile pdfFile @optional args)
    let((gsArgs)  ;; 绑定局部变量
        gsArgs = cons("-dNOPAUSE" (cons "-dBATCH" (cons "-sDEVICE=pdfwrite"   ;; 将元素添加到列表头部
            (cons strcat("-sOutputFile=" pdfFile) args))))  ;; 连接字符串
        gsArgs = cons(psFile gsArgs)  ;; 将元素添加到列表头部
        AST_ExecTool("GhostScript" gsArgs nil)
    )
)
