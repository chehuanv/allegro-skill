;; ============================================================
;; File: via_stitching.il
;; Purpose: Via stitching
;; Encoding: ASCII
;; ============================================================

;------??????--------------
;------???
procedure( ASTB_Via_Stitching()
prog((form)
	form = gtopen_AutoVia_createform()
	gtopen_AutoVia_int_var(form)
	gtopen_AutoVia_update_form(form)
)
)


;------??form
procedure( gt_calculator_createform()
let((file port form)
	file = strcat(ASTB_GLOBAL->FormPath "/gtopen_calculator.form")
	when(boundp('calculator_form)
		when(axlIsFormType(eval('calculator_form))
			axlFormClose(eval('calculator_form))
		)
	)
	form = axlFormCreate('calculator_form file nil 'gt_calculator_CB t)
	form
)
)


;------form???
procedure( gt_calculator_int_var(form)
let(()
	form->var = ncons(nil)
	form->var->mils_input = nil
	form->var->mm_input = nil
)
)

;------form??
procedure( gt_calculator_update_form(form)
let((tt)
	
	foreach(n0 form->var->?
		tt = member(n0 form->var)
		axlFormSetField(form symbolToString(car(tt)) cadr(tt))
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)
)
)

;------form????
procedure( gt_calculator_CB(form)
let((tt update)
	update = t
	case(form->curField
		("mils_input"
			if(rexMatchp("[^0-9.]+" form->curValue) then
				axlUIWPrint(form "\312\344\310\353\264\355\316\363")
			else
				tt = evalstring(form->curValue)
				if(tt > 393700787 then
					axlUIWPrint(form "\312\344\310\353\264\355\316\363")
				else
					form->var->mils_input = form->curValue
			  	form->var->mm_input = sprintf(nil "%.3g" axlMKSConvert(tt "MILS" "MM"))
				)
			)
		)
	
    ("mm_input"
	 		if(rexMatchp("[^0-9.]+" form->curValue) then 
				axlUIWPrint(form "\312\344\310\353\264\355\316\363")
			else 
				tt = evalstring(form->curValue)
				if(tt > 10000000 then
					axlUIWPrint(form "\312\344\310\353\264\355\316\363")
				else
					form->var->mm_input = form->curValue
			  	form->var->mils_input = sprintf(nil "%.3g" axlMKSConvert(tt "MM" "MILS"))
				)
			)
		)
		
		("done"
			axlFormClose(form)
			update = nil
		)
	)
	when(update
		gt_calculator_update_form(form)
	)
)
)


;------??????--------------
;------???
procedure( ASTB_Via_Stitching()
prog((form)
	form = gtopen_AutoVia_createform()
	gtopen_AutoVia_int_var(form)
	gtopen_AutoVia_update_form(form)
)
)

;------??form
procedure( gtopen_AutoVia_createform()
let((file port form)
	file = strcat(ASTB_GLOBAL->FormPath "/gtopen_AutoVia.form")
	when(boundp('AutoVia_form)
		when(axlIsFormType(eval('AutoVia_form))
			axlFormClose(eval('AutoVia_form))
		)
	)
	form = axlFormCreate('AutoVia_form file nil 'gtopen_AutoVia_CB t)
	form
)
)

;------form???
procedure( gtopen_AutoVia_int_var(form)
let(()
	form->var = ncons(nil)
	form->var->ViaName = nil
	form->var->NetName = nil
	form->var->Layer1 = nil
	form->var->Layer2 = nil
	form->var->XSize = nil
	form->var->YSize = nil
	form->var->Spacing = nil
	form->var->Angle = nil
	form->var->Offset = nil
	form->var->Edge = nil
	form->var->Shape = nil
	form->var->Lock = nil
	form->var->Delete = nil
	form->var->Select = nil
	form->var->List = nil
)
)

;------form??
procedure( gtopen_AutoVia_update_form(form)
let((tt)
	
	foreach(n0 form->var->?
		tt = member(n0 form->var)
		axlFormSetField(form symbolToString(car(tt)) cadr(tt))
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)
)
)

;------form????
procedure( gtopen_AutoVia_CB(form)
let((tt update)
	update = t
	case(form->curField
		("ViaName"
			form->var->ViaName = form->curValue
		)
		("NetName"
			form->var->NetName = form->curValue
		)
		("Layer1"
			form->var->Layer1 = form->curValue
		)
		("Layer2"
			form->var->Layer2 = form->curValue
		)
		("XSize"
			form->var->XSize = form->curValue
		)
		("YSize"
			form->var->YSize = form->curValue
		)
		("Spacing"
			form->var->Spacing = form->curValue
		)
		("Angle"
			form->var->Angle = form->curValue
		)
		("Offset"
			form->var->Offset = form->curValue
		)
		("Edge"
			form->var->Edge = form->curValue
		)
		("Shape"
			form->var->Shape = form->curValue
		)
		("Lock"
			form->var->Lock = form->curValue
		)
		("Delete"
			form->var->Delete = form->curValue
		)
		("Select"
			form->var->Select = form->curValue
		)
		("List"
			form->var->List = form->curValue
		)
		("done"
			axlFormClose(form)
			update = nil
		)
	)
	when(update
		gtopen_AutoVia_update_form(form)
	)
)
)

;------??????--------------
;------???
procedure( ASTB_Via_Stitching()
prog((form)
	form = gtopen_AutoVia_createform()
	gtopen_AutoVia_int_var(form)
	gtopen_AutoVia_update_form(form)
)
)

;------??form
procedure( gtopen_AutoVia_createform()
let((file port form)
	file = strcat(ASTB_GLOBAL->FormPath "/gtopen_AutoVia.form")
	when(boundp('AutoVia_form)
		when(axlIsFormType(eval('AutoVia_form))
			axlFormClose(eval('AutoVia_form))
		)
	)
	form = axlFormCreate('AutoVia_form file nil 'gtopen_AutoVia_CB t)
	form
)
)

;------form???
procedure( gtopen_AutoVia_int_var(form)
let(()
	form->var = ncons(nil)
	form->var->ViaName = nil
	form->var->NetName = nil
	form->var->Layer1 = nil
	form->var->Layer2 = nil
	form->var->XSize = nil
	form->var->YSize = nil
	form->var->Spacing = nil
	form->var->Angle = nil
	form->var->Offset = nil
	form->var->Edge = nil
	form->var->Shape = nil
	form->var->Lock = nil
	form->var->Delete = nil
	form->var->Select = nil
	form->var->List = nil
)
)

;------form??
procedure( gtopen_AutoVia_update_form(form)
let((tt)
	
	foreach(n0 form->var->?
		tt = member(n0 form->var)
		axlFormSetField(form symbolToString(car(tt)) cadr(tt))
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)
)
)

;------form????
procedure( gtopen_AutoVia_CB(form)
let((tt update)
	update = t
	case(form->curField
		("ViaName"
			form->var->ViaName = form->curValue
		)
		("NetName"
			form->var->NetName = form->curValue
		)
		("Layer1"
			form->var->Layer1 = form->curValue
		)
		("Layer2"
			form->var->Layer2 = form->curValue
		)
		("XSize"
			form->var->XSize = form->curValue
		)
		("YSize"
			form->var->YSize = form->curValue
		)
		("Spacing"
			form->var->Spacing = form->curValue
		)
		("Angle"
			form->var->Angle = form->curValue
		)
		("Offset"
			form->var->Offset = form->curValue
		)
		("Edge"
			form->var->Edge = form->curValue
		)
		("Shape"
			form->var->Shape = form->curValue
		)
		("Lock"
			form->var->Lock = form->curValue
		)
		("Delete"
			form->var->Delete = form->curValue
		)
		("Select"
			form->var->Select = form->curValue
		)
		("List"
			form->var->List = form->curValue
		)
		("done"
			axlFormClose(form)
			update = nil
		)
	)
	when(update
		gtopen_AutoVia_update_form(form)
	)
)
)
