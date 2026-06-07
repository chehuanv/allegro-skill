;; ============================================================
;; 文件名: align_fix_v2.il
;; 功能说明: 布局工具 - 对齐修复V2模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
/*
;########################################################################################
;  AllegroSkillToolbox Align Module - FIX v2
;  Root Cause: _AST_AlignSnapMove rounds per-object independently
;  Fix: Snap the TARGET line first (same for all), then move each object to it
; 
;########################################################################################
*/

;------------------------------------------------------------------------
; FIX v2: Snap TARGET position (not move vector) — ensures all objects align to same line
;------------------------------------------------------------------------
procedure( _AST_AlignSnapTarget(val axis grids)  ;; V2修复: 统一吸附目标线位置
    prog((maj org)  ;; 开始局部变量作用域块
        when(_AST_AlignFormData->snapToGrid  ;; 条件为真时执行
            if(axis == "x" then  ;; 条件分支判断
                maj = grids->xMajor
                org = grids->xOrigin
            else
                maj = grids->yMajor
                org = grids->yOrigin
            )
            val = round((val - org) / maj) * maj + org  ;; 四舍五入取整
        )
        return(val)  ;; 从当前函数返回
    )
)

;------------------------------------------------------------------------
; FIX v2: Replace _AST_AlignDoMove — snap target line, not per-object move
;------------------------------------------------------------------------
procedure( _AST_AlignDoMove(modeName)
    prog((target i obj bbox dy dx bboxes sel grids targetX targetY)  ;; 开始局部变量作用域块
        sel    = _AST_AlignSelSet
        bboxes = _AST_AlignBBoxList
        when(or(null(sel) null(bboxes))  ;; 条件为真时执行
            axlMsgPut("[AST] No stored selection.")  ;; 输出消息到Allegro命令窗口
                        axlDisplayFlush()  ;; 刷新显示，更新画布
return(nil)  ;; 从当前函数返回
        )
        grids = _AST_AlignGetCurrentGrid()

        for(i 1 length(sel)  ;; C风格循环
            obj  = nthelem(i sel)  ;; 获取列表第n个元素(1-based)
            bbox = nthelem(i bboxes)  ;; 获取列表第n个元素(1-based)
            dx = 0
            dy = 0
            case(modeName  ;; 多分支值匹配
                ("top"
                    ; Common target: max Y of all bboxes, snapped to grid
                    targetY = _AST_AlignGetMaxY(bboxes)
                    targetY = _AST_AlignSnapTarget(targetY "y" grids)
                    dy = targetY - cadadr(bbox)
                )
                ("bottom"
                    targetY = _AST_AlignGetMinY(bboxes)
                    targetY = _AST_AlignSnapTarget(targetY "y" grids)
                    dy = targetY - cadar(bbox)
                )
                ("left"
                    targetX = _AST_AlignGetMinX(bboxes)
                    targetX = _AST_AlignSnapTarget(targetX "x" grids)
                    dx = targetX - caar(bbox)
                )
                ("right"
                    targetX = _AST_AlignGetMaxX(bboxes)
                    targetX = _AST_AlignSnapTarget(targetX "x" grids)
                    dx = targetX - caadr(bbox)
                )
                ; CenterH = horizontal row = align to horizontal center line = change Y
                ("centerH"
                    targetY = (_AST_AlignGetMinY(bboxes) + _AST_AlignGetMaxY(bboxes)) / 2.0
                    targetY = _AST_AlignSnapTarget(targetY "y" grids)
                    dy = targetY - (cadar(bbox) + cadadr(bbox)) / 2.0
                )
                ; CenterV = vertical row = align to vertical center line = change X
                ("centerV"
                    targetX = (_AST_AlignGetMinX(bboxes) + _AST_AlignGetMaxX(bboxes)) / 2.0
                    targetX = _AST_AlignSnapTarget(targetX "x" grids)
                    dx = targetX - (caar(bbox) + caadr(bbox)) / 2.0
                )
                ; NEW: center mode = both horizontal and vertical center
                ("center"
                    targetX = (_AST_AlignGetMinX(bboxes) + _AST_AlignGetMaxX(bboxes)) / 2.0
                    targetX = _AST_AlignSnapTarget(targetX "x" grids)
                    dx = targetX - (caar(bbox) + caadr(bbox)) / 2.0
                    targetY = (_AST_AlignGetMinY(bboxes) + _AST_AlignGetMaxY(bboxes)) / 2.0
                    targetY = _AST_AlignSnapTarget(targetY "y" grids)
                    dy = targetY - (cadar(bbox) + cadadr(bbox)) / 2.0
                )
            )
            when(or(abs(dx) > 0.001 abs(dy) > 0.001)  ;; 条件为真时执行
                mk = axlDBTransactionStart("AST_Align")  ;; 开始事务，支持撤销
            axlTransformObject(obj ?move list(dx dy))  ;; 移动对象到指定位置
            )
        )
        axlMsgPut("[AST] Aligned %d objects: %s" length(sel) modeName)
        axlDBTransactionCommit(mk)  ;; 提交事务，确认修改  ;; 输出消息到Allegro命令窗口
    )
)

;------------------------------------------------------------------------
; v2 command: Center both horizontal and vertical (command-line)
;------------------------------------------------------------------------
;;=========================================================================
;; 对齐工具修复补丁 V2
;; 修复内容: 修复目标线吸附不一致的问题
;; 修复原理: 先统一吸附目标线位置(所有对象共用)，再移动各对象到目标线
;; 根本原因: V1中每个对象独立吸附导致对齐后位置不一致
;; 使用方式: 自动加载，替换V1修复方案
;;=========================================================================

procedure( AST_Layout_Center()
    prog((sel bboxes)  ;; 开始局部变量作用域块
        when(axlOKToProceed()  ;; 条件为真时执行
            _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
            axlSetFindFilter(?enabled '(GROUPS SYMBOLS PINS VIAS TEXT NAMEFORM) ?onButtons '(SYMBOLS))  ;; 设置查找过滤器，限定可选择对象类型
            axlMsgPut("[AST] Select object(s) to center align")  ;; 输出消息到Allegro命令窗口
            axlSelect(?groupMode nil)  ;; 启动交互选择模式，等待用户选择对象
            sel = axlGetSelSet()  ;; 获取当前选择集中的对象列表
            when(sel  ;; 条件为真时执行
                bboxes = _AST_AlignGetBBoxes(sel)
                when(and(bboxes length(bboxes) >= 2)  ;; 条件为真时执行
                    _AST_AlignSelSet = sel
                    _AST_AlignBBoxList = bboxes
                    _AST_AlignInitFormData()
                    _AST_AlignDoMove("center")
                )
                unless(and(bboxes length(bboxes) >= 2)  ;; 条件为假时执行
                    axlMsgPut("[AST] Need 2+ valid objects.")  ;; 输出消息到Allegro命令窗口
                )
            )
            unless(sel  ;; 条件为假时执行
                axlMsgPut("[AST] No objects selected.")  ;; 输出消息到Allegro命令窗口
            )
        )
    )
)
