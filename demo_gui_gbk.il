;; ============================================================
;; 文件名: demo_gui_gbk.il
;; 功能说明: GUI创建示例 - 全中文GBK编码
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================

/*
#########################################################################################
#  模式: 动态生成临时 .form 文件的中文GBK编码GUI
#  命令: DemoGUI_GBK
#  功能: 演示文本框、下拉框、复选框、按钮的中文界面
#########################################################################################
*/

;------------------------------------------------------------------------
; 主入口: 动态生成临时 .form 文件
; 签名: axlFormCreate((gensym) formFile position callback parent)
;------------------------------------------------------------------------
procedure( DemoGUI_GBK()
  prog((formFile formPort formHandle)
    
    ; 第一步: 生成临时 .form 文件
    formFile = strcat(axlTempDirectory() "/DemoGUI_GBK.form")
    formPort = outfile(formFile "w")
    
    fprintf(formPort "FILE_TYPE=FORM_DEFN VERSION=2\n")
    fprintf(formPort "FORM\n")
    fprintf(formPort "FIXED\n")
    fprintf(formPort "PORT 55 20\n")
    fprintf(formPort "HEADER "过孔替换工具"\n")
    fprintf(formPort "TILE\n")
    
    ;--- 字段定义 ---
    fprintf(formPort "TEXT "网络名称:"\n")
    fprintf(formPort "TLOC 1 1\n")
    fprintf(formPort "ENDTEXT\n")
    
    fprintf(formPort "FIELD inputName\n")
    fprintf(formPort "FLOC 12 1\n")
    fprintf(formPort "STRFILLIN 30 64\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "TEXT "目标层:"\n")
    fprintf(formPort "TLOC 1 4\n")
    fprintf(formPort "ENDTEXT\n")
    
    fprintf(formPort "FIELD selLayer\n")
    fprintf(formPort "FLOC 12 4\n")
    fprintf(formPort "ENUM 20\n")
    fprintf(formPort "POPUP "顶层|TOP|底层|BOTTOM"\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "FIELD chkEnable\n")
    fprintf(formPort "FLOC 1 7\n")
    fprintf(formPort "CHECKLIST "启用DRC检查"\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "FIELD btnRun\n")
    fprintf(formPort "FLOC 1 11\n")
    fprintf(formPort "MENUBUTTON "执行替换" 14 3\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "FIELD btnPreview\n")
    fprintf(formPort "FLOC 20 11\n")
    fprintf(formPort "MENUBUTTON "预览高亮" 14 3\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "FIELD btnClose\n")
    fprintf(formPort "FLOC 38 11\n")
    fprintf(formPort "MENUBUTTON "关闭退出" 14 3\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "TEXT ""\n")
    fprintf(formPort "TLOC 1 15\n")
    fprintf(formPort "INFO status 50\n")
    fprintf(formPort "ENDTEXT\n")
    
    fprintf(formPort "ENDTILE\n")
    fprintf(formPort "ENDFORM\n")
    
    close(formPort)
    
    ; 第二步: 创建表单
    formHandle = axlFormCreate(
      (gensym)
      formFile
      '(center)
      '_DemoGUI_GBK_Callback
      t
    )
    
    ; 删除临时文件
    deleteFile(formFile)
    
    unless(formHandle
      axlMsgPut("错误: 表单创建失败，请检查Allegro版本兼容性")
      return(nil)
    )
    
    ; 初始化默认值
    axlFormSetField(formHandle "inputName" "CLK_100M")
    axlFormSetField(formHandle "selLayer" "TOP")
    axlFormSetField(formHandle "chkEnable" "1")
    axlFormSetField(formHandle "status" "就绪。点击 [执行替换] 开始")
    
    ; 显示表单
    axlFormDisplay(formHandle)
    return(formHandle)
  )
)

;------------------------------------------------------------------------
; 回调函数 - 使用 (form) 签名，通过 form->curField 获取触发字段
;------------------------------------------------------------------------
procedure( DemoGUI_GBK_Callback(form)
  case(form->curField
    ("btnRun"
      prog((name layer isEnabled)
        name = axlFormGetField(form "inputName")
        layer = axlFormGetField(form "selLayer")
        isEnabled = axlFormGetField(form "chkEnable")
        
        axlMsgPut("[执行] 网络=%s 层=%s 启用=%s" name layer isEnabled)
        axlFormSetField(form "status" 
          sprintf(nil "执行完成: 网络=%s, 层=%s" name layer))
      )
    )
    ("btnPreview"
      prog((name)
        name = axlFormGetField(form "inputName")
        axlMsgPut("[预览] 高亮显示: %s" name)
        axlFormSetField(form "status" sprintf(nil "预览高亮: %s" name))
      )
    )
    ("btnClose"
      axlFormClose(form)
      axlMsgPut("[信息] 用户关闭窗口")
    )
    (t
      nil
    )
  )
)

;------------------------------------------------------------------------
; 快捷入口 - 在Allegro命令窗口直接调用
;------------------------------------------------------------------------
procedure( TestDemoGUI()
  axlMsgPut("正在启动 DemoGUI_GBK...")
  DemoGUI_GBK()
)
