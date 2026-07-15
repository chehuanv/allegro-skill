;; ============================================================
;; File: text_importlogo.il
;; Purpose: Import logo
;; Encoding: ASCII
;; ============================================================

/*
#########################################################################################                                                                    
#                  	Command: FYLG                                     					#
#                  	Skill File: FanySkill_Logo.il                   					#
#                  	How To Load: Command> (load("FanySkill_Logo.il"))					#
#               	How To Execute: Command> FYLG  			   							#
#              	 	Write by: Wanghh Download Addr:https://github.com/whh5118/GTOpen 	#
#########################################################################################
*/



procedure( ASTB_Text_ImportLogo()
let((form)
	
	axlShell("noappmode")
	form = gtopen_Logo_Createform()
	gtopen_Logo_Int_Var(form)
	gtopen_Logo_Update_form(form)
)
)




procedure( gtopen_Logo_Createform()
let((file form)
	;file = strcat(FanySkill_global->InstallPath "/FanySkill/SkillCode/gtopen_Logo.form")
	;printf( "file----------------(%s)",  file)
	;printf( "file1----------------(%s)",  FanySkill_global->InstallPath)
	;file = "C:/Cadence/SPB_16.6/share/local/pcb/skill/FanySkill/SkillCode/gtopen_Logo.form"
	;file = strcat(getSkillPath() "/FanySkill/SkillCode/form/gtopen_Logo.form")
	when('gtopen_Logoform && boundp('gtopen_Logoform)
		when(axlIsFormType(eval('gtopen_Logoform))
			axlFormClose(eval('gtopen_Logoform))
		)
	)
	
	
	form = axlFormCreate('gtopen_Logoform "Logo.form" nil 'gtopen_Logo_CB t)
	
	form
)
)


procedure( gtopen_Logo_Int_Var(form)
let((_getFontList)
	form->pop = ncons(nil)
	form->pop->layerclass = list("BOARD GEOMETRY" "PACKAGE GEOMETRY" "MANUFACTURING" "ETCH" "DRAWING FORMAT")
	form->pop->layer = list("SILKSCREEN_TOP" "SILKSCREEN_BOTTOM" "OUTLINE" "ASSEMBLY_TOP" "ASSEMBLY_BOTTOM")
	form->pop->font = list("Standard" "Fixed" "Gothic" "Gothic_English" "Gothic_German" "Gothic_Italian" "Greek" "Italic" "Italic_English" "Italic_German" "Italic_Italian" "Roman" "Roman_English" "Roman_German" "Roman_Italian")
)
)


procedure( gtopen_Logo_Update_form(form)
let((tt)
	
	foreach(n0 form->pop->?
		tt = member(n0 form->pop->layerclass)
		when(tt
			axlFormSetField(form "layerclass" car(tt))
		)
	)
	
	foreach(n0 form->pop->?
		tt = member(n0 form->pop->layer)
		when(tt
			axlFormSetField(form "layer" car(tt))
		)
	)
	
	foreach(n0 form->pop->?
		tt = member(n0 form->pop->font)
		when(tt
			axlFormSetField(form "font" car(tt))
		)
	)
	
	axlFormSetField(form "width" "0.15")
	axlFormSetField(form "height" "0.15")
	axlFormSetField(form "line_space" "0.15")
	axlFormSetField(form "char_space" "0.15")
	axlFormSetField(form "x" "0")
	axlFormSetField(form "y" "0")
	axlFormSetField(form "rotation" "0")
	axlFormSetField(form "mirror" "No")
	
	axlFormDisplay(form)
)
)


procedure( gtopen_Logo_CB(form)
let((field value)
	field = form->curField
	value = form->curValue
	case(field
		("layerclass"
			form->pop->layerclass = cons(value remove(value form->pop->layerclass))
		)
		("layer"
			form->pop->layer = cons(value remove(value form->pop->layer))
		)
		("font"
			form->pop->font = cons(value remove(value form->pop->font))
		)
		("Done"
			axlFormClose(form)
			gtopen_Logo_CreateLogo(form)
		)
		("Cancel"
			axlFormClose(form)
		)
	)
)
)


procedure( gtopen_Logo_CreateLogo(form)
let((layerclass layer font width height line_space char_space x y rotation mirror text file_path)
	layerclass = car(form->pop->layerclass)
	layer = car(form->pop->layer)
	font = car(form->pop->font)
	width = atof(form->width)
	height = atof(form->height)
	line_space = atof(form->line_space)
	char_space = atof(form->char_space)
	x = atof(form->x)
	y = atof(form->y)
	rotation = atof(form->rotation)
	mirror = form->mirror == "Yes"
	
	file_path = axlUIGetUserData()->filePath
	when(file_path
		file = infile(file_path)
		when(file
			line_num = 0
			while(gets(line file)
				line_num = line_num + 1
				text = strcat(text line)
				if(line_num > 1 then
					text = strcat(text "\n")
				)
			)
			close(file)
		)
	)
	
	when(text
		axlDBCreateText(
			strcat(layerclass "/" layer)
			text
			list(x y)
			font
			width
			height
			rotation
			mirror
		)
	)
)
)

; Toolbox wrapper
ASTB_RegisterCommand("ASTB_Text_ImportLogo" "ASTB_Text_ImportLogo" "text" "Import logo from file")
