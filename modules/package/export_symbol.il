;; ============================================================
;; 文件名: export_symbol.il
;; 功能说明: 封装工具 - 符号导出模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 封装工具-导出封装 - 导出选中器件的封装文件
;; 文件路径 : modules/package/export_symbol.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    export_symbol.il  (upgraded)
; Category:  package
; Purpose:   Export package file for selected symbol
; Command:   AST_ExportSymbol
; Source:    FanySkill sig_pack — ported to AllegroSkillToolbox
;--------------------------------------------------------------------------

; Keep original AST_ExportSymbol from AllegroSkillToolbox if it exists,
; but this upgraded version adds single-click point selection.

axlCmdRegister("AST_ExportSymbol" 'AST_ExportSymbol ?cmdType "general")

;;=========================================================================
;; 导出封装主函数
;; 功能说明: 导出选中的封装到封装库文件
;; 操作方式: 点击选中一个符号，自动导出其封装定义
;; 使用方式: 在Allegro命令行输入 AST_ExportSymbol 执行
;;=========================================================================

procedure( AST_ExportSymbol()
    let(()  ;; 绑定局部变量
        axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
        axlSetFindFilter(?enabled list("noall" "symbols")  ;; 设置查找过滤器，限定可选择对象类型
                         ?onButtons list("noall" "symbols"))
        axlSingleSelectPoint()  ;; 单点选择模式
        sym = axlGetSelSet()  ;; 获取当前选择集中的对象列表
        foreach(symdbid sym  ;; 遍历列表中的每个元素
            symdef = symdbid->definition  ;; 获取符号定义
            axlWritePackageFile(symdef)
            axlUIWPrint(nil "---------Name---------")
            axlMsgPut("%s was exported." symdbid->name)  ;; 输出消息到Allegro命令窗口
        )
    )
)
