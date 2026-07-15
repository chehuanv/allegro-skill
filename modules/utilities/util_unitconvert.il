;; ============================================================
;; File: util_unitconvert.il
;; Purpose: Unit conversion
;; Encoding: ASCII
;; ============================================================


/*
#########################################################################################                                                                    
#                  	Command: FYCA                                     					#
#                  	Skill File: FanySkill_Calculator.il                   				#
#                  	How To Load: Command> (load("FanySkill_Calculator.il"))				#
#               	How To Execute: Command> FYCA  			   							#
#              	 	Write by: Wanghh Download Addr:https://github.com/whh5118/GTOpen 	#
#########################################################################################
*/


;------??????--------------
;------???
procedure( ASTB_Util_UnitConvert()
prog((form)
	form = gt_calculator_createform()
	gt_calculator_int_var(form)
	gt_calculator_update_form(form)
)
)


;------??form
procedure( gt_calculator_createform()
let((file port form)
	;file = strcat(gtopen_global->InstallPath "/FanySkill/SkillCode/form/gtopen_Logo.form")
	;file = strcat(getSkillPath() "/FanySkill/SkillCode/FanySkill_Calculator.form")
	;file = "C:/Cadence/SPB_16.6/share/local/pcb/skill/FanySkill/SkillCode/FanySkill_Calculator.form"
	when(boundp('calculator_form)
		when(axlIsFormType(eval('calculator_form))
			axlFormClose(eval('calculator_form))
		)
	)
	form = axlFormCreate('calculator_form "Calculator.form" nil 'gt_calculator_CB t)
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
		tt = member(n0 form->var->mils_input)
		when(tt
			axlFormSetField(form "mils_input" car(tt))
		)
	)
	
	foreach(n0 form->var->?
		tt = member(n0 form->var->mm_input)
		when(tt
			axlFormSetField(form "mm_input" car(tt))
		)
	)
	
	axlFormDisplay(form)
)
)


;------form callback
procedure( gt_calculator_CB(form)
let((field value)
	field = form->curField
	value = form->curValue
	case(field
		("mils_input"
			form->var->mils_input = cons(value remove(value form->var->mils_input))
			when(value && value != ""
				axlFormSetField(form "mm_input" atof(value) * 0.0254)
			)
		)
		("mm_input"
			form->var->mm_input = cons(value remove(value form->var->mm_input))
			when(value && value != ""
				axlFormSetField(form "mils_input" atof(value) / 0.0254)
			)
		)
		("Done"
			axlFormClose(form)
		)
		("Cancel"
			axlFormClose(form)
		)
	)
)
)


; Toolbox wrapper
ASTB_RegisterCommand("ASTB_Util_UnitConvert" "ASTB_Util_UnitConvert" "utilities" "Unit conversion calculator")
