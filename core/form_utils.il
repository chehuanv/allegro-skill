;; ============================================================
;; 文件名: form_utils.il
;; 功能说明: 表单工具库，提供表单创建和管理的辅助函数
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 窗体工具库 - 封装常用窗体创建、字段设置和回调处理函数
;; 文件路径 : core/form_utils.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Form Utilities - Unified form creation and callback management                      #
#########################################################################################
*/

;;=========================================================================
;; Create a standard form with common settings
;;=========================================================================
procedure( AST_FormCreate(formName formFile callback)
  prog((fp)  ;; 开始局部变量作用域块
    fp = axlFormCreate(  ;; 创建Allegro表单窗口
      gensym(formName)      ; unique form ID
      formFile              ; .form file name
      '(ne canvas msglines 0) ; position flags
      callback              ; callback function symbol
      t                     ; use default parent
    )
    return(fp)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; Load a mini-status form (toolbar style)
;;=========================================================================
procedure( AST_MiniFormCreate(formFile callback)
  prog((fp)  ;; 开始局部变量作用域块
    fp = axlMiniStatusLoad(gensym("AST") formFile callback)  ;; 生成唯一符号名
    return(fp)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; Standard field setters with nil-check
;;=========================================================================
procedure( AST_FormSetField(fp field value)
  when( fp  ;; 条件为真时执行
    axlFormSetField(fp field value)  ;; 设置表单字段的值
  )
)

procedure( AST_FormSetDecimal(fp field value)
  when( fp  ;; 条件为真时执行
    axlFormSetDecimal(fp field value)
  )
)

procedure( AST_FormSetFieldEditable(fp field editable)
  when( fp  ;; 条件为真时执行
    axlFormSetFieldEditable(fp field editable)  ;; 设置表单字段的值
  )
)

procedure( AST_FormSetFieldVisible(fp field visible)
  when( fp  ;; 条件为真时执行
    axlFormSetFieldVisible(fp field visible)  ;; 设置表单字段的值
  )
)

;;=========================================================================
;; Show / Close form
;;=========================================================================
procedure( AST_FormShow(fp)
  when( fp  ;; 条件为真时执行
    axlFormDisplay(fp)  ;; 显示已创建的表单窗口
  )
)

procedure( AST_FormClose(fp)
  when( fp  ;; 条件为真时执行
    axlFormClose(fp)  ;; 关闭表单窗口
  )
)

;;=========================================================================
;; Prompt user for a point and execute callback
;;=========================================================================
procedure( AST_PickPoint(prompt callback)
  prog((point)  ;; 开始局部变量作用域块
    point = axlEnterPoint(?prompts list(prompt))  ;; 启动交互点选模式，等待用户点击位置
    when( and(point callback)  ;; 条件为真时执行
      funcall(callback point)
    )
    return(point)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; Prompt user for object selection with custom filter
;;=========================================================================
procedure( AST_PickObject(prompt enabled onButtons callback)
  prog((objs)  ;; 开始局部变量作用域块
    axlSetFindFilter(?enabled enabled ?onButtons onButtons)  ;; 设置查找过滤器，限定可选择对象类型
    axlMsgPut(prompt)  ;; 输出消息到Allegro命令窗口
    axlSelect()  ;; 启动交互选择模式，等待用户选择对象
    objs = axlGetSelSet()  ;; 获取当前选择集中的对象列表
    when( and(objs callback)  ;; 条件为真时执行
      funcall(callback objs)
    )
    return(objs)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; Simple confirmation wrapper
;;=========================================================================
procedure( AST_Confirm(msg)
  axlUIConfirm(msg)  ;; 弹出确认对话框显示信息
)

procedure( AST_YesNo(msg)
  axlUIYesNo(msg)
)

;;=========================================================================
;; Form state persistence helpers
;;=========================================================================
procedure( AST_SaveFormState(formName stateList)
  prog((key)  ;; 开始局部变量作用域块
    key = strcat("AST_FORM_" formName)  ;; 连接字符串
    AST_SaveData(key stateList)
  )
)

procedure( AST_RestoreFormState(formName)
  prog((key)  ;; 开始局部变量作用域块
    key = strcat("AST_FORM_" formName)  ;; 连接字符串
    return(AST_LoadData(key))  ;; 从当前函数返回
  )
)
