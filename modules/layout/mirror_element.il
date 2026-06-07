;; ============================================================
;; 文件名: mirror_element.il
;; 功能说明: 布局工具 - 镜像元素模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 布局工具-镜像元素 - 镜像选中的器件、走线、过孔、铜皮等
;; 文件路径 : modules/layout/mirror_element.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;--------------------------------------------------------------------------
; Module:    mirror_element.il
; Category:  layout
; Purpose:   Mirror selected elements (symbols, clines, vias, shapes, etc.)
; Command:   AST_MirrorElem
; Source:    FanySkill — ported to AllegroSkillToolbox
;--------------------------------------------------------------------------

if(axlVersion('version) > 17.0 then  ;; 条件分支判断
    axlCmdRegister("AST_MirrorElem" 'AST_MirrorElem ?cmdType "interactive"
        ?doneCmd '_AST_MirrorElemDone
        ?cancelCmd '_AST_MirrorElemCancel
        ?undo t)
else
    axlCmdRegister("AST_MirrorElem" 'AST_MirrorElem ?cmdType "interactive"
        ?doneCmd '_AST_MirrorElemDone
        ?cancelCmd '_AST_MirrorElemCancel)
)

;;=========================================================================
;; 镜像元素主函数
;; 功能说明: 镜像选中的元素(符号、走线、过孔、铜皮等)
;; 操作方式: 1) 选择要镜像的元素 2) 选择镜像轴 3) 执行镜像
;; 使用方式: 在Allegro命令行输入 AST_MirrorElem 执行
;;=========================================================================

procedure( AST_MirrorElem()
    let(()  ;; 绑定局部变量
        axlUIPopupSet(axlUIPopupDefine(nil  ;; 设置弹出菜单
            '(("Done" _AST_MirrorElemDone)
              ("Oops" _AST_MirrorElemOops)
              ("Cancel" _AST_MirrorElemCancel)
        )))
        axlControlRaise('find)
        axlSetFindFilter(?enabled `("NOALL" "SYMBOLS" "CLINES" "VIAS" "SHAPES" "boundary_shapes" "lines" "text") ?onButtons `("all"))  ;; 设置查找过滤器:只允许选择cline(有电气属性的走线)
        mk_mir = axlDBTransactionStart("AST_Mirror")  ;; 开始数据库事务，支持撤销操作
        while(axlSelect(?prompt "Please select the area to mirror.")  ;; 启动交互选择模式，等待用户选择对象
            axlDBTransactionMark(mk_mir)
            axlDBCloak('_AST_MirrorElemList() 'shape)
        )
        axlUIPopupSet(nil)  ;; 设置当前右键弹出菜单
    )
)

procedure( _AST_MirrorElemList()
    let((syb ptSrc ptDes)  ;; 绑定局部变量
        syb = axlGetSelSet()  ;; 获取当前选择集中的对象列表
        _AST_SavedSelSet = axlGetSelSet()  ;; 保存当前选择集
    axlClearSelSet()  ;; 清空当前选择集，准备新的选择操作
        when(syb  ;; 条件为真时执行
            axlVisibleLayer("BOUNDARY/TOP" t)  ;; 设置指定层为可见
            axlVisibleLayer("BOUNDARY/BOTTOM" t)  ;; 设置指定层为可见
            ptSrc = _AST_GetGroupOrigin(syb)
            unless(ptSrc  ;; 条件为假时执行
                ptSrc = axlMidPointLine(axlDBGetExtents(syb t))
            )
            axlEraseObject(syb)
            axlDynamicsObject(syb ptSrc)
            axlSetDynamicsMirror(t)
            axlVisibleLayer("BOUNDARY/TOP" nil)  ;; 设置指定层为不可见
            axlVisibleLayer("BOUNDARY/BOTTOM" nil)  ;; 设置指定层为不可见
            mir_stage = nil
            when(ptDes = axlEnterPoint(?prompts `("please click to select the point to place"))  ;; 启动交互点选模式，等待用户点击位置
                mir_stage = t
                axlTransformObject(syb ?mirror t ?origin ptSrc ?move axlMXYSub(ptDes ptSrc))  ;; 移动对象到指定位置
            )
            axlClearDynamics()
        )
    )
)

procedure( _AST_GetGroupOrigin(item)
    let((allSyms i minN tmp resPt)  ;; 绑定局部变量
        allSyms = setof(x item x->objType == "symbol")  ;; 过滤列表，收集满足条件的元素
        minN = 0
        foreach(i allSyms  ;; 遍历列表中的每个元素
            tmp = length(i->pins)  ;; 获取列表长度
            when(tmp > minN  ;; 条件为真时执行
                minN = tmp
                resPt = i->xy
            )
        )
        resPt
    )
)

procedure( _AST_MirrorElemDone()
    axlDBTransactionCommit(mk_mir)  ;; 提交数据库事务，确认修改
    axlFinishEnterFun()
)

procedure( _AST_MirrorElemCancel()
    axlDBTransactionRollback(mk_mir)  ;; 回滚数据库事务，撤销修改
    axlCancelEnterFun()
)

procedure( _AST_MirrorElemOops()
    unless(mir_stage  ;; 条件为假时执行
        axlClearDynamics()
        axlCancelEnterFun()
        mir_stage = t
    )
    axlDBTransactionOops(mk_mir)
)
