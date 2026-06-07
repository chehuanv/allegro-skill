;; ============================================================
;; 文件名: cline_cross_check.il
;; 功能说明: 布线工具 - 走线交叉检查模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布线工具-走线交叉检查 - 查找并报告相互交叉的走线(串扰风险)
;; 文件路径 : modules/router/cline_cross_check.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    cline_cross_check.il
; Category:  router
; Purpose:   Find and report clines/lines that cross each other (X-talk risk)
; Command:   AST_ClineCrossCheck
; Source:    P1 rewrite of FanySkill_Cline_Cross.il
;--------------------------------------------------------------------------

axlCmdRegister("AST_ClineCrossCheck" 'AST_ClineCrossCheck ?cmdType "general")

;;=========================================================================
;; 走线交叉检查主函数
;; 功能说明: 查找并报告相互交叉的走线/线段(串扰风险)
;; 检查原理: 遍历所有cline和line，检测线段之间的交叉点
;; 输出结果: 将交叉点信息写入日志
;; 使用方式: 在Allegro命令行输入 AST_ClineCrossCheck 执行
;;=========================================================================

procedure( AST_ClineCrossCheck()
    prog((allClines crossPairs i j c1 c2 seg1 seg2 pts crosses log lines allObjs n obj1 obj2 pt)  ;; 开始局部变量作用域块
        ; Collect all clines and lines in design
        allClines = axlDBGetDesign()->clines  ;; 获取所有走线
        when(null(allClines) allClines = nil)  ;; 条件为真时执行
        ; Also get standalone lines
        lines = setof(x axlDBGetDesign()->lines x != nil)  ;; 获取所有独立线段
        allObjs = append(allClines lines)  ;; 连接多个列表
        
        unless(allObjs  ;; 条件为假时执行
            axlMsgPut("No clines or lines found in design.")  ;; 输出消息到Allegro命令窗口
            return(nil)  ;; 从当前函数返回
        )
        
        crossPairs = nil
        n = length(allObjs)  ;; 获取列表长度
        
        for(i 1 n - 1  ;; C风格循环
            c1 = nthelem(i allObjs)  ;; 获取列表第n个元素(1-based)
            for(j i + 1 n  ;; C风格循环
                c2 = nthelem(j allObjs)  ;; 获取列表第n个元素(1-based)
                when(c1 != c2  ;; 条件为真时执行
                    ; Get line segments
                    seg1 = c1->segments
                    seg2 = c2->segments
                    when(and(seg1 seg2)  ;; 条件为真时执行
                        pts = _AST_SegmentsCross(seg1 seg2)
                        when(pts  ;; 条件为真时执行
                            crossPairs = cons(list(c1 c2 pts) crossPairs)  ;; 将元素添加到列表头部
                        )
                    )
                )
            )
        )
        
        ; Report
        log = axlDMOpenLog("cline_cross.log")  ;; 打开日志文件
        fprintf(log "# Cline Cross Check Report\n\n")  ;; 格式化输出到文件
        crosses = length(crossPairs)  ;; 获取列表长度
        when(crossPairs  ;; 条件为真时执行
            foreach(pair crossPairs  ;; 遍历列表中的每个元素
                obj1 = car(pair)  ;; 取列表第一个元素
                obj2 = cadr(pair)  ;; 取列表第二个元素
                pt   = caddr(pair)  ;; 取列表第三个元素
                fprintf(log "Cross: %s <-> %s at %L\n" obj1->name obj2->name pt)  ;; 格式化输出到文件
                axlHighlightObject(obj1)  ;; 高亮显示指定对象，便于视觉识别
                axlHighlightObject(obj2)  ;; 高亮显示指定对象，便于视觉识别
            )
        )
        fprintf(log "\nTotal crossings found: %d\n" crosses)  ;; 格式化输出到文件
        axlDMClose(log)  ;; 关闭日志文件
        
        axlMsgPut("Cline cross check: %d crossings found. See cline_cross.log" crosses)  ;; 输出消息到Allegro命令窗口
        axlMsgPut("Crossed clines highlighted in design.")  ;; 输出消息到Allegro命令窗口
    )
)

; Check if any segments from two objects cross
procedure( _AST_SegmentsCross(segs1 segs2)
    let((s1 s2 result)  ;; 绑定局部变量
        result = nil
        foreach(seg1 segs1  ;; 遍历列表中的每个元素
            foreach(seg2 segs2  ;; 遍历列表中的每个元素
                pt = _AST_LinesIntersect(seg1->start seg1->end seg2->start seg2->end)
                when(pt result = pt)  ;; 条件为真时执行
            )
        )
        result
    )
)

; Line intersection test (2D)
procedure( _AST_LinesIntersect(p1 p2 p3 p4)
    let((x1 y1 x2 y2 x3 y3 x4 y4 denom tt s pt)  ;; 绑定局部变量
        x1 = car(p1)  y1 = cadr(p1)  ;; 取列表第一个元素
        x2 = car(p2)  y2 = cadr(p2)  ;; 取列表第一个元素
        x3 = car(p3)  y3 = cadr(p3)  ;; 取列表第一个元素
        x4 = car(p4)  y4 = cadr(p4)  ;; 取列表第一个元素
        
        denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
        when(denom != 0  ;; 条件为真时执行
            tt = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
            s = ((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2)) / denom
            when(and(tt > 0 tt < 1 s > 0 s < 1)  ;; 条件为真时执行
                pt = list(x1 + tt * (x2 - x1) y1 + tt * (y2 - y1))
                return(pt)  ;; 从当前函数返回
            )
        )
        nil
    )
)
