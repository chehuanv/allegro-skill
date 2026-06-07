;; ============================================================
;; 文件名: diff_via_antipad.il
;; 功能说明: 布线工具 - 差分过孔反焊盘模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布线工具-差分过孔反焊盘 - 在差分对过孔周围创建反焊盘隔离区
;; 文件路径 : modules/router/diff_via_antipad.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    diff_via_antipad.il
; Category:  router
; Purpose:   Create anti-pad keepout around diff-pair vias
; Command:   AST_CreateDiffKeepout
; Source:    P1 rewrite of FanySkill_lnDiffViaAntiPad.il (DVAP)
;--------------------------------------------------------------------------

axlCmdRegister("AST_CreateDiffKeepout" 'AST_CreateDiffKeepout ?cmdType "general")

defvar(_AST_DiffKeepoutRadius 25.0)  ; default anti-pad radius in mils  ;; 默认反焊盘半径(单位:mils)
defvar(_AST_DiffKeepoutLayer "ANTI ETCH/ALL")  ;; 反焊盘所在层

;;=========================================================================
;; 差分过孔反焊盘主函数
;; 功能说明: 在差分对过孔周围创建反焊盘禁止区域
;; 操作方式: 自动识别差分对，在过孔周围生成圆形禁止区域
;; 参数设置: _AST_DiffKeepoutRadius - 反焊盘半径(默认25mil)
;; 使用方式: 在Allegro命令行输入 AST_CreateDiffKeepout 执行
;;=========================================================================

procedure( AST_CreateDiffKeepout()
    prog((diffPairs vias mk log count net1 net2 vias1 vias2 pt poly)  ;; 开始局部变量作用域块
        ; Get all differential pairs in design
        diffPairs = axlDBGetDesign()->diffPairs  ;; 获取所有差分对
        unless(diffPairs  ;; 条件为假时执行
            axlMsgPut("No differential pairs found in design.")  ;; 输出消息到Allegro命令窗口
                        axlDisplayFlush()  ;; 刷新显示，更新画布
return(nil)  ;; 从当前函数返回
        )
        
        mk = axlDBTransactionStart("AST_DiffKeepout")  ;; 开始数据库事务，支持撤销操作
        count = 0
        log = axlDMOpenLog("diff_keepout.log")  ;; 打开日志文件
        fprintf(log "# Diff Via Anti-Pad Keepout Report\n\n")  ;; 格式化输出到文件
        
        foreach(pair diffPairs  ;; 遍历列表中的每个元素
            net1 = pair->net1
            net2 = pair->net2
            
            ; Collect vias on both nets
            vias1 = when(net1 axlDBGetViaList(net1))
            vias2 = when(net2 axlDBGetViaList(net2))
            vias = append(vias1 vias2)  ;; 连接多个列表
            
            when(vias  ;; 条件为真时执行
                fprintf(log "Pair: %s (%s / %s) -> %d vias\n"   ;; 格式化输出到文件
                    pair->name net1->name net2->name length(vias))  ;; 获取列表长度
                
                foreach(via vias  ;; 遍历列表中的每个元素
                    pt = via->xy
                    when(pt  ;; 条件为真时执行
                        ; Create circular anti-pad keepout
                        poly = _AST_CreateCirclePoly(pt _AST_DiffKeepoutRadius)
                        when(poly  ;; 条件为真时执行
                            axlDBCreateShape(poly t _AST_DiffKeepoutLayer nil)  ;; 创建shape(铜皮/填充区域)
                            count++
                            axlHighlightObject(via)  ;; 高亮显示指定对象，便于视觉识别
                        )
                    )
                )
            )
        )
        
        axlDBTransactionCommit(mk)  ;; 提交数据库事务，确认修改
        fprintf(log "\nTotal keepouts created: %d\n" count)  ;; 格式化输出到文件
        axlDMClose(log)  ;; 关闭日志文件
        
        axlMsgPut("Diff keepout: %d anti-pads created on %d pairs. See diff_keepout.log"   ;; 输出消息到Allegro命令窗口
            count length(diffPairs))  ;; 获取列表长度
    )
)

; Create circular polygon around point
procedure( _AST_CreateCirclePoly(center radius)
    let((pts n step angle x y)  ;; 绑定局部变量
        pts = nil
        n = 32   ; 32 segments for smooth circle
        step = 2 * 3.14159265359 / n
        for(i 0 n  ;; C风格循环
            angle = i * step
            x = car(center) + radius * cos(angle)  ;; 取列表第一个元素
            y = cadr(center) + radius * sin(angle)  ;; 取列表第二个元素
            pts = cons(list(x y) pts)  ;; 将元素添加到列表头部
        )
        axlPolyFromPts(reverse(pts))
    )
)
