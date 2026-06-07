;; ============================================================
;; 文件名: text_silk.il
;; 功能说明: 丝印集成工具 - 统一GUI界面
;; 命令: AST_Text_SilkTool
;; 编码格式: GBK (简体中文)
;; ============================================================

axlCmdRegister("AST_Text_SilkTool" 'AST_Text_SilkTool ?cmdType "general")

defvar(_AST_TextSilkForm nil)

;;=========================================================================
;; 主函数: 创建并显示丝印集成GUI
;;=========================================================================

procedure(AST_Text_SilkTool()
  prog((formFile formPort formHandle)
    
    ;; 检查设计是否打开
    unless(axlCurrentDesign()
      axlMsgPut("[错误] 没有打开的设计文件")
      return(nil)
    )
    
    ;; 生成临时 .form 文件
    formFile = strcat(axlTempDirectory() "/AST_TextSilk.form")
    formPort = outfile(formFile "w")
    
    unless(formPort
      axlMsgPut("[错误] 无法创建临时表单文件")
      return(nil)
    )
    
    fprintf(formPort "FILE_TYPE=FORM_DEFN VERSION=2\n")
    fprintf(formPort "FORM\n")
    fprintf(formPort "FIXED\n")
    fprintf(formPort "PORT 72 36\n")
    fprintf(formPort "HEADER \"Silkscreen Integration Tool\"\n")
    fprintf(formPort "TILE\n")
    
    ;; TABSET
    fprintf(formPort "TABSET tabs\n")
    fprintf(formPort "FLOC 2 2\n")
    fprintf(formPort "FSIZE 68 32\n")
    
    ;; Tab 1: Auto REFDES
    fprintf(formPort "TAB \"Auto REFDES\"\n")
    fprintf(formPort "TEXT \"Move REFDES to center-top of each component\"\n")
    fprintf(formPort "TLOC 3 3\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD enableAutoSilk\n")
    fprintf(formPort "FLOC 3 6\n")
    fprintf(formPort "CHECKLIST \"Enable auto adjustment\"\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "TEXT \"Vertical Offset (mils):\"\n")
    fprintf(formPort "TLOC 3 9\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD offsetY\n")
    fprintf(formPort "FLOC 28 9\n")
    fprintf(formPort "REALFILLIN 10 2\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD bnAutoSilk\n")
    fprintf(formPort "FLOC 3 13\n")
    fprintf(formPort "MENUBUTTON \"Execute Auto REFDES\" 24 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "ENDTAB\n")
    
    ;; Tab 2: Net Label
    fprintf(formPort "TAB \"Net Label\"\n")
    fprintf(formPort "TEXT \"Add net name silkscreen along trace midpoint\"\n")
    fprintf(formPort "TLOC 3 3\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD enableNetSilk\n")
    fprintf(formPort "FLOC 3 6\n")
    fprintf(formPort "CHECKLIST \"Enable net labeling\"\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "TEXT \"Text Height (mils):\"\n")
    fprintf(formPort "TLOC 3 9\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD netTextHeight\n")
    fprintf(formPort "FLOC 28 9\n")
    fprintf(formPort "REALFILLIN 10 2\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "TEXT \"Target Layer:\"\n")
    fprintf(formPort "TLOC 3 12\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD netLayer\n")
    fprintf(formPort "FLOC 28 12\n")
    fprintf(formPort "ENUM 20\n")
    fprintf(formPort "POPUP \"SILKSCREEN_TOP|SILKSCREEN_TOP|SILKSCREEN_BOTTOM|SILKSCREEN_BOTTOM\"\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD bnNetSilk\n")
    fprintf(formPort "FLOC 3 16\n")
    fprintf(formPort "MENUBUTTON \"Execute Net Label\" 24 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "ENDTAB\n")
    
    ;; Tab 3: Text Size
    fprintf(formPort "TAB \"Text Size\"\n")
    fprintf(formPort "TEXT \"Batch resize selected text objects\"\n")
    fprintf(formPort "TLOC 3 3\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD enableSetSize\n")
    fprintf(formPort "FLOC 3 6\n")
    fprintf(formPort "CHECKLIST \"Enable batch resize\"\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "TEXT \"Text Block #:\"\n")
    fprintf(formPort "TLOC 3 9\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD textBlockNum\n")
    fprintf(formPort "FLOC 28 9\n")
    fprintf(formPort "INTFILLIN 3 2\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD bnSetSize\n")
    fprintf(formPort "FLOC 3 13\n")
    fprintf(formPort "MENUBUTTON \"Execute Text Resize\" 24 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "ENDTAB\n")
    
    ;; Tab 4: Chinese
    fprintf(formPort "TAB \"Chinese\"\n")
    fprintf(formPort "TEXT \"Place Chinese text as stroke line segments\"\n")
    fprintf(formPort "TLOC 3 3\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "TEXT \"Text Content:\"\n")
    fprintf(formPort "TLOC 3 6\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD chineseText\n")
    fprintf(formPort "FLOC 3 8\n")
    fprintf(formPort "STRFILLIN 50 64\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "TEXT \"Target Layer:\"\n")
    fprintf(formPort "TLOC 3 12\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD chineseLayer\n")
    fprintf(formPort "FLOC 28 12\n")
    fprintf(formPort "ENUM 20\n")
    fprintf(formPort "POPUP \"SILKSCREEN_TOP|SILKSCREEN_TOP|SILKSCREEN_BOTTOM|SILKSCREEN_BOTTOM|ASSEMBLY_TOP|ASSEMBLY_TOP\"\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD bnChinese\n")
    fprintf(formPort "FLOC 3 16\n")
    fprintf(formPort "MENUBUTTON \"Place Chinese Text\" 24 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "ENDTAB\n")
    
    ;; Tab 5: Logo
    fprintf(formPort "TAB \"Logo\"\n")
    fprintf(formPort "TEXT \"Import 1-bit BMP as PCB line/shape elements\"\n")
    fprintf(formPort "TLOC 3 3\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "TEXT \"BMP File:\"\n")
    fprintf(formPort "TLOC 3 6\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD logoFile\n")
    fprintf(formPort "FLOC 3 8\n")
    fprintf(formPort "STRFILLIN 50 256\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "TEXT \"Target Layer:\"\n")
    fprintf(formPort "TLOC 3 12\n")
    fprintf(formPort "ENDTEXT\n")
    fprintf(formPort "FIELD logoLayer\n")
    fprintf(formPort "FLOC 28 12\n")
    fprintf(formPort "ENUM 20\n")
    fprintf(formPort "POPUP \"SILKSCREEN_TOP|SILKSCREEN_TOP|SILKSCREEN_BOTTOM|SILKSCREEN_BOTTOM|ETCH_TOP|ETCH_TOP\"\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "FIELD bnLogo\n")
    fprintf(formPort "FLOC 3 16\n")
    fprintf(formPort "MENUBUTTON \"Import Logo\" 24 3\n")
    fprintf(formPort "ENDFIELD\n")
    fprintf(formPort "ENDTAB\n")
    
    fprintf(formPort "ENDTABSET\n")
    
    ;; 状态信息
    fprintf(formPort "FIELD status\n")
    fprintf(formPort "FLOC 2 34\n")
    fprintf(formPort "INFO 55\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "FIELD bnClose\n")
    fprintf(formPort "FLOC 58 34\n")
    fprintf(formPort "MENUBUTTON \"Close\" 12 2\n")
    fprintf(formPort "ENDFIELD\n")
    
    fprintf(formPort "ENDTILE\n")
    fprintf(formPort "ENDFORM\n")
    
    close(formPort)
    
    ;; 创建表单 - 使用 gensym() 函数调用
    formHandle = axlFormCreate(gensym() formFile '(center) '_AST_TextSilkCB t)
    
    ;; 删除临时文件
    when(isFile(formFile)
      deleteFile(formFile)
    )
    
    unless(formHandle
      axlMsgPut("[错误] 无法创建表单")
      return(nil)
    )
    
    _AST_TextSilkForm = formHandle
    
    ;; 初始化默认值
    axlFormSetField(formHandle "offsetY" "20.0")
    axlFormSetField(formHandle "enableAutoSilk" "1")
    axlFormSetField(formHandle "netTextHeight" "25.0")
    axlFormSetField(formHandle "netLayer" "SILKSCREEN_TOP")
    axlFormSetField(formHandle "enableNetSilk" "1")
    axlFormSetField(formHandle "textBlockNum" "2")
    axlFormSetField(formHandle "enableSetSize" "1")
    axlFormSetField(formHandle "chineseText" "示例文字")
    axlFormSetField(formHandle "chineseLayer" "SILKSCREEN_TOP")
    axlFormSetField(formHandle "logoFile" "logo.bmp")
    axlFormSetField(formHandle "logoLayer" "SILKSCREEN_TOP")
    axlFormSetField(formHandle "status" "Ready. Select a tab and click Execute.")
    
    axlFormDisplay(formHandle)
    formHandle
  )
)

;;=========================================================================
;; Auto REFDES
;;=========================================================================

procedure(_AST_TextSilk_AutoRefdes(form)
  prog((comps count sym bbox cx cy topY textObjs layerPrefix offsetY orient)
    
    offsetY = atof(axlFormGetField(form "offsetY"))
    when(offsetY <= 0 offsetY = 20.0)
    
    comps = axlDBGetDesign()->components
    count = 0
    layerPrefix = "REF DES/SILKSCREEN_"
    
    foreach(comp comps
      when(comp
        sym = car(axlSelectByName("COMPONENT" comp->refdes))
        when(sym
          bbox = sym->bBox
          cx = (caar(bbox) + caadr(bbox)) / 2
          cy = (cadar(bbox) + cadr(cadr(bbox))) / 2
          topY = cadr(cadr(bbox)) + offsetY
          
          foreach(child sym->children
            when(child->objType == "text"
              when(index(child->layer layerPrefix)
                prog((dx dy)
                  dx = cx - car(child->xy)
                  dy = topY - cadr(child->xy)
                  orient = make_axlTextOrientation(
                    ?textBlock child->textBlock
                    ?rotation 0
                    ?mirrored child->isMirrored
                    ?justify "center"
                  )
                  axlDBChangeText(child child->text ?orientation orient)
                  axlTransformObject(child ?move list(dx dy))
                  count = count + 1
                )
              )
            )
          )
        )
      )
    )
    
    axlDisplayFlush()
    axlFormSetField(form "status" sprintf(nil "Auto REFDES: %d components adjusted." count))
    return(count)
  )
)

;;=========================================================================
;; Net Label
;;=========================================================================

procedure(_AST_TextSilk_NetLabel(form)
  prog((nets selNets count textHeight textLayer midPt textObj)
    
    textHeight = atof(axlFormGetField(form "netTextHeight"))
    when(textHeight <= 0 textHeight = 25.0)
    textLayer = axlFormGetField(form "netLayer")
    unless(textLayer textLayer = "SILKSCREEN_TOP")
    
    nets = axlDBGetNets()
    unless(nets
      axlFormSetField(form "status" "Net Label: No nets found.")
      return(0)
    )
    
    selNets = nil
    foreach(net nets
      unless(rexMatchp("^(VCC|VDD|GND|PGND|AGND|DGND|POWER|VSS|VBB|VEE)" net->name)
        selNets = cons(net selNets)
      )
    )
    
    count = 0
    foreach(net selNets
      midPt = _AST_TextSilk_GetNetMidpoint(net)
      when(midPt
        textObj = axlDBCreateText(
          net->name
          midPt
          textLayer
          textHeight
          0.0
          "center"
          nil
        )
        when(textObj
          count = count + 1
          axlHighlightObject(net)
        )
      )
    )
    
    axlDisplayFlush()
    axlFormSetField(form "status" sprintf(nil "Net Label: %d nets labeled." count))
    return(count)
  )
)

;;------------------------------------------------------------------------
;; 辅助: 获取网络走线的中点位置
;;------------------------------------------------------------------------

procedure(_AST_TextSilk_GetNetMidpoint(net)
  prog((clines minX minY maxX maxY midX midY)
    
    clines = net->clines
    unless(clines return(nil))
    
    minX = nil minY = nil maxX = nil maxY = nil
    
    foreach(cline clines
      when(cline->xy
        foreach(pt cline->xy
          when(minX == nil || car(pt) < minX minX = car(pt))
          when(minY == nil || cadr(pt) < minY minY = cadr(pt))
          when(maxX == nil || car(pt) > maxX maxX = car(pt))
          when(maxY == nil || cadr(pt) > maxY maxY = cadr(pt))
        )
      )
    )
    
    when(minX
      midX = (minX + maxX) / 2
      midY = (minY + maxY) / 2
      return(list(midX midY))
    )
    
    return(nil)
  )
)

;;=========================================================================
;; Text Size
;;=========================================================================

procedure(_AST_TextSilk_SetSize(form)
  prog((texts blockNum orient blockStr)
    
    axlClearSelSet()
    axlSetFindFilter(?enabled '(NOALL TEXT) ?onButtons '(TEXT))
    axlMsgPut("Select text objects to resize, then right-click Done.")
    axlSelect()
    texts = axlGetSelSet()
    
    unless(texts
      axlFormSetField(form "status" "Text Size: No text objects selected.")
      return(nil)
    )
    
    blockStr = axlFormGetField(form "textBlockNum")
    blockNum = atoi(blockStr)
    when(blockNum <= 0 blockNum = 2)
    
    prog((testBlock)
      testBlock = axlDBTextBlockCreate(blockNum ?width 30.0 ?height 30.0 ?photoWidth 5.0)
      when(testBlock == nil
        axlMsgPut("WARNING: Text block #%d may not exist. Using default." blockNum)
      )
    )
    
    foreach(txt texts
      when(txt->objType == "text"
        orient = make_axlTextOrientation(
          ?textBlock blockNum
          ?rotation txt->rotation
          ?mirrored txt->isMirrored
          ?justify "center"
        )
        axlDBChangeText(txt txt->text ?orientation orient)
      )
    )
    
    axlClearSelSet()
    axlDisplayFlush()
    axlFormSetField(form "status" sprintf(nil "Text Size: %d objects resized to block #%d." length(texts) blockNum))
    return(length(texts))
  )
)

;;=========================================================================
;; Chinese
;;=========================================================================

procedure(_AST_TextSilk_Chinese(form)
  prog((str pt layer textHeight)
    
    str = axlFormGetField(form "chineseText")
    unless(str
      axlFormSetField(form "status" "Chinese: Please enter text content.")
      return(nil)
    )
    
    layer = axlFormGetField(form "chineseLayer")
    unless(layer layer = "SILKSCREEN_TOP")
    textHeight = 50.0
    
    axlMsgPut("Pick text placement point...")
    pt = axlEnterPoint(?prompts '("Pick text placement point"))
    
    when(pt
      axlDBCreateText(
        strcat("[CN]" str)
        pt
        layer
        textHeight
        0.0
        "center"
        nil
      )
      axlFormSetField(form "status" sprintf(nil "Chinese: Placeholder placed. Full stroke conversion requires external tool."))
      axlDisplayFlush()
    )
    
    return(t)
  )
)

;;=========================================================================
;; Logo
;;=========================================================================

procedure(_AST_TextSilk_Logo(form)
  prog((bmpFile pt layer)
    
    bmpFile = axlFormGetField(form "logoFile")
    unless(bmpFile
      axlFormSetField(form "status" "Logo: Please specify BMP file path.")
      return(nil)
    )
    
    unless(isFile(bmpFile)
      axlFormSetField(form "status" sprintf(nil "Logo: File not found: %s" bmpFile))
      return(nil)
    )
    
    layer = axlFormGetField(form "logoLayer")
    unless(layer layer = "SILKSCREEN_TOP")
    
    axlMsgPut("Pick logo insertion point...")
    pt = axlEnterPoint(?prompts '("Pick logo insertion point"))
    
    when(pt
      prog((bbox)
        bbox = list(
          list(car(pt) cadr(pt))
          list(car(pt) + 100.0 cadr(pt) + 100.0)
        )
        axlDBCreateRectangle(bbox layer)
        axlDBCreateText(
          strcat("[LOGO] " bmpFile)
          list(car(pt) + 50.0 cadr(pt) + 50.0)
          layer
          20.0
          0.0
          "center"
          nil
        )
      )
      axlFormSetField(form "status" sprintf(nil "Logo: Placeholder placed. Full BMP parser not yet implemented."))
      axlDisplayFlush()
    )
    
    return(t)
  )
)

;;------------------------------------------------------------------------
;; 表单回调
;;------------------------------------------------------------------------

procedure(_AST_TextSilkCB(form)
  prog((field)
    field = axlFormGetField(form)
    
    case(field
      ("bnAutoSilk"
        when(axlFormGetField(form "enableAutoSilk") == "1"
          _AST_TextSilk_AutoRefdes(form)
        else
          axlFormSetField(form "status" "Auto REFDES is disabled. Check the enable box.")
        )
      )
      ("bnNetSilk"
        when(axlFormGetField(form "enableNetSilk") == "1"
          _AST_TextSilk_NetLabel(form)
        else
          axlFormSetField(form "status" "Net Label is disabled. Check the enable box.")
        )
      )
      ("bnSetSize"
        when(axlFormGetField(form "enableSetSize") == "1"
          _AST_TextSilk_SetSize(form)
        else
          axlFormSetField(form "status" "Text Size is disabled. Check the enable box.")
        )
      )
      ("bnChinese"
        _AST_TextSilk_Chinese(form)
      )
      ("bnLogo"
        _AST_TextSilk_Logo(form)
      )
      ("bnClose"
        axlFormClose(form)
        _AST_TextSilkForm = nil
      )
      (t
        nil
      )
    )
  )
)
