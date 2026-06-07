;; ============================================================
;; 文件名: unit_convert.il
;; 功能说明: 通用工具 - 单位转换模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 辅助工具-单位转换 - 在mils/mm/inch/micron/cm之间转换
;; 文件路径 : modules/tools/unit_convert.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Unit Converter                                                              #
#  Command: AST_Tools_UnitConvert                                                      #
#  Desc:    Convert between mils, mm, inch, micron, cm                                 #
#  API:     axlFormCreate, axlFormDisplay                                              #  ;; 创建Allegro表单窗口
#########################################################################################
*/

axlCmdRegister("AST_Tools_UnitConvert" 'AST_Tools_UnitConvert ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

defvar(_ucForm nil)  ;; 单位转换表单指针

;;=========================================================================
;; 单位转换主函数
;; 功能说明: 在mils/mm/inch/micron/cm之间进行单位转换
;; 操作方式: 弹出转换表单，输入数值和源/目标单位，自动计算
;; 使用方式: 在Allegro命令行输入 AST_Tools_UnitConvert 执行
;;=========================================================================

procedure( AST_Tools_UnitConvert()
  prog(()  ;; 开始局部变量作用域块
    when( _ucForm  ;; 条件为真时执行
      axlFormClose(_ucForm)  ;; 关闭表单窗口
      _ucForm = nil
    )
    _ucForm = axlFormCreate(gensym() "unitconvert.form" '(ne) '_ucCallback t)  ;; 创建单位转换表单
    axlFormSetField(_ucForm "fInput" 100.0)  ;; 设置表单字段的值
    axlFormSetField(_ucForm "cmbFrom" "mils")  ;; 设置表单字段的值
    axlFormSetField(_ucForm "cmbTo" "mm")  ;; 设置表单字段的值
    axlFormDisplay(_ucForm)  ;; 显示已创建的表单窗口
    return(t)  ;; 从当前函数返回
  )
)

procedure( _ucCallback(form)
  case( form->curField  ;; 多分支值匹配
    ("btnConvert" _ucDoConvert(form))
    ("btnClose" axlFormClose(form) _ucForm = nil)  ;; 关闭表单窗口
  )
)

procedure( _ucDoConvert(form)
  prog((val fromUnit toUnit mils result)  ;; 开始局部变量作用域块
    val = atof(axlFormGetField(form "fInput"))  ;; 获取表单字段的当前值
    fromUnit = axlFormGetField(form "cmbFrom")  ;; 获取表单字段的当前值
    toUnit = axlFormGetField(form "cmbTo")  ;; 获取表单字段的当前值
    
    when( val != 0  ;; 条件为真时执行
      ;; Convert to mils first
      mils = case( fromUnit
        ("mils" val)
        ("mm" val / 0.0254)
        ("inch" val * 1000.0)
        ("micron" val / 25.4)
        ("cm" val / 0.00254)
        (t val)
      )
      
      ;; Convert from mils to target
      result = case( toUnit
        ("mils" mils)
        ("mm" mils * 0.0254)
        ("inch" mils / 1000.0)
        ("micron" mils * 25.4)
        ("cm" mils * 0.00254)
        (t mils)
      )
      
      axlFormSetField(form "fOutput" sprintf(nil "%.4f %s" result toUnit))  ;; 设置表单字段的值
    )
  )
)
