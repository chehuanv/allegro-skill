;; ============================================================
;; 文件名: coords.il
;; 功能说明: 输出工具 - 坐标输出模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 输出工具-坐标表导出 - 导出所有已放置器件的公制坐标表
;; 文件路径 : modules/output/coords.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Export Component Coordinates (Metric)                                       #
#  Command: AST_Out_Coords                                                             #
#  Desc:    Generate metric coordinate table for all placed components                 #
#  API:     axlDBGetDesign, outfile, fprintf                                           #
#########################################################################################
*/

axlCmdRegister("AST_Out_Coords" 'AST_Out_Coords ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 坐标输出主函数
;; 功能说明: 生成所有已放置器件的公制坐标表
;; 输出格式: RefDes(位号) X(mm) Y(mm) Rotation(旋转角) Side(层)
;; 输出文件: coordinates.txt
;; 使用方式: 在Allegro命令行输入 AST_Out_Coords 执行
;;=========================================================================

procedure( AST_Out_Coords()
  prog((comps port file design)  ;; 开始局部变量作用域块
    file = "coordinates.txt"  ;; 输出文件名
    port = outfile(file)  ;; 打开输出文件
    
    ;; Header
    fprintf(port "%-12s %-12s %-12s %-10s %-8s\n" "RefDes" "X(mm)" "Y(mm)" "Rotation" "Side")  ;; 格式化输出到文件
    fprintf(port "%-12s %-12s %-12s %-10s %-8s\n" "------" "-----" "-----" "--------" "----")  ;; 格式化输出到文件
    
    ;; Get components from design
    design = axlDBGetDesign()
    comps = design->components
    
    foreach( comp comps  ;; 遍历列表中的每个元素
      when( comp  ;; 条件为真时执行
        fprintf(port "%-12s %-12.3f %-12.3f %-10.1f %-8s\n"  ;; 格式化输出到文件
          comp->refdes
          AST_MilsToUnit(car(comp->xy) "millimeter")  ;; 取列表第一个元素
          AST_MilsToUnit(cadr(comp->xy) "millimeter")  ;; 取列表第二个元素
          comp->rotation
          comp->side
        )
      )
    )
    
    close(port)  ;; 关闭文件端口
    AST_Msg("INFO" sprintf(nil "Coordinates exported to %s (%d components)." file length(comps)))  ;; 格式化字符串
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
  )
)
