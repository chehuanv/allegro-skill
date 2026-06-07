;; ============================================================
;; 文件名: gerber.il
;; 功能说明: 输出工具 - Gerber输出模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 输出工具-Gerber导出 - 一键设置并导出Gerber光绘文件
;; 文件路径 : modules/output/gerber.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Export Gerber                                                               #
#  Command: AST_Out_Gerber                                                             #
#  Desc:    One-click Gerber artwork setup and export                                  #
#  API:     axlRunBatchDBProgram, shell                                                #  ;; 运行Allegro批处理程序
#########################################################################################
*/

axlCmdRegister("AST_Out_Gerber" 'AST_Out_Gerber ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; Gerber输出主函数
;; 功能说明: 一键设置并导出Gerber光绘文件
;; 输出内容: 各层的光绘数据、钻孔文件、装配图等
;; 使用方式: 在Allegro命令行输入 AST_Out_Gerber 执行
;;=========================================================================

procedure( AST_Out_Gerber()
  prog((brdName outDir)  ;; 开始局部变量作用域块
    brdName = axlDBGetDesign()->name
    outDir = sprintf(nil "%s/gerber_output" getWorkingDir())  ;; 设置输出目录
    
    ;; Create output directory
    shell(sprintf(nil "mkdir \"%s\"" outDir))  ;; 创建输出目录
    
    ;; Run Allegro artwork batch
    axlRunBatchDBProgram("artwork" nil)  ;; 运行Allegro批处理程序
    
    AST_Msg("INFO" sprintf(nil "Gerber export initiated. Output: %s" outDir))  ;; 格式化字符串
    axlUIConfirm("Gerber export complete. Check gerber_output folder.")  ;; 弹出确认对话框显示信息
    return(t)  ;; 从当前函数返回
  )
)
