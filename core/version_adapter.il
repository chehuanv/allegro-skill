;; ============================================================
;; 文件名: version_adapter.il
;; 功能说明: 版本适配器，处理不同Allegro版本的兼容性
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 版本适配器 - 自动检测Allegro版本并选择兼容的API和路径
;; 文件路径 : core/version_adapter.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    version_adapter.il
; Category:  core (framework)
; Purpose:   Auto-detect Allegro version and select compatible APIs/paths
; Commands:  AST_GetAllegroVersion()
;            AST_VersionAdapt(funcName @optional args)
;            AST_LibPathForVersion()
; Source:    P2 framework — new capability
;--------------------------------------------------------------------------

; Supported version tiers
defvar(_AST_VERSION_TIERS '(  ;; 定义全局变量(仅首次赋值)
    ("16.6" 16.6  "legacy")
    ("17.2" 17.2  "stable")
    ("17.4" 17.4  "current")
    ("23.1" 23.1  "modern")
    ("24.1" 24.1  "latest")
))

; Current detected version
defvar(_AST_DetectedVersion nil)  ;; 定义全局变量(仅首次赋值)
defvar(_AST_DetectedVerNum nil)  ;; 定义全局变量(仅首次赋值)
defvar(_AST_DetectedTier nil)  ;; 定义全局变量(仅首次赋值)

; API compatibility table: funcName -> list((minVer maxVer skillExpr))
defvar(_AST_APICompat nil)  ;; 定义全局变量(仅首次赋值)

procedure( AST_VersionInit()
    _AST_DetectVersion()
    _AST_APICompat = makeTable('apiCompat nil)  ;; 创建哈希表(table)用于键值存储
    _AST_RegisterCompatFuncs()
    axlMsgPut("Allegro version detected: %s (tier: %s)" _AST_DetectedVersion _AST_DetectedTier)  ;; 输出消息到Allegro命令窗口
)

; Detect Allegro version from axlVersion() or env
procedure( _AST_DetectVersion()
    let((verStr verNum tier)  ;; 绑定局部变量
        ; Try axlVersion first
        verStr = axlVersion('str)  ;; 获取Allegro版本信息
        when(null(verStr)  ;; 条件为真时执行
            ; Fallback: check CDSROOT env
            verStr = getenv("CDS_PRODUCT_VER")
        )
        
        when(verStr  ;; 条件为真时执行
            ; Parse "17.4-sxxx" or "16.6" etc
            verNum = atof(verStr)  ;; 字符串转浮点数
            _AST_DetectedVersion = verStr
            _AST_DetectedVerNum = verNum
            
            ; Determine tier
            tier = "unknown"
            when(verNum < 17.0  tier = "legacy")  ;; 条件为真时执行
            when(and(verNum >= 17.0 verNum < 23.0)  tier = "stable")  ;; 条件为真时执行
            when(and(verNum >= 23.0 verNum < 24.0)  tier = "modern")  ;; 条件为真时执行
            when(verNum >= 24.0  tier = "latest")  ;; 条件为真时执行
            _AST_DetectedTier = tier
        )
        
        unless(_AST_DetectedVersion  ;; 条件为假时执行
            _AST_DetectedVersion = "unknown"
            _AST_DetectedVerNum = 0.0
            _AST_DetectedTier = "unknown"
        )
    )
)

; Register API compatibility entries
procedure( _AST_RegisterCompatFuncs()
    ; axlTransformObject — mirror param added in 17.0
    _AST_APICompat["TransformMirror"] = '(
        (0   16.999 "axlTransformObject(obj ?move delta)")  ;; 移动对象到指定位置
        (17.0 99.999 "axlTransformObject(obj ?mirror t ?origin pt ?move delta)")  ;; 移动对象到指定位置
    )
    
    ; axlDBCreateShape — different signatures across versions
    _AST_APICompat["CreateShape"] = '(
        (0   16.999 "axlDBCreateShape(poly t layer)")  ;; 创建shape(铜皮/填充区域)
        (17.0 99.999 "axlDBCreateShape(poly t layer nil)")  ;; 创建shape(铜皮/填充区域)
    )
    
    ; Transaction undo support
    _AST_APICompat["TransactionUndo"] = '(
        (0   16.999 "axlDBTransactionStart()")  ;; 开始数据库事务，支持撤销操作
        (17.0 99.999 "axlDBTransactionStart(?name \"ast\")")  ;; 开始数据库事务，支持撤销操作
    )
    
    ; Form creation — gensym vs symbol
    _AST_APICompat["FormCreate"] = '(
        (0   16.999 "axlFormCreate(gensym() formFile args callback)")  ;; 创建Allegro表单窗口
        (17.0 99.999 "axlFormCreate(gensym() formFile args callback t)")  ;; 创建Allegro表单窗口
    )
    
    ; Library path suffix
    _AST_APICompat["LibSuffix"] = '(
        (0   16.999 "16.6")
        (17.0 17.299 "17.2")
        (17.3 17.499 "17.4")
        (23.0 23.999 "23.1")
        (24.0 99.999 "24.1")
    )
)

