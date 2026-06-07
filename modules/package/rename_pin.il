;; ============================================================
;; 文件名: rename_pin.il
;; 功能说明: 封装工具 - 引脚重命名模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 封装工具-批量重命名管脚 - 在封装编辑器中自动或批量重命名管脚编号
;; 文件路径 : modules/package/rename_pin.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Rename Pin Number                                                           #
#  Command: AST_Pkg_RenamePin                                                          #
#  Desc:    Auto-assign or batch rename pin numbers in symbol editor                   #
#  API:     axlDBChangePinName, axlSelect                                              #  ;; 启动交互选择模式，等待用户选择对象
#########################################################################################
*/

axlCmdRegister("AST_Pkg_RenamePin" 'AST_Pkg_RenamePin ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 引脚重命名主函数
;; 功能说明: 在封装编辑器中批量重命名引脚编号
;; 操作方式: 1) 进入封装编辑器 2) 选择引脚 3) 输入新编号规则
;; 注意事项: 必须在Symbol Editor(.dra)中运行
;; 使用方式: 在Allegro命令行输入 AST_Pkg_RenamePin 执行
;;=========================================================================

procedure( AST_Pkg_RenamePin()
  prog((pins i pinName)  ;; 开始局部变量作用域块
    ;; Check if in symbol editor
    unless( axlDBGetDesign()->symbolType  ;; 检查是否在封装编辑器中
      axlUIConfirm("This command must be run in Symbol Editor (.dra).")  ;; 弹出确认对话框显示信息
      return(nil)  ;; 从当前函数返回
    )
    
    ;; Select pins
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
    axlSetFindFilter(?enabled '(NOALL PINS) ?onButtons '(PINS))  ;; 设置查找过滤器:只允许选择引脚(pin)
    axlMsgPut("Select pins to rename (in order), then right-click Done.")  ;; 输出消息到Allegro命令窗口
    axlSelect()  ;; 启动交互选择模式，等待用户选择对象
    pins = axlGetSelSet()  ;; 获取当前选择集中的对象列表
    
    unless( pins  ;; 条件为假时执行
      AST_Msg("WARN" "No pins selected.")
      return(nil)  ;; 从当前函数返回
    )
    
    ;; Sort pins by Y then X (top-to-bottom, left-to-right)
    pins = sort(pins '_pinSortYX)  ;; 对列表进行排序
    
    ;; Rename sequentially
    i = 1
    foreach( pin pins  ;; 遍历列表中的每个元素
      when( pin->objType == "pin"  ;; 条件为真时执行
        pinName = sprintf(nil "%d" i)  ;; 格式化字符串
        axlDBChangePinName(pin pinName)
        i = i + 1
      )
    )
    
    AST_Msg("INFO" sprintf(nil "Renamed %d pins sequentially." length(pins)))  ;; 格式化字符串
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
    return(t)  ;; 从当前函数返回
  )
)

procedure( _pinSortYX(a b)
  prog((ay by ax bx)  ;; 开始局部变量作用域块
    ay = cadr(a->xy)  ;; 取列表第二个元素
    by = cadr(b->xy)  ;; 取列表第二个元素
    ax = car(a->xy)  ;; 取列表第一个元素
    bx = car(b->xy)  ;; 取列表第一个元素
    
    ;; Sort by Y descending (top to bottom), then X ascending (left to right)
    when( abs(ay - by) > 1.0  ;; 条件为真时执行
      return(ay > by)  ;; 从当前函数返回
    )
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(ax < bx)  ;; 从当前函数返回
  )
)
