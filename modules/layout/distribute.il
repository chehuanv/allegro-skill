;; ============================================================
;; 文件名: distribute.il
;; 功能说明: 布局工具 - 分布排列模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布局工具-等距分布 - 水平或垂直等间距分布选中对象
;; 文件路径 : modules/layout/distribute.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Distribute Objects                                                          #
#  Command: AST_Layout_Distribute                                                      #
#  Desc:    Distribute selected objects horizontally or vertically with equal spacing  #
#  API:     axlTransformObject, axlSelect                                              #  ;; 启动交互选择模式，等待用户选择对象
#########################################################################################
*/

axlCmdRegister("AST_Layout_Distribute" 'AST_Layout_Distribute ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 分布排列主函数
;; 功能说明: 将选中的对象按水平或垂直方向等间距排列
;; 操作方式: 1) 选择多个对象 2) 选择排列方向 3) 自动等距分布
;; 使用方式: 在Allegro命令行输入 AST_Layout_Distribute 执行
;;=========================================================================

procedure( AST_Layout_Distribute()
  prog((objs axis sortedObjs bboxList minX maxX minY maxY step i xPos yPos)  ;; 开始局部变量作用域块
    ;; Select objects
    _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空选择集
    axlSetFindFilter(?enabled '(NOALL SYMBOLS) ?onButtons '(SYMBOLS))  ;; 设置查找过滤器:只允许选择符号(symbol)
    axlMsgPut("Select objects to distribute, then right-click Done.")  ;; 输出消息到Allegro命令窗口
    axlSelect()  ;; 启动交互选择模式，等待用户选择对象
    objs = axlGetSelSet()  ;; 获取当前选择集中的对象列表
    
    unless( objs  ;; 条件为假时执行
      AST_Msg("WARN" "No objects selected.")
      return(nil)  ;; 从当前函数返回
    )
    
    when( length(objs) < 3  ;; 条件为真时执行
      AST_Msg("WARN" "Need at least 3 objects for distribution.")
      return(nil)  ;; 从当前函数返回
    )
    
    ;; Ask axis - for now default to horizontal
    axis = "horizontal"
    
    ;; Build bounding box list
    bboxList = nil
    foreach( obj objs  ;; 遍历列表中的每个元素
      bboxList = cons(list(obj obj->bBox) bboxList)  ;; 将元素添加到列表头部
    )
    bboxList = reverse(bboxList)
    
    ;; Sort by position
    when( axis == "horizontal"  ;; 条件为真时执行
      ;; Sort by center X
      sortedObjs = sort(bboxList '_distCompareX)  ;; 对列表进行排序
      
      ;; Find span
      minX = caar(cadar(sortedObjs))   ;; left of first
      maxX = caadr(cadar(last(sortedObjs))) ;; right of last
      step = (maxX - minX) / (length(sortedObjs) - 1)  ;; 获取列表长度
      
      ;; Distribute
      i = 0
      foreach( item sortedObjs  ;; 遍历列表中的每个元素
        prog((obj bbox cx cy dx)  ;; 开始局部变量作用域块
          obj = car(item)  ;; 取列表第一个元素
          bbox = cadr(item)  ;; 取列表第二个元素
          cx = (caar(bbox) + caadr(bbox)) / 2
          cy = (cadar(bbox) + cadr(cadr(bbox))) / 2  ;; 取列表第二个元素
          xPos = minX + i * step
          dx = xPos - cx
          when( abs(dx) > 0.001  ;; 条件为真时执行
            axlTransformObject(obj ?move list(dx 0))  ;; 移动对象到指定位置
          )
          i++
        )
      )
    else
      ;; Vertical distribution
      sortedObjs = sort(bboxList '_distCompareY)  ;; 对列表进行排序
      minY = cadar(cadar(sortedObjs))
      maxY = cadr(cadar(last(sortedObjs)))  ;; 取列表第二个元素
      step = (maxY - minY) / (length(sortedObjs) - 1)  ;; 获取列表长度
      
      i = 0
      foreach( item sortedObjs  ;; 遍历列表中的每个元素
        prog((obj bbox cx cy dy)  ;; 开始局部变量作用域块
          obj = car(item)  ;; 取列表第一个元素
          bbox = cadr(item)  ;; 取列表第二个元素
          cx = (caar(bbox) + caadr(bbox)) / 2
          cy = (cadar(bbox) + cadr(cadr(bbox))) / 2  ;; 取列表第二个元素
          yPos = minY + i * step
          dy = yPos - cy
          when( abs(dy) > 0.001  ;; 条件为真时执行
            axlTransformObject(obj ?move list(0 dy))  ;; 移动对象到指定位置
          )
          i++
        )
      )
    )
    
    AST_Msg("INFO" sprintf(nil "Distributed %d objects %s." length(objs) axis))  ;; 格式化字符串
    _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空选择集
    return(t)  ;; 从当前函数返回
  )
)

;; Comparison helpers for sorting
procedure( _distCompareX(a b)
  prog((ca cb)  ;; 开始局部变量作用域块
    ca = (caar(cadr(a)) + caadr(cadr(a))) / 2  ;; 取列表第二个元素
    cb = (caar(cadr(b)) + caadr(cadr(b))) / 2  ;; 取列表第二个元素
    return(ca < cb)  ;; 从当前函数返回
  )
)

procedure( _distCompareY(a b)
  prog((ca cb)  ;; 开始局部变量作用域块
    ca = (cadar(cadr(a)) + cadr(cadr(cadr(a)))) / 2  ;; 取列表第二个元素
    cb = (cadar(cadr(b)) + cadr(cadr(cadr(b)))) / 2  ;; 取列表第二个元素
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(ca < cb)  ;; 从当前函数返回
  )
)
