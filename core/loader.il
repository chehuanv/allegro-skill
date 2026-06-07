;; ============================================================
;; 文件名: loader.il
;; 功能说明: 模块加载器，负责动态加载所有功能模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 模块加载器 - 自动扫描modules目录并按依赖顺序加载SKILL脚本
;; 文件路径 : core/loader.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module Loader - Auto-scan and load .il files from modules/ directory                #
#########################################################################################
*/

;; Global list to track loaded modules
defvar(AST_LOADED_MODULES nil)  ;; 定义全局变量(仅首次赋值)

;;=========================================================================
;; Scan a directory tree and load all .il / .ile files
;;=========================================================================
procedure( AST_ScanAndLoadModules(rootPath)
  prog((subDirs dirPath files f fullPath)  ;; 开始局部变量作用域块
    when( isDir(rootPath)  ;; 检查指定路径是否为目录
      ;; Get immediate subdirectories (categories)
      subDirs = AST_GetSubDirs(rootPath)
      
      ;; If no subdirs, load files directly in rootPath
      unless( subDirs  ;; 条件为假时执行
        AST_LoadFilesInDir(rootPath)
      )
      
      ;; Load each category directory
      foreach( dirName subDirs  ;; 遍历列表中的每个元素
        dirPath = strcat(rootPath "/" dirName)  ;; 连接字符串
        when( isDir(dirPath)  ;; 检查指定路径是否为目录
          AST_LoadFilesInDir(dirPath)
        )
      )
    )
  )
)

;;=========================================================================
;; Load all .il / .ile files in a single directory (non-recursive)
;;=========================================================================
procedure( AST_LoadFilesInDir(dirPath)
  prog((files f fullPath)  ;; 开始局部变量作用域块
    files = AST_GetFilesByExt(dirPath "il")
    foreach( f files  ;; 遍历列表中的每个元素
      fullPath = strcat(dirPath "/" f)  ;; 连接字符串
      when( isFile(fullPath)  ;; 检查指定路径是否为文件
        printf("[AST] Loading module: %s\n" f)
        errset(load(fullPath) t)
        AST_LOADED_MODULES = cons(f AST_LOADED_MODULES)  ;; 将元素添加到列表头部
      )
    )
  )
)

;;=========================================================================
;; Helper: list directory contents via OS shell (Windows dir /b)
;;=========================================================================
procedure( AST_ListDir(path)
  prog((tmpFile port lines line result)  ;; 开始局部变量作用域块
    result = nil
    tmpFile = axlTempFile()
    ;; Use Windows dir /b to list filenames; redirect to temp file
    shell(sprintf(nil "cmd /c dir /b \"%s\" > \"%s\"" path tmpFile))  ;; 格式化字符串
    when( isFile(tmpFile)  ;; 检查指定路径是否为文件
      port = infile(tmpFile)  ;; 打开输入文件用于读取
      while( gets(line port)
        line = AST_StringTrim(line)
        when( line != ""  ;; 条件为真时执行
          result = cons(line result)  ;; 将元素添加到列表头部
        )
      )
      close(port)  ;; 关闭文件端口
      deleteFile(tmpFile)
    )
    return(reverse(result))  ;; 从当前函数返回
  )
)

;;=========================================================================
;; Helper: get subdirectories
;;=========================================================================
procedure( AST_GetSubDirs(path)
  prog((result name)  ;; 开始局部变量作用域块
    result = nil
    foreach( name AST_ListDir(path)  ;; 遍历列表中的每个元素
      when( isDir(strcat(path "/" name))  ;; 连接字符串
        result = cons(name result)  ;; 将元素添加到列表头部
      )
    )
    return(reverse(result))  ;; 从当前函数返回
  )
)

;;=========================================================================
;; Helper: get files by extension
;;=========================================================================
procedure( AST_GetFilesByExt(path ext)
  prog((result name)  ;; 开始局部变量作用域块
    result = nil
    foreach( name AST_ListDir(path)  ;; 遍历列表中的每个元素
      when( isFile(strcat(path "/" name))  ;; 连接字符串
        when( rexMatchp(sprintf(nil "\\.%s$" ext) name)  ;; 格式化字符串
          result = cons(name result)  ;; 将元素添加到列表头部
        )
      )
    )
    return(reverse(result))  ;; 从当前函数返回
  )
)

;;=========================================================================
;; Get loaded module names
;;=========================================================================
procedure( AST_GetLoadedModules()
  AST_LOADED_MODULES
)
