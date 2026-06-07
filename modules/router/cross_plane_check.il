;; ============================================================
;; 文件名: cross_plane_check.il
;; 功能说明: 布线工具 - 跨平面检查模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布线工具-跨平面检查 - 检查蚀刻走线是否跨越分割平面边界
;; 文件路径 : modules/router/cross_plane_check.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    cross_plane_check.il
; Category:  router
; Purpose:   Check if etch traces cross split plane boundaries (reference gap)
; Command:   AST_CheckCrossPlane
; Source:    P1 rewrite of FanySkill_etch_cross_plane.il
;--------------------------------------------------------------------------

axlCmdRegister("AST_CheckCrossPlane" 'AST_CheckCrossPlane ?cmdType "general")

;;=========================================================================
;; 跨平面检查主函数
;; 功能说明: 检查走线是否跨过分割平面边界(参考层不连续)
;; 检查原理: 获取动态铜皮形状，检查走线与铜皮边界的关系
;; 使用方式: 在Allegro命令行输入 AST_CheckCrossPlane 执行
;;=========================================================================

procedure( AST_CheckCrossPlane()
    prog((shapes clines splitLayers offenders log cLayer cPath pt unique cl off)  ;; 开始局部变量作用域块
        ; Get all split plane shapes (dynamic shapes on etch layers)
        shapes = setof(x axlDBGetDesign()->shapes  ;; 获取所有动态铜皮形状
            when(x->layer  ;; 条件为真时执行
                and(rexMatchp("^ETCH" x->layer) x->isDynamic == t)  ;; 正则表达式匹配检查
            )
        )
        
        unless(shapes  ;; 条件为假时执行
            axlMsgPut("No dynamic split planes found. Run DRC or assign shapes first.")  ;; 输出消息到Allegro命令窗口
                        axlDisplayFlush()  ;; 刷新显示，更新画布
return(nil)  ;; 从当前函数返回
        )
        
        ; Get all clines on corresponding etch layers
        clines = axlDBGetDesign()->clines  ;; 获取设计中所有cline(有电气属性的走线)
        offenders = nil
        
        foreach(cline clines  ;; 遍历列表中的每个元素
            cLayer = cline->layer
            cPath  = cline->path
            when(cPath  ;; 条件为真时执行
                foreach(pt cPath  ;; 遍历列表中的每个元素
                    ; Check if point falls inside any split plane shape on same layer
                    foreach(shape shapes  ;; 遍历列表中的每个元素
                        when(shape->layer == cLayer  ;; 条件为真时执行
                            if(null(axlGeoPointInShape(pt shape)) then  ;; 条件分支判断
                                ; Point is outside the shape = crosses gap
                                offenders = cons(list(cline pt shape) offenders)  ;; 将元素添加到列表头部
                            )
                        )
                    )
                )
            )
        )
        
        ; De-duplicate by cline
        unique = nil
        foreach(off offenders  ;; 遍历列表中的每个元素
            cl = car(off)  ;; 取列表第一个元素
            when(null(member(cl unique))  ;; 条件为真时执行
                unique = cons(cl unique)  ;; 将元素添加到列表头部
                axlHighlightObject(cl)  ;; 高亮显示指定对象，便于视觉识别
            )
        )
        
        ; Log
        log = axlDMOpenLog("cross_plane.log")  ;; 打开日志文件
        fprintf(log "# Cross-Plane Check Report\n\n")  ;; 格式化输出到文件
        fprintf(log "Total split planes: %d\n" length(shapes))  ;; 格式化输出到文件
        fprintf(log "Total offending traces: %d\n\n" length(unique))  ;; 格式化输出到文件
        foreach(off offenders  ;; 遍历列表中的每个元素
            fprintf(log "Cline %s on %s crosses gap near %L\n"  ;; 格式化输出到文件
                car(off)->name car(off)->layer cadr(off))  ;; 取列表第一个元素
        )
        axlDMClose(log)  ;; 关闭日志文件
        
        axlMsgPut("Cross-plane check: %d traces cross split gaps. See cross_plane.log" length(unique))  ;; 输出消息到Allegro命令窗口
    )
)
