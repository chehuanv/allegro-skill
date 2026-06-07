;; ============================================================
;; 文件名: grid_choose.il
;; 功能说明: 布局工具 - 栅格选择模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布局工具-快速栅格 - 在常用栅格预设之间快速切换
;; 文件路径 : modules/layout/grid_choose.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    grid_choose.il
; Category:  layout
; Purpose:   Quick grid picker — switch between common grid presets
; Command:   AST_ChooseGrid
; Source:    P1 rewrite of FanySkill_ChooseGrid.il
;--------------------------------------------------------------------------

axlCmdRegister("AST_ChooseGrid" 'AST_ChooseGrid ?cmdType "general")
axlCmdRegister("AST_SetGrid"    'AST_SetGrid    ?cmdType "general")

; Preset grids: (name xSpacing ySpacing)
defvar(_AST_GridPresets '(  ;; 定义常用栅格预设列表
    ("1 mil"      1.0    1.0)
    ("2 mil"      2.0    2.0)
    ("5 mil"      5.0    5.0)
    ("10 mil"     10.0   10.0)
    ("25 mil"     25.0   25.0)
    ("50 mil"     50.0   50.0)
    ("1 mm"       39.37  39.37)
    ("0.5 mm"     19.685 19.685)
    ("0.1 mm"     3.937  3.937)
))

;;=========================================================================
;; 栅格选择主函数
;; 功能说明: 快速切换常用栅格预设(1mil/2mil/5mil/10mil/25mil/50mil/1mm等)
;; 操作方式: 弹出栅格选择列表，点击即可切换
;; 使用方式: 在Allegro命令行输入 AST_ChooseGrid 执行
;;=========================================================================

procedure( AST_ChooseGrid()
    let((form idx preset)  ;; 绑定局部变量
        ; Build simple enumerated list form
        form = axlFormCreate(gensym() "gridchoose.form" '(ne) '_AST_GridFormCB t)  ;; 创建Allegro表单窗口
        foreach(preset _AST_GridPresets  ;; 遍历列表中的每个元素
            idx = idx + 1
            axlFormSetField(form sprintf(nil "item%d" idx) car(preset))  ;; 设置表单字段的值
        )
        axlFormDisplay(form)  ;; 显示已创建的表单窗口
    )
)

procedure( _AST_GridFormCB(form)
    let((val preset)  ;; 绑定局部变量
        val = form->curField
        preset = assoc(val _AST_GridPresets)
        when(preset  ;; 条件为真时执行
            _AST_SetGridValues(cadr(preset) caddr(preset))  ;; 取列表第二个元素
            axlFormClose(form)  ;; 关闭表单窗口
        )
    )
)

procedure( AST_SetGrid(x y)
    _AST_SetGridValues(x y)
)

procedure( _AST_SetGridValues(x y)
    let((grids)  ;; 绑定局部变量
        grids = axlGetParam("paramGrid")  ;; 获取Allegro参数值
        when(grids  ;; 条件为真时执行
            grids->xGrid = x
            grids->yGrid = y
            axlSetParam(grids)  ;; 设置Allegro参数值
            axlMsgPut("Grid set to %.3f x %.3f mils" x y)  ;; 输出消息到Allegro命令窗口
        )
    )
)
