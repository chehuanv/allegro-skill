;; ============================================================
;; 文件名: check_cross_split.il
;; 功能说明: DFM检查 - 交叉分割检查模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : DFM检查-跨分割平面 - 检查信号是否跨分割平面导致参考层变化
;; 文件路径 : modules/check_dfm/check_cross_split.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Check Cross Split Plane                                                     #
#  Command: AST_Check_CrossSplit                                                       #
#  Desc:    Check if signals cross split planes (reference change)                     #
#########################################################################################
*/

axlCmdRegister("AST_Check_CrossSplit" 'AST_Check_CrossSplit ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 跨分割平面检查主函数
;; 功能说明: 检查信号走线是否跨过分割平面(参考平面变化)
;; 检查原理: 分析每个网络在不同层上的参考平面连续性
;; 返回值:   t(检查完成)
;; 使用方式: 在Allegro命令行输入 AST_Check_CrossSplit 执行
;;=========================================================================

procedure( AST_Check_CrossSplit()
  prog((nets)  ;; 开始局部变量作用域块
    nets = axlDBGetNets()  ;; 获取设计中所有网络
    ;; TODO: for each net, check if etch crosses anti-etch boundary on reference layer
    AST_Msg("INFO" "Cross split check: implement layer intersection analysis.")
    return(t)  ;; 从当前函数返回
  )
)
