;; ============================================================
;; 文件名: change_width.il
;; 功能说明: 布局工具 - 线宽修改模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布局工具-批量改线宽 - 批量修改选中走线的宽度
;; 文件路径 : modules/layout/change_width.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    change_width.il
; Category:  layout
; Purpose:   Change width of selected clines
; Command:   AST_Layout_ChangeWidth
;--------------------------------------------------------------------------

axlCmdRegister("AST_Layout_ChangeWidth" 'AST_Layout_ChangeWidth ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 线宽修改主函数
;; 功能说明: 批量修改选中走线的宽度
;; 操作方式: 1) 选择要修改的cline 2) 输入新的线宽值 3) 自动应用
;; 使用方式: 在Allegro命令行输入 AST_Layout_ChangeWidth 执行
;;=========================================================================

procedure( AST_Layout_ChangeWidth()
    prog((objs newWidth)  ;; 开始局部变量作用域块
        ; Prompt user to select clines
        axlClearSelSet()  ;; 清空当前选择集
        axlSetFindFilter(?enabled '(NOALL CLINES) ?onButtons '(CLINES))  ;; 设置过滤器，只允许选择cline
        axlMsgPut("[AST] Select clines to change width, then right-click Done.")  ;; 输出消息到Allegro命令窗口
        axlSelect()  ;; 启动交互选择模式，等待用户选择对象
        objs = axlGetSelSet()  ;; 获取用户选中的对象
        
        unless(objs  ;; 条件为假时执行
            axlMsgPut("[AST-WARN] No clines selected.")  ;; 输出警告消息到命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        ; Ask for new width via simple dialog
        newWidth = axlUIDataBrowse("Enter new line width (mils)" 'string "10.0" nil)
        unless(newWidth  ;; 条件为假时执行
            axlMsgPut("[AST] Cancelled.")  ;; 输出消息到Allegro命令窗口
            return(nil)  ;; 从当前函数返回
        )
        newWidth = atof(newWidth)  ;; 字符串转浮点数
        when(newWidth <= 0  ;; 条件为真时执行
            axlMsgPut("[AST-WARN] Invalid width value.")  ;; 输出警告消息到命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        ; Apply width change
        foreach(obj objs  ;; 遍历列表中的每个元素
            when(obj->objType == "path"  ;; 条件为真时执行
                axlDBChangeWidth(obj newWidth)
            )
        )
        
        axlMsgPut(sprintf(nil "[AST] Changed width to %.2f mils for %d objects." newWidth length(objs)))  ;; 输出消息到Allegro命令窗口
        axlClearSelSet()  ;; 清空当前选择集
                axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
    )
)
