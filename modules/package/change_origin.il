;; ============================================================
;; 文件名: change_origin.il
;; 功能说明: 封装工具 - 原点修改模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 封装工具-修改原点 - 将封装原点移动到选中两点中心或外框中心
;; 文件路径 : modules/package/change_origin.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Change Symbol Origin                                                        #
#  Command: AST_Pkg_ChangeOrigin                                                       #
#  Desc:    Move package origin to center of 2 selected elements or bounding box       #
#  API:     axlDBChangeDesignOrigin, axlTransformObject                                #  ;; 对对象进行变换操作(移动/旋转/镜像)
#  Note:    Must be run in Symbol Editor (.dra)                                        #
#########################################################################################
*/

axlCmdRegister("AST_Pkg_ChangeOrigin" 'AST_Pkg_ChangeOrigin ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 修改原点主函数
;; 功能说明: 在封装编辑器中移动封装原点到指定位置
;; 操作方式: 1) 选择两个参考元素 2) 计算中心点 3) 移动原点
;; 注意事项: 必须在Symbol Editor(.dra)中运行
;; 使用方式: 在Allegro命令行输入 AST_Pkg_ChangeOrigin 执行
;;=========================================================================

procedure( AST_Pkg_ChangeOrigin()
  prog((obj1 obj2 newOrigin dx dy)  ;; 开始局部变量作用域块
    ;; Check if in symbol editor
    unless( axlDBGetDesign()->symbolType  ;; 检查是否在封装编辑器中
      axlUIConfirm("This command must be run in Symbol Editor ( .dra file ).")  ;; 弹出确认对话框显示信息
      return(nil)  ;; 从当前函数返回
    )
    
    ;; Select first reference element
    _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
    axlSetFindFilter(?enabled '(NOALL PINS SHAPES LINES) ?onButtons '(PINS SHAPES))  ;; 设置查找过滤器:只允许选择shape(铜皮)
    axlMsgPut("Select first reference element...")  ;; 输出消息到Allegro命令窗口
    axlSelect()  ;; 启动交互选择模式，等待用户选择对象
    obj1 = car(axlGetSelSet())  ;; 获取当前选择集中的对象列表
    
    unless( obj1  ;; 条件为假时执行
      AST_Msg("WARN" "No first element selected.")
      return(nil)  ;; 从当前函数返回
    )
    
    ;; Select second reference element
    _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
    axlMsgPut("Select second reference element...")  ;; 输出消息到Allegro命令窗口
    axlSelect()  ;; 启动交互选择模式，等待用户选择对象
    obj2 = car(axlGetSelSet())  ;; 获取当前选择集中的对象列表
    
    unless( obj2  ;; 条件为假时执行
      AST_Msg("WARN" "No second element selected.")
      return(nil)  ;; 从当前函数返回
    )
    
    ;; Calculate midpoint
    newOrigin = AST_MidPoint(obj1->xy obj2->xy)
    
    ;; Get current origin
    dx = -car(newOrigin)  ;; 取列表第一个元素
    dy = -cadr(newOrigin)  ;; 取列表第二个元素
    
    ;; Move all objects by offset (inverse of new origin)
    ;; In Allegro symbol editor, changing origin is done by moving all geometry
    let((allObjs)  ;; 绑定局部变量
      allObjs = axlGetSelSet()  ;; 获取当前选择集中的对象列表
      _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
      axlAddSelectAll()
      allObjs = axlGetSelSet()  ;; 获取当前选择集中的对象列表
      
      foreach( obj allObjs  ;; 遍历列表中的每个元素
        when( and(obj obj->objType != "paramDesign")  ;; 条件为真时执行
          mk = axlDBTransactionStart("AST_Align")  ;; 开始事务，支持撤销
            axlTransformObject(obj ?move list(dx dy))  ;; 移动对象到指定位置
        )
      )
    )
    
    AST_Msg("INFO" sprintf(nil "Origin moved to: %.3f, %.3f" car(newOrigin) cadr(newOrigin)))  ;; 格式化字符串
    _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
  )
)
