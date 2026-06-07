;; ============================================================
;; 文件名: replace_via.il
;; 功能说明: 过孔替换工具 - GUI版本
;; 命令: AST_Layout_ReplaceVia
;; 编码格式: GBK (简体中文)
;; ============================================================

axlCmdRegister("AST_Layout_ReplaceVia" 'AST_ReplaceVia ?cmdType "general")

;; 全局变量
defvar(_AST_ReplaceViaForm nil)

;;=========================================================================
;; 主函数: 创建并显示过孔替换GUI
;;=========================================================================

procedure(AST_ReplaceVia()
  prog((formFile formPort formHandle)
    
    ;; 检查设计是否打开
    unless(axlCurrentDesign()
      axlMsgPut("[错误] 没有打开的设计文件")
      return(nil)
    )
    
    ;; 生成临时 .form 文件
    formFile = strcat(axlTempDirectory() "/AST_ReplaceVia.form")
    formPort = outfile(formFile "w")
    
    unless(formPort
      axlMsgPut("[错误] 无法创建临时表单文件")
      return(nil)
    )
    
    fprintf(formPort "FILE_TYPE=FORM_DEFN VERSION=2\n")
    fprintf(formPort "FORM\n")
    fprintf(formPort "FIXED\n")
    fprintf(formPort "PORT 50 18\n")
    fprintf(formPort "HEADER \"Replace Via Tool\"\n")
    fprintf(formPort "TILE\n")
    
    ;; 旧焊盘输入
    fprintf(formPort "TEXT \"Old Padstack:\"\n")
    fprintf(formPort "TLOC 2 2\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD oldVia\n")
    fprintf(formPort "FLOC 20 2\n")
    fprintf(formPort "STRFILLIN 25 64\n")
    fprintf(formPort "ENDFIELD\n")
    
    ;; 新焊盘输入
    fprintf(formPort "TEXT \"New Padstack:\"\n")
    fprintf(formPort "TLOC 2 5\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD newVia\n")
    fprintf(formPort "FLOC 20 5\n")
    fprintf(formPort "STRFILLIN 25 64\n")
    fprintf(formPort "ENDFIELD\n")
    
    ;; 范围选择 - 使用下拉框
    fprintf(formPort "TEXT \"Scope:\"\n")
    fprintf(formPort "TLOC 2 8\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD scope\n")
    fprintf(formPort "FLOC 20 8\n")
    fprintf(formPort "ENUM 20\n")
    fprintf(formPort "POPUP \"Selected vias|selected|All vias|all\"\n")
    fprintf(formPort "ENDFIELD\n")
    
    ;; 执行和关闭按钮
    fprintf(formPort "FIELD btnRun\n")
    fprintf(formPort "FLOC 5 12\n")
    fprintf(formPort "MENUBUTTON \"Replace\" 12 3\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "FIELD btnCancel\n")
    fprintf(formPort "FLOC 25 12\n")
    fprintf(formPort "MENUBUTTON \"Cancel\" 12 3\n")
    fprintf(formPort "ENDFIELD\n")
    
    ;; 状态信息
    fprintf(formPort "FIELD status\n")
    fprintf(formPort "FLOC 2 15\n")
    fprintf(formPort "INFO 45\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "ENDTILE\n")
    fprintf(formPort "ENDFORM\n")
    
    close(formPort)
    
    ;; 创建表单 - 使用 gensym() 函数调用
    formHandle = axlFormCreate(gensym() formFile '(center) '_AST_ReplaceViaCB t)
    
    ;; 删除临时文件
    when(isFile(formFile)
      deleteFile(formFile)
    )
    
    unless(formHandle
      axlMsgPut("[错误] 无法创建表单")
      return(nil)
    )
    
    _AST_ReplaceViaForm = formHandle
    
    ;; 初始化字段值
    axlFormSetField(formHandle "oldVia" "VIA8D8")
    axlFormSetField(formHandle "newVia" "VIA10D10")
    axlFormSetField(formHandle "scope" "all")
    axlFormSetField(formHandle "status" "Ready")
    
    ;; 显示表单
    axlFormDisplay(formHandle)
    formHandle
  )
)

;;=========================================================================
;; 回调函数
;;=========================================================================

procedure(_AST_ReplaceViaCB(form)
  prog((field)
    field = axlFormGetField(form)
    
    case(field
      ("btnRun"
        _AST_ReplaceViaExecute(form)
      )
      ("btnCancel"
        axlFormClose(form)
        _AST_ReplaceViaForm = nil
      )
      (t
        nil
      )
    )
  )
)

;;=========================================================================
;; 执行替换
;;=========================================================================

procedure(_AST_ReplaceViaExecute(form)
  prog((oldPad newPad scope allVias targets count via xy netName)
    
    ;; 获取输入值
    oldPad = axlFormGetField(form "oldVia")
    newPad = axlFormGetField(form "newVia")
    scope = axlFormGetField(form "scope")
    
    ;; 输入验证
    unless(oldPad && newPad
      axlFormSetField(form "status" "Error: Padstack names required")
      return(nil)
    )
    
    when(oldPad == newPad
      axlFormSetField(form "status" "Error: Old and new padstacks are same")
      return(nil)
    )
    
    ;; 获取目标过孔
    axlClearSelSet()
    axlSetFindFilter(?enabled '(NOALL VIAS) ?onButtons '(VIAS))
    
    case(scope
      ("selected"
        allVias = axlGetSelSet()
        unless(allVias
          axlFormSetField(form "status" "Error: No vias selected")
          return(nil)
        )
      )
      (t
        axlAddSelectAll()
        allVias = axlGetSelSet()
        axlClearSelSet()
      )
    )
    
    ;; 过滤匹配的过孔
    targets = nil
    foreach(via allVias
      when(via->padstack == oldPad
        targets = cons(via targets)
      )
    )
    targets = reverse(targets)
    
    unless(targets
      axlFormSetField(form "status" sprintf(nil "No vias found: %s" oldPad))
      return(nil)
    )
    
    ;; 用户确认
    unless(axlUIConfirm(sprintf(nil "Found %d vias [%s], replace with [%s]?" length(targets) oldPad newPad))
      axlFormSetField(form "status" "Cancelled")
      return(nil)
    )
    
    ;; 执行替换
    count = 0
    foreach(via targets
      prog(()
        xy = via->xy
        netName = when(via->net via->net->name)
        
        when(axlDeleteObject(via)
          if(axlDBCreateVia(newPad xy netName) then
            count = count + 1
          else
            axlMsgPut("Warning: Failed to create via at %L" xy)
          )
        )
      )
    )
    
    ;; 完成
    axlDisplayFlush()
    axlFormSetField(form "status" sprintf(nil "Done: %d vias replaced" count))
    axlMsgPut("[Replace Via] %s -> %s, count: %d" oldPad newPad count)
    
    return(count)
  )
)
