;; ============================================================
;; 文件名: align.il
;; 功能说明: 布局工具 - 对齐功能模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;--------------------------------------------------------------------------
; Module:    align.il
; Category:  layout
; Purpose:   Full align tool — align, distribute, pick, gap, snap-to-grid
; Reference: Allegro布局走线对齐工具 (interactive + axlMiniStatusLoad pattern)
; Commands:  AST_Layout_Align
;--------------------------------------------------------------------------

axlCmdRegister("AST_Layout_Align" 'AST_Layout_Align ?cmdType "interactive" ?doneCmd 'AST_AlignDone ?cancelCmd 'AST_AlignCancel)

;------------------------------------------------------------------------
; Global state
;------------------------------------------------------------------------
defvar(_AST_AlignFinish          nil)  ;; 对齐完成标志
defvar(_AST_AlignHandler         nil)  ;; 事件处理器
defvar(_AST_AlignSelSet          nil)  ;; 选中的对象集合
defvar(_AST_AlignBBoxList        nil)  ;; 对象边界框列表
defvar(_AST_AlignFormPtr         nil)  ;; 表单指针
defvar(_AST_AlignTransactionMark nil)  ;; 事务标记(支持撤销)
defvar(_AST_AlignFormData        nil)  ;; 表单数据

;------------------------------------------------------------------------
; Form data init
;------------------------------------------------------------------------

procedure( _AST_AlignInitFormData()
    let((units mult)  ;; 绑定局部变量
        units = axlDBGetDesignUnits()
        mult = 1.0
        case(car(units)  ;; 多分支值匹配
            ("mils"       mult = 1.0)
            ("inches"     mult = 0.001)
            ("microns"    mult = 25.4)
            ("millimeters" mult = 0.0254)
            ("centimeters" mult = 0.00254)
        )
        _AST_AlignFormData = list(nil)
        _AST_AlignFormData->snapToGrid = t
        _AST_AlignFormData->snapPoint  = "center"
        _AST_AlignFormData->pickH      = 0.0
        _AST_AlignFormData->pickV      = 0.0
        _AST_AlignFormData->stepH      = 100.0 * mult
        _AST_AlignFormData->stepV      = 100.0 * mult
        _AST_AlignFormData->useGap    = nil
        _AST_AlignFormData->usePickH  = nil
        _AST_AlignFormData->usePickV  = nil
        _AST_AlignFormData->useStepH  = nil
        _AST_AlignFormData->useStepV  = nil
    )
)

;------------------------------------------------------------------------
; Helpers: object location according to snap mode
;------------------------------------------------------------------------

procedure( _AST_AlignGetObjLoc(obj)
    let((result pinList pin)  ;; 绑定局部变量
        case(_AST_AlignFormData->snapPoint  ;; 多分支值匹配
            ("origin" result = axlDBAltOrigin('origin obj))
            ("center" result = axlDBAltOrigin('center obj))
            ("pin"
                pinList = obj->pins
                result = nil
                foreach(pin pinList  ;; 遍历列表中的每个元素
                    when(equal(pin->number "1") result = pin->xy)  ;; 条件为真时执行
                )
                unless(result result = axlDBAltOrigin('center obj))  ;; 条件为假时执行
            )
        )
        result
    )
)

; BBox using DFA_BOUND > PLACE_BOUND > object->bBox
procedure( _AST_AlignGetObjBBox(obj)
    let((children dfaLayer placeLayer result child)  ;; 绑定局部变量
        if(obj->isMirrored  ;; 条件分支判断
            then dfaLayer = "PACKAGE GEOMETRY/DFA_BOUND_BOTTOM" placeLayer = "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"
            else dfaLayer = "PACKAGE GEOMETRY/DFA_BOUND_TOP"     placeLayer = "PACKAGE GEOMETRY/PLACE_BOUND_TOP"
        )
        children = obj->children
        when(children  ;; 条件为真时执行
            foreach(child children  ;; 遍历列表中的每个元素
                when(and(child->objType == "shape" child->layer == dfaLayer) result = child->bBox)  ;; 条件为真时执行
            )
            unless(result  ;; 条件为假时执行
                foreach(child children  ;; 遍历列表中的每个元素
                    when(and(child->objType == "shape" child->layer == placeLayer) result = child->bBox)  ;; 条件为真时执行
                )
            )
        )
        unless(result result = obj->bBox)  ;; 条件为假时执行
        result
    )
)

procedure( _AST_AlignGetBBoxes(objectList)
    let((result obj)  ;; 绑定局部变量
        result = nil
        foreach(obj objectList result = cons(_AST_AlignGetObjBBox(obj) result))  ;; 遍历列表中的每个元素
        reverse(result)
    )
)

;------------------------------------------------------------------------
; Grid snapping
;------------------------------------------------------------------------

procedure( _AST_AlignGetCurrentGrid()
    let((grids)  ;; 绑定局部变量
        grids = axlDBGridGet(axlConductorTopLayer())
        unless(grids grids = axlDBGridGet("non-etch"))  ;; 条件为假时执行
        grids
    )
)

procedure( _AST_AlignSnapPoint(point grids)
    let((px py xMaj yMaj xOrg yOrg)  ;; 绑定局部变量
        px = car(point)  ;; 取列表第一个元素
        py = cadr(point)  ;; 取列表第二个元素
        when(_AST_AlignFormData->snapToGrid  ;; 条件为真时执行
            xMaj = grids->xMajor
            yMaj = grids->yMajor
            xOrg = grids->xOrigin
            yOrg = grids->yOrigin
            px = round(px / xMaj) * xMaj + xOrg  ;; 四舍五入取整
            py = round(py / yMaj) * yMaj + yOrg  ;; 四舍五入取整
        )
        list(px py)
    )
)

;------------------------------------------------------------------------
; Target / edge computations
;------------------------------------------------------------------------

procedure( _AST_AlignGetMaxY(bboxes)    let((v y) v = cadadr(car(bboxes)) foreach(bbox cdr(bboxes) y = cadadr(bbox) when(y > v v = y)) v))  ;; 取列表第一个元素
procedure( _AST_AlignGetMinY(bboxes)    let((v y) v = cadar(car(bboxes))  foreach(bbox cdr(bboxes) y = cadar(bbox)  when(y < v v = y)) v))  ;; 取列表第一个元素
procedure( _AST_AlignGetMaxX(bboxes)    let((v x) v = caadr(car(bboxes))  foreach(bbox cdr(bboxes) x = caadr(bbox)  when(x > v v = x)) v))  ;; 取列表第一个元素
procedure( _AST_AlignGetMinX(bboxes)    let((v x) v = caar(car(bboxes))   foreach(bbox cdr(bboxes) x = caar(bbox)   when(x < v v = x)) v))  ;; 取列表第一个元素

;------------------------------------------------------------------------
; Sorting for distribute
;------------------------------------------------------------------------

procedure( _AST_AlignCompareX(obj1 obj2)
    let((p1 p2)  ;; 绑定局部变量
        p1 = _AST_AlignGetObjLoc(obj1)
        p2 = _AST_AlignGetObjLoc(obj2)
        if(car(p1) < car(p2) then t else if(car(p1) == car(p2) then cadr(p1) < cadr(p2) else nil))  ;; 条件分支判断
    )
)

procedure( _AST_AlignCompareY(obj1 obj2)
    let((p1 p2)  ;; 绑定局部变量
        p1 = _AST_AlignGetObjLoc(obj1)
        p2 = _AST_AlignGetObjLoc(obj2)
        if(cadr(p1) < cadr(p2) then t else if(cadr(p1) == cadr(p2) then car(p1) < car(p2) else nil))  ;; 条件分支判断
    )
)

;------------------------------------------------------------------------
; Core move engine
;------------------------------------------------------------------------

procedure( _AST_AlignDoMove(modeName)
    prog((target i obj bbox dy dx bboxes sel grids snapDest)  ;; 开始局部变量作用域块
        sel    = _AST_AlignSelSet
        bboxes = _AST_AlignBBoxList
        when(or(null(sel) null(bboxes))  ;; 条件为真时执行
            axlMsgPut("[AST] No stored selection.")  ;; 输出消息到Allegro命令窗口
            return(nil)  ;; 从当前函数返回
        )
        grids = _AST_AlignGetCurrentGrid()

        for(i 1 length(sel)  ;; C风格循环
            obj  = nthelem(i sel)  ;; 获取列表第n个元素(1-based)
            bbox = nthelem(i bboxes)  ;; 获取列表第n个元素(1-based)
            case(modeName  ;; 多分支值匹配
                ("top"
                    dy = _AST_AlignGetMaxY(bboxes) - cadadr(bbox)
                    when(abs(dy) > 0.001  ;; 条件为真时执行
                        snapDest = _AST_AlignSnapPoint(list(0 dy) grids)
                        axlTransformObject(obj ?move snapDest)  ;; 移动对象到指定位置
                    )
                )
                ("bottom"
                    dy = _AST_AlignGetMinY(bboxes) - cadar(bbox)
                    when(abs(dy) > 0.001  ;; 条件为真时执行
                        snapDest = _AST_AlignSnapPoint(list(0 dy) grids)
                        axlTransformObject(obj ?move snapDest)  ;; 移动对象到指定位置
                    )
                )
                ("left"
                    dx = _AST_AlignGetMinX(bboxes) - caar(bbox)
                    when(abs(dx) > 0.001  ;; 条件为真时执行
                        snapDest = _AST_AlignSnapPoint(list(dx 0) grids)
                        axlTransformObject(obj ?move snapDest)  ;; 移动对象到指定位置
                    )
                )
                ("right"
                    dx = _AST_AlignGetMaxX(bboxes) - caadr(bbox)
                    when(abs(dx) > 0.001  ;; 条件为真时执行
                        snapDest = _AST_AlignSnapPoint(list(dx 0) grids)
                        axlTransformObject(obj ?move snapDest)  ;; 移动对象到指定位置
                    )
                )
                ; CenterH = horizontal row button = align to horizontal center line = change Y
                ("centerH"
                    dy = (_AST_AlignGetMinY(bboxes) + _AST_AlignGetMaxY(bboxes)) / 2.0 - (cadar(bbox) + cadadr(bbox)) / 2.0
                    when(abs(dy) > 0.001  ;; 条件为真时执行
                        snapDest = _AST_AlignSnapPoint(list(0 dy) grids)
                        axlTransformObject(obj ?move snapDest)  ;; 移动对象到指定位置
                    )
                )
                ; CenterV = vertical row button = align to vertical center line = change X
                ("centerV"
                    dx = (_AST_AlignGetMinX(bboxes) + _AST_AlignGetMaxX(bboxes)) / 2.0 - (caar(bbox) + caadr(bbox)) / 2.0
                    when(abs(dx) > 0.001  ;; 条件为真时执行
                        snapDest = _AST_AlignSnapPoint(list(dx 0) grids)
                        axlTransformObject(obj ?move snapDest)  ;; 移动对象到指定位置
                    )
                )
            )
        )
        axlMsgPut("[AST] Aligned %d objects: %s" length(sel) modeName)  ;; 输出消息到Allegro命令窗口
    )
)

;------------------------------------------------------------------------
; Distribute
;------------------------------------------------------------------------

procedure( _AST_AlignDoDistributeH()
    let((objs step i point dx p1 pn grids)  ;; 绑定局部变量
        objs = sort(_AST_AlignSelSet '_AST_AlignCompareX)  ;; 对列表进行排序
        p1 = _AST_AlignGetObjLoc(car(objs))  ;; 取列表第一个元素
        pn = _AST_AlignGetObjLoc(car(last(objs)))  ;; 取列表第一个元素
        grids = _AST_AlignGetCurrentGrid()
        ; Use custom step if bxStepH is checked
        if(_AST_AlignFormData->useStepH  ;; 条件分支判断
            then step = _AST_AlignFormData->stepH
            else step = (car(pn) - car(p1)) / (length(objs) - 1)  ;; 取列表第一个元素
        )
        ; Snap step to grid if > 2 objects and not using custom step
        when(and(length(objs) > 2 not(_AST_AlignFormData->useStepH))  ;; 条件为真时执行
            step = car(_AST_AlignSnapPoint(list(step 0) grids))  ;; 取列表第一个元素
        )
        ; Start from exact first object position
        i = car(p1)  ;; 取列表第一个元素
        foreach(obj objs  ;; 遍历列表中的每个元素
            point = _AST_AlignGetObjLoc(obj)
            dx = i - car(point)  ;; 取列表第一个元素
            when(abs(dx) > 0.001  ;; 条件为真时执行
                axlTransformObject(obj ?move list(dx 0))  ;; 移动对象到指定位置
            )
            i = i + step
        )
        if(_AST_AlignFormData->useStepH  ;; 条件分支判断
            then axlMsgPut("[AST] Distributed %d objects horizontally with step %.3f." length(objs) step)  ;; 输出消息到Allegro命令窗口
            else axlMsgPut("[AST] Distributed %d objects horizontally." length(objs))  ;; 输出消息到Allegro命令窗口
        )
    )
)

procedure( _AST_AlignDoDistributeV()
    let((objs step i point dy p1 pn grids)  ;; 绑定局部变量
        objs = sort(_AST_AlignSelSet '_AST_AlignCompareY)  ;; 对列表进行排序
        p1 = _AST_AlignGetObjLoc(car(objs))  ;; 取列表第一个元素
        pn = _AST_AlignGetObjLoc(car(last(objs)))  ;; 取列表第一个元素
        grids = _AST_AlignGetCurrentGrid()
        ; Use custom step if bxStepV is checked
        if(_AST_AlignFormData->useStepV  ;; 条件分支判断
            then step = _AST_AlignFormData->stepV
            else step = (cadr(pn) - cadr(p1)) / (length(objs) - 1)  ;; 取列表第二个元素
        )
        ; Snap step to grid if > 2 objects and not using custom step
        when(and(length(objs) > 2 not(_AST_AlignFormData->useStepV))  ;; 条件为真时执行
            step = cadr(_AST_AlignSnapPoint(list(0 step) grids))  ;; 取列表第二个元素
        )
        ; Start from exact first object position
        i = cadr(p1)  ;; 取列表第二个元素
        foreach(obj objs  ;; 遍历列表中的每个元素
            point = _AST_AlignGetObjLoc(obj)
            dy = i - cadr(point)  ;; 取列表第二个元素
            when(abs(dy) > 0.001  ;; 条件为真时执行
                axlTransformObject(obj ?move list(0 dy))  ;; 移动对象到指定位置
            )
            i = i + step
        )
        if(_AST_AlignFormData->useStepV  ;; 条件分支判断
            then axlMsgPut("[AST] Distributed %d objects vertically with step %.3f." length(objs) step)  ;; 输出消息到Allegro命令窗口
            else axlMsgPut("[AST] Distributed %d objects vertically." length(objs))  ;; 输出消息到Allegro命令窗口
        )
    )
)

;------------------------------------------------------------------------
; Pick (interactive point selection)
;------------------------------------------------------------------------

procedure( _AST_AlignDoPickH()
    let((fixedPoint fixedY obj grids snapDest)  ;; 绑定局部变量
        if(_AST_AlignFormData->usePickH  ;; 条件分支判断
            then fixedY = _AST_AlignFormData->pickH
            else
                fixedPoint = axlEnterPoint(?prompts "Select a reference point or object")  ;; 启动交互点选模式，等待用户点击位置
                when(fixedPoint  ;; 条件为真时执行
                    axlSingleSelectPoint(fixedPoint)  ;; 单点选择模式:点击选择单个对象
                    obj = car(axlGetSelSet())  ;; 获取当前选择集中的对象列表
                    if(obj  ;; 条件分支判断
                        then fixedY = cadr(_AST_AlignGetObjLoc(obj))  ;; 取列表第二个元素
                        else fixedY = cadr(fixedPoint)  ;; 取列表第二个元素
                    )
                )
        )
        when(fixedY  ;; 条件为真时执行
            grids = _AST_AlignGetCurrentGrid()
            fixedY = cadr(_AST_AlignSnapPoint(list(0 fixedY) grids))  ;; 取列表第二个元素
            _AST_AlignFormData->pickH = fixedY
            axlFormSetField(_AST_AlignFormPtr "fPickH" fixedY)  ;; 设置表单字段的值
            foreach(obj _AST_AlignSelSet  ;; 遍历列表中的每个元素
                let((dy point)  ;; 绑定局部变量
                    point = _AST_AlignGetObjLoc(obj)
                    dy = fixedY - cadr(point)  ;; 取列表第二个元素
                    snapDest = _AST_AlignSnapPoint(list(0 dy) grids)
                    axlTransformObject(obj ?move snapDest)  ;; 移动对象到指定位置
                )
            )
            axlMsgPut("[AST] Picked horizontal alignment at Y=%.3f" fixedY)  ;; 输出消息到Allegro命令窗口
        )
    )
)

procedure( _AST_AlignDoPickV()
    let((fixedPoint fixedX obj grids snapDest)  ;; 绑定局部变量
        if(_AST_AlignFormData->usePickV  ;; 条件分支判断
            then fixedX = _AST_AlignFormData->pickV
            else
                fixedPoint = axlEnterPoint(?prompts "Select a reference point or object")  ;; 启动交互点选模式，等待用户点击位置
                when(fixedPoint  ;; 条件为真时执行
                    axlSingleSelectPoint(fixedPoint)  ;; 单点选择模式:点击选择单个对象
                    obj = car(axlGetSelSet())  ;; 获取当前选择集中的对象列表
                    if(obj  ;; 条件分支判断
                        then fixedX = car(_AST_AlignGetObjLoc(obj))  ;; 取列表第一个元素
                        else fixedX = car(fixedPoint)  ;; 取列表第一个元素
                    )
                )
        )
        when(fixedX  ;; 条件为真时执行
            grids = _AST_AlignGetCurrentGrid()
            fixedX = car(_AST_AlignSnapPoint(list(fixedX 0) grids))  ;; 取列表第一个元素
            _AST_AlignFormData->pickV = fixedX
            axlFormSetField(_AST_AlignFormPtr "fPickV" fixedX)  ;; 设置表单字段的值
            foreach(obj _AST_AlignSelSet  ;; 遍历列表中的每个元素
                let((dx point)  ;; 绑定局部变量
                    point = _AST_AlignGetObjLoc(obj)
                    dx = fixedX - car(point)  ;; 取列表第一个元素
                    snapDest = _AST_AlignSnapPoint(list(dx 0) grids)
                    axlTransformObject(obj ?move snapDest)  ;; 移动对象到指定位置
                )
            )
            axlMsgPut("[AST] Picked vertical alignment at X=%.3f" fixedX)  ;; 输出消息到Allegro命令窗口
        )
    )
)

;------------------------------------------------------------------------
; Handler setters (called by form callback)
;------------------------------------------------------------------------

procedure( _AST_AlignOnTop()       axlMsgPut("[AST] Align by TOP")     _AST_AlignHandler = '_AST_AlignDoTop     axlCancelEnterFun())  ;; 输出消息到Allegro命令窗口
procedure( _AST_AlignOnBottom()    axlMsgPut("[AST] Align by BOTTOM")  _AST_AlignHandler = '_AST_AlignDoBottom  axlCancelEnterFun())  ;; 输出消息到Allegro命令窗口
procedure( _AST_AlignOnLeft()      axlMsgPut("[AST] Align by LEFT")    _AST_AlignHandler = '_AST_AlignDoLeft    axlCancelEnterFun())  ;; 输出消息到Allegro命令窗口
procedure( _AST_AlignOnRight()     axlMsgPut("[AST] Align by RIGHT")   _AST_AlignHandler = '_AST_AlignDoRight   axlCancelEnterFun())  ;; 输出消息到Allegro命令窗口
procedure( _AST_AlignOnCenterH()   axlMsgPut("[AST] Align horizontally") _AST_AlignHandler = '_AST_AlignDoCenterH axlFinishEnterFun())  ;; 输出消息到Allegro命令窗口
procedure( _AST_AlignOnCenterV()   axlMsgPut("[AST] Align vertically")   _AST_AlignHandler = '_AST_AlignDoCenterV axlFinishEnterFun())  ;; 输出消息到Allegro命令窗口

procedure( _AST_AlignOnDistributeH()
    _AST_AlignSelSet = sort(_AST_AlignSelSet '_AST_AlignCompareX)  ;; 对列表进行排序
    _AST_AlignHandler = '_AST_AlignDoDistributeH
    axlFinishEnterFun()
)

procedure( _AST_AlignOnDistributeV()
    _AST_AlignSelSet = sort(_AST_AlignSelSet '_AST_AlignCompareY)  ;; 对列表进行排序
    _AST_AlignHandler = '_AST_AlignDoDistributeV
    axlFinishEnterFun()
)

procedure( _AST_AlignOnPickH()
    _AST_AlignHandler = '_AST_AlignDoPickH
    axlFinishEnterFun()
)

procedure( _AST_AlignOnPickV()
    _AST_AlignHandler = '_AST_AlignDoPickV
    axlFinishEnterFun()
)

; Execute handlers
procedure( _AST_AlignDoTop()         _AST_AlignDoMove("top")      nil)
procedure( _AST_AlignDoBottom()      _AST_AlignDoMove("bottom")   nil)
procedure( _AST_AlignDoLeft()        _AST_AlignDoMove("left")     nil)
procedure( _AST_AlignDoRight()       _AST_AlignDoMove("right")    nil)
procedure( _AST_AlignDoCenterH()     _AST_AlignDoMove("centerH")  nil)
procedure( _AST_AlignDoCenterV()     _AST_AlignDoMove("centerV")  nil)

;------------------------------------------------------------------------
; Main command
;------------------------------------------------------------------------

;;=========================================================================
;; 对齐工具主函数
;; 功能说明: 提供交互式对齐功能，支持水平/垂直对齐、等距分布、吸附栅格
;; 操作方式: 1) 选择要对齐的对象 2) 选择对齐模式 3) 指定参考点
;; 支持模式: left(左对齐) right(右对齐) center(中心对齐) top(顶对齐) bottom(底对齐)
;; 使用方式: 在Allegro命令行输入 AST_Layout_Align 执行
;;=========================================================================

procedure( AST_Layout_Align()
    prog(()  ;; 开始局部变量作用域块
        when(axlOKToProceed()  ;; 条件为真时执行
            _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
            _AST_AlignFinish  = nil
            _AST_AlignHandler = nil
            _AST_AlignSelSet  = nil
            _AST_AlignBBoxList = nil
            _AST_AlignInitFormData()

            axlSetFindFilter(?enabled '(GROUPS SYMBOLS PINS VIAS TEXT NAMEFORM) ?onButtons '(SYMBOLS))  ;; 设置查找过滤器，限定可选择对象类型
            axlMsgPut("[AST] Select object(s)")  ;; 输出消息到Allegro命令窗口

            _AST_AlignFormPtr = axlMiniStatusLoad(gensym() "align.form" '_AST_AlignFormCB)  ;; 生成唯一符号名
            _AST_AlignTransactionMark = axlDBTransactionStart("AST_Align")  ;; 开始数据库事务，支持撤销操作

            while(_AST_AlignFinish == nil
                _AST_AlignSelSet = axlGetSelSet()  ;; 获取当前选择集中的对象列表
                when(_AST_AlignSelSet  ;; 条件为真时执行
                    axlMsgPut("[AST] %d objects selected." length(_AST_AlignSelSet))  ;; 输出消息到Allegro命令窗口
                )
                axlSelect(?groupMode nil ?prompt nil)  ;; 启动交互选择模式，等待用户选择对象
                when(_AST_AlignHandler  ;; 条件为真时执行
                    when(_AST_AlignSelSet  ;; 条件为真时执行
                        _AST_AlignBBoxList = _AST_AlignGetBBoxes(_AST_AlignSelSet)
                        when(and(_AST_AlignBBoxList length(_AST_AlignBBoxList) >= 2)  ;; 条件为真时执行
                            axlDBTransactionMark(_AST_AlignTransactionMark)
                            funcall(_AST_AlignHandler)
                            _AST_AlignSelSet = axlDBRefreshId(_AST_AlignSelSet)
                            axlSingleSelectObject(_AST_AlignSelSet)
                        )
                        unless(and(_AST_AlignBBoxList length(_AST_AlignBBoxList) >= 2)  ;; 条件为假时执行
                            axlMsgPut("[AST] Need 2+ valid objects.")  ;; 输出消息到Allegro命令窗口
                        )
                    )
                    unless(_AST_AlignSelSet  ;; 条件为假时执行
                        axlMsgPut("[AST] No objects selected.")  ;; 输出消息到Allegro命令窗口
                    )
                    _AST_AlignHandler = nil
                )
            )

            when(_AST_AlignTransactionMark  ;; 条件为真时执行
                axlDBTransactionCommit(_AST_AlignTransactionMark)  ;; 提交数据库事务，确认修改
            )
            axlMsgPut("[AST] Align command finished.")  ;; 输出消息到Allegro命令窗口
            _AST_AlignExit()
        )
    )
)

;------------------------------------------------------------------------
; Form callback
;------------------------------------------------------------------------

procedure( _AST_AlignFormCB(form)
    let((field)  ;; 绑定局部变量
        field = form->curField
        case(field  ;; 多分支值匹配
            ("bnTop"         _AST_AlignOnTop())
            ("bnBottom"      _AST_AlignOnBottom())
            ("bnLeft"        _AST_AlignOnLeft())
            ("bnRight"       _AST_AlignOnRight())
            ("bnCenterH"     _AST_AlignOnCenterH())
            ("bnCenterV"     _AST_AlignOnCenterV())
            ("bnPickH"       _AST_AlignOnPickH())
            ("bnPickV"       _AST_AlignOnPickV())
            ("bnDistributeH" _AST_AlignOnDistributeH())
            ("bnDistributeV" _AST_AlignOnDistributeV())
            ("bnClose"       _AST_AlignFinish = t axlCancelEnterFun())
            ("bxSnapToGrid"  _AST_AlignFormData->snapToGrid = form->curValue)
            ("cmbSnapPoint"  _AST_AlignFormData->snapPoint = form->curValue)
            ("bxGap"         _AST_AlignFormData->useGap = form->curValue)
            ("bxPickH"       _AST_AlignFormData->usePickH = form->curValue)
            ("bxPickV"       _AST_AlignFormData->usePickV = form->curValue)
            ("bxStepH"       _AST_AlignFormData->useStepH = form->curValue)
            ("bxStepV"       _AST_AlignFormData->useStepV = form->curValue)
            ("fPickH"        _AST_AlignFormData->pickH = form->curValue)
            ("fPickV"        _AST_AlignFormData->pickV = form->curValue)
            ("fStepH"        _AST_AlignFormData->stepH = form->curValue)
            ("fStepV"        _AST_AlignFormData->stepV = form->curValue)
            ("bxStretch"     _AST_AlignFormData->useStretch = form->curValue
                             when(_AST_AlignFormData->useStretch  ;; 条件为真时执行
                                 axlFormSetField(form "bxRipup" nil)  ;; 设置表单字段的值
                                 _AST_AlignFormData->useRipup = nil
                             ))
            ("bxRipup"       _AST_AlignFormData->useRipup = form->curValue
                             when(_AST_AlignFormData->useRipup  ;; 条件为真时执行
                                 axlFormSetField(form "bxStretch" nil)  ;; 设置表单字段的值
                                 _AST_AlignFormData->useStretch = nil
                             ))
            (t nil)
        )
    )
)

;------------------------------------------------------------------------
; Done / Cancel / Exit
;------------------------------------------------------------------------

procedure( AST_AlignDone()
    _AST_AlignFinish = t
    when(_AST_AlignFormPtr errset(axlFormClose(_AST_AlignFormPtr)) _AST_AlignFormPtr = nil)  ;; 关闭表单窗口
    when(_AST_AlignTransactionMark axlDBTransactionCommit(_AST_AlignTransactionMark))  ;; 提交数据库事务，确认修改
    _AST_AlignExit()
    axlMsgPut("[AST] Align done.")  ;; 输出消息到Allegro命令窗口
)

procedure( AST_AlignCancel()
    _AST_AlignFinish = t
    when(_AST_AlignFormPtr errset(axlFormClose(_AST_AlignFormPtr)) _AST_AlignFormPtr = nil)  ;; 关闭表单窗口
    when(_AST_AlignTransactionMark axlDBTransactionRollback(_AST_AlignTransactionMark))  ;; 回滚数据库事务，撤销修改
    _AST_AlignExit()
    axlMsgPut("[AST] Align cancelled.")  ;; 输出消息到Allegro命令窗口
)

procedure( _AST_AlignExit()
    _AST_AlignFinish = t
    when(_AST_AlignFormPtr errset(axlFormClose(_AST_AlignFormPtr)) _AST_AlignFormPtr = nil)  ;; 关闭表单窗口
    axlCancelEnterFun()
    _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
)
