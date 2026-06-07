;; ============================================================
;; 文件名: check_refdes_dir.il
;; 功能说明: DFM检查 - 位号方向检查模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : DFM检查-位号方向 - 检查位号文字旋转角度是否与器件方向一致
;; 文件路径 : modules/check_dfm/check_refdes_dir.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Check Refdes Direction                                                      #
#  Command: AST_Check_RefDir                                                           #
#  Desc:    Check if REFDES text rotation matches component rotation (readable)        #
#  API:     axlHighlightObject, axlDBGetDesign                                         #  ;; 高亮显示指定对象，便于视觉识别
#########################################################################################
*/

axlCmdRegister("AST_Check_RefDir" 'AST_Check_RefDir ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 位号方向检查主函数
;; 功能说明: 检查REFDES文本旋转角度是否与器件旋转一致(确保可读性)
;; 检查原理: 比较器件旋转角度和位号文本旋转角度，标记不一致的器件
;; 返回值:   发现的问题数量
;; 使用方式: 在Allegro命令行输入 AST_Check_RefDir 执行
;;=========================================================================

procedure( AST_Check_RefDir()
  prog((comps count badList sym rot refObjs textRot diff)  ;; 开始局部变量作用域块
    comps = axlDBGetDesign()->components  ;; 获取设计中所有器件
    count = 0
    badList = nil  ;; 初始化问题列表
    
    foreach( comp comps  ;; 遍历列表中的每个元素
      when( comp  ;; 条件为真时执行
        sym = car(axlSelectByName("COMPONENT" comp->refdes))  ;; 启动交互选择模式，等待用户选择对象
        when( sym  ;; 条件为真时执行
          rot = sym->rotation
          
          ;; Check each REFDES text
          foreach( child sym->children  ;; 遍历列表中的每个元素
            when( child->objType == "text"  ;; 条件为真时执行
              when( index(child->layer "REF DES/SILKSCREEN")  ;; 条件为真时执行
                textRot = child->rotation
                ;; Normalize angles to 0-360
                rot = mod(rot 360)
                textRot = mod(textRot 360)
                
                ;; Calculate difference
                diff = abs(rot - textRot)  ;; 取绝对值
                when( diff > 180  diff = 360 - diff )  ;; 条件为真时执行
                
                ;; If difference > 90, text is upside-down or sideways
                when( diff > 90  ;; 条件为真时执行
                  count++
                  badList = cons(list(comp->refdes rot textRot) badList)  ;; 将元素添加到列表头部
                  axlHighlightObject(child)  ;; 高亮显示指定对象，便于视觉识别
                )
              )
            )
          )
        )
      )
    )
    
    when( count > 0  ;; 条件为真时执行
      let((port)  ;; 绑定局部变量
        port = outfile("refdir_report.txt")  ;; 打开输出文件用于写入
        fprintf(port "RefDes Direction Check Report\n")  ;; 格式化输出到文件
        fprintf(port "=============================\n")  ;; 格式化输出到文件
        foreach( item badList  ;; 遍历列表中的每个元素
          fprintf(port "RefDes: %s, CompRot: %.1f, TextRot: %.1f\n"  ;; 格式化输出到文件
            car(item) cadr(item) caddr(item))  ;; 取列表第一个元素
        )
        close(port)  ;; 关闭文件端口
      )
      AST_Msg("WARN" sprintf(nil "%d refdes direction issues found. See refdir_report.txt" count))  ;; 格式化字符串
    else
      AST_Msg("INFO" "All refdes directions are readable.")
    )
            axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
  )
)
