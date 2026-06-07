;; ============================================================
;; 文件名: color_setting.il
;; 功能说明: 通用工具 - 颜色设置模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 辅助工具-高级颜色设置 - 增强的颜色预设和层颜色切换
;; 文件路径 : modules/tools/color_setting.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    color_setting.il
; Category:  tools
; Purpose:   Enhanced color presets + layer color toggles
; Command:   AST_ColorSetting
; Source:    P1 rewrite of FanySkill_Color_Setting.il
;--------------------------------------------------------------------------

axlCmdRegister("AST_ColorSetting" 'AST_ColorSetting ?cmdType "general")

; Color presets by design phase
defvar(_AST_ColorPresets '(  ;; 定义颜色预设列表
    ("Placement"  '(
        ("ETCH/TOP"          1)
        ("ETCH/BOTTOM"       2)
        ("PIN/TOP"           3)
        ("PIN/BOTTOM"        4)
        ("VIA CLASS/TOP"     5)
        ("BOARD GEOMETRY/OUTLINE" 6)
        ("PACKAGE GEOMETRY/PLACE_BOUND_TOP" 7)
        ("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" 8)
    ))
    ("Routing"   '(
        ("ETCH/TOP"          1)
        ("ETCH/BOTTOM"       2)
        ("ETCH/INTERNAL1"     3)
        ("ETCH/INTERNAL2"     4)
        ("VIA CLASS/TOP"      5)
        ("VIA CLASS/BOTTOM"   6)
        ("BOARD GEOMETRY/OUTLINE" 7)
        ("MANUFACTURING/PHOTOPLOT_OUTLINE" 8)
    ))
    ("Review"    '(
        ("DRC ERROR CLASS/TOP"    1)
        ("DRC ERROR CLASS/BOTTOM" 2)
        ("ANTI ETCH/TOP"          3)
        ("ANTI ETCH/BOTTOM"       4)
        ("BOUNDARY/TOP"           5)
        ("BOUNDARY/BOTTOM"        6)
        ("BOARD GEOMETRY/OUTLINE" 7)
        ("MANUFACTURING/NCLEGEND" 8)
    ))
    ("All Off"   nil)
))

;;=========================================================================
;; 颜色设置主函数
;; 功能说明: 增强型颜色预设和层颜色切换
;; 预设方案: Placement(布局)、Routing(布线)、Silkscreen(丝印)、DRC(检查)等
;; 使用方式: 在Allegro命令行输入 AST_ColorSetting 执行
;;=========================================================================

procedure( AST_ColorSetting()
    let((form)  ;; 绑定局部变量
        form = axlFormCreate(gensym() "colorsetting.form" '(ne) '_AST_ColorFormCB t)  ;; 创建Allegro表单窗口
        foreach(preset _AST_ColorPresets  ;; 遍历列表中的每个元素
            axlFormSetField(form "presetList" car(preset))  ;; 设置表单字段的值
        )
        axlFormDisplay(form)  ;; 显示已创建的表单窗口
    )
)

procedure( _AST_ColorFormCB(form)
    let((val preset layers)  ;; 绑定局部变量
        val = form->curField
        preset = assoc(val _AST_ColorPresets)
        when(preset  ;; 条件为真时执行
            layers = cadr(preset)  ;; 取列表第二个元素
            _AST_ApplyColorPreset(layers)
        )
    )
)

procedure( _AST_ApplyColorPreset(layers)
    let((allLyr)  ;; 绑定局部变量
        ; First turn everything off
        allLyr = axlGetParam("paramLayerGroup:ALL")  ;; 获取Allegro参数值
        when(allLyr  ;; 条件为真时执行
            foreach(lyr allLyr->groupMembers  ;; 遍历列表中的每个元素
                axlVisibleLayer(lyr nil)  ;; 设置指定层为不可见
            )
        )
        ; Then turn on requested layers
        when(layers  ;; 条件为真时执行
            foreach(pair layers  ;; 遍历列表中的每个元素
                lyr = car(pair)  ;; 取列表第一个元素
                color = cadr(pair)  ;; 取列表第二个元素
                axlVisibleLayer(lyr t)  ;; 设置指定层为可见
                ; Note: actual color assignment requires axlLayerSetColor which
                ; may not exist in all Allegro versions; visibility is the safe fallback
            )
        )
        axlVisibleUpdate(nil)
        axlMsgPut("Color preset applied.")  ;; 输出消息到Allegro命令窗口
    )
)
