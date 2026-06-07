;; ============================================================
;; 文件名: rollback.il
;; 功能说明: 代码回滚机制 - 备份与恢复
;; 编码格式: GBK (简体中文)
;; ============================================================

;;############################################################################
;;#  模块: 代码回滚机制 (Code Rollback System)                                #
;;#  命令: AST_Backup / AST_Rollback / AST_RollbackList / AST_RollbackTo    #
;;#  功能: 自动备份代码，支持一键回滚到历史版本                              #
;;#############################################################################

;;=========================================================================
;; 全局配置
;;=========================================================================

defvar(_AST_RollbackMaxCount 10)    ;; 最大保留备份数量
defvar(_AST_RollbackAutoBackup t)   ;; 重载时是否自动备份
defvar(_AST_RollbackLastBackup nil) ;; 最后一次备份名称

;;=========================================================================
;; 获取备份目录路径
;;=========================================================================

procedure( AST_GetBackupPath()
  prog((backupPath)
    backupPath = strcat(AST_GLOBAL->ToolboxPath "/backup")
    unless(isDir(backupPath)
      createDir(backupPath)
    )
    return(backupPath)
  )
)

;;=========================================================================
;; 生成备份名称 (backup_YYYYMMDD_HHMMSS)
;;=========================================================================

procedure( AST_GenerateBackupName()
  prog((now year month day hour minute second)
    now = getCurrentTime()
    year = nth(5 now)
    month = nth(4 now)
    day = nth(3 now)
    hour = nth(2 now)
    minute = nth(1 now)
    second = car(now)
    
    return(sprintf(nil "backup_%04d%02d%02d_%02d%02d%02d"
      year month day hour minute second))
  )
)

;;=========================================================================
;; 复制文件 (递归复制目录)
;;=========================================================================

procedure( AST_CopyFileRecursive(srcDir dstDir)
  prog((files f srcFile dstFile)
    
    unless(isDir(dstDir)
      createDirHier(dstDir)
    )
    
    files = getDirFiles(srcDir)
    
    foreach(f files
      srcFile = strcat(srcDir "/" f)
      dstFile = strcat(dstDir "/" f)
      
      when(isFile(srcFile)
        ;; 复制文件
        axlFileCopy(srcFile dstFile)
      )
      
      when(isDir(srcFile)
        ;; 递归复制子目录
        AST_CopyFileRecursive(srcFile dstFile)
      )
    )
    
    return(t)
  )
)

;;=========================================================================
;; 创建备份
;;=========================================================================

procedure( AST_Backup(@optional (label nil))
  prog((backupPath backupName backupDir srcDirs srcDir)
    
    backupPath = AST_GetBackupPath()
    backupName = AST_GenerateBackupName()
    
    when(label
      backupName = strcat(backupName "_" label)
    )
    
    backupDir = strcat(backupPath "/" backupName)
    
    ;; 创建备份目录
    createDirHier(backupDir)
    
    axlMsgPut("[回滚] 开始备份到: %s" backupName)
    
    ;; 备份核心目录
    srcDirs = list(
      list(AST_GLOBAL->CorePath    "core")
      list(AST_GLOBAL->ModulePath   "modules")
      list(AST_GLOBAL->FormPath    "forms")
    )
    
    foreach(srcDir srcDirs
      when(isDir(car(srcDir))
        prog((dstSubDir)
          dstSubDir = strcat(backupDir "/" cadr(srcDir))
          AST_CopyFileRecursive(car(srcDir) dstSubDir)
          axlMsgPut("[回滚] 已备份: %s" cadr(srcDir))
        )
      )
    )
    
    ;; 保存备份元信息
    prog((metaFile metaPort)
      metaFile = strcat(backupDir "/.backup_info")
      metaPort = outfile(metaFile "w")
      fprintf(metaPort "BACKUP_NAME=%s\n" backupName)
      fprintf(metaPort "BACKUP_TIME=%s\n" getCurrentTime())
      fprintf(metaPort "BACKUP_LABEL=%s\n" when(label label "auto"))
      fprintf(metaPort "TOOLBOX_PATH=%s\n" AST_GLOBAL->ToolboxPath)
      close(metaPort)
    )
    
    _AST_RollbackLastBackup = backupName
    
    ;; 清理旧备份
    AST_CleanupOldBackups()
    
    axlMsgPut("[回滚] 备份完成: %s" backupName)
    return(backupName)
  )
)

;;=========================================================================
;; 清理旧备份 (保留最近 _AST_RollbackMaxCount 个)
;;=========================================================================

