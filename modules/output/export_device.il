;; ============================================================
;; 文件名: export_device.il
;; 功能说明: 输出工具 - 器件导出模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 输出工具-器件导出 - 导出器件封装和相关信息
;; 文件路径 : modules/output/export_device.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#################################################################################                                                                    
#                  	Command: FYED                                     			#
#                  	Skill File: AST_ExportDevice.il                   	#
#                  	How To Load: Command> (load("AST_ExportDevice.il"))	#
#               	How To Execute: Command> FYED  						#
#              	 	Write by: deargds            							#
#################################################################################
*/
axlCmdRegister( "AST_ExportDevice" 'AST_ExportDevice ?cmdType "general")

;;=========================================================================
;; 器件导出主函数
;; 功能说明: 导出封装库中所有器件的信息
;; 操作方式: 扫描当前目录下的.dra文件，导出器件数据
;; 使用方式: 在Allegro命令行输入 AST_ExportDevice 执行
;;=========================================================================

procedure( AST_ExportDevice()
    prog(()  ;; 开始局部变量作用域块
        dra_list =  rexMatchList(".dra$" getDirFiles(".\\"))  ;; 获取当前目录下所有.dra文件
        foreach( p dra_list  ;; 遍历列表中的每个元素
            when( axlOpenDesign(?design p ?mode "wf")   ;; 打开指定设计文件
                when( axlDesignType(t) == "PACKAGE"  ;; 条件为真时执行
                    ScriptFileName = axlTempFile()
                    Script_File = axlDMOpenFile("TEMP", ScriptFileName, "w") 
                    
                    fprintf(Script_File "scriptmode +i\n\n")  ;; 格式化输出到文件
                    fprintf(Script_File "setwindow pcb \n")  ;; 格式化输出到文件
                    fprintf(Script_File "create device \n")  ;; 格式化输出到文件
                    fprintf(Script_File "setwindow form.crdevice \n")  ;; 格式化输出到文件
                    fprintf(Script_File "FORM crdevice done \n")  ;; 格式化输出到文件
                    fprintf(Script_File "setwindow pcb \n")  ;; 格式化输出到文件
                    
                    axlDMClose(Script_File)   ;; 关闭日志文件
                    sprintf(runScript, "replay %s" , ScriptFileName)   ;; 格式化字符串
                    ;; 注意: axlShell 调用后所有 dbid 会失效，后续操作需重新获取
    axlShell(runScript)  ;; 执行Allegro shell命令
                )
            )
        )
    )
)
