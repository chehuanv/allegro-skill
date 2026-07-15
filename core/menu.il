;; ============================================================
;; File: core/menu.il
;; Purpose: Menu builder and injector with i18n support
;; Encoding: ASCII (16.6 compatible)
;; ============================================================

defvar(ASTB_ZH_LABELS makeTable('ASTB_ZH_LABELS nil))
defvar(ASTB_MENU_INJECTED nil)
defvar(ASTB_MENU_IDS makeTable('ASTB_MENU_IDS))

;; ============================================================
;; i18n: Language switch & label lookup
;; ============================================================

;;=========================================================================
;; Load Chinese labels from core/labels_raw.dat (raw GBK, one per line).
;;=========================================================================
procedure( ASTB_LoadChineseLabels()
  let((datPath port line idx keys tblSize)
    keys = list(
      "allegro_skill_toolbox"
      "Package"
      "Placement"
      "Routing"
      "Via"
      "Shape"
      "Text/Silk"
      "Check"
      "Manufacturing"
      "Utilities"
      "System"
      "Change Origin"
      "Export Footprint"
      "Export Pad"
      "Create Device File"
      "Rename Pins"
      "Create Oval Flash"
      "Symbol Check"
      "Update Symbol"
      "Find Component"
      "Check No Place Bound"
      "Component Changes"
      "Component Height"
      "Create Pad"
      "Find Components v13"
      "Package Output"
      "Place by Page"
      "Gather Components"
      "Align"
      "Equal Spacing"
      "Mirror Group"
      "Set Grid"
      "Move to Grid"
      "Place Inside"
      "RefDes to Center"
      "Align Symbol"
      "Align Text"
      "Gather Symbols"
      "Align Via"
      "Equal Symbol Spacing"
      "Move Screen"
      "Cut Line/Shape"
      "Change Line Width"
      "Delete Dangling"
      "Find Dangling"
      "Find Stub"
      "Short Segments"
      "Check Cross Split"
      "Line to Shape"
      "Auto 10deg Trace"
      "RPD"
      "Replace Via"
      "Change Via Net"
      "Stack Vias"
      "Same Via Highlight"
      "Delete GND Via"
      "Via Stitching"
      "Delete Isolating Vias"
      "Update Dynamic Shape"
      "Create Thermal Flash"
      "Change Shape Net"
      "Split Shape"
      "Set Text Attr"
      "Import Logo"
      "Add Chinese"
      "Adjust RefDes"
      "Add Net Name"
      "Check Ref Orient"
      "Check Text Overlap"
      "Mirror Text"
      "Rename RefDes"
      "AutoSilk Utils"
      "Check No RefDes"
      "Check Ref Direction"
      "DRC Walk"
      "Kill External DRC"
      "Find Orphan Net"
      "No Fanout SMD"
      "Check 90deg Line"
      "Run DbDoctor"
      "Find DRC"
      "Check Direction"
      "Check No Ref"
      "Checklist"
      "Loop 90 Check"
      "Net Editor"
      "Pad Count"
      "QFP Pitch"
      "Spacing Check"
      "Export Gerber"
      "Export Coords"
      "Export JSON"
      "Export IPC-356"
      "Panelize"
      "Auto Drill Legend"
      "Auto Copper Balance"
      "Solder Paste"
      "CAM Clear"
      "Valor Output"
      "Valor Extract"
      "Valor Film"
      "Unit Convert"
      "Color Power Nets"
      "Set Shortcut"
      "Calculator"
      "Pin Keepout"
      "Choose Grid"
      "Color Setting"
      "Quick Colors"
      "Class Map"
      "Display Options"
      "Etch Visible"
      "Height Check"
      "Quick Display"
      "Quick View"
      "Show Height"
      "Form Generator"
      "Quick Search"
      "Assembly"
      "DP Replace"
      "Draw Targets"
      "EAD Tools"
      "Find Component"
      "Game TCS"
      "Grid SA"
      "View Reports"
      "Super Net Finder"
      "Tech Manager"
      "Tech Manager V1.2"
      "Make Device"
      "Pad Line"
      "PDI Visibility"
      "Pick Data"
      "Place List"
      "Place Symbols"
      "Quick Grids"
      "Quick Text Set"
      "QView"
      "Replay"
      "Ruler"
      "Search"
      "Show Library"
      "Stack"
      "Update FE Height"
      "SClass"
      "About"
      "Reload"
      "Switch Language"
    )
    tblSize = length(keys)
    datPath = strcat(ASTB_GLOBAL->CorePath "/labels_raw.dat")
    printf("[ASTB] Loading Chinese labels from: %s\n" datPath)
    port = infile(datPath)
    unless(port
      printf("[ASTB] ERROR: cannot open labels_raw.dat\n")
      return(nil)
    )
    idx = 0
    while(gets(line port)
      line = ASTB_StringTrim(line)
      when(and(idx < tblSize nequal(line ""))
        ASTB_ZH_LABELS[nth(idx keys)] = line
      )
      idx = idx + 1
    )
    close(port)
    printf("[ASTB] Chinese labels loaded: %d entries\n" idx)
  )
)

;; Lookup Chinese label; fall back to English if not found.
procedure( ASTB_ZH_GET(enLabel)
  let((zh)
    zh = ASTB_ZH_LABELS[enLabel]
    if(zh then zh else enLabel)
  )
)

;; Determine if current language is English
procedure( ASTB_IsLanguageEnglish()
  prog((lang)
    lang = ASTB_GetConfig("language" "zh-CN")
    when( or(null(lang) eq(lang 'unbound))
      lang = "zh-CN"
    )
    return( lang == "en" || lang == "en-US" || lang == "english" || lang == "en-us" )
  )
)

procedure( ASTB_GetMenuStructure()
  list(

    ;; ====== Top-level toolbox menu ======
    list('popup "allegro_skill_toolbox" "allegro_skill_toolbox")

    ;; ====== Package ======
    list('popup "Package" "Package")
    list("Change Origin"       "Change Origin"       "ASTB_Pkg_ChangeOrigin")
    list("Export Footprint"    "Export Footprint"    "ASTB_Pkg_ExportFootprint")
    list("Export Pad"          "Export Pad"          "ASTB_Pkg_ExportPad")
    list("Create Device File"  "Create Device File"  "ASTB_Pkg_CreateDevFile")
    list("Create Oval Flash"   "Create Oval Flash"   "ASTB_Pkg_CreateOvalFlash")
    '(end)
    '(separator)

    ;; ====== Placement ======
    list('popup "Placement" "Placement")
    list("Place by Page"      "Place by Page"       "ASTB_Place_PlaceByPage")
    list("Gather Components"  "Gather Components"   "ASTB_Place_GatherComps")
    list("Align"              "Align"               "ASTB_Place_Align")
    list("Place Inside"       "Place Inside"        "ASTB_Place_PlaceInside")
    list("Move to Grid"       "Move to Grid"        "ASTB_Place_MoveToGrid")
    list("Move Screen"        "Move Screen"         "ASTB_Place_MoveScreen")
    '(end)
    '(separator)

    ;; ====== Routing ======
    list('popup "Routing" "Routing")
    list("Cut Line/Shape"     "Cut Line/Shape"      "ASTB_Route_CutLineShape")
    list("Change Line Width"  "Change Line Width"   "ASTB_Route_ChangeLineWidth")
    list("Delete Dangling"    "Delete Dangling"     "ASTB_Route_DeleteDangling")
    list("Short Segments"     "Short Segments"      "ASTB_Route_ShortSeg")
    list("Check Cross Split"  "Check Cross Split"   "ASTB_Route_CheckSplit")
    list("Line to Shape"      "Line to Shape"       "ASTB_Route_LineToShape")
    list("Auto 10deg Trace"   "Auto 10deg Trace"    "ASTB_Route_Auto10deg")
    '(end)
    '(separator)

    ;; ====== Via ======
    list('popup "Via" "Via")
    list("Change Via Net"     "Change Via Net"      "ASTB_Via_ChangeViaNet")
    list("Stack Vias"         "Stack Vias"          "ASTB_Via_StackVias")
    list("Same Via Highlight" "Same Via Highlight"  "ASTB_Via_SameVia")
    list("Via Stitching"      "Via Stitching"       "ASTB_Via_Stitching")
    '(end)
    '(separator)

    ;; ====== Shape ======
    list('popup "Shape" "Shape")
    list("Update Dynamic Shape" "Update Dynamic Shape" "ASTB_Shape_UpdateDynamic")
    list("Change Shape Net"     "Change Shape Net"     "ASTB_Shape_ChangeNet")
    '(end)
    '(separator)

    ;; ====== Text/Silk ======
    list('popup "Text/Silk" "Text/Silk")
    list("Import Logo"        "Import Logo"         "ASTB_Text_ImportLogo")
    list("Check Ref Orient"   "Check Ref Orient"    "ASTB_Text_CheckRefOrient")
    list("Add Net Name"       "Add Net Name"        "ASTB_Text_AddNetName")
    list("Check Text Overlap" "Check Text Overlap"  "ASTB_Text_CheckOverlap")
    list("AutoSilk Utils"     "AutoSilk Utils"      "ASTB_Text_AutoSilkUtils")
    '(end)
    '(separator)

    ;; ====== Check ======
    list('popup "Check" "Check")
    list("Check No RefDes"    "Check No RefDes"     "ASTB_Check_NoRefDes")
    list("DRC Walk"           "DRC Walk"            "ASTB_Check_DRCWalk")
    list("Find Orphan Net"    "Find Orphan Net"     "ASTB_Check_OrphanNet")
    list("Check 90deg Line"   "Check 90deg Line"    "ASTB_Check_90degLine")
    list("Run DbDoctor"       "Run DbDoctor"        "ASTB_Check_DbDoctor")
    list("Pad Count"          "Pad Count"           "ASTB_Check_PadCount")
    list("Spacing Check"      "Spacing Check"       "ASTB_Check_Spacing")
    '(end)
    '(separator)

    ;; ====== Utilities ======
    list('popup "Utilities" "Utilities")
    list("Unit Convert"       "Unit Convert"        "ASTB_Util_UnitConvert")
    list("Color Power Nets"   "Color Power Nets"    "ASTB_Util_ColorPowerNets")
    list("Super Net Finder"   "Super Net Finder"    "ASTB_Util_SuperNetFinder")
    list("Choose Grid"        "Choose Grid"         "ASTB_Util_ChooseGrid")
    '(end)
    '(separator)

    ;; ====== System ======
    list('popup "System" "System")
    list("About"   "About"   "ASTB_About")
    list("Reload"  "Reload"  "ASTB_Reload")
    '(separator)
    list('popup "Language" "Language")
    list("English"  "English"  "ASTB_SetLanguageEnglish")
    list("Chinese"  "Chinese"  "ASTB_SetLanguageChinese")
    '(end)
    '(end)
    '(end)
  )
)

procedure( ASTB_MenuIsPopup(item)
  and(listp(item) car(item) == 'popup)
)

procedure( ASTB_MenuIsEnd(item)
  and(listp(item) car(item) == 'end)
)

procedure( ASTB_MenuIsSeparator(item)
  and(listp(item) car(item) == 'separator)
)

procedure( ASTB_MenuIsCommand(item)
  and(listp(item) length(item) >= 3 stringp(car(item)) stringp(cadr(item)) stringp(caddr(item)))
)

procedure( ASTB_MenuGetPopupLabel(item)
  if( ASTB_IsLanguageEnglish() then cadr(item) else ASTB_ZH_GET(cadr(item)) )
)

procedure( ASTB_MenuGetCommandLabel(item)
  if( ASTB_IsLanguageEnglish() then car(item) else ASTB_ZH_GET(car(item)) )
)

procedure( ASTB_MenuGetCommand(item)
  caddr(item)
)

procedure( ASTB_GetMenuCommands(menuList)
  prog((result item)
    result = nil
    foreach( item menuList
      when( ASTB_MenuIsCommand(item)
        result = cons(ASTB_MenuGetCommand(item) result)
      )
    )
    result
  )
)

procedure( ASTB_MenuAlreadyInjected()
  prog((tmpFile port line found ret)
    when( ASTB_MENU_INJECTED
      return(t)
    )
    found = nil
    ret = errset(
      prog(()
        tmpFile = axlTempFile()
        when( tmpFile
          axlUIMenuDump(tmpFile)
          port = infile(tmpFile)
          when( port
            while( gets(line port)
              when( rexMatchp("allegro_skill_toolbox" line)
                found = t
              )
            )
            close(port)
          )
          deleteFile(tmpFile)
        )
      )
      t
    )
    unless( ret
      return(nil)
    )
    found
  )
)

procedure( ASTB_InjectMenu()
  prog((menuList stack parentId item ret label cmd subId firstPopup enKey)
    when( ASTB_MenuAlreadyInjected()
      ASTB_LogInfo("Menu already injected, skipping.")
      return(t)
    )
    menuList = ASTB_GetMenuStructure()
    when( null(menuList)
      ASTB_LogError("Menu structure is empty")
      return(nil)
    )
    firstPopup = car(menuList)
    unless( ASTB_MenuIsPopup(firstPopup)
      ASTB_LogError("Invalid top-level menu structure")
      return(nil)
    )
    parentId = ASTB_MenuFindSafe(nil -1)
    label = ASTB_MenuGetPopupLabel(firstPopup)
    enKey = cadr(firstPopup)
    ret = errset(parentId = axlUIMenuInsert(parentId 'popup label) t)
    unless( ret
      ASTB_LogError("Failed to create top-level popup")
      return(nil)
    )
    parentId = car(ret)
    ASTB_MENU_IDS[enKey] = parentId
    stack = list(parentId)
    foreach( item cdr(menuList)
      when( listp(item)
        cond(
          ( ASTB_MenuIsPopup(item)
            label = ASTB_MenuGetPopupLabel(item)
            enKey = cadr(item)
            ret = errset(subId = axlUIMenuInsert(parentId 'popup label) t)
            when( ret
              stack = cons(car(ret) stack)
              parentId = car(ret)
              ASTB_MENU_IDS[enKey] = parentId
            )
          )
          ( ASTB_MenuIsEnd(item)
            stack = cdr(stack)
            parentId = car(stack)
          )
          ( ASTB_MenuIsSeparator(item)
            errset(axlUIMenuInsert(parentId 'separator) t)
          )
          ( ASTB_MenuIsCommand(item)
            label = ASTB_MenuGetCommandLabel(item)
            cmd = ASTB_MenuGetCommand(item)
            ret = errset(subId = axlUIMenuInsert(parentId label cmd) t)
            when( ret
              ASTB_MENU_IDS[car(item)] = car(ret)
            )
          )
        )
      )
    )
    ASTB_MENU_INJECTED = t
    ASTB_LogInfo("Menu injected successfully.")
    return(t)
  )
)

procedure( ASTB_RegisterAllMenuCommands()
  prog((menuList item cmd count)
    menuList = ASTB_GetMenuStructure()
    count = 0
    foreach( item menuList
      when( ASTB_MenuIsCommand(item)
        cmd = ASTB_MenuGetCommand(item)
        ASTB_RegisterCommand(cmd cmd ?cmdType 'interactive)
        count = count + 1
      )
    )
    ;; Register system language commands
    ASTB_RegisterCommand("ASTB_SetLanguageEnglish" "ASTB_SetLanguageEnglish" ?cmdType 'interactive)
    ASTB_RegisterCommand("ASTB_SetLanguageChinese" "ASTB_SetLanguageChinese" ?cmdType 'interactive)
    count = count + 2
    ASTB_LogInfo(sprintf(nil "Registered %d menu commands" count))
  )
)

;;=========================================================================
;; Apply current language to already injected menu (runtime switch)
;; Strategy: delete old top-level popup -> reset state -> re-inject.
;;=========================================================================
procedure( ASTB_ApplyMenuLanguage()
  prog((topId deleted langStr)
    topId = ASTB_MENU_IDS["allegro_skill_toolbox"]
    when( topId
      deleted = errset(axlUIMenuDelete(topId) t)
      unless( deleted
        ASTB_LogWarn("axlUIMenuDelete unavailable; language change requires restart")
        return(nil)
      )
    )
    ;; Reset injection state so ASTB_InjectMenu can run again
    ASTB_MENU_INJECTED = nil
    ASTB_MENU_IDS = makeTable('ASTB_MENU_IDS)
    ;; Re-inject with new language labels
    unless( ASTB_InjectMenu()
      ASTB_LogError("Failed to re-inject menu after language switch")
      return(nil)
    )
    langStr = if(ASTB_IsLanguageEnglish() then "English" else "Chinese")
    printf("[ASTB] Menu language switched to %s.\n" langStr)
    return(t)
  )
)

;;=========================================================================
;; Set menu language and update displayed labels
;;=========================================================================
procedure( ASTB_SetLanguage(lang)
  prog((oldLang cfgVal isEn ok msg)
    oldLang = ASTB_GetConfig("language" "zh-CN")
    ASTB_LogInfo(sprintf(nil "SetLanguage: oldLang=%L lang=%L" oldLang lang))
    when( or(null(oldLang) eq(oldLang 'unbound))
      oldLang = "zh-CN"
    )
    when( oldLang == lang
      axlUIConfirm(sprintf(nil "Language is already %s" lang))
      return(t)
    )
    ;; Save preference first (so it persists across restarts)
    ASTB_SetConfig("language" lang)
    ASTB_SaveConfig()
    cfgVal = ASTB_GetConfig("language" "zh-CN")
    ASTB_LogInfo(sprintf(nil "SetLanguage: saved value=%L" cfgVal))
    ;; Try runtime switch
    ok = ASTB_ApplyMenuLanguage()
    isEn = ASTB_IsLanguageEnglish()
    if( ok
    then
      msg = if(isEn then "Switched to English." else "Switched to Chinese.")
    else
      msg = if(isEn
             then "Language set to English.\nRestart Allegro to apply menu changes."
             else "Language set to Chinese.\nRestart Allegro to apply menu changes.")
    )
    axlUIConfirm(msg)
    return(t)
  )
)

procedure( ASTB_SetLanguageEnglish()
  ASTB_SetLanguage("en")
)

procedure( ASTB_SetLanguageChinese()
  ASTB_SetLanguage("zh-CN")
)

;;=========================================================================
;; Load Chinese labels at startup
;;=========================================================================
when(and(boundp('ASTB_GLOBAL) ASTB_GLOBAL->CorePath)
  unless(errset(ASTB_LoadChineseLabels() t)
    printf("[ASTB] ERROR: ASTB_LoadChineseLabels failed\n")
  )
)

printf("[ASTB] ZH_GET sample: Package -> '%s'\n" ASTB_ZH_GET("Package"))
printf("[ASTB] ZH_GET sample: Layout  -> '%s'\n" ASTB_ZH_GET("Layout"))

printf("[ASTB] core/menu.il loaded.\n")
