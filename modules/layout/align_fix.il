;; ============================================================
;; 文件名: align_fix.il
;; 功能说明: 布局工具 - 对齐修复模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
/*
;########################################################################################
;  AllegroSkillToolbox Align Module - FIX PATCH
;  Fixes:
;  1. _AST_AlignSnapPoint snap bug for move vectors
;  2. Adds _AST_AlignSnapMove (snap only non-zero components)
;  3. Adds "center" mode (both horizontal and vertical)
;  4. Adds AST_Layout_Center command (command-line)
;
;########################################################################################
*/

;------------------------------------------------------------------------
; FIX 1: New snap function - only snaps non-zero components of move vectors
;------------------------------------------------------------------------
procedure( _AST_AlignSnapMove(dx dy grids)  ;; 修复后的吸附函数 - 仅对非零分量进行栅格吸附
    prog((xMaj yMaj)  ;; 开始局部变量作用域块
        when(_AST_AlignFormData->snapToGrid  ;; 条件为真时执行
            xMaj = grids->xMajor
            yMaj = grids->yMajor
            when(abs(dx) > 0.001  ;; 条件为真时执行
                dx = round(dx / xMaj) * xMaj  ;; 四舍五入取整
            )
            when(abs(dy) > 0.001  ;; 条件为真时执行
                dy = round(dy / yMaj) * yMaj  ;; 四舍五入取整
            )
        )
        return(list(dx dy))  ;; 从当前函数返回
    )
)

;------------------------------------------------------------------------
; FIX 2: Replace _AST_AlignDoMove - unified snap, added center mode
;------------------------------------------------------------------------
procedure( _AST_AlignDoMove(modeName)
    prog((target i obj bbox dy dx bboxes sel grids moveVec)  ;; 开始局部变量作用域块
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
                    dy = _AST_AlignGetMaxY(bboxes) - cadadr(bbox)
                )
                ("bottom"
                    dy = _AST_AlignGetMinY(bboxes) - cadar(bbox)
                )
                ("left"
                    dx = _AST_AlignGetMinX(bboxes) - caar(bbox)
                )
                ("right"
                    dx = _AST_AlignGetMaxX(bboxes) - caadr(bbox)
                )
                ; CenterH = horizontal row = align to horizontal center line = change Y
                ("centerH"
                    dy = (_AST_AlignGetMinY(bboxes) + _AST_AlignGetMaxY(bboxes)) / 2.0 - (cadar(bbox) + cadadr(bbox)) / 2.0
                )
                ; CenterV = vertical row = align to vertical center line = change X
                ("centerV"
                    dx = (_AST_AlignGetMinX(bboxes) + _AST_AlignGetMaxX(bboxes)) / 2.0 - (caar(bbox) + caadr(bbox)) / 2.0
                )
                ; NEW: center mode = both horizontal and vertical center
                ("center"
                    dx = (_AST_AlignGetMinX(bboxes) + _AST_AlignGetMaxX(bboxes)) / 2.0 - (caar(bbox) + caadr(bbox)) / 2.0
                    dy = (_AST_AlignGetMinY(bboxes) + _AST_AlignGetMaxY(bboxes)) / 2.0 - (cadar(bbox) + cadadr(bbox)) / 2.0
                )
            )
            ; FIX: Unified snap for move vectors (only snap non-zero components)
            moveVec = _AST_AlignSnapMove(dx dy grids)
            dx = car(moveVec)  ;; 取列表第一个元素
            dy = cadr(moveVec)  ;; 取列表第二个元素
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
; FIX 3: New command - Center both horizontal and vertical (command-line)
;------------------------------------------------------------------------
;;=========================================================================
;; 对齐工具修复补丁 V1
;; 修复内容: 1) 修复移动向量吸附栅格的bug 2) 添加中心对齐模式
;; 修复原理: 只对非零分量的移动向量进行栅格吸附，避免误吸附
;; 使用方式: 自动加载，修复对齐工具的已知问题
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