; Public: get detected version string
procedure( AST_GetAllegroVersion()
    _AST_DetectedVersion
)

; Public: get version tier
procedure( AST_GetVersionTier()
    _AST_DetectedTier
)

; Public: adapt function call for current version
; Returns the compatible SKILL expression as a string
procedure( AST_VersionAdapt(funcName @optional args)
    prog((entries entry expr)  ;; 开始局部变量作用域块
        entries = _AST_APICompat[funcName]
        unless(entries  ;; 条件为假时执行
            axlMsgPut("WARNING: No compat entry for %s" funcName)  ;; 输出警告消息到命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        expr = nil
        foreach(entry entries  ;; 遍历列表中的每个元素
            minV = car(entry)  ;; 取列表第一个元素
            maxV = cadr(entry)  ;; 取列表第二个元素
            skillExpr = caddr(entry)  ;; 取列表第三个元素
            when(and(_AST_DetectedVerNum >= minV _AST_DetectedVerNum <= maxV)  ;; 条件为真时执行
                expr = skillExpr
            )
        )
        
        when(null(expr)  ;; 条件为真时执行
            ; Fallback to last entry (most recent)
            expr = caddr(car(reverse(entries)))  ;; 取列表第一个元素
        )
        
        ; Substitute args if provided
        when(and(args expr)  ;; 条件为真时执行
            foreach(pair args  ;; 遍历列表中的每个元素
                placeholder = car(pair)  ;; 取列表第一个元素
                value = cadr(pair)  ;; 取列表第二个元素
                expr = strreplace(expr placeholder value)
            )
        )
        
        expr
    )
)

; Public: get library path suffix for current version
; Example: returns "17.4" so toolbox can load AllegroSkillToolbox/lib/17.4/
procedure( AST_LibPathForVersion()
    prog((expr)  ;; 开始局部变量作用域块
        expr = AST_VersionAdapt("LibSuffix")
        when(expr return(expr))  ;; 条件为真时执行
        return("current")  ;; 从当前函数返回
    )
)

; Public: check if current version supports a feature
procedure( AST_VersionSupports(featureName)
    prog((entries entry supported)  ;; 开始局部变量作用域块
        entries = _AST_APICompat[featureName]
        unless(entries         axlDisplayFlush()  ;; 刷新显示，更新画布
return(nil))  ;; 条件为假时执行
        
        supported = nil
        foreach(entry entries  ;; 遍历列表中的每个元素
            minV = car(entry)  ;; 取列表第一个元素
            maxV = cadr(entry)  ;; 取列表第二个元素
            when(and(_AST_DetectedVerNum >= minV _AST_DetectedVerNum <= maxV)  ;; 条件为真时执行
                supported = t
            )
        )
        supported
    )
)

; Public: load version-specific module if available
;   basePath — e.g. "modules/router/keepout_create"
; Tries: keepout_create_17.4.il, keepout_create_17.2.il, keepout_create.il
procedure( AST_LoadVersionedModule(basePath)
    let((verSuffix paths pathToLoad)  ;; 绑定局部变量
        verSuffix = AST_LibPathForVersion()
        paths = list(
            strcat(basePath "_" verSuffix ".il")  ;; 连接字符串
            strcat(basePath ".il")  ;; 连接字符串
        )
        
        pathToLoad = nil
        foreach(p paths  ;; 遍历列表中的每个元素
            when(and(isFile(p) null(pathToLoad))  ;; 检查指定路径是否为文件
                pathToLoad = p
            )
        )
        
        when(pathToLoad  ;; 条件为真时执行
            errset(load(pathToLoad) t)
            axlMsgPut("Loaded versioned module: %s" pathToLoad)  ;; 输出消息到Allegro命令窗口
            t
        else
            axlMsgPut("WARNING: No compatible module found for %s (ver %s)" basePath verSuffix)  ;; 输出警告消息到命令窗口
            nil
        )
    )
)
