;; ============================================================
;; File: autosilkutils_public.il
;; Purpose: AutoSilk Utils (truncated for GitHub upload)
;; Encoding: UTF-8 (may show ? in 16.6)
;; Source: 07-文本与丝印/autosilkUtils_public.il
;; ============================================================

;; NOTE: This is a large file (119KB, 5237 lines).
;; The full version is available in the original zip package.
;; This stub provides the command registration and main entry point.

axlCmdRegister("silkutils" 'ASU_start ?cmdType "interactive")

defun( ASU_start (@optional txtSpacing, shpSpacing, lineSpacing, spacingUnits)
 let((preset, version, release, releaseType, releaseNumber, analyse, unitsList, units, designProperties, artworks, formFile
      p, x, y, grpLen, tabLen, y1, form, defaultFilm, nonCuFilms, filmPairs, vias, viaResist)
  preset = boundp('ASU_thisDesign) && ASU_thisDesign == axlCurrentDesign()
  defvar(ASU_version, 8.23)
  defvar(ASU_versionWarning)
  version = axlVersion('version)
  release = axlVersion('release)
  releaseType = lowerCase(substring(release, 1, 1)), releaseNumber = readNumberString(substring(release, 2))
  cond(
    (version == 15.2 && (releaseType != "s" || releaseNumber < 14)
      ASU_versionWarning = "WARNING: Will not fully work on releases prior to s014"
    )
    (version >= 15.2, ASU_versionWarning = nil)
    (t, ASU_versionWarning = "WARNING: Not been tested for releases prior to 15.2")
  )
  unitsList = AFn_getDesignUnits()
  units = car(unitsList)
  defvar(ASU_designUnits, units)
  defvar(ASU_precision, cadr(unitsList))
  defvar(ASU_spacing)
  ASU_spacing = if(member(units, '("mils", "inches")), axlMKSConvert(10, "mils"), axlMKSConvert(0.25 "mm"))
  unless(txtSpacing, txtSpacing = ASU_spacing)
  if(preset then
    analyse = axlUIYesNo("Re-Analyse Design?")
   else
    analyse = t
    defvar(ASU_thisDesign, axlCurrentDesign())
    defvar(ASU_checktext, t)
    defvar(ASU_checktextloc, t)
    defvar(ASU_quickChk)
    defvar(ASU_checklines, t)
    defvar(ASU_checkshapes, t)
    defvar(ASU_checkPins, t)
    defvar(ASU_solderedpadsChk)
    defvar(ASU_checkVias, t)
    defvar(ASU_checksmShps, t)
    defvar(ASU_shapescopyCheck, t)
    defvar(ASU_shapesCopyIgnoreFixed, t)
    defvar(ASU_checktop, t)
    defvar(ASU_checkbottom, t)
    defvar(ASU_TOPfilm)
    defvar(ASU_BOTTOMfilm)
    defvar(ASU_AUTOSILK)
    defvar(ASU_SILKSCREEN)
    defvar(ASU_ASSEMBLY)
    defvar(ASU_autosilkChkClasses, '("ASU_AUTOSILK", ("MANUFACTURING", t)))
    defvar(ASU_silkChkClasses
      '("ASU_SILKSCREEN", ("BOARD GEOMETRY", t), ("PACKAGE GEOMETRY", t), ("COMP VALUE", t), ("DEV TYPE", t), ("REF DES", t), ("TOLERANCE", t), ("USER PART", t))
    )
    defvar(ASU_assyChkClasses
      '("ASU_ASSEMBLY", ("BOARD GEOMETRY", t), ("PACKAGE GEOMETRY", t), ("COMP VALUE", nil), ("DEV TYPE", nil), ("REF DES", t), ("TOLERANCE", nil), ("USER PART", nil))
    )
    defvar(ASU_subclasses, '("silkscreenlayer", "autosilklayer", "assemblylayer"))
    defvar(ASU_chkSubclass)
    defvar(ASU_soldermaskClasses, '("BOARD GEOMETRY", "PACKAGE GEOMETRY", "PIN", "VIA CLASS"))
    defvar(ASU_userClass)
    defvar(ASU_userSubclass)
    defvar(ASU_drcMsgs)
    defvar(ASU_vectorFontData, AFn_vectorFontData())
  )
  when(analyse
    defvar(ASU_allChkClasses, '("MANUFACTURING")); Required to enable check box if user copies shapes to this Autosilk layer
    ASU_allChkClasses = ASU_analyseDesign(ASU_allChkClasses, ASU_autosilkChkClasses, ASU_silkChkClasses, ASU_assyChkClasses)
  )
  unless(preset, defvar(ASU_tickedClasses, ASU_allChkClasses))
  when(stringp(txtSpacing), txtSpacing = atof(txtSpacing))
  when(stringp(shpSpacing), shpSpacing = atof(shpSpacing))
  when(stringp(lineSpacing), lineSpacing = atof(lineSpacing))
  when(spacingUnits; Required when parsing values from a menu as they are strings.
    txtSpacing = axlMKSConvert(txtSpacing, spacingUnits, units)
    shpSpacing = axlMKSConvert(shpSpacing, spacingUnits, units)
    lineSpacing = axlMKSConvert(lineSpacing, spacingUnits, units)
  )
  defvar(ASU_minSpacing, axlMKSConvert(0.125 "mm"))
  defvar(ASU_defaultTxtSpacing, txtSpacing)
  defvar(ASU_defaultShpSpacing, shpSpacing || txtSpacing)
  defvar(ASU_defaultLineSpacing, lineSpacing || txtSpacing)
  axlDBRefreshId(nil)
  designProperties = axlDBGetDesign() ->prop
  txtSpacing = designProperties ->ASU_TXTSPACING || txtSpacing
  shpSpacing = designProperties ->ASU_SHPSPACING || shpSpacing
  lineSpacing = designProperties ->ASU_LINESPACING || lineSpacing
  when(stringp(txtSpacing), txtSpacing = atof(txtSpacing))
  when(stringp(shpSpacing), shpSpacing = atof(shpSpacing))
  when(stringp(lineSpacing), lineSpacing = atof(lineSpacing))
  unless(shpSpacing, shpSpacing = txtSpacing)
  unless(lineSpacing, lineSpacing = shpSpacing)
  artworks = axlGetParam("artwork") ->groupMembers

  grpLen = 3 + max(length(ASU_allChkClasses), length(ASU_subclasses), 2) * 2
  tabLen = max(40, 29 + grpLen)
  x = 1, y = 0
  p = AFn_formOpenFile()
  formFile = get_filename(p)
  AFn_formHeader(p, 43, sprintf(nil, "Silkscreen Check v%2.2f", ASU_version))
  AFn_formPopupDefine(p, "TOPFILMPOP", '("topfilm"))
  AFn_formPopupDefine(p, "BOTTOMFILMPOP", '("bottomfilm"))
  AFn_formPopupDefine(p, "UCLASS")
  AFn_formPopupDefine(p, "USUBCLASS")
  AFn_formMessage(p, "chkProgress", ?level 0, ?msgString "Checking %s %s...")
  AFn_formMessage(p, "drcsFound", ?level 0, ?msgString "%d DRCs found")
  AFn_formMessage(p, "drcsCreated", ?level 0, ?msgString "%d shapes copied. %d DRCs created")
  AFn_formMessage(p, "shpsCopied", ?level 0, ?msgString "%d shapes copied. No checks performed")
  when(ASU_versionWarning, AFn_formText(p, ASU_versionWarning, x + 1, y ?label "versionwarning"), y = y + 1)
  y = y + 1
  AFn_formThumbnail(p, "taitlogo", x + 37, 0, 5, 3)
  AFn_formTabSetDispatch(p, x, y, 42, tabLen)
  AFn_formTab(p, "Setup"), y = 1
  AFn_formButton(p, "silkparam", "Setup Cadence Silkscreen", x + 2, y, 30, 3)
  AFn_formButton(p, "silkparamHelp", "?", x + 33, y, 3, 3), y = y + 2
  AFn_formGroup(p, "Spacing Constraints", x, y, 39, 14)
  y = y + 2, AFn_formChecklistItem(p, "text", x + 2, y, "Text Spacing")
  AFn_formButton(p, "txtspcdefault", "D", x + 16, y, 3, 3)
  AFn_formRealFillin(p, "txtspc", 6, 6, x + 19, y, ?value txtSpacing, ?decimalPlaces ASU_precision, ?minVal 0, ?units units)
  AFn_formButton(p, "txtspcHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "quickchk", x + 6, y, "Faster Text Check")
  AFn_formButton(p, "quickchkHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "shapes", x + 2, y, "Shape Spacing")
  AFn_formButton(p, "shpspcdefault", "D", x + 16, y, 3, 3)
  AFn_formRealFillin(p, "shpspc", 6, 6, x + 19, y, ?value shpSpacing, ?decimalPlaces ASU_precision, ?minVal 0, ?units units)
  AFn_formButton(p, "shpspcHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "lines", x + 2, y, "Line Spacing")
  AFn_formButton(p, "linespcdefault", "D", x + 16, y, 3, 3)
  AFn_formRealFillin(p, "linespc", 6, 6, x + 19, y, ?value lineSpacing, ?decimalPlaces ASU_precision, ?minVal 0, ?units units)
  AFn_formButton(p, "linespcHelp", "?", x + 33, y, 3, 3)
  
  y = y + 3, AFn_formChecklistItem(p, "textloc", x + 2, y, "Reference Designator Locations")
  AFn_formButton(p, "textlocHelp", "?", x + 33, y, 3, 3)
  
  y = y + 3, AFn_formGroup(p, "Solder Mask Objects to be Checked", x, y, 39, 11)
  y = y + 2, AFn_formChecklistItem(p, "pins", x + 2, y, "Check to Solder Mask Pads on Pads")
  AFn_formButton(p, "pinsHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "solderedpads", x + 6, y, "Check to Soldered Pads Only")
  AFn_formButton(p, "solderedpadsHelp", "?", x + 33, y, 3, 3)

  y = y + 2, AFn_formChecklistItem(p, "vias", x + 2, y, "Check to Solder Mask Pads on Vias")
  AFn_formButton(p, "viasHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "smShps", x + 2, y, "Check to Solder Mask Shapes")
  AFn_formButton(p, "smShpsHelp", "?", x + 33, y, 3, 3)

  y = y + 3, AFn_formGroup(p, "AutoSilk Layers Shapes Copying", x, y, 39, if(isCallable('axlDBIgnoreFixed), 9, 7))
  y = y + 2, AFn_formChecklistItem(p, "shapescopyCheck", x + 2, y, "Check Spacings on objects selected above")
  when(isCallable('axlDBIgnoreFixed)
    y = y + 2, AFn_formChecklistItem(p, "shapescopyignorefixed", x + 6, y, "Ignore fixed status")
    AFn_formButton(p, "ignorefixedHelp", "?", x + 33, y, 3, 3)
  )
  y = y + 2, AFn_formButton(p, "copy", "Copy Geometry Layer Shapes to AutoSilk", x + 2, y, 30, 3)
  AFn_formEndTab(p)
  
  AFn_formTab(p, "Check"), y = 0
  when(axlGetParam("artwork") && sort(copy(artworks), nil) != '("BOTTOM" "TOP")
    AFn_formGroup(p, "Use Films", x, y, 38, 9)
    y = y + 2, AFn_formChecklistItem(p, "usefilms", x + 1, y, "Use films to determine checked layers" ?radioLabel "chktype")
    y = y + 2, AFn_formText(p, "Top:", x + 1, y), AFn_formPop(p, "TOPfilm", "TOPFILMPOP", x + 9, y, 20)
    y = y + 2, AFn_formText(p, "Bottom:", x + 1, y), AFn_formPop(p, "BOTTOMfilm", "BOTTOMFILMPOP", x + 9, y, 20)
    y++
  )
  y = y + 2, AFn_formGroup(p, "Use Silk Layers", x, y, 38, grpLen + 5); 4
  y = y + 2
  AFn_formChecklistItem(p, "usesilk", x + 1, y, "Auto suggested layer selection" ?radioLabel "chktype")
  y = y + 1, y1 = y
  AFn_formGroup(p, "Classes", x + 1, y1, 21, 2 + length(ASU_allChkClasses) * 2)
  foreach(chkClass, ASU_allChkClasses, y1 = y1 + 2, AFn_formChecklistItem(p, chkClass, x + 2, y1, axlPPrint(chkClass)))
  AFn_formGroup(p, "Subclasses", x + 23, y, 14, 2 + length(ASU_subclasses) * 2)
  foreach(subclass, ASU_subclasses
    y = y + 2, AFn_formChecklistItem(p, subclass, x + 24, y, axlPPrint(substring(subclass, 1, strlen(subclass) - 5)) ?radioLabel "chklayer")
  )

  y = max(y1, y) + 2
  AFn_formText(p, "Check sides:", x + 2, y)
  AFn_formChecklistItem(p, "checktop", x + 14, y, "Top")
  AFn_formChecklistItem(p, "checkbottom", x + 22, y, "Bottom")
  
  y = y + 3, AFn_formGroup(p, "User selection", x, y, 38, 9)
  y = y + 2, AFn_formChecklistItem(p, "useother", x + 1, y, "Select user layer to check" ?radioLabel "chktype")
  y = y + 2, AFn_formText(p, "Class:", x + 1, y), AFn_formPop(p, "userclass", "UCLASS", x + 9, y, 20)
  y = y + 2, AFn_formText(p, "Subclass:", x + 1, y)
  AFn_formPop(p, "usersubclass", "USUBCLASS", x + 9, y, 20 ?options "ownerdrawn")
  y = y + 4, AFn_formButton(p, "checkWindow", "Check in Window", x + 3, y, 15, 3)
  AFn_formButton(p, "checkAll", "Check All", x + 22, y, 15, 3)
  AFn_formEndTab(p)
  AFn_formEndTabSet(p)
  y = tabLen + 3
  AFn_formButton(p, "viewLog", "View Log", x + 2, y, 9, 3)
  AFn_formButton(p, "cancel", "Close", x + 15, y, 9, 3)
  AFn_formButton(p, "asuhelp", "Help", x + 28, y, 9, 3)
  AFn_formEnd(p)
  axlDMClose(p)
  
  defvar(ASU_startForm, axlFormCreate('form, formFile, '(E INNER), 'ASU_formAction, nil))
  axlGRPDrwInit(form, "taitlogo", 'tait_logoThumbnail)
  when(ASU_versionWarning && substring(ASU_versionWarning, 1, 7) == "WARNING"
    axlFormColorize(form, "versionwarning", 'text, 'red)
  )
  ASU_setSpacingBackgroundColours(form)
  axlFormSetField(form, "quickchk", ASU_quickChk)
  axlFormSetField(form, "solderedpads", ASU_solderedpadsChk)
  axlFormSetField(form, "shapescopyCheck", ASU_shapescopyCheck)
  unless(ASU_shapescopyCheck, axlFormSetFieldEditable(form, "shapescopyignorefixed", 0))
  if(ASU_checkPins then axlFormSetField(form, "pins", t) else axlFormSetFieldEditable(form, "solderedpads", 0))
  vias = findTypeObjects("VIAS")
  foreach(side, '("TOP" "BOTTOM")
    while(!viaResist && vias
      when(axlDBGetPad(car(vias), strcat("PIN/SOLDERMASK_", side), "REGULAR"), viaResist = t)
      vias = cdr(vias)
    )
  )
  if(viaResist then when(ASU_checkVias, axlFormSetField(form, "vias", t)) else axlFormSetFieldEditable(form, "vias", 0))
  if(ASU_getGeometryObjects("SOLDERMASK", "SHAPES")
   then when(ASU_checksmShps, axlFormSetField(form, "smShps", t))
   else axlFormSetFieldEditable(form, "smShps", 0)
  )
  axlFormSetField(form, "shapescopyignorefixed", ASU_shapesCopyIgnoreFixed)

  foreach(side, '("TOP" "BOTTOM")
    defaultFilm = car(setof(f, artworks, setof(l, axlGetParam(strcat("artwork:", f)) ->groupMembers, index(l, strcat("_", side)) && index(l, "SILK"))))
    nonCuFilms = setof(f, artworks, !index(buildString(axlGetParam(strcat("artwork:", f)) ->groupMembers), "ETCH/"))
    filmPairs = cons('("", ""), mapcar(lambda((filmName), list(filmName, filmName)), nonCuFilms))
    axlFormBuildPopup(form, strcat(side, "FILMPOP"), filmPairs)
    defaultFilm = eval(stringToSymbol(strcat("ASU_", side, "film"))) || defaultFilm
    when(defaultFilm
      axlFormSetField(form, strcat(side, "film"), defaultFilm)
      unless(boundp('ASU_useFilms) && !ASU_useFilms, axlFormSetField(form, "usefilms", t), defvar(ASU_useFilms, t))
    )
  )
  axlFormBuildPopup(form, "UCLASS", '("MANUFACTURING" "BOARD GEOMETRY" "PACKAGE GEOMETRY"))
  cond(
    (ASU_AUTOSILK != '(nil, nil, nil) && (!ASU_chkSubclass || ASU_chkSubclass == "autosilklayer")
      axlFormSetField(form, "autosilklayer", t)
      ASU_chkSubclass = "autosilklayer"
      ASU_setChkClasses(form, ASU_autosilkChkClasses)
    )
    (ASU_SILKSCREEN != '(nil, nil, nil) && (!ASU_chkSubclass || ASU_chkSubclass == "silkscreenlayer")
      axlFormSetField(form, "silkscreenlayer", t)
      ASU_chkSubclass = "silkscreenlayer"
      ASU_setChkClasses(form, ASU_silkChkClasses)
    )
    (ASU_ASSEMBLY != '(nil, nil, nil) && (!ASU_chkSubclass || ASU_chkSubclass == "assemblylayer")
      axlFormSetField(form, "assemblylayer", t)
      ASU_chkSubclass = "assemblylayer"
      ASU_setChkClasses(form, ASU_assyChkClasses)
    )
  )
  axlFormSetField(form, "checktop", ASU_checktop)
  axlFormSetField(form, "checkbottom", ASU_checkbottom)

  cond(
    (and(boundp('ASU_useFilms), ASU_useFilms), axlFormSetField(form, "usefilms", t))
    (and(boundp('ASU_useSilk), ASU_useSilk), axlFormSetField(form, "usesilk", t))
    (and(boundp('ASU_useOther), ASU_useOther), axlFormSetField(form, "useother", t))
    (ASU_chkSubclass, defvar(ASU_useSilk, t), axlFormSetField(form, "usesilk", t))
    (t, defvar(ASU_useOther, t), axlFormSetField(form, "useother", t))
  )

  unless(axlFormGetField(form, "usefilms"
    foreach(field, '("TOPfilm" "BOTTOMfilm"), axlFormSetFieldEditable(form, field, 0))
  )
  unless(axlFormGetField(form, "usesilk"
    foreach(field, append(ASU_allChkClasses, ASU_subclasses), axlFormSetFieldEditable(form, field, 0))
    foreach(field, '("checktop" "checkbottom"), axlFormSetFieldEditable(form, field, 0))
  )
  when(ASU_userClass
    axlFormSetField(form, "userclass", ASU_userClass)
    axlSubclassFormPopup(form, "usersubclass", ASU_userClass, nil)
  )
  when(ASU_userSubclass, axlFormSetField(form, "usersubclass", ASU_userSubclass))
  unless(axlFormGetField(form, "useother"
    foreach(field, '("userclass" "usersubclass"), axlFormSetFieldEditable(form, field, 0))
  )
  axlFormSetFieldEditable(form, "viewLog", 0)
  axlFormDisplay(form)
  deleteFile(formFile)
))

;; [Full implementation continues with helper functions...]
;; See original source for complete code (5237 lines total)

printf("[ASTB] autosilkutils_public.il loaded (stub).\n")
