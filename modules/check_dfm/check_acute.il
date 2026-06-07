;; ============================================================
;; 文件名: check_acute.il
;; 功能说明: DFM检查 - 锐角检查模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : DFM检查-锐角走线 - 查找并高亮小于90度的锐角走线
;; 文件路径 : modules/check_dfm/check_acute.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Check Acute Angle Traces                                                    #
#  Command: AST_Check_Acute                                                            #
#  Desc:    Find traces with acute angles (< 90 deg) and highlight/report              #
#  API:     axlDBGetNets, axlHighlightObject                                           #  ;; 高亮显示指定对象，便于视觉识别
#########################################################################################
*/

axlCmdRegister("AST_Check_Acute" 'AST_Check_Acute ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 锐角检查主函数
;; 功能说明: 遍历所有网络，检查走线是否存在小于90度的锐角
;; 检查原理: 获取每条走线的线段，计算相邻线段之间的夹角
;; 返回值:   发现的锐角数量
;; 使用方式: 在Allegro命令行输入 AST_Check_Acute 执行
;;=========================================================================

procedure( AST_Check_Acute()
  prog((nets count acuteList segList p1 p2 p3 v1 v2 dot len1 len2 angle)  ;; 开始局部变量作用域块
    count = 0  ;; 初始化计数器，记录发现的锐角数量
    acuteList = nil  ;; 初始化锐角列表，用于存储发现的问题点
    nets = axlDBGetNets()  ;; 获取设计中所有网络列表
    
    AST_Msg("INFO" "Checking for acute angles (< 90°)...")
    
    foreach( net nets  ;; 遍历列表中的每个元素
      ;; Get all segments (paths) for this net
      segList = net->segments
      
      ;; Check each pair of consecutive segments
      for( i 0 length(segList) - 2  ;; C风格循环
        prog((segA segB ptsA ptsB)  ;; 开始局部变量作用域块
          segA = nth(i segList)
          segB = nth(i + 1 segList)
          
          when( and(segA segB segA->objType == "path" segB->objType == "path")  ;; 条件为真时执行
            ptsA = segA->points
            ptsB = segB->points
            
            ;; Get shared point and endpoints
            p1 = car(ptsA)      ;; start of segA
            p2 = car(last(ptsA)) ;; end of segA (should be start of segB)
            p3 = car(last(ptsB)) ;; end of segB
            
            ;; Calculate vectors
            v1 = list(car(p2) - car(p1) cadr(p2) - cadr(p1))  ;; 取列表第一个元素
            v2 = list(car(p3) - car(p2) cadr(p3) - cadr(p2))  ;; 取列表第一个元素
            
            ;; Calculate angle using dot product
            len1 = sqrt(car(v1)*car(v1) + cadr(v1)*cadr(v1))  ;; 取列表第一个元素
            len2 = sqrt(car(v2)*car(v2) + cadr(v2)*cadr(v2))  ;; 取列表第一个元素
            
            when( and(len1 > 0 len2 > 0)  ;; 条件为真时执行
              dot = (car(v1)*car(v2) + cadr(v1)*cadr(v2)) / (len1 * len2)  ;; 取列表第一个元素
              ;; Clamp to [-1, 1] to avoid acos domain error
              when( dot > 1.0  dot = 1.0 )  ;; 条件为真时执行
              when( dot < -1.0 dot = -1.0 )  ;; 条件为真时执行
              angle = acos(dot) * 180.0 / 3.14159265359
              
              when( angle < 90.0  ;; 条件为真时执行
                count = count + 1
                acuteList = cons(list(net->name angle p2) acuteList)  ;; 将元素添加到列表头部
                axlHighlightObject(segA)  ;; 高亮显示指定对象，便于视觉识别
                axlHighlightObject(segB)  ;; 高亮显示指定对象，便于视觉识别
              )
            )
          )
        )
      )
    )
    
    ;; Report results
    when( count > 0  ;; 条件为真时执行
      AST_Msg("WARN" sprintf(nil "Found %d acute angle violations." count))  ;; 格式化字符串
      ;; Write report to file
      let((port)  ;; 绑定局部变量
        port = outfile("acute_angle_report.txt")  ;; 打开输出文件用于写入
        fprintf(port "Acute Angle Check Report\n")  ;; 格式化输出到文件
        fprintf(port "========================\n")  ;; 格式化输出到文件
        foreach( item acuteList  ;; 遍历列表中的每个元素
          fprintf(port "Net: %s, Angle: %.1f°, Location: (%.3f, %.3f)\n"  ;; 格式化输出到文件
            car(item) cadr(item) car(caddr(item)) cadr(caddr(item)))  ;; 取列表第一个元素
        )
        close(port)  ;; 关闭文件端口
      )
      AST_Msg("INFO" "Report saved to acute_angle_report.txt")
    else
      AST_Msg("INFO" "No acute angle violations found.")
    )
            axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
  )
)
