; ============================================================
; File: via_samevia.il
; Purpose: Same Via Processing
; Encoding: ASCII
; Source: 00-完整项目参考/AXL-SKILL/same_via.il
; ============================================================

axlCmdRegister("same_via" 'same_via)

defun(same_via ()

	file = axlTempFile()
	port = outfile(file)

	lst_AllViaDbid = axlGetAllViaList()
	lst_AllViaName = list()
	foreach(i lst_AllViaDbid
		lst_AllViaName = cons(i->name lst_AllViaName)
	)
	lst_AllViaName = reverse(lst_AllViaName)
	
	int_choice = axlUIMultipleChoice("Choose a via type" lst_AllViaName "Same Via Processing")
	when(int_choice==-1	lfunc())
	
	axlVisibleLayer("Via Class" t)
	axlSetFindFilter(
		?enabled   '("noall" "vias")
		?onButtons '("noall" "vias")
	)
	axlAddSelectAll()
	lst_temp = axlGetSelSet()
	axlClearSelSet()
	
	lst_tgtViaDbid = lst_temp
	foreach(i lst_temp
		unless(i->name == nth(int_choice - 1, lst_AllViaName)
			lst_tgtViaDbid = remove(i, lst_tgtViaDbid)
		)
	)
	axlHighlightObject(lst_tgtViaDbid)
	
	lst_AllViaName = remove(nth(int_choice - 1, lst_AllViaName), lst_AllViaName)
	
	int_choice = axlUIMultipleChoice("Choose target via type" lst_AllViaName "Same Via Processing")
	when(int_choice==-1	lfunc())
	
	axlDBIgnoreFixed()
	
	axlDBControl('dynameFillMode nil)
	
	foreach(i lst_tgtViaDbid
		temp = axlDBCreateVia(nth(int_choice - 1, lst_AllViaName), i->xy, i->net)
		axlHighlightObject(temp)
		fprintf(port, "Via @ %L is replaced to %s", i->xy, nth(int_choice - 1, lst_AllViaName))
		axlDeleteObject(i)
	)
	if(axlUIYesNo("Update shape now?") then
	axlShapeDynamicUpdate(nil nil)
	)
	
	close(port)
	axlUIWExpose(axlUIViewFileCreate(file "Same Via Processing" t))

)

;END

; Toolbox wrapper
procedure( ASTB_Via_SameVia()
  same_via()
)

ASTB_RegisterCommand("ASTB_Via_SameVia" "ASTB_Via_SameVia" "via" "Replace same type vias")
