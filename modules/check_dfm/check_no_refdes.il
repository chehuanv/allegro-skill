;; ============================================================
;; 文件名: check_no_refdes.il
;; 功能说明: DFM检查 - 无位号检查模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : DFM检查-缺失位号 - 检查封装中是否缺少REFDES位号
;; 文件路径 : modules/check_dfm/check_no_refdes.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================


axlCmdRegister("AST_CheckNoRefdes" 'AST_CheckNoRefdes ?cmdType "general")
;axlSetFunckey("skn" "AST_CheckNoRefdes")
;;=========================================================================
;; 缺失位号检查主函数
;; 功能说明: 检查所有器件是否都有REFDES(位号)丝印
;; 检查原理: 遍历所有符号，检查是否附加了REF DES层上的文本对象
;; 输出结果: 将缺失位号的器件信息写入日志文件 no_refdes.log
;; 使用方式: 在Allegro命令行输入 AST_CheckNoRefdes 执行
;;=========================================================================

procedure( AST_CheckNoRefdes()
	prog(()  ;; 开始局部变量作用域块
		axlVisibleDesign(nil)  ;; 关闭所有层显示，准备只显示相关层
		axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )  ;; 设置指定层为可见
		axlVisibleLayer( "PIN/TOP" t )  ;; 设置指定层为可见
		axlVisibleLayer( "PIN/BOTTOM" t )  ;; 设置指定层为可见
		axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )  ;; 设置指定层为可见
		axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )  ;; 设置指定层为可见
		axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )  ;; 设置指定层为可见
		axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )  ;; 设置指定层为可见

		logfile = axlDMOpenLog("no_refdes.log")  ;; 打开日志文件，记录检查结果
		fprintf(logfile "#Check the component without refdes . \n\n")  ;; 格式化输出到文件
		fprintf(logfile "REF_DES  COORDIRATION\n")  ;; 格式化输出到文件

		setq(allsym axlDBGetDesign()->symbols)  ;; 获取设计中所有符号(器件)
		axlDehighlightObject(allsym)  ;; 取消高亮显示
		noref = nil
		norefcnt = 0  ;; 初始化缺失位号计数器
		foreach(symbol allsym   ;; 遍历列表中的每个元素
			text= axlDBGetAttachedText(symbol)
			txt = nil
			foreach(find text  ;; 遍历列表中的每个元素
				if(or(find->layer == "REF DES/SILKSCREEN_TOP"   ;; 条件分支判断
				      find->layer == "REF DES/SILKSCREEN_BOTTOM") then 									
					txt = find			
				)								
			)
			if(and(txt == nil symbol->refdes != nil) then   ;; 条件分支判断
				axlHighlightObject(symbol)  ;; 高亮显示指定对象，便于视觉识别
				fprintf(logfile "%-8s %L\n" symbol->refdes symbol->xy)  ;; 格式化输出到文件
				;noref = cons(symbol->refdes noref)
				norefcnt = norefcnt + 1
			)
		);foreach-end

		fprintf(logfile "\nTotal of no refdes: %d\n" norefcnt)  ;; 格式化输出到文件
		axlDMClose(logfile)  ;; 关闭日志文件
		
		axlMsgPut("Total component without refdes: %d\n" norefcnt)  ;; 输出消息到Allegro命令窗口
		axlMsgPut("Components without refdes , please view logfile.")  ;; 输出消息到Allegro命令窗口
	;   axlUIViewFileCreate("no_refdes.log" "No refdes Log" nil)          
	)
)
