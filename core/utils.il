;; ============================================================
;; 文件名: utils.il
;; 功能说明: 通用工具函数库，提供常用辅助功能
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 通用工具库 - 提供常用的字符串、列表、几何计算等辅助函数
;; 文件路径 : core/utils.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Common Utilities - Shared functions for all modules                                 #
#########################################################################################
*/

;;=========================================================================
;; Unit Conversion
;;=========================================================================
procedure( AST_UnitToMils(value sourceUnit)
  prog(()  ;; 开始局部变量作用域块
    case( sourceUnit  ;; 多分支值匹配
      ("mils"       value)
      ("inch"       value * 1000.0)
      ("millimeter" value / 0.0254)
      ("micron"     value / 25.4)
      ("centimeter" value / 0.00254)
      (t value)
    )
  )
)

procedure( AST_MilsToUnit(value targetUnit)
  prog(()  ;; 开始局部变量作用域块
    case( targetUnit  ;; 多分支值匹配
      ("mils"       value)
      ("inch"       value / 1000.0)
      ("millimeter" value * 0.0254)
      ("micron"     value * 25.4)
      ("centimeter" value * 0.00254)
      (t value)
    )
  )
)

;;=========================================================================
;; Selection Helpers
;;=========================================================================
procedure( AST_GetSelSetFiltered(@key (enabled '(NOALL SYMBOLS)) (onButtons '(SYMBOLS)))
  prog(()  ;; 开始局部变量作用域块
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
    axlSetFindFilter(?enabled enabled ?onButtons onButtons)  ;; 设置查找过滤器，限定可选择对象类型
    axlSelect()  ;; 启动交互选择模式，等待用户选择对象
    return(axlGetSelSet())  ;; 获取当前选择集中的对象列表
  )
)

procedure( AST_SelByName(objType name)
  prog((db)  ;; 开始局部变量作用域块
    db = axlDBFindByName(objType name)
    when( db  ;; 条件为真时执行
      axlSingleSelectObject(db)
    )
    return(db)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; Coordinate / Geometry Helpers
;;=========================================================================
procedure( AST_PointOffset(pt dx dy)
  list(car(pt) + dx cadr(pt) + dy)  ;; 取列表第一个元素
)

procedure( AST_PointDistance(p1 p2)
  prog((dx dy)  ;; 开始局部变量作用域块
    dx = float(car(p1) - car(p2))  ;; 取列表第一个元素
    dy = float(cadr(p1) - cadr(p2))  ;; 取列表第二个元素
    sqrt(dx * dx + dy * dy)  ;; 计算平方根
  )
)

procedure( AST_MidPoint(p1 p2)
  list((car(p1) + car(p2)) / 2 (cadr(p1) + cadr(p2)) / 2)  ;; 取列表第一个元素
)

;;=========================================================================
;; Message / Logging
;;=========================================================================
procedure( AST_Msg(level msg)
  prog((prefix)  ;; 开始局部变量作用域块
    prefix = case( level
      ("INFO"  "[AST-INFO ]")
      ("WARN"  "[AST-WARN ]")
      ("ERROR" "[AST-ERROR]")
      (t       "[AST-INFO ]")
    )
    printf("%s %s\n" prefix msg)
    axlMsgPut(sprintf(nil "%s %s" prefix msg))  ;; 输出消息到Allegro命令窗口
  )
)

;;=========================================================================
;; Transaction Wrapper (Undo/Redo support)
;;=========================================================================
procedure( AST_TransactionStart(name)
  prog((mark)  ;; 开始局部变量作用域块
    mark = axlDBTransactionStart(name)  ;; 开始数据库事务，支持撤销操作
    return(mark)  ;; 从当前函数返回
  )
)

procedure( AST_TransactionCommit(mark)
  axlDBTransactionCommit(mark)  ;; 提交数据库事务，确认修改
)

procedure( AST_TransactionRollback(mark)
  axlDBTransactionRollback(mark)  ;; 回滚数据库事务，撤销修改
)

;;=========================================================================
;; Layer Helpers
;;=========================================================================
procedure( AST_GetEtchLayers()
  prog((grp)  ;; 开始局部变量作用域块
    grp = axlGetParam("paramLayerGroup:ETCH")  ;; 获取Allegro参数值
    when( grp  ;; 条件为真时执行
      return(grp->groupMembers)  ;; 从当前函数返回
    )
    return(nil)  ;; 从当前函数返回
  )
)

procedure( AST_LayerSetVisible(layerName visible)
  prog((lyr)  ;; 开始局部变量作用域块
    lyr = axlLayerGet(layerName)
    when( lyr  ;; 条件为真时执行
      axlVisibleLayer(layerName visible)  ;; 设置指定层为不可见
    )
  )
)

;;=========================================================================
;; Design Attachment Persistence (save data in .brd file)
;;=========================================================================
procedure( AST_SaveData(key data)
  prog((strData att)  ;; 开始局部变量作用域块
    strData = sprintf(nil "%L" data)  ;; 格式化字符串
    att = axlGetAttachment(key 'string)
    if( att then  ;; 条件分支判断
      att->data = strData
      axlSetAttachment(att "AST toolbox data")
    else
      att = axlCreateAttachment(key "AST toolbox data" 0 'string strData)
    )
  )
)

procedure( AST_LoadData(key)
  prog((att strData result)  ;; 开始局部变量作用域块
    result = nil
    att = axlGetAttachment(key 'string)
    when( att  ;; 条件为真时执行
      strData = att->data
      when( strData  ;; 条件为真时执行
        result = car(errsetstring(sprintf(nil "'%s" strData)))  ;; 格式化字符串
      )
    )
    return(result)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; File I/O Helpers
;;=========================================================================
procedure( AST_ReadLines(filePath)
  prog((port lines line)  ;; 开始局部变量作用域块
    lines = nil
    when( isFile(filePath)  ;; 检查指定路径是否为文件
      port = infile(filePath)  ;; 打开输入文件用于读取
      while( gets(line port)
        lines = cons(line lines)  ;; 将元素添加到列表头部
      )
      close(port)  ;; 关闭文件端口
    )
    return(reverse(lines))  ;; 从当前函数返回
  )
)

procedure( AST_FileExists(path)
  isFile(path)  ;; 检查指定路径是否为文件
)
