;; ============================================================
;; 文件名: cline_to_shape.il
;; 功能说明: 布线工具 - 走线转铜皮模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布线工具-走线转铜皮 - 将选中的cline/line转换为shape铜皮
;; 文件路径 : modules/router/cline_to_shape.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    cline_to_shape.il
; Category:  router
; Purpose:   Convert selected clines/lines into shapes
; Command:   AST_ClineToShape
; Source:    FanySkill — ported to AllegroSkillToolbox
;--------------------------------------------------------------------------

axlCmdRegister("AST_ClineToShape" 'AST_ClineToShape ?cmdType "interactive"
    ?doneCmd 'AST_C2S_Done ?cancelCmd 'AST_C2S_Cancel)

;;=========================================================================
;; 走线转铜皮主函数
;; 功能说明: 将选中的cline/line转换为shape铜皮
;; 操作方式: 1) 选择cline/line 2) 设置转换参数 3) 执行转换
;; 使用方式: 在Allegro命令行输入 AST_ClineToShape 执行
;;=========================================================================

procedure( AST_ClineToShape()
    let(()  ;; 绑定局部变量
        axlSetFindFilter(?enabled list("noall" "clines" "lines")  ;; 设置过滤器，允许选择cline和line
                         ?onButtons list("noall" "clines" "lines"))
        AST_C2S_popup = axlUIPopupDefine(nil (list  ;; 定义右键弹出菜单
            (list "Done" 'AST_C2S_Done)
            (list "Undo" 'AST_C2S_unDo)
            (list "Cancel" 'AST_C2S_Cancel)
        ))
        axlUIPopupSet(AST_C2S_popup)  ;; 设置当前右键弹出菜单

        AST_C2S_mark = axlDBTransactionStart("AST_Cline2Shape")  ;; 开始数据库事务，支持撤销操作
        notdone = t
        while(notdone
            lclines = axlGetSelSet(axlSelect(?prompt "Select Clines to convert to a shape."))  ;; 启动交互选择模式，等待用户选择对象
            if(lclines then  ;; 条件分支判断
                foreach(clinedbid lclines  ;; 遍历列表中的每个元素
                    layer = car(axlGetSelSet())->layer  ;; 获取当前选择集中的对象列表
                    polydbid = axlPolyFromDB(clinedbid ?endCapType "ROUND")
                    if(polydbid then  ;; 条件分支判断
                        if(null(axlDBCreateShape(car(polydbid) t layer)) then  ;; 创建shape(铜皮/填充区域)
                            axlUIWPrint(nil "** Error. Failed to create Shape from Cline. **")
                        )
                        if(cadr(polydbid) then  ;; 条件分支判断
                            axlDBCreateShape(cadr(polydbid) t layer)  ;; 创建shape(铜皮/填充区域)
                        )
                    else
                        axlUIWPrint(nil "** Error. Failed to create Polydbid from Cline. **")
                    )
                )
            )
        )
        axlDBTransactionCommit(AST_C2S_mark)  ;; 提交数据库事务，确认修改
    )
)

procedure( AST_C2S_unDo()
    let(()  ;; 绑定局部变量
        if(null(axlDBTransactionOops(AST_C2S_mark)) then  ;; 条件分支判断
            axlUIWPrint(nil "-- Nothing Left To Undo. --")
        else
            axlUIWPrint(nil "-- Replacing Clines. --")
        )
        _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
    )
)

procedure( AST_C2S_Cancel()
    let(()  ;; 绑定局部变量
        axlUIWPrint(nil "** Cancelled Program. **")
        notdone = nil
        _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
        axlCancelEnterFun()
    )
)

procedure( AST_C2S_Done()
    let(()  ;; 绑定局部变量
        axlUIWPrint(nil "- Done -")
        axlDBTransactionCommit(AST_C2S_mark)  ;; 提交数据库事务，确认修改
        notdone = nil
        axlCancelEnterFun()
    )
)
