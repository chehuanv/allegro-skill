;; ============================================================
;; 文件名: impedance.il
;; 功能说明: 特殊工具 - 阻抗计算模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 特殊工具-阻抗计算 - 根据层叠结构计算走线阻抗
;; 文件路径 : modules/special/impedance.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Impedance Calculator                                                        #
#  Command: AST_Special_Impedance                                                      #
#  Desc:    Calculate trace impedance based on layer stackup                           #
#  API:     axlGetParam, axlXSectionGet                                                #  ;; 获取Allegro参数值
#########################################################################################
*/

axlCmdRegister("AST_Special_Impedance" 'AST_Special_Impedance ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 阻抗计算主函数
;; 功能说明: 根据层叠结构计算走线阻抗
;; 计算原理: 获取层叠参数(介电常数、层厚、线宽)，使用公式计算特性阻抗
;; 使用方式: 在Allegro命令行输入 AST_Special_Impedance 执行
;;=========================================================================

procedure( AST_Special_Impedance()
  prog((cs layers h er w z0 msg)  ;; 开始局部变量作用域块
    cs = axlGetParam("paramLayerGroup:CROSSSECTION")  ;; 获取层叠截面参数
    unless( cs  ;; 条件为假时执行
      axlUIConfirm("No cross section defined. Please set up layer stackup first.")  ;; 弹出确认对话框显示信息
      return(nil)  ;; 从当前函数返回
    )
    
    layers = cs->groupMembers
    
    ;; Simplified: ask user for key parameters
    h = atof(axlUIDataBrowse("Dielectric thickness (mils)" 'string "4.0" nil))  ;; 字符串转浮点数
    er = atof(axlUIDataBrowse("Dielectric constant (Er)" 'string "4.2" nil))  ;; 字符串转浮点数
    w = atof(axlUIDataBrowse("Trace width (mils)" 'string "10.0" nil))  ;; 字符串转浮点数
    
    when( and(h > 0 er > 0 w > 0)  ;; 条件为真时执行
      ;; Microstrip simplified formula
      ;; Z0 = 87 / sqrt(Er + 1.41) * ln(5.98 * h / (0.8*w + t))
      ;; Ignoring copper thickness t for simplicity
      z0 = 87.0 / sqrt(er + 1.41) * log(5.98 * h / (0.8 * w))  ;; 计算平方根
      
      msg = sprintf(nil "Microstrip Impedance (approx):\nZ0 = %.1f Ohm\nWidth = %.2f mils\nHeight = %.2f mils\nEr = %.2f" z0 w h er)  ;; 格式化字符串
      axlUIConfirm(msg)  ;; 弹出确认对话框显示信息
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
    )
  )
)
