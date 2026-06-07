;; ============================================================
;; 文件名: keepout_create.il
;; 功能说明: 布线工具 - 禁止区域创建模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布线工具-创建禁布区 - 交互式创建shape或矩形禁布区
;; 文件路径 : modules/router/keepout_create.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    keepout_create.il
; Category:  router
; Purpose:   Interactive create keepout area (shape or rectangle)
; Command:   AST_CreateKeepout
; Source:    P1 rewrite of FanySkill_Keepout.il
;--------------------------------------------------------------------------

axlCmdRegister("AST_CreateKeepout" 'AST_CreateKeepout ?cmdType "interactive"
    ?doneCmd '_AST_KO_Done ?cancelCmd '_AST_KO_Cancel)

defvar(_AST_KOMode "shape")  ; "shape" or "rect"  ;; 创建模式: shape(多边形) 或 rect(矩形)

defvar(_AST_KOLayer "PACKAGE KEEPOUT/TOP")  ;; 默认目标层

defvar(_AST_KOExpand 0.0)  ;; 定义全局变量(仅首次赋值)

;;=========================================================================
;; 禁止区域创建主函数
;; 功能说明: 交互式创建禁止区域(shape或矩形)
;; 操作方式: 1) 选择创建模式(shape/rect) 2) 选择目标层 3) 绘制区域
;; 使用方式: 在Allegro命令行输入 AST_CreateKeepout 执行
;;=========================================================================

procedure( AST_CreateKeepout()
    let((mk popup)  ;; 绑定局部变量
        ; Ask for mode
        _AST_KOMode = if(axlUIConfirm("Create Keepout as:\n1=Shape (pick polygon)\n2=Rectangle (2 corners)")   ;; 弹出确认对话框显示信息
            then "shape"
            else "shape")
        
        ; Select target layer
        axlMsgPut("Keepout will be placed on %s" _AST_KOLayer)  ;; 输出消息到Allegro命令窗口
        
        mk = axlDBTransactionStart("AST_Keepout")  ;; 开始数据库事务，支持撤销操作
        popup = axlUIPopupDefine(nil '(("Done" _AST_KO_Done)  ;; 定义右键弹出菜单
                                     ("Cancel" _AST_KO_Cancel)))
        axlUIPopupSet(popup)  ;; 设置当前右键弹出菜单
        
        case(_AST_KOMode  ;; 多分支值匹配
            ("shape" _AST_KO_CreateShape(mk))
            ("rect"  _AST_KO_CreateRect(mk))
        )
    )
)

procedure( _AST_KO_CreateShape(mk)
    let((pts poly)  ;; 绑定局部变量
        axlMsgPut("Pick polygon points. Right-click Done to finish.")  ;; 输出消息到Allegro命令窗口
        pts = nil
        while(axlEnterPoint(?prompts '("Pick next point"))  ;; 启动交互点选模式，等待用户点击位置
            pt = axlLastPick(nil)
            when(pt pts = cons(pt pts))  ;; 条件为真时执行
        )
        when(pts  ;; 条件为真时执行
            pts = reverse(pts)
            poly = axlPolyFromPts(pts)
            when(poly  ;; 条件为真时执行
                axlDBCreateShape(poly nil _AST_KOLayer nil)  ;; 创建shape(铜皮/填充区域)
                axlDBTransactionCommit(mk)  ;; 提交数据库事务，确认修改
                axlMsgPut("Keepout shape created on %s" _AST_KOLayer)  ;; 输出消息到Allegro命令窗口
            )
        )
    )
)

procedure( _AST_KO_CreateRect(mk)
    let((p1 p2)  ;; 绑定局部变量
        axlMsgPut("Pick first corner of keepout rectangle.")  ;; 输出消息到Allegro命令窗口
        p1 = axlEnterPoint(?prompts '("First corner"))  ;; 启动交互点选模式，等待用户点击位置
        when(p1  ;; 条件为真时执行
            p1 = axlLastPick(nil)
            axlMsgPut("Pick opposite corner.")  ;; 输出消息到Allegro命令窗口
            p2 = axlEnterPoint(?prompts '("Opposite corner"))  ;; 启动交互点选模式，等待用户点击位置
            when(p2  ;; 条件为真时执行
                p2 = axlLastPick(nil)
                _AST_KO_DrawRect(p1 p2 mk)
            )
        )
    )
)

procedure( _AST_KO_DrawRect(p1 p2 mk)
    let((x1 y1 x2 y2 pts poly)  ;; 绑定局部变量
        x1 = min(car(p1) car(p2))  ;; 取列表第一个元素
        y1 = min(cadr(p1) cadr(p2))  ;; 取列表第二个元素
        x2 = max(car(p1) car(p2))  ;; 取列表第一个元素
        y2 = max(cadr(p1) cadr(p2))  ;; 取列表第二个元素
        pts = list(list(x1 y1) list(x2 y1) list(x2 y2) list(x1 y2))
        poly = axlPolyFromPts(pts)
        when(poly  ;; 条件为真时执行
            axlDBCreateShape(poly nil _AST_KOLayer nil)  ;; 创建shape(铜皮/填充区域)
            axlDBTransactionCommit(mk)  ;; 提交数据库事务，确认修改
            axlMsgPut("Keepout rectangle created on %s" _AST_KOLayer)  ;; 输出消息到Allegro命令窗口
        )
    )
)

procedure( _AST_KO_Done()
    axlFinishEnterFun()
)

procedure( _AST_KO_Cancel()
    axlCancelEnterFun()
)
