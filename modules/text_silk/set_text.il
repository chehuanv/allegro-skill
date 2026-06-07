;; ============================================================
;; 文件名: set_text.il
;; 功能说明: 丝印工具 - 文本设置模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 丝印工具-批量设置文字 - 批量将文字设置为2号大小并居中
;; 文件路径 : modules/text_silk/set_text.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Set Text Size                                                               #
#  Command: AST_Text_SetSize                                                           #
#  Desc:    Batch set text to #2 size and center justify                               #
#  API:     axlDBChangeText, make_axlTextOrientation                                   #
#########################################################################################
*/

axlCmdRegister("AST_Text_SetSize" 'AST_Text_SetSize ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 设置文字大小主函数
;; 功能说明: 批量将选中的文字设置为2号大小并居中对齐
;; 操作方式: 1) 选择文字对象 2) 自动应用2号大小和居中
;; 使用方式: 在Allegro命令行输入 AST_Text_SetSize 执行
;;=========================================================================

procedure( AST_Text_SetSize()
  prog((texts blockNum orient)  ;; 开始局部变量作用域块
    ;; Prompt user to select text objects
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
    axlSetFindFilter(?enabled '(NOALL TEXT) ?onButtons '(TEXT))  ;; 设置过滤器，只允许选择文字
    axlMsgPut("Select text objects to resize, then right-click Done.")  ;; 输出消息到Allegro命令窗口
    axlSelect()  ;; 启动交互选择模式，等待用户选择对象
    texts = axlGetSelSet()  ;; 获取当前选择集中的对象列表
    
    unless( texts  ;; 条件为假时执行
      AST_Msg("WARN" "No text objects selected.")
      return(nil)  ;; 从当前函数返回
    )
    
    ;; Create text block #2 if not exists (30x5 mils)
    blockNum = axlDBTextBlockCreate(1 ?width 30.0 ?height 30.0 ?photoWidth 5.0)
    when( blockNum == nil  ;; 条件为真时执行
      blockNum = 2  ;; Fallback to block 2
    )
    
    ;; Apply to each selected text
    foreach( txt texts  ;; 遍历列表中的每个元素
      when( txt->objType == "text"  ;; 条件为真时执行
        ;; Create orientation with block 2, centered
        orient = make_axlTextOrientation(
          ?textBlock blockNum
          ?rotation txt->rotation
          ?mirrored txt->isMirrored
          ?justify "center"
        )
        axlDBChangeText(txt txt->text ?orientation orient)
      )
    )
    
    AST_Msg("INFO" sprintf(nil "Set %d text objects to size #2 (30x5 mils, centered)." length(texts)))  ;; 格式化字符串
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
  )
)
