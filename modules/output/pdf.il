;; ============================================================
;; 文件名: pdf.il
;; 功能说明: 输出工具 - PDF输出模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 输出工具-PDF装配图 - 导出顶层/底层PDF装配图
;; 文件路径 : modules/output/pdf.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Export PDF Assembly Drawing                                                 #
#  Command: AST_Out_PDF                                                                #
#  Desc:    Export PDF with top/bottom assembly views                                  #
#  API:     axlRunBatchDBProgram                                                       #  ;; 运行Allegro批处理程序
#########################################################################################
*/

axlCmdRegister("AST_Out_PDF" 'AST_Out_PDF ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; PDF输出主函数
;; 功能说明: 导出顶层/底层的PDF装配图
;; 输出方式: 调用Allegro PDF导出批处理
;; 使用方式: 在Allegro命令行输入 AST_Out_PDF 执行
;;=========================================================================

procedure( AST_Out_PDF()
  prog((brdName)  ;; 开始局部变量作用域块
    brdName = axlDBGetDesign()->name
    
    ;; Run Allegro PDF export batch
    axlRunBatchDBProgram("pdf" nil)  ;; 调用Allegro PDF导出批处理
    
    AST_Msg("INFO" sprintf(nil "PDF export initiated for %s" brdName))  ;; 格式化字符串
    axlUIConfirm("PDF export complete.")  ;; 弹出确认对话框显示信息
    return(t)  ;; 从当前函数返回
  )
)
