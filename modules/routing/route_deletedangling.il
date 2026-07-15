;; ============================================================
;; File: route_deletedangling.il
;; Purpose: Delete dangling
;; Encoding: ASCII
;; ============================================================

;; ============================================================
;; ???: del_dangling.il
;; ????: ???? - ??????GUI?(??/??/??)
;; ????: GBK (????)
;; ????: ?????GBK????????UTF-8??
;; ============================================================
;; ================================================================================
;; ???? : ????-??????GUI?
;;            ??????????????????????????
;; ???? : modules/cleanup/del_dangling.il
;; ???? : GBK/GB18030 (??????)
;; ???? : ?
;; ???? : ?????GB?????????UTF-8????????????
;; ???? : FanySkill_quick_danglings.il (EDA365)
;; ================================================================================

;;#############################################################################
;;#  ??: ?????? (Delete Dangling Objects)                                 #
;;#  ??: AST_DelDangling / AST_Cleanup_DelDangling                              #
;;#  ??: GUI???????????????????                              #
;;#  API:  axlDBGetConnect, axlDeleteObject, axlFormCreate, axlHighlightObject   #
;;#############################################################################



;;=========================================================================
;; ????
;;=========================================================================

defvar(_AST_DanglingForm)
defvar(_AST_DanglingData)

;;=========================================================================
;; ???: ?????????GUI
;;=========================================================================

procedure( ASTB_Route_DeleteDangling()
  prog((lData lLines lVias lShapes)
    
    ;; ????????
    unless(axlOKToProceed()
      axlUIConfirm("??????????")
      return(nil)
    )
    
    ;; ????
    lData = _AST_GetDanglingData()
    
    ;; ??
    if(null(lData) then
      axlUIConfirm("????????????")
      return(nil)
    )
    
    ;; ????????
    lLines = car(lData)
    lVias = cadr(lData)
    lShapes = caddr(lData)
    
    ;; ?????
    _AST_DelDanglingForm(lData)
    
    return(t)
  )
)

;;=========================================================================
;; ???: ??????????
;;=========================================================================

procedure( _AST_GetDanglingData()
  prog((lLines lVias lShapes lAll lObj lConn)
    
    lLines = nil
    lVias = nil
    lShapes = nil
    
    ;; ?????????
    lAll = axlGetSelSet()
    when(null(lAll)
      ;; ????????????????????
      axlSetFindFilter(?enabled list("noall" "lines" "vias" "shapes")
                       ?onButtons list("noall" "lines" "vias" "shapes"))
      lAll = axlSelectAll()
    )
    
    ;; ????????????
    foreach(lObj lAll
      case(lObj->objType
        ("line"
          lConn = axlDBGetConnect(lObj)
          when(null(lConn) || length(lConn) == 1
            lLines = cons(lObj lLines)
          )
        )
        ("via"
          lConn = axlDBGetConnect(lObj)
          when(null(lConn) || length(lConn) == 1
            lVias = cons(lObj lVias)
          )
        )
        ("shape"
          lConn = axlDBGetConnect(lObj)
          when(null(lConn) || length(lConn) == 1
            lShapes = cons(lObj lShapes)
          )
        )
      )
    )
    
    ;; ?????
    lLines = reverse(lLines)
    lVias = reverse(lVias)
    lShapes = reverse(lShapes)
    
    ;; ??????????
    if(null(lLines) && null(lVias) && null(lShapes) then
      return(nil)
    )
    
    return(list(lLines lVias lShapes))
  )
)

;;=========================================================================
;; ???: ???????GUI
;;=========================================================================

