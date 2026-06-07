;; ============================================================
;; 文件名: template_loader.il
;; 功能说明: 模板加载器，负责加载和管理表单模板
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 模板加载器 - 加载并应用叠层、约束、颜色等模板文件
;; 文件路径 : core/template_loader.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    template_loader.il
; Category:  core (framework)
; Purpose:   Load and apply template files (stackup, constraints, color, etc.)
; Commands:  AST_LoadTemplate(templateName)
;            AST_TemplateRegister(name path type)
;            AST_TemplateList()
; Source:    P2 framework — new capability
;--------------------------------------------------------------------------

; Template registry: table(name -> list(path type))
defvar(_AST_TemplateRegistry nil)  ;; 定义全局变量(仅首次赋值)

defvar(_AST_TemplateDir nil)  ;; 定义全局变量(仅首次赋值)

; Template types
defvar(_AST_TEMPLATE_TYPES '(  ;; 定义全局变量(仅首次赋值)
    ("stackup"      "*.stk"      "Technology file")
    ("constraints"  "*.dcfx"     "Constraint rule")
    ("color"        "*.col"      "Color scheme")
    ("shape"        "*.ssm"      "Shape symbol")
    ("pad"          "*.pad"      "Padstack")
    ("package"      "*.dra"      "Package drawing")
    ("script"       "*.scr"      "Allegro script")
    ("form"         "*.form"     "Form definition")
))

procedure( AST_TemplateInit()
    _AST_TemplateRegistry = makeTable('templateRegistry nil)  ;; 创建哈希表(table)用于键值存储
    _AST_TemplateDir = strcat(_AST_GetToolboxPath() "/templates")  ;; 连接字符串
    
    ; Auto-scan template directory
    when(isDir(_AST_TemplateDir)  ;; 检查指定路径是否为目录
        _AST_TemplateScanDir(_AST_TemplateDir)
    )
)

; Scan directory for templates by type
procedure( _AST_TemplateScanDir(dirPath)
    let((files f ext typeName)  ;; 绑定局部变量
        files = AST_GetFilesByExt(dirPath "*")
        foreach(f files  ;; 遍历列表中的每个元素
            ext = strrchr(f ".")
            when(ext  ;; 条件为真时执行
                typeName = _AST_TemplateGetType(ext)
                when(typeName  ;; 条件为真时执行
                    fullPath = strcat(dirPath "/" f)  ;; 连接字符串
                    _AST_TemplateRegistry[f] = list(fullPath typeName)
                )
            )
        )
    )
)

; Map extension to template type
procedure( _AST_TemplateGetType(ext)
    let((entry)  ;; 绑定局部变量
        entry = assoc(ext _AST_TEMPLATE_TYPES)
        when(entry cadr(entry))  ;; 条件为真时执行
    )
)

; Public: register a template
procedure( AST_TemplateRegister(name path type)
    when(isFile(path)  ;; 检查指定路径是否为文件
        _AST_TemplateRegistry[name] = list(path type)
        axlMsgPut("Registered template: %s (%s)" name type)  ;; 输出消息到Allegro命令窗口
    else
        axlMsgPut("ERROR: Template file not found: %s" path)  ;; 输出错误消息到命令窗口
    )
)

; Public: list available templates
procedure( AST_TemplateList()
    let((items)  ;; 绑定局部变量
        items = nil
        foreach(key _AST_TemplateRegistry  ;; 遍历列表中的每个元素
            info = _AST_TemplateRegistry[key]
            items = cons(list(key cadr(info) car(info)) items)  ;; 取列表第一个元素
        )
        reverse(items)
    )
)

; Public: load and apply a template
;   templateName — registered name
;   @optional target — design object to apply to
procedure( AST_LoadTemplate(templateName @optional target)
    prog((info path type result)  ;; 开始局部变量作用域块
        info = _AST_TemplateRegistry[templateName]
        unless(info  ;; 条件为假时执行
            axlMsgPut("ERROR: Template not found: %s" templateName)  ;; 输出错误消息到命令窗口
                        axlDisplayFlush()  ;; 刷新显示，更新画布
return(nil)  ;; 从当前函数返回
        )
        path = car(info)  ;; 取列表第一个元素
        type = cadr(info)  ;; 取列表第二个元素
        
        result = case(type
            ("Technology file"      _AST_TemplateApplyStackup(path))
            ("Constraint rule"      _AST_TemplateApplyConstraints(path))
            ("Color scheme"         _AST_TemplateApplyColor(path))
            ("Shape symbol"         _AST_TemplateApplyShape(path target))
            ("Padstack"             _AST_TemplateApplyPad(path target))
            ("Package drawing"      _AST_TemplateApplyPackage(path))
            ("Allegro script"       _AST_TemplateApplyScript(path))
            ("Form definition"      _AST_TemplateApplyForm(path))
            (t                     axlMsgPut("Unknown template type: %s" type))  ;; 输出消息到Allegro命令窗口
        )
        
        when(result  ;; 条件为真时执行
            axlMsgPut("Template applied: %s" templateName)  ;; 输出消息到Allegro命令窗口
        )
        result
    )
)

; Apply stackup technology file
procedure( _AST_TemplateApplyStackup(path)
    ;; 注意: axlShell 调用后所有 dbid 会失效，后续操作需重新获取
    axlShell(sprintf(nil "techfile in \"%s\"" path))  ;; 执行Allegro shell命令
    t
)

; Apply constraint rules
procedure( _AST_TemplateApplyConstraints(path)
    ;; 注意: axlShell 调用后所有 dbid 会失效，后续操作需重新获取
    axlShell(sprintf(nil "constraint import \"%s\"" path))  ;; 执行Allegro shell命令
    t
)

; Apply color scheme
procedure( _AST_TemplateApplyColor(path)
    ;; 注意: axlShell 调用后所有 dbid 会失效，后续操作需重新获取
    axlShell(sprintf(nil "color load \"%s\"" path))  ;; 执行Allegro shell命令
    t
)

; Apply shape symbol
procedure( _AST_TemplateApplyShape(path target)
    when(target  ;; 条件为真时执行
        axlDBCreateSymbol(path target->xy target->rotation)  ;; 创建符号(symbol)实例
        t
    )
)

; Apply padstack
procedure( _AST_TemplateApplyPad(path target)
    when(target  ;; 条件为真时执行
        axlDBChangePad(target path)
        t
    )
)

; Apply package drawing (open in new window)
procedure( _AST_TemplateApplyPackage(path)
    axlOpenDesign(?design path ?mode "r")  ;; 打开指定设计文件
    t
)

; Apply Allegro script
procedure( _AST_TemplateApplyScript(path)
    ;; 注意: axlShell 调用后所有 dbid 会失效，后续操作需重新获取
    axlShell(sprintf(nil "script \"%s\"" path))  ;; 执行Allegro shell命令
    t
)

; Apply form definition (just validate)
procedure( _AST_TemplateApplyForm(path)
    when(isFile(path)  ;; 检查指定路径是否为文件
        axlMsgPut("Form template ready: %s" path)  ;; 输出消息到Allegro命令窗口
        t
    )
)