procedure( AST_CleanupOldBackups()
  prog((backupPath backups sortedBackups deleteCount)
    
    backupPath = AST_GetBackupPath()
    backups = nil
    
    ;; 获取所有备份目录
    foreach(f getDirFiles(backupPath)
      when(rexMatchp("^backup_" f)
        backups = cons(f backups)
      )
    )
    
    backups = sort(backups 'alphalessp)
    
    when(length(backups) > _AST_RollbackMaxCount
      deleteCount = length(backups) - _AST_RollbackMaxCount
      
      foreach(i range(0 deleteCount - 1)
        prog((oldBackup)
          oldBackup = strcat(backupPath "/" nth(i backups))
          axlMsgPut("[回滚] 清理旧备份: %s" nth(i backups))
          AST_DeleteDirRecursive(oldBackup)
        )
      )
    )
    
    return(t)
  )
)

;;=========================================================================
;; 递归删除目录
;;=========================================================================

procedure( AST_DeleteDirRecursive(dirPath)
  prog((files f)
    
    when(isDir(dirPath)
      files = getDirFiles(dirPath)
      
      foreach(f files
        prog((fullPath)
          fullPath = strcat(dirPath "/" f)
          when(isFile(fullPath)
            deleteFile(fullPath)
          )
          when(isDir(fullPath)
            AST_DeleteDirRecursive(fullPath)
          )
        )
      )
      
      deleteDir(dirPath)
    )
    
    return(t)
  )
)

;;=========================================================================
;; 列出所有备份
;;=========================================================================

procedure( AST_ListBackups()
  prog((backupPath backups count)
    
    backupPath = AST_GetBackupPath()
    backups = nil
    
    foreach(f getDirFiles(backupPath)
      when(rexMatchp("^backup_" f)
        backups = cons(f backups)
      )
    )
    
    backups = sort(backups 'alphalessp)
    count = length(backups)
    
    axlMsgPut("=" strcat(makeString(50 "=")))
    axlMsgPut("[回滚] 备份列表 (共 %d 个, 保留最近 %d 个)" count _AST_RollbackMaxCount)
    axlMsgPut("=" strcat(makeString(50 "=")))
    
    when(count == 0
      axlMsgPut("[回滚] 暂无备份")
      return(nil)
    )
    
    foreach(i range(0 count - 1)
      prog((bName marker)
        bName = nth(i backups)
        marker = when(bName == _AST_RollbackLastBackup " <-- 最新" else "")
        axlMsgPut("  [%2d] %s%s" (i + 1) bName marker)
      )
    )
    
    axlMsgPut("=" strcat(makeString(50 "=")))
    axlMsgPut("[回滚] 使用 AST_RollbackTo(编号) 回滚到指定版本")
    
    return(backups)
  )
)

;;=========================================================================
;; 回滚到指定备份
;;=========================================================================

procedure( AST_RollbackTo(backupNameOrIndex)
  prog((backupPath backups backupName backupDir srcDirs srcDir)
    
    backupPath = AST_GetBackupPath()
    
    ;; 如果是数字索引，转换为备份名
    when(fixp(backupNameOrIndex)
      backups = nil
      foreach(f getDirFiles(backupPath)
        when(rexMatchp("^backup_" f)
          backups = cons(f backups)
        )
      )
      backups = sort(backups 'alphalessp)
      
      when(backupNameOrIndex < 1 || backupNameOrIndex > length(backups)
        axlMsgPut("[错误] 无效的备份编号: %d (有效范围: 1-%d)" 
                  backupNameOrIndex length(backups))
        return(nil)
      )
      
      backupName = nth(backupNameOrIndex - 1 backups)
    else
      backupName = backupNameOrIndex
    )
    
    backupDir = strcat(backupPath "/" backupName)
    
    unless(isDir(backupDir)
      axlMsgPut("[错误] 备份不存在: %s" backupName)
      return(nil)
    )
    
    ;; 确认回滚
    unless(axlUIConfirm(sprintf(nil "确定要回滚到备份 [%s]?\n当前代码将被覆盖，建议先手动备份。" backupName))
      axlMsgPut("[回滚] 操作已取消")
      return(nil)
    )
    
    ;; 先备份当前状态（防止误操作后无法恢复）
    axlMsgPut("[回滚] 先备份当前状态...")
    AST_Backup("pre_rollback")
    
    ;; 执行回滚
    axlMsgPut("[回滚] 开始恢复: %s" backupName)
    
    srcDirs = list(
      list("core"    AST_GLOBAL->CorePath)
      list("modules" AST_GLOBAL->ModulePath)
      list("forms"   AST_GLOBAL->FormPath)
    )
    
    foreach(srcDir srcDirs
      prog((srcSubDir dstDir)
        srcSubDir = strcat(backupDir "/" car(srcDir))
        dstDir = cadr(srcDir)
        
        when(isDir(srcSubDir)
          ;; 清空目标目录
          AST_DeleteDirRecursive(dstDir)
          createDirHier(dstDir)
          
          ;; 复制备份文件
          AST_CopyFileRecursive(srcSubDir dstDir)
          axlMsgPut("[回滚] 已恢复: %s" car(srcDir))
        )
      )
    )
    
    axlMsgPut("[回滚] 回滚完成: %s" backupName)
    axlMsgPut("[回滚] 请执行 AST_Reload 重新加载代码")
    
    return(backupName)
  )
)

;;=========================================================================
;; 快速回滚到上一个版本
;;=========================================================================

procedure( AST_Rollback()
  prog((backups)
    
    ;; 先列出备份
    backups = AST_ListBackups()
    
    unless(backups
      axlMsgPut("[回滚] 没有可用的备份")
      return(nil)
    )
    
    ;; 回滚到最新的备份
    return(AST_RollbackTo(length(backups)))
  )
)

;;=========================================================================
;; 注册命令
;;=========================================================================

axlCmdRegister("AST_Backup"     'AST_Backup     ?cmdType "general")
axlCmdRegister("AST_Rollback"   'AST_Rollback   ?cmdType "general")
axlCmdRegister("AST_RollbackTo" 'AST_RollbackTo ?cmdType "general")
axlCmdRegister("AST_ListBackups" 'AST_ListBackups ?cmdType "general")

axlMsgPut("[回滚] 代码回滚机制已加载")
axlMsgPut("[回滚] 命令: AST_Backup / AST_Rollback / AST_RollbackTo(编号) / AST_ListBackups")
