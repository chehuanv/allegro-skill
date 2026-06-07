;; ============================================================
;; 文件名: cut_cline.il
;; 功能说明: 布局工具 - 切割走线模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布局工具-切割走线 - 在用户指定位置切断选中的cline
;; 文件路径 : modules/layout/cut_cline.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    cut_cline.il
; Category:  layout
; Purpose:   Cut selected cline at user-picked point
; Command:   AST_Layout_CutCline
;--------------------------------------------------------------------------

axlCmdRegister("AST_Layout_CutCline" 'AST_Layout_CutCline ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 切割走线主函数
;; 功能说明: 在用户指定位置将一条cline切割为两段
;; 操作方式: 1) 选择一条cline 2) 点击切割点 3) 自动分割
;; 使用方式: 在Allegro命令行输入 AST_Layout_CutCline 执行
;;=========================================================================

procedure( AST_Layout_CutCline()
    prog((cline pt pts cutIdx newPts1 newPts2 i n layer width netName mk segStart segEnd closestSeg)  ;; 开始局部变量作用域块
        ; Step 1: Prompt user to select ONE cline
        _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
        axlSetFindFilter(?enabled '(NOALL CLINES) ?onButtons '(CLINES))  ;; 设置查找过滤器:只允许选择cline(有电气属性的走线)
        axlMsgPut("[AST] Select ONE cline to cut, then right-click Done.")  ;; 输出消息到Allegro命令窗口
        axlSelect()  ;; 启动交互选择模式，等待用户选择对象
        cline = car(axlGetSelSet())  ;; 获取用户选中的第一条cline
        
        unless(cline  ;; 条件为假时执行
            axlMsgPut("[AST-WARN] No cline selected.")  ;; 输出警告消息到命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        when(cline->objType != "path"  ;; 条件为真时执行
            axlMsgPut("[AST-WARN] Selected object is not a cline/path.")  ;; 输出警告消息到命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        ; Step 2: Prompt for cut point
        axlMsgPut("[AST] Now pick the cut point on the cline.")  ;; 输出消息到Allegro命令窗口
        pt = axlEnterPoint(?prompts list("Pick cut point on the selected cline"))  ;; 启动交互点选模式，等待用户点击位置
        
        unless(pt  ;; 条件为假时执行
            axlMsgPut("[AST] Cancelled.")  ;; 输出消息到Allegro命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        ; Get cline properties
        pts    = cline->points
        layer  = cline->layer
        width  = cline->width
        netName = when(cline->net then cline->net->name else nil)
        n = length(pts)  ;; 获取列表长度
        
        when(n < 2  ;; 条件为真时执行
            axlMsgPut("[AST-WARN] Cline has too few points to cut.")  ;; 输出警告消息到命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        ; Find closest segment to the point and insert cut point
        closestSeg = _cutFindClosestSegment(pts pt)
        cutIdx = car(closestSeg)  ;; 取列表第一个元素
        
        when(or(cutIdx < 0 cutIdx >= n - 1)  ;; 条件为真时执行
            axlMsgPut("[AST-WARN] Cannot cut at this location.")  ;; 输出警告消息到命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        ; Build two new point lists
        ; First segment: pts[0..cutIdx] + pt
        newPts1 = nil
        i = 0
        while(i <= cutIdx
            newPts1 = cons(nth(i pts) newPts1)  ;; 将元素添加到列表头部
            i = i + 1
        )
        newPts1 = cons(pt newPts1)  ;; 将元素添加到列表头部
        newPts1 = reverse(newPts1)
        
        ; Second segment: pt + pts[cutIdx+1..n-1]
        newPts2 = list(pt)
        i = cutIdx + 1
        while(i < n
            newPts2 = cons(nth(i pts) newPts2)  ;; 将元素添加到列表头部
            i = i + 1
        )
        newPts2 = reverse(newPts2)
        
        ; Create two new paths and delete original
        mk = axlDBTransactionStart("AST_CutCline")  ;; 开始数据库事务，支持撤销操作
        
        ; Delete original cline first
        axlDBDelete(cline)
        
        ; Create first new cline
        if(netName then  ;; 条件分支判断
            axlDBCreatePath(newPts1 layer width netName)  ;; 从路径创建走线(path->cline)
        else
            axlDBCreatePath(newPts1 layer width nil)  ;; 从路径创建走线(path->cline)
        )
        
        ; Create second new cline
        if(netName then  ;; 条件分支判断
            axlDBCreatePath(newPts2 layer width netName)  ;; 从路径创建走线(path->cline)
        else
            axlDBCreatePath(newPts2 layer width nil)  ;; 从路径创建走线(path->cline)
        )
        
        axlDBTransactionCommit(mk)  ;; 提交数据库事务，确认修改
        
        axlMsgPut("[AST] Cline cut successfully into two segments.")  ;; 输出消息到Allegro命令窗口
        _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
        return(t)  ;; 从当前函数返回
    )
)

; Find index of the segment closest to target point
; Returns (segmentIndex distance)
procedure( _cutFindClosestSegment(pts target)
    prog((minDist minIdx i n dist p1 p2)  ;; 开始局部变量作用域块
        minDist = 1e9
        minIdx = 0
        n = length(pts)  ;; 获取列表长度
        i = 0
        
        while(i < n - 1
            p1 = nth(i pts)
            p2 = nth(i + 1 pts)
            ; Calculate distance from target to segment (simplified: use start point)
            dist = AST_PointDistance(p1 target)
            when(dist < minDist  ;; 条件为真时执行
                minDist = dist
                minIdx = i
            )
            i = i + 1
        )
        
                axlDisplayFlush()  ;; 刷新显示，更新画布
return(list(minIdx minDist))  ;; 从当前函数返回
    )
)
