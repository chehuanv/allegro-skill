;; ============================================================
;; 文件名: calculator.il
;; 功能说明: 通用工具 - 计算器模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 辅助工具-PCB电流计算器 - 根据IPC-2221公式计算最大允许电流
;; 文件路径 : modules/tools/calculator.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: PCB Trace Current Calculator                                                #
#  Command: AST_Tools_Calculator                                                       #
#  Desc:    Calculate max current based on IPC-2221 formula                            #
#  API:     axlFormCreate, axlFormDisplay                                              #  ;; 创建Allegro表单窗口
#########################################################################################
*/

axlCmdRegister("AST_Tools_Calculator" 'AST_Tools_Calculator ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

defvar(_calcForm nil)  ;; 计算器表单指针

;;=========================================================================
;; PCB电流计算器主函数
;; 功能说明: 根据IPC-2221公式计算走线最大载流能力
;; 计算参数: 线宽、铜厚、温升等
;; 使用方式: 在Allegro命令行输入 AST_Tools_Calculator 执行
;;=========================================================================

procedure( AST_Tools_Calculator()
  prog(()  ;; 开始局部变量作用域块
    when( _calcForm  ;; 条件为真时执行
      axlFormClose(_calcForm)  ;; 关闭表单窗口
      _calcForm = nil
    )
    _calcForm = axlFormCreate(gensym() "calculator.form" '(ne) '_calcCallback t)  ;; 创建计算器表单
    axlFormSetField(_calcForm "fWidth" 10.0)  ;; 设置表单字段的值
    axlFormSetField(_calcForm "fCopper" 1.0)  ;; 设置表单字段的值
    axlFormSetField(_calcForm "fTemp" 10.0)  ;; 设置表单字段的值
    axlFormDisplay(_calcForm)  ;; 显示已创建的表单窗口
    return(t)  ;; 从当前函数返回
  )
)

procedure( _calcCallback(form)
  case( form->curField  ;; 多分支值匹配
    ("btnCalc" _calcDoCalc(form))
    ("btnClose" axlFormClose(form) _calcForm = nil)  ;; 关闭表单窗口
  )
)

procedure( _calcDoCalc(form)
  prog((width copper temp k area current result)  ;; 开始局部变量作用域块
    width = atof(axlFormGetField(form "fWidth"))  ;; 获取表单字段的当前值
    copper = atof(axlFormGetField(form "fCopper"))  ;; 获取表单字段的当前值
    temp = atof(axlFormGetField(form "fTemp"))  ;; 获取表单字段的当前值
    
    when( and(width > 0 copper > 0 temp > 0)  ;; 条件为真时执行
      ;; IPC-2221 simplified formula for external layers
      ;; I = k * dT^0.44 * A^0.725
      ;; k = 0.024 for external, 0.048 for internal
      ;; A = width * copper_thickness (mils)
      ;; 1 oz = 1.37 mils
      k = 0.024
      area = width * copper * 1.37
      current = k * exp(0.44 * log(temp)) * exp(0.725 * log(area))
      
      result = sprintf(nil "Max Current: %.2f A (ext layer, IPC-2221)" current)  ;; 格式化字符串
      axlFormSetField(form "fResult" result)  ;; 设置表单字段的值
    else
      axlFormSetField(form "fResult" "Invalid input values.")  ;; 设置表单字段的值
    )
  )
)
