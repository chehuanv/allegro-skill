;; ============================================================
;; 文件名: place_inside.il
;; 功能说明: 布局工具 - 内部放置模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布局工具-区域内摆放 - 将选中器件摆放到用户定义的矩形区域内
;; 文件路径 : modules/layout/place_inside.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    place_inside.il
; Category:  layout
; Purpose:   Place selected components inside a user-defined rectangular area
; Command:   AST_PlaceInside
; Source:    P1 rewrite of FanySkill_Place_Inside.il
;--------------------------------------------------------------------------

axlCmdRegister("AST_PlaceInside" 'AST_PlaceInside ?cmdType "interactive"
    ?doneCmd '_AST_PI_Done ?cancelCmd '_AST_PI_Cancel)

;;=========================================================================
;; 内部放置主函数
;; 功能说明: 将选中的器件自动放置到用户指定的矩形区域内
;; 操作方式: 1) 选择器件 2) 框选放置区域 3) 自动排列
;; 使用方式: 在Allegro命令行输入 AST_PlaceInside 执行
;;=========================================================================

procedure( AST_PlaceInside()
    prog((syms p1 p2 mk)  ;; 开始局部变量作用域块
        ; Select symbols to place
        _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
        axlSetFindFilter(?enabled '(NOALL SYMBOLS) ?onButtons '(SYMBOLS))  ;; 设置查找过滤器:只允许选择符号(symbol)
        axlMsgPut("Select symbols to place inside area, then right-click Done.")  ;; 输出消息到Allegro命令窗口
        axlSelect()  ;; 启动交互选择模式，等待用户选择对象
        syms = axlGetSelSet()  ;; 获取选中的符号(器件)
        
        unless(syms  ;; 条件为假时执行
            axlMsgPut("No symbols selected.")  ;; 输出消息到Allegro命令窗口
                        axlDisplayFlush()  ;; 刷新显示，更新画布
return(nil)  ;; 从当前函数返回
        )
        
        ; Pick placement area
        axlMsgPut("Pick first corner of placement area.")  ;; 输出消息到Allegro命令窗口
        p1 = axlEnterPoint(?prompts '("First corner"))  ;; 启动交互点选模式，等待用户点击位置
        when(p1  ;; 条件为真时执行
            p1 = axlLastPick(nil)
            axlMsgPut("Pick opposite corner.")  ;; 输出消息到Allegro命令窗口
            p2 = axlEnterPoint(?prompts '("Opposite corner"))  ;; 启动交互点选模式，等待用户点击位置
            when(p2  ;; 条件为真时执行
                p2 = axlLastPick(nil)
                _AST_PlaceInsideArea(syms p1 p2)
            )
        )
    )
)

procedure( _AST_PlaceInsideArea(syms p1 p2)
    let((x1 y1 x2 y2 mk i sym symBbox cx cy)  ;; 绑定局部变量
        x1 = min(car(p1) car(p2))  ;; 取列表第一个元素
        y1 = min(cadr(p1) cadr(p2))  ;; 取列表第二个元素
        x2 = max(car(p1) car(p2))  ;; 取列表第一个元素
        y2 = max(cadr(p1) cadr(p2))  ;; 取列表第二个元素
        
        mk = axlDBTransactionStart("AST_PlaceInside")  ;; 开始数据库事务，支持撤销操作
        for(i 1 length(syms)  ;; C风格循环
            sym = nthelem(i syms)  ;; 获取列表第n个元素(1-based)
            symBbox = axlDBGetExtents(list(sym) t)
            when(symBbox  ;; 条件为真时执行
                ; Center of symbol
                cx = (caar(symBbox) + caadr(symBbox)) / 2.0
                cy = (cadar(symBbox) + cadadr(symBbox)) / 2.0
                
                ; Clamp to area
                cx = max(x1 + (caadr(symBbox) - caar(symBbox)) / 2.0,
                         min(cx, x2 - (caadr(symBbox) - caar(symBbox)) / 2.0))  ;; 取最小值
                cy = max(y1 + (cadadr(symBbox) - cadar(symBbox)) / 2.0,
                         min(cy, y2 - (cadadr(symBbox) - cadar(symBbox)) / 2.0))  ;; 取最小值
                
                ; Move symbol
                dx = cx - (caar(symBbox) + caadr(symBbox)) / 2.0
                dy = cy - (cadar(symBbox) + cadadr(symBbox)) / 2.0
                when(or(dx != 0 dy != 0)  ;; 条件为真时执行
                    axlTransformObject(sym ?move list(dx dy))  ;; 移动对象到指定位置
                )
            )
        )
        axlDBTransactionCommit(mk)  ;; 提交数据库事务，确认修改
        axlMsgPut("Placed %d symbols inside area." length(syms))  ;; 输出消息到Allegro命令窗口
    )
)

procedure( _AST_PI_Done()
    axlFinishEnterFun()
)

procedure( _AST_PI_Cancel()
    axlCancelEnterFun()
)
