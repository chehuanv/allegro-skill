;; ============================================================
;; 文件名: dxf.il
;; 功能说明: 输出工具 - DXF输出模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 输出工具-DXF导出 - 将PCB外形和元素导出为DXF文件
;; 文件路径 : modules/output/dxf.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Export DXF                                                                  #
#  Command: AST_Out_DXF                                                                #
#  Desc:    Export PCB outline and elements to DXF                                     #
#  API:     axlRunBatchDBProgram                                                       #  ;; 运行Allegro批处理程序
#########################################################################################
*/

axlCmdRegister("AST_Out_DXF" 'AST_Out_DXF ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; DXF输出主函数
;; 功能说明: 将PCB板框和元素导出为DXF格式文件
;; 输出方式: 调用Allegro批处理命令导出DXF
;; 使用方式: 在Allegro命令行输入 AST_Out_DXF 执行
;;=========================================================================

procedure( AST_Out_DXF()
  prog((brdName)  ;; 开始局部变量作用域块
    brdName = axlDBGetDesign()->name  ;; 获取设计名称
    
    ;; Run Allegro DXF export batch
    axlRunBatchDBProgram("dxf out" nil)  ;; 调用Allegro DXF导出批处理
    
    AST_Msg("INFO" sprintf(nil "DXF export initiated for %s" brdName))  ;; 格式化字符串
    axlUIConfirm("DXF export complete.")  ;; 弹出确认对话框显示信息
    return(t)  ;; 从当前函数返回
  )
)
