;; ============================================================
;; 文件名: del_dangling.il
;; 功能说明: 清理工具 - 删除悬空对象GUI版(走线/过孔/铜皮)
;; 编码格式: GBK (中文注释)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编辑
;; ============================================================
;; ================================================================================
;; 文件说明 : 清理工具-删除悬空对象GUI版
;;            自动查找并删除没有电气连接的悬空走线、过孔、孤岛铜皮
;; 文件路径 : modules/cleanup/del_dangling.il
;; 编码格式 : GBK/GB18030 (支持中文注释)
;; 坐标体系 : 无
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8格式直接保存，否则会乱码
;; 参考来源 : FanySkill_quick_danglings.il (EDA365)
;; ================================================================================

;;#############################################################################
;;#  模块: 删除悬空对象 (Delete Dangling Objects)                                 #
;;#  命令: AST_DelDangling / AST_Cleanup_DelDangling                              #
;;#  功能: GUI界面查找并删除悬空走线、过孔、孤岛铜皮                              #
;;#  API:  axlDBGetConnect, axlDeleteObject, axlFormCreate, axlHighlightObject   #
;;#############################################################################

axlCmdRegister("AST_Cleanup_DelDangling" 'AST_Cleanup_DelDangling ?cmdType "general")
axlCmdRegister("AST_DelDangling" 'AST_Cleanup_DelDangling ?cmdType "general")

;;=========================================================================
;; 全局变量
;;=========================================================================

defvar(_AST_DanglingForm)
defvar(_AST_DanglingData)

;;=========================================================================
;; 主函数: 检测悬空对象并显示GUI
;;=========================================================================

procedure( AST_Cleanup_DelDangling()
  prog((lData lLines lVias lShapes)
    
    ;; 检查是否可以继续
    unless(axlOKToProceed()
      axlUIConfirm("请先保存一下当前文件")
      return(nil)
    )
    
    ;; 执行检测
    lData = _AST_DanglingCheck()
    lLines = car(lData)
    lVias = cadr(lData)
    lShapes = caddr(lData)
    
    ;; 保存数据到全局变量供后续使用
    _AST_DanglingData = lData
    
    ;; 如果没有发现问题，直接提示
    unless(lLines || lVias || lShapes
      axlUIConfirm("未检测到悬空对象，板子很干净")
      return(0)
    )
    
    unless(axlUIConfirm("注意：GUI中的删除操作不可撤销\n\n建议先保存再执行操作\n\n是否继续？")
      return(nil)
    )
    
    ;; 创建并显示GUI
    _AST_DanglingForm = _AST_CreateDanglingForm(lData)
    when(_AST_DanglingForm
      axlFormDisplay(_AST_DanglingForm)
      axlUIWDisableQuit(_AST_DanglingForm)
      
      ;; 显示统计信息
      when(lLines
        axlMsgPut(sprintf(nil "[AST] 发现 %d 条悬空走线" length(lLines)))
      )
      when(lVias
        axlMsgPut(sprintf(nil "[AST] 发现 %d 个悬空过孔" length(lVias)))
      )
      when(lShapes
        axlMsgPut(sprintf(nil "[AST] 发现 %d 个孤岛铜皮" length(lShapes)))
      )
    )
    
    return(length(lLines) + length(lVias) + length(lShapes))
  )
)

;;=========================================================================
;; 创建GUI Form
;;=========================================================================

procedure( _AST_CreateDanglingForm(lData)
  prog((formFile formPort formHandle lLines lVias lShapes)
    
    lLines = car(lData)
    lVias = cadr(lData)
    lShapes = caddr(lData)
    
    formFile = strcat(axlTempDirectory() "/AST_DanglingForm.form")
    formPort = outfile(formFile "w")
    
    fprintf(formPort "FILE_TYPE=FORM_DEFN VERSION=2\n")
    fprintf(formPort "FORM\n")
    fprintf(formPort "FIXED\n")
    fprintf(formPort "PORT 50 50\n")
    fprintf(formPort "HEADER \"AST - 删除悬空对象\"\n")
    fprintf(formPort "TILE\n")
    
    fprintf(formPort "FIELD ddoRefresh\n")
    fprintf(formPort "FLOC 2 47\n")
    fprintf(formPort "MENUBUTTON \"刷新(Refresh)\" 12 3\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "FIELD ddoHelp\n")
    fprintf(formPort "FLOC 18 47\n")
    fprintf(formPort "MENUBUTTON \"帮助(Help)\" 10 3\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "FIELD ddoClose\n")
    fprintf(formPort "FLOC 34 47\n")
    fprintf(formPort "MENUBUTTON \"关闭(Close)\" 10 3\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "TABSET tset\n")
    fprintf(formPort "FLOC 2 2\n")
    fprintf(formPort "FSIZE 46 44\n")
    
    fprintf(formPort "TAB \"悬空走线 (%d)\"\n" length(lLines))
    fprintf(formPort "TEXT \"悬空走线列表:\"\n")
    fprintf(formPort "TLOC 2 1\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "TEXT \"\n")
    fprintf(formPort "FLOC 16 1\n")
    fprintf(formPort "INFO ddoLineInfo 10\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD ddoLineList\n")
    fprintf(formPort "FLOC 2 3\n")
    fprintf(formPort "LIST \"\" 40 16\n")
    fprintf(formPort "OPTIONS multiselect\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD ddoLinesDel\n")
    fprintf(formPort "FLOC 16 34\n")
    fprintf(formPort "MENUBUTTON \"删除选中(Delete)\" 14 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "ENDTAB\n")
    
    fprintf(formPort "TAB \"悬空过孔 (%d)\"\n" length(lVias))
    fprintf(formPort "TEXT \"悬空过孔列表:\"\n")
    fprintf(formPort "TLOC 2 1\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "TEXT \"\n")
    fprintf(formPort "FLOC 16 1\n")
    fprintf(formPort "INFO ddoViaInfo 10\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD ddoViaList\n")
    fprintf(formPort "FLOC 2 3\n")
    fprintf(formPort "LIST \"\" 40 16\n")
    fprintf(formPort "OPTIONS multiselect\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD ddoViasDel\n")
    fprintf(formPort "FLOC 2 34\n")
    fprintf(formPort "MENUBUTTON \"删除选中(Delete)\" 14 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD ddoAssign\n")
    fprintf(formPort "FLOC 24 34\n")
    fprintf(formPort "MENUBUTTON \"改网络(Change Net)\" 14 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "ENDTAB\n")
    
    fprintf(formPort "TAB \"孤岛铜皮 (%d)\"\n" length(lShapes))
    fprintf(formPort "TEXT \"孤岛铜皮列表:\"\n")
    fprintf(formPort "TLOC 2 1\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "TEXT \"\n")
    fprintf(formPort "FLOC 16 1\n")
    fprintf(formPort "INFO ddoShapeInfo 10\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD ddoShapeList\n")
    fprintf(formPort "FLOC 2 3\n")
    fprintf(formPort "LIST \"\" 40 16\n")
    fprintf(formPort "OPTIONS multiselect\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD ddoShapesDel\n")
    fprintf(formPort "FLOC 2 34\n")
    fprintf(formPort "MENUBUTTON \"删除(Delete)\" 12 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD ddoShapesVoid\n")
    fprintf(formPort "FLOC 18 34\n")
    fprintf(formPort "MENUBUTTON \"挖空(Void)\" 12 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "ENDTAB\n")
    
    fprintf(formPort "ENDTABSET\n")
    fprintf(formPort "ENDTILE\n")
    fprintf(formPort "ENDFORM\n")
    
    close(formPort)
    
    formHandle = axlFormCreate((gensym) formFile '(e outer) '_AST_DanglingFormCallback t)
    
    ;; 设置列表数据
    when(formHandle
      axlFormSetField(formHandle "ddoLineList" lLines)
      axlFormSetField(formHandle "ddoViaList" lVias)
      axlFormSetField(formHandle "ddoShapeList" lShapes)
      axlFormSetField(formHandle "ddoLineInfo" length(lLines))
      axlFormSetField(formHandle "ddoViaInfo" length(lVias))
      axlFormSetField(formHandle "ddoShapeInfo" length(lShapes))
      
      ;; 设置颜色
      when(length(lLines) > 0
        axlFormColorize(formHandle "ddoLineInfo" 'text 'red)
      )
      when(length(lVias) > 0
        axlFormColorize(formHandle "ddoViaInfo" 'text 'red)
      )
      when(length(lShapes) > 0
        axlFormColorize(formHandle "ddoShapeInfo" 'text 'red)
      )
    )
    
    ;; 删除临时文件
    deleteFile(formFile)
    
    return(formHandle)
  )
)

;;=========================================================================
;; GUI回调函数
;;=========================================================================

procedure( _AST_DanglingFormCallback(form)
  prog((lData lLines lVias lShapes selItems lIssueObjs obj dVia dShape
        lCoord fCoordX fCoordY lClines lSeg lStartA lEndA lStartB lEndB
        sStartTempA sEndTempA sStartTempB sEndTempB sStart sEnd
        sLayer fStartX fStartY fEndX fEndY fFindRange
        lVia lShape sNet sMessage bDRC bDynFill lSys)
    
    fFindRange = axlMKSConvert(1 "MILS")
    
    case(form->curField
      
      ;;-------------------------------------------------------------------
      ;; 刷新按钮
      ;;-------------------------------------------------------------------
      ("ddoRefresh"
        axlClearSelSet()
        lData = _AST_DanglingCheck()
        _AST_DanglingData = lData
        lLines = car(lData)
        lVias = cadr(lData)
        lShapes = caddr(lData)
        
        ;; 清空并重新填充列表
        axlFormListDeleteAll(form "ddoLineList")
        axlFormListDeleteAll(form "ddoViaList")
        axlFormListDeleteAll(form "ddoShapeList")
        axlFormSetField(form "ddoLineList" lLines)
        axlFormSetField(form "ddoViaList" lVias)
        axlFormSetField(form "ddoShapeList" lShapes)
        axlFormSetField(form "ddoLineInfo" length(lLines))
        axlFormSetField(form "ddoViaInfo" length(lVias))
        axlFormSetField(form "ddoShapeInfo" length(lShapes))
        
        when(length(lLines) > 0
          axlFormColorize(form "ddoLineInfo" 'text 'red)
        )
        when(length(lVias) > 0
          axlFormColorize(form "ddoViaInfo" 'text 'red)
        )
        when(length(lShapes) > 0
          axlFormColorize(form "ddoShapeInfo" 'text 'red)
        )
        
        axlMsgPut("[AST] 列表已刷新")
      )
      
      ;;-------------------------------------------------------------------
      ;; 走线列表选择 - 高亮显示
      ;;-------------------------------------------------------------------
      ("ddoLineList"
        selItems = axlFormListGetSelItems(form "ddoLineList")
        when(selItems
          axlClearSelSet()
          axlSetFindFilter(?enabled '("noall" "clines") ?onButtons '("clines"))
          lIssueObjs = nil
          axlVisibleDesign(nil)
          
          foreach(sline selItems
            lCoord = parseString(sline " ,()")
            sLayer = car(lCoord)
            fStartX = atof(nth(2 lCoord))
            fStartY = atof(nth(3 lCoord))
            fEndX = atof(nth(5 lCoord))
            fEndY = atof(nth(6 lCoord))
            
            axlVisibleLayer(strcat("etch/" sLayer) t)
            axlVisibleLayer(strcat("via class/" sLayer) t)
            axlVisibleLayer(strcat("pin/" sLayer) t)
            
            sStart = sprintf(nil "x%0.3fy%0.3f" fStartX fStartY)
            sEnd = sprintf(nil "x%0.3fy%0.3f" fEndX fEndY)
            
            lClines = axlGetSelSet(
              axlSingleSelectBox(
                list((fStartX - fFindRange):(fStartY - fFindRange)
                     (fStartX + fFindRange):(fStartY + fFindRange))
              )
            )
            axlClearSelSet()
            
            when(lClines
              foreach(cline lClines
                lSeg = cline->segments
                lStartA = car(car(lSeg)->startEnd)
                lEndA = cadr(car(last(lSeg))->startEnd)
                sStartTempA = sprintf(nil "x%0.3fy%0.3f" car(lStartA) cadr(lStartA))
                sEndTempA = sprintf(nil "x%0.3fy%0.3f" car(lEndA) cadr(lEndA))
                lStartB = car(car(last(lSeg))->startEnd)
                lEndB = cadr(car(lSeg)->startEnd)
                sStartTempB = sprintf(nil "x%0.3fy%0.3f" car(lStartB) cadr(lStartB))
                sEndTempB = sprintf(nil "x%0.3fy%0.3f" car(lEndB) cadr(lEndB))
                
                when((sStartTempA == sStart && sEndTempA == sEnd) ||
                     (sStartTempA == sEnd && sEndTempA == sStart) ||
                     (sStartTempB == sStart && sEndTempB == sEnd) ||
                     (sStartTempB == sEnd && sEndTempB == sStart)
                  lIssueObjs = cons(cline lIssueObjs)
                )
              )
            )
          )
          axlHighlightObject(lIssueObjs)
          axlZoomToDbid(lIssueObjs t)
        )
      )
      
      ;;-------------------------------------------------------------------
      ;; 删除选中的走线
      ;;-------------------------------------------------------------------
      ("ddoLinesDel"
        selItems = axlFormListGetSelItems(form "ddoLineList")
        when(selItems
          lIssueObjs = nil
          foreach(sline selItems
            lCoord = parseString(sline " ,()")
            sLayer = car(lCoord)
            fStartX = atof(nth(2 lCoord))
            fStartY = atof(nth(3 lCoord))
            fEndX = atof(nth(5 lCoord))
            fEndY = atof(nth(6 lCoord))
            
            sStart = sprintf(nil "x%0.3fy%0.3f" fStartX fStartY)
            sEnd = sprintf(nil "x%0.3fy%0.3f" fEndX fEndY)
            
            lClines = axlGetSelSet(
              axlSingleSelectBox(
                list((fStartX - fFindRange):(fStartY - fFindRange)
                     (fStartX + fFindRange):(fStartY + fFindRange))
              )
            )
            axlClearSelSet()
            
            when(lClines
              foreach(cline lClines
                lSeg = cline->segments
                lStartA = car(car(lSeg)->startEnd)
                lEndA = cadr(car(last(lSeg))->startEnd)
                sStartTempA = sprintf(nil "x%0.3fy%0.3f" car(lStartA) cadr(lStartA))
                sEndTempA = sprintf(nil "x%0.3fy%0.3f" car(lEndA) cadr(lEndA))
                lStartB = car(car(last(lSeg))->startEnd)
                lEndB = cadr(car(lSeg)->startEnd)
                sStartTempB = sprintf(nil "x%0.3fy%0.3f" car(lStartB) cadr(lStartB))
                sEndTempB = sprintf(nil "x%0.3fy%0.3f" car(lEndB) cadr(lEndB))
                
                when((sStartTempA == sStart && sEndTempA == sEnd) ||
                     (sStartTempA == sEnd && sEndTempA == sStart) ||
                     (sStartTempB == sStart && sEndTempB == sEnd) ||
                     (sStartTempB == sEnd && sEndTempB == sStart)
                  lIssueObjs = cons(cline lIssueObjs)
                )
              )
            )
          )
          
          when(lIssueObjs
            mk_del = axlDBTransactionStart("Delete Dangling Lines")
            axlDeleteObject(lIssueObjs)
            axlDBTransactionCommit(mk_del)
            axlFormListDeleteItem(form "ddoLineList" selItems)
            axlFormSetField(form "ddoLineInfo"
              axlFormListGetCount(form "ddoLineList"))
            axlMsgPut("[AST] 已删除选中的悬空走线")
          )
        )
      )
      
      ;;-------------------------------------------------------------------
      ;; 过孔列表选择 - 高亮显示
      ;;-------------------------------------------------------------------
      ("ddoViaList"
        selItems = axlFormListGetSelItems(form "ddoViaList")
        when(selItems
          axlClearSelSet()
          axlSetFindFilter(?enabled '("noall" "vias") ?onButtons '("vias"))
          lVia = nil
          axlVisibleDesign(nil)
          
          foreach(svia selItems
            lCoord = parseString(svia " ,()")
            sLayer = car(lCoord)
            fCoordX = atof(nth(2 lCoord))
            fCoordY = atof(nth(3 lCoord))
            
            axlVisibleLayer(strcat("via class/" sLayer) t)
            axlVisibleLayer(strcat("etch/" sLayer) t)
            axlVisibleLayer(strcat("pin/" sLayer) t)
            
            dVia = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when(dVia
              lVia = cons(dVia lVia)
            )
          )
          axlHighlightObject(lVia)
          axlZoomToDbid(lVia t)
        )
      )
      
      ;;-------------------------------------------------------------------
      ;; 删除选中的过孔
      ;;-------------------------------------------------------------------
      ("ddoViasDel"
        bDRC = axlDBControl('drcEnable nil)
        bDynFill = axlDBControl('dynamicFillMode nil)
        
        selItems = axlFormListGetSelItems(form "ddoViaList")
        when(selItems
          lVia = nil
          lSys = axlVisibleGet()
          axlVisibleDesign(nil)
          
          foreach(svia selItems
            lCoord = parseString(svia " ,()")
            sLayer = car(lCoord)
            fCoordX = atof(nth(2 lCoord))
            fCoordY = atof(nth(3 lCoord))
            
            axlVisibleLayer(strcat("via class/" sLayer) t)
            dVia = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when(dVia
              lVia = cons(dVia lVia)
            )
            axlVisibleLayer(strcat("via class/" sLayer) nil)
          )
          
          when(lVia
            mk_del = axlDBTransactionStart("Delete Dangling Vias")
            axlDeleteObject(lVia)
            axlDBTransactionCommit(mk_del)
            axlFormListDeleteItem(form "ddoViaList" selItems)
            axlFormSetField(form "ddoViaInfo"
              axlFormListGetCount(form "ddoViaList"))
            axlMsgPut("[AST] 已删除选中的悬空过孔")
          )
          axlVisibleSet(lSys)
        )
        
        axlDBControl('drcEnable bDRC)
        axlDBControl('dynamicFillMode bDynFill)
      )
      
      ;;-------------------------------------------------------------------
      ;; 改网络
      ;;-------------------------------------------------------------------
      ("ddoAssign"
        bDRC = axlDBControl('drcEnable nil)
        bDynFill = axlDBControl('dynamicFillMode nil)
        
        selItems = axlFormListGetSelItems(form "ddoViaList")
        if(selItems then
          lVia = nil
          lSys = axlVisibleGet()
          axlVisibleDesign(nil)
          
          foreach(svia selItems
            lCoord = parseString(svia " ,()")
            sLayer = car(lCoord)
            fCoordX = atof(nth(2 lCoord))
            fCoordY = atof(nth(3 lCoord))
            
            axlVisibleLayer(strcat("via class/" sLayer) t)
            dVia = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when(dVia
              lVia = cons(dVia lVia)
            )
            axlVisibleLayer(strcat("via class/" sLayer) nil)
          )
          
          axlVisibleSet(lSys)
          axlMsgPut("[AST] 请在板子上选择一个网络")
          axlSetFindFilter(?enabled '("noall" "nets") ?onButtons '("nets"))
          
          if(axlSingleSelectPoint() then
            sNet = car(axlGetSelSet())->name
            axlClearSelSet()
            
            foreach(item lVia
              axlDBCloak('axlDBCreateVia(item->name item->xy sNet) 'shape)
              if(item->net->name then
                sMessage = sprintf(nil "[AST] 过孔网络从 %s 改为 %s" item->net->name sNet)
              else
                sMessage = sprintf(nil "[AST] 过孔网络从 nil 改为 %s" sNet)
              )
              axlMsgPut(sMessage)
            )
            
            mk_del = axlDBTransactionStart("Change Via Net")
            axlDeleteObject(lVia)
            axlDBTransactionCommit(mk_del)
            axlFormListDeleteItem(form "ddoViaList" selItems)
            axlFormSetField(form "ddoViaInfo"
              axlFormListGetCount(form "ddoViaList"))
          else
            axlMsgPut("[AST] 未选择网络，未执行操作")
          )
        else
          axlUIConfirm("请先从列表中选中一个过孔")
        )
        
        axlDBControl('drcEnable bDRC)
        axlDBControl('dynamicFillMode bDynFill)
      )
      
      ;;-------------------------------------------------------------------
      ;; 铜皮列表选择 - 高亮显示
      ;;-------------------------------------------------------------------
      ("ddoShapeList"
        selItems = axlFormListGetSelItems(form "ddoShapeList")
        when(selItems
          axlClearSelSet()
          axlSetFindFilter(?enabled '("noall" "shapes") ?onButtons '("shapes"))
          lShape = nil
          axlVisibleDesign(nil)
          
          foreach(sshape selItems
            lCoord = parseString(sshape " ,()")
            sLayer = car(lCoord)
            fCoordX = atof(nth(2 lCoord))
            fCoordY = atof(nth(3 lCoord))
            
            axlVisibleLayer(strcat("via class/" sLayer) t)
            axlVisibleLayer(strcat("etch/" sLayer) t)
            axlVisibleLayer(strcat("pin/" sLayer) t)
            
            dShape = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when(dShape
              lShape = cons(dShape lShape)
            )
          )
          axlHighlightObject(lShape)
          axlZoomToDbid(lShape t)
        )
      )
      
      ;;-------------------------------------------------------------------
      ;; 删除选中的 static 铜皮 / 用FanySkill方式处理 dynamic 铜皮
      ;;-------------------------------------------------------------------
      ("ddoShapesDel"
        axlMsgPut("[AST] 参考 FanySkill 方式删除/处理铜皮...")
        bDRC = axlDBControl('drcEnable nil)
        bDynFill = axlDBControl('dynamicFillMode nil)
        
        selItems = axlFormListGetSelItems(form "ddoShapeList")
        if(selItems then
          lShape = nil
          lDynCount = 0
          lStaticCount = 0
          lSys = axlVisibleGet()
          axlVisibleDesign(nil)
          
          foreach(sshape selItems
            lCoord = parseString(sshape " ,()")
            sLayer = car(lCoord)
            fCoordX = atof(nth(2 lCoord))
            fCoordY = atof(nth(3 lCoord))
            
            axlVisibleLayer(strcat("via class/" sLayer) t)
            axlVisibleLayer(strcat("etch/" sLayer) t)
            axlVisibleLayer(strcat("pin/" sLayer) t)
            
            dShape = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when(dShape
              if(dShape->shapeBoundary then
                ;; Dynamic shape - use polygon operation (reference FanySkill)
                dVoidPoly = car(axlPolyFromDB(dShape))
                dDynaShapePoly = car(axlPolyFromDB(dShape->shapeBoundary))
                dNewPoly = car(axlPolyOperation(dDynaShapePoly dVoidPoly 'ANDNOT))
                sNetName = dShape->net->name
                sShapeLayer = dShape->shapeBoundary->layer
                axlDeleteObject(dShape->shapeBoundary)
                dNewShape = car(axlDBCreateShape(dNewPoly t sShapeLayer sNetName))
                axlShapeDynamicUpdate(dNewShape t)
                lDynCount = lDynCount + 1
              else
                ;; Static shape - collect for batch deletion
                lShape = cons(dShape lShape)
                lStaticCount = lStaticCount + 1
              )
            )
            axlVisibleLayer(strcat("etch/" sLayer) nil)
          )
          
          ;; Delete static shapes in batch
          when(lShape
            mk_del = axlDBTransactionStart("Delete Island Shapes")
            axlDeleteObject(lShape)
            axlDBTransactionCommit(mk_del)
          )
          
          axlFormListDeleteItem(form "ddoShapeList" selItems)
          axlFormSetField(form "ddoShapeInfo"
            axlFormListGetCount(form "ddoShapeList"))
          axlMsgPut(sprintf(nil "[AST] 已处理 %d 个 static + %d 个 dynamic 孤岛铜皮"
            lStaticCount lDynCount))
          axlVisibleSet(lSys)
          axlFlushDisplay()
        else
          axlUIConfirm("请先从列表中选中一个铜皮")
        )
        
        axlDBControl('drcEnable bDRC)
        axlDBControl('dynamicFillMode bDynFill)
      )
      
      ;;-------------------------------------------------------------------
      ;; 挖空选中的 dynamic 铜皮
      ;;-------------------------------------------------------------------
      ("ddoShapesVoid"
        bDRC = axlDBControl('drcEnable nil)
        bDynFill = axlDBControl('dynamicFillMode nil)
        
        selItems = axlFormListGetSelItems(form "ddoShapeList")
        if(selItems then
          lVoidCount = 0
          lSys = axlVisibleGet()
          axlVisibleDesign(nil)
          
          foreach(sshape selItems
            lCoord = parseString(sshape " ,()")
            sLayer = car(lCoord)
            fCoordX = atof(nth(2 lCoord))
            fCoordY = atof(nth(3 lCoord))
            
            axlVisibleLayer(strcat("via class/" sLayer) t)
            axlVisibleLayer(strcat("etch/" sLayer) t)
            axlVisibleLayer(strcat("pin/" sLayer) t)
            
            dShape = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when(dShape
              when(dShape->shapeType == "DYNAMIC" || dShape->shapeAuto
                ;; Create rectangular void around the island center
                voidPoly = list(
                  list((fCoordX - 5.0):(fCoordY - 5.0)
                       (fCoordX + 5.0):(fCoordY - 5.0)
                       (fCoordX + 5.0):(fCoordY + 5.0)
                       (fCoordX - 5.0):(fCoordY + 5.0))
                )
                axlDBCreateVoid(dShape voidPoly)
                lVoidCount = lVoidCount + 1
              )
            )
            axlVisibleLayer(strcat("etch/" sLayer) nil)
          )
          
          when(lVoidCount > 0
            axlFormListDeleteItem(form "ddoShapeList" selItems)
            axlFormSetField(form "ddoShapeInfo"
              axlFormListGetCount(form "ddoShapeList"))
            axlMsgPut(sprintf(nil "[AST] 已对 %d 个 dynamic 铜皮创建 void 挖空" lVoidCount))
          )
          axlVisibleSet(lSys)
          axlFlushDisplay()
        else
          axlUIConfirm("请先从列表中选中一个铜皮")
        )
        
        axlDBControl('drcEnable bDRC)
        axlDBControl('dynamicFillMode bDynFill)
      )
      
      ;;-------------------------------------------------------------------
      ;; 关闭按钮
      ;;-------------------------------------------------------------------
      ("ddoClose"
        axlFormClose(form)
        axlClearSelSet()
        axlFlushDisplay()
        axlEndSkillMode()
        axlMsgPut("[AST] 悬空对象工具已关闭，请更新DRC并刷新铜皮")
      )
      
      ;;-------------------------------------------------------------------
      ;; 帮助按钮
      ;;-------------------------------------------------------------------
      ("ddoHelp"
        axlUIConfirm(
          "AST - 删除悬空对象工具\n"
          "\n"
          "功能说明:\n"
          "  自动查找并删除没有电气连接的悬空走线、过孔、孤岛铜皮\n"
          "\n"
          "使用方法:\n"
          "  1. 点击列表中的项目会自动高亮并缩放到对应位置\n"
          "  2. 选中要删除的项目后点击 Delete 按钮删除\n"
          "  3. 过孔可以选中后点击 Change Net 改网络\n"
          "  4. dynamic 铜皮可点击 Void 按钮挖空\n"
          "  5. 点击 Refresh 重新扫描\n"
          "  6. 点击 Close 关闭工具\n"
          "\n"
          "注意事项:\n"
          "  - 删除前请先保存文件\n"
          "  - 删除后请更新DRC\n"
          "  - dynamic 铜皮不可直接删除，只能挖空(void)"
        )
      )
    )
  )
)

;;=========================================================================
;; 检测函数: 扫描全板悬空对象
;; 返回值: list(lDanglingLines lDanglingVias lIslandShapes)
;;         每个列表元素为字符串格式: "layer, net, x,y" 或 "layer, net, x,y to x,y"
;;=========================================================================

procedure( _AST_DanglingCheck()
  prog((lClines lVias lShapes lDanglingLines lDanglingVias lIslandShapes
        sNet sLine sVia sShape bIgnore)
    
    lDanglingLines = nil
    lDanglingVias = nil
    lIslandShapes = nil
    
    ;; 扫描走线
    axlClearSelSet()
    axlSetFindFilter(?enabled '("noall" "invisible" "clines") ?onButtons '("clines"))
    lClines = axlGetSelSet(axlAddSelectAll())
    axlClearSelSet()
    
    foreach(cline lClines
      when(length(axlDBGetConnect(cline t)) < 2
        unless(cline->prop->FILLET || cline->symbolEtch
          if(cline->net then
            sNet = cline->net->name
          else
            sNet = "Dummy"
          )
          sLine = sprintf(nil "%s, %s, %L to %L"
            cadr(parseString(cline->layer "/"))
            sNet
            car(car(cline->segments)->startEnd)
            cadr(car(last(cline->segments))->startEnd)
          )
          lDanglingLines = cons(sLine lDanglingLines)
        )
      )
    )
    lDanglingLines = reverse(sort(lDanglingLines nil))
    
    ;; 扫描过孔
    axlClearSelSet()
    axlSetFindFilter(?enabled '("noall" "invisible" "vias") ?onButtons '("vias"))
    lVias = axlGetSelSet(axlAddSelectAll())
    axlClearSelSet()
    
    foreach(via lVias
      unless(via->symbolEtch
        bIgnore = nil
        if(via->net then
          sNet = via->net->name
          when(rexMatchp("^SNN_" sNet)
            bIgnore = t
          )
        else
          sNet = "Dummy"
        )
        
        sVia = sprintf(nil "%s, %s, %L"
          cadr(parseString(car(via->startEnd) "/"))
          sNet
          via->xy
        )
        
        unless(bIgnore
          when(onep(length(axlDBGetConnect(via t)))
            unless(via->testPoint || rexMatchp("_VOID$" via->name)
              lDanglingVias = cons(sVia lDanglingVias)
            )
          )
          when(zerop(length(axlDBGetConnect(via t)))
            unless(via->testPoint || rexMatchp("_VOID$" via->name)
              lDanglingVias = cons(sVia lDanglingVias)
            )
          )
        )
      )
    )
    lDanglingVias = reverse(sort(lDanglingVias nil))
    
    ;; 扫描铜皮: 连接数 < 2 即为孤岛
    lShapes = axlDBGetShapes("etch")
    foreach(shape lShapes
      when(length(axlDBGetConnect(shape t)) < 2
        sNet = "Dummy"
        when(shape->net && shape->net->name != ""
          sNet = shape->net->name
        )
        sShape = sprintf(nil "%s, %s, %L"
          cadr(parseString(shape->layer "/"))
          sNet
          car(car(shape->segments)->startEnd)
        )
        lIslandShapes = cons(sShape lIslandShapes)
      )
    )
    lIslandShapes = reverse(sort(lIslandShapes nil))
    
    return(list(lDanglingLines lDanglingVias lIslandShapes))
  )
)
