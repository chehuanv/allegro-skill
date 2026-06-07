;; ============================================================
;; 文件名: main.il
;; 功能说明: AllegroSkillToolbox 主入口文件
;; 作者: AllegroSkillToolbox 开发团队
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 主框架入口 - 初始化环境、扫描加载模块、注册菜单和热键
;; 文件路径 : main.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  AllegroSkillToolbox - Main Framework                                                #
#  Architecture: auto-discovery | modular loader | config-driven menu | hotkey mgr     #
#########################################################################################
*/

;;=========================================================================
;; 1. Global Environment & Path Discovery
;;=========================================================================
procedure( AST_InitEnv()
  prog((installPath paths)  ;; 开始局部变量作用域块
    unless( boundp('AST_GLOBAL)  ;; 条件为假时执行
      defvar(AST_GLOBAL ncons(nil))  ;; 定义全局变量(仅首次赋值)
    )
    
    ;; Priority 1: path passed from allegro.ilinit via AST_INSTALL_DIR
    if( and(boundp('AST_INSTALL_DIR) AST_INSTALL_DIR)  ;; 条件分支判断
    then
      installPath = AST_INSTALL_DIR
    else
      ;; Priority 2: find the path that contains AllegroSkillToolbox/main.il
      paths = getSkillPath()
      foreach( p paths  ;; 遍历列表中的每个元素
        when( isFile(strcat(p "/AllegroSkillToolbox/main.il"))  ;; 连接字符串
          installPath = p
        )
      )
    )
    
    ;; Fallback: current working directory
    unless( installPath  ;; 条件为假时执行
      installPath = getWorkingDir()  ;; 获取当前工作目录
    )
    
    AST_GLOBAL->InstallPath = axlOSSlash(installPath)
    AST_GLOBAL->ToolboxPath = strcat(AST_GLOBAL->InstallPath "/AllegroSkillToolbox")  ;; 连接字符串
    AST_GLOBAL->CorePath    = strcat(AST_GLOBAL->ToolboxPath "/core")  ;; 连接字符串
    AST_GLOBAL->ModulePath  = strcat(AST_GLOBAL->ToolboxPath "/modules")  ;; 连接字符串
    AST_GLOBAL->FormPath    = strcat(AST_GLOBAL->ToolboxPath "/forms")  ;; 连接字符串
    AST_GLOBAL->IconPath    = strcat(AST_GLOBAL->ToolboxPath "/icons")  ;; 连接字符串
    AST_GLOBAL->ConfigPath  = strcat(AST_GLOBAL->ToolboxPath "/config")  ;; 连接字符串
    
    ;; Make forms discoverable by Allegro
    when( isDir(AST_GLOBAL->FormPath)  ;; 检查指定路径是否为目录
      unless( member(AST_GLOBAL->FormPath getSkillPath())  ;; 条件为假时执行
        setSkillPath(cons(AST_GLOBAL->FormPath getSkillPath()))  ;; 将元素添加到列表头部
      )
    )
    
    ;; Make icons discoverable
    when( isDir(AST_GLOBAL->IconPath)  ;; 检查指定路径是否为目录
      unless( member(AST_GLOBAL->IconPath getSkillPath())  ;; 条件为假时执行
        setSkillPath(cons(AST_GLOBAL->IconPath getSkillPath()))  ;; 将元素添加到列表头部
      )
    )
    
    printf("[AST] Toolbox path: %s\n" AST_GLOBAL->ToolboxPath)
  )
)

;;=========================================================================
;; 2. Load Core Libraries
;;=========================================================================
procedure( AST_LoadCore()
  prog((coreFiles f)  ;; 开始局部变量作用域块
    coreFiles = '("utils.il" "form_utils.il" "menu.il" "loader.il"
                 "exec_tool.il" "template_loader.il" "version_adapter.il"
                 "rollback.il")
    foreach( f coreFiles  ;; 遍历列表中的每个元素
      load(strcat(AST_GLOBAL->CorePath "/" f))  ;; 连接字符串
    )
    printf("[AST] Core libraries loaded.\n")
  )
)

;;=========================================================================
;; 3. Load All Modules
;;=========================================================================
procedure( AST_LoadModules()
  prog(()  ;; 开始局部变量作用域块
    AST_ScanAndLoadModules(AST_GLOBAL->ModulePath)
    printf("[AST] Modules loaded.\n")
  )
)

;;=========================================================================
;; 4. Menu Injection (delayed to ensure Allegro menu system is ready)
;;=========================================================================
procedure( AST_MenuLoad(@optional window timerId elapsedTime)
  prog((menuexit file port line menuList offset)  ;; 开始局部变量作用域块
    ;; Check if menu already injected by looking for our marker
    file = axlTempFile()
    axlUIMenuDump(file)
    port = infile(file)  ;; 打开输入文件用于读取
    menuexit = nil
    while( gets(line port)
      when( rexMatchp("AllegroSkillToolbox" line)  ;; 正则表达式匹配检查
        menuexit = t
      )
    )
    close(port)  ;; 关闭文件端口
    deleteFile(file)
    
    when( menuexit  ;; 条件为真时执行
      return(t)  ;; 从当前函数返回
    )
    
    ;; Allegro menu not ready yet, retry later
    timerId = axlUIWTimerAdd(nil 3000 t 'AST_MenuLoad)
    
    ;; Build and insert menu
    menuList = AST_BuildMenuList()
    when( menuList  ;; 条件为真时执行
      offset = "-1"
      axlUIMenuFind(nil readstring(offset))
      errset(axlUIMenuInsert(nil menuList) t)
      printf("[AST] Menu injected.\n")
    )
      return(t)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; 5. Hotkey Management
;;=========================================================================
procedure( AST_SetupHotkeys()
  prog(()  ;; 开始局部变量作用域块
    ;; Example: register toolbox quick commands
    ;; Users can customize via config/hotkeys.cfg in the future
    
    ;; axlSetFunckey("~" "AST_OpenToolbox")
    ;; axlSetFunckey("`" "AST_QuickLauncher")
    
    printf("[AST] Hotkeys configured.\n")
  )
)

;;=========================================================================
;; 6. Command Registration
;;=========================================================================

;; Dummy callbacks for interactive-type commands to auto-exit after execution
procedure( AST_DummyDone()
  t
)

procedure( AST_DummyCancel()
  t
)

procedure( AST_RegisterCommands()
  prog(()  ;; 开始局部变量作用域块
    axlCmdRegister("AST_Uninstall" 'AST_Uninstall ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)
    axlCmdRegister("AST_About"     'AST_About     ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)
    axlCmdRegister("AST_Reload"    'AST_Reload    ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)
  )
)

;;=========================================================================
;; 7. Uninstall / About / Reload
;;=========================================================================
procedure( AST_Uninstall()
  prog((ilinitFile port lines newLines paths)  ;; 开始局部变量作用域块
    ;; Remove allegro.ilinit entry
    paths = getSkillPath()
    foreach( p paths  ;; 遍历列表中的每个元素
      when( isFile(sprintf(nil "%s/allegro.ilinit" p))  ;; 格式化字符串
        ilinitFile = sprintf(nil "%s/allegro.ilinit" p)  ;; 格式化字符串
      )
    )
    
    when( ilinitFile  ;; 条件为真时执行
      port = infile(ilinitFile)  ;; 打开输入文件用于读取
      lines = nil
      while( gets(line port)
        unless( rexMatchp("AllegroSkillToolbox" line)  ;; 正则表达式匹配检查
          lines = cons(line lines)  ;; 将元素添加到列表头部
        )
      )
      close(port)  ;; 关闭文件端口
      
      port = outfile(ilinitFile)  ;; 打开输出文件用于写入
      foreach( line reverse(lines)  ;; 遍历列表中的每个元素
        fprintf(port "%s" line)  ;; 格式化输出到文件
      )
      close(port)  ;; 关闭文件端口
    )
    
    axlUIConfirm("AllegroSkillToolbox uninstalled. Please restart Allegro.")  ;; 弹出确认对话框显示信息
    return(t)  ;; 从当前函数返回
  )
)

procedure( AST_About()
  prog((msg)  ;; 开始局部变量作用域块
    msg = strcat("AllegroSkillToolbox v1.0\n"  ;; 连接字符串
                 "A modular SKILL framework for Allegro PCB.\n\n"
                 "Path: " AST_GLOBAL->ToolboxPath "\n"
                 "Modules: " sprintf(nil "%d" length(AST_GetLoadedModules())))  ;; 格式化字符串
    axlUIConfirm(msg)  ;; 弹出确认对话框显示信息
    return(t)  ;; 从当前函数返回
  )
)

procedure( AST_Reload()
  prog(()  ;; 开始局部变量作用域块
    ;; 自动备份当前代码（如果回滚机制已加载）
    when(boundp('AST_Backup)
      when(boundp('_AST_RollbackAutoBackup) && _AST_RollbackAutoBackup
        axlMsgPut("[回滚] 自动备份当前代码...")
        AST_Backup("auto_reload")
      )
    )
    
    AST_LoadCore()
    AST_LoadModules()
    axlUIConfirm("AllegroSkillToolbox reloaded.")  ;; 弹出确认对话框显示信息
    return(t)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; 8. Delayed Load (called by timer after Allegro is fully ready)
;;=========================================================================
procedure( AST_DelayedLoad(@optional window timerId elapsedTime)
  prog(()  ;; 开始局部变量作用域块
    AST_LoadModules()
    printf("[AST] Modules loaded.\n")
    when(boundp('AST_LoadHotkeys)  ;; 条件为真时执行
      AST_LoadHotkeys()
      AST_ApplyHotkeys("default")
      printf("[AST] Hotkeys applied (default mode).\n")
    )
  )
)

;;=========================================================================
;; 9. Master Init
;;=========================================================================
procedure( AST_Init()
  prog((tid1 tid2)  ;; 开始局部变量作用域块
    AST_InitEnv()
    AST_LoadCore()
    AST_RegisterCommands()
    AST_SetupHotkeys()
    
    ;; Initialize P2 framework modules
    when(boundp('AST_ExecToolInit)  AST_ExecToolInit())  ;; 条件为真时执行
    when(boundp('AST_TemplateInit)  AST_TemplateInit())  ;; 条件为真时执行
    when(boundp('AST_VersionInit)    AST_VersionInit())  ;; 条件为真时执行
    
    ;; Delay module loading until Allegro is idle
    tid1 = axlUIWTimerAdd(nil 3000 t 'AST_DelayedLoad)
    
    ;; Delayed menu injection
    tid2 = axlUIWTimerAdd(nil 5000 t 'AST_MenuLoad)
    
    printf("[AST] AllegroSkillToolbox initialized successfully.\n")
  )
)

;; Run initialization
AST_Init()