procedure( _AST_DelDanglingForm(lData)
  prog((lLines lVias lShapes lForm lFields)
    
    lLines = car(lData)
    lVias = cadr(lData)
    lShapes = caddr(lData)
    
    ;; ???????
    lForm = axlFormCreate((gensym) "del_dangling.form"
                           '(e outside "Done")
                           '_AST_DelDanglingFormCallback)
    
    ;; ?????
    axlFormSetField(lForm "lineCount" sprintf(nil "%d" length(lLines)))
    axlFormSetField(lForm "viaCount" sprintf(nil "%d" length(lVias)))
    axlFormSetField(lForm "shapeCount" sprintf(nil "%d" length(lShapes)))
    
    ;; ????????
    axlFormSetField(lForm "deleteLines" "1")
    axlFormSetField(lForm "deleteVias" "1")
    axlFormSetField(lForm "deleteShapes" "1")
    
    ;; ??
    axlFormDisplay(lForm)
    
    ;; ?????
    _AST_DanglingForm = lForm
    _AST_DanglingData = lData
    
    return(lForm)
  )
)

;;=========================================================================
;; ???: GUI????
;;=========================================================================

procedure( _AST_DelDanglingFormCallback(lForm lField)
  prog((lLines lVias lShapes lDeleteLines lDeleteVias lDeleteShapes)
    
    case(lField
      ("delete"
        ;; ????????
        lLines = car(_AST_DanglingData)
        lVias = cadr(_AST_DanglingData)
        lShapes = caddr(_AST_DanglingData)
        
        lDeleteLines = axlFormGetField(lForm "deleteLines")
        lDeleteVias = axlFormGetField(lForm "deleteVias")
        lDeleteShapes = axlFormGetField(lForm "deleteShapes")
        
        ;; ??????
        when(lDeleteLines == "1"
          foreach(lObj lLines
            axlDeleteObject(lObj)
          )
        )
        
        ;; ??????
        when(lDeleteVias == "1"
          foreach(lObj lVias
            axlDeleteObject(lObj)
          )
        )
        
        ;; ??????
        when(lDeleteShapes == "1"
          foreach(lObj lShapes
            axlDeleteObject(lObj)
          )
        )
        
        ;; ?????
        axlUIConfirm("????????????")
        
        ;; ??GUI
        axlFormClose(lForm)
        _AST_DanglingForm = nil
        _AST_DanglingData = nil
      )
      ("preview"
        ;; ??????????
        lLines = car(_AST_DanglingData)
        lVias = cadr(_AST_DanglingData)
        lShapes = caddr(_AST_DanglingData)
        
        lDeleteLines = axlFormGetField(lForm "deleteLines")
        lDeleteVias = axlFormGetField(lForm "deleteVias")
        lDeleteShapes = axlFormGetField(lForm "deleteShapes")
        
        ;; ?????
        axlClearSelSet()
        
        ;; ???????
        when(lDeleteLines == "1"
          foreach(lObj lLines
            axlAddSelectObject(lObj)
          )
        )
        
        ;; ???????
        when(lDeleteVias == "1"
          foreach(lObj lVias
            axlAddSelectObject(lObj)
          )
        )
        
        ;; ???????
        when(lDeleteShapes == "1"
          foreach(lObj lShapes
            axlAddSelectObject(lObj)
          )
        )
        
        ;; ?????????
        axlZoomToSelSet()
      )
      ("cancel"
        ;; ??GUI
        axlFormClose(lForm)
        _AST_DanglingForm = nil
        _AST_DanglingData = nil
      )
    )
    
    return(t)
  )
)

;;=========================================================================
;; ???: ????????
;;=========================================================================

procedure( ASTB_Cleanup_DeleteDangling()
  prog((lData lLines lVias lShapes)
    
    ;; ????????
    unless(axlOKToProceed()
      axlUIConfirm("??????????")
      return(nil)
    )
    
    ;; ????
    lData = _AST_GetDanglingData()
    
    ;; ??
    if(null(lData) then
      axlUIConfirm("????????????")
      return(nil)
    )
    
    ;; ????????
    lLines = car(lData)
    lVias = cadr(lData)
    lShapes = caddr(lData)
    
    ;; ??????????
    foreach(lObj lLines
      axlDeleteObject(lObj)
    )
    foreach(lObj lVias
      axlDeleteObject(lObj)
    )
    foreach(lObj lShapes
      axlDeleteObject(lObj)
    )
    
    ;; ?????
    axlUIConfirm(sprintf(nil "?????? %d ????? %d ??? %d ?????"
                         length(lLines) length(lVias) length(lShapes)))
    
    return(t)
  )
)

;;=========================================================================
;; ???: ??????
;;=========================================================================

axlCmdRegister("delete dangling" 'ASTB_Route_DeleteDangling)
axlCmdRegister("cleanup dangling" 'ASTB_Cleanup_DeleteDangling)

;;#############################################################################
;;#  ????: ????(Delete Dangling) - GUI + ???????                          #
;;#  ????: Allegro SKILL (AXL)                                                #
;;#  ????: SPB 16.6+                                                          #
;;#############################################################################
