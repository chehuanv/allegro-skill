;; ============================================================
;; File: pkg_createovalflash.il
;; Purpose: Create oval thermal flash
;; Encoding: ASCII
;; ============================================================


/*
#########################################################################################                                                                    
#           Command: FYCOT                                     							#
#           Skill File: FanySkill_Create_Oblong_Thermal.il                   			#
#           How To Load: Command> (load("FanySkill_Create_Oblong_Thermal.il"))			#
#           LOGO File: SPB_16.6\share\local\pcb\icons\cot.bmp                   		#
#           How To Execute: Command> FYCOT  			   								#
#			Modify by:  longxf 2020-1-1 Download Addr:https://pcbbar.com/ 				#
#			Original author : Richard L.    liulichiu@yahoo.com							#
#########################################################################################
*/


axlCmdRegister( "FYCOT" `CreateOblongThermal)

/*---------------------------------
CreateOblThForm()
---------------------------------*/

defun( CreateOblThForm ()
	MainFormFile=axlTempFile()
	p = outfile(MainFormFile "w")
	f_FormBegin(p 35,20,"Create Oblong Thermal - RichardL." "TOOLWINDOW")
	f_Bitmap(p "cot" "cot" 0 0 14 14)
	f_Text(p "Outer diameter(A):",15,0)  f_EditFloat(p "A",29,0,5,5,4)
	f_Text(p "Inner diameter(B):",15,3)  f_EditFloat(p "B",29,3,5,5,4)
	f_Text(p "Oblong length(D):", 15,6)  f_EditFloat(p "D",29,6,5,5,4)
	f_Text(p "Circle spoke(C):",  15,9)  f_EditFloat(p "C",29,9,5,5,4)
	f_Text(p "Oblong spoke(E):",  15,12) f_EditFloat(p "E",29,12,5,5,4)
	f_Group(p "Direction",2,14,32,4)
	f_CheckList(p "H", 4,16,"Horizontal","di")
	f_CheckList(p "V",18,16,"Vertical","di")
	f_Button(p "OK",2,19,15,1.5)
	f_Button(p "Cancel",18,19,15,1.5)
	f_FormEnd(p)
	close(p)
	MainFormFile
)

/*---------------------------------
CreateOblongThermal()
---------------------------------*/

defun( CreateOblongThermal ()
	prog((A B C D E H V MainFormFile)
		MainFormFile=CreateOblThForm()
		form=axlFormCreate( (gensym) MainFormFile '("E" "e") 'CreateOblongThermal_Callback t)
		axlFormDisplay(form)
		A=1.0 B=0.5 C=0.2 D=0.5 E=0.2 H=1 V=0
		axlFormSetField( form "A" A)
		axlFormSetField( form "B" B)
		axlFormSetField( form "C" C)
		axlFormSetField( form "D" D)
		axlFormSetField( form "E" E)
		axlFormSetField( form "H" H)
		axlFormSetField( form "V" V)
		axlFormBuildPopupMenu( form "A" '("0.5" "0.8" "1.0" "1.5" "2.0" "2.5"))
		axlFormBuildPopupMenu( form "B" '("0.3" "0.4" "0.5" "0.8" "1.0" "1.5"))
		axlFormBuildPopupMenu( form "C" '("0.1" "0.15" "0.2" "0.25" "0.3"))
		axlFormBuildPopupMenu( form "D" '("0.5" "0.8" "1.0" "1.5" "2.0" "2.5"))
		axlFormBuildPopupMenu( form "E" '("0.1" "0.15" "0.2" "0.25" "0.3"))
		axlFormTest(form)
		deleteFile(MainFormFile)
	)
)

/*---------------------------------
CreateOblongThermal_Callback()
---------------------------------*/

defun( CreateOblongThermal_Callback (form)
	case( form->curField
		("A" A=atof(form->curValue))
		("B" B=atof(form->curValue))
		("C" C=atof(form->curValue))
		("D" D=atof(form->curValue))
		("E" E=atof(form->curValue))
		("H" H=atof(form->curValue))
		("V" V=atof(form->curValue))
		("OK" 
			axlFormClose( form )
			CreateOblongThermal_DB( A B C D E H V)
		)
		("Cancel" axlFormClose( form ))
	)
	case( form->curEvent
		("Done" axlFormClose( form ))
	)
)

/*---------------------------------
CreateOblongThermal_DB()
---------------------------------*/

defun( CreateOblongThermal_DB (A B C D E H V)
	prog((FlashName TempList)
		FlashName=sprintf(nil "OblThA%3.2fB%3.2fC%3.2fD%3.2fE%3.2fH%1dV%1d" A B C D E H V)
		TempList=list(
			list("NAME" FlashName)
			list("START_NAME" "")
			list("END_NAME" "")
			list("FLASH_ID" 0)
			list("RECORD_TAG" 0)
			list("SWAP_ID" "")
			list("RECORD_NUMBER" 0)
			list("PARENT" "")
			list("CLASS" "FLASH")
			list("SUBCLASS" "")
			list("ORIGIN_X" 0.0)
			list("ORIGIN_Y" 0.0)
			list("NAMESPACE" "GEOMETRY")
			list("GEOMETRY" list(
				list("SHAPE" "OBLONGX")
				list("WIDTH" A)
				list("HEIGHT" A)
				list("DIAMETER" 0.0)
				list("CIRCLE_SPOKE" C)
				list("OBLONG_SPOKE" E)
				list("OBLONG_LENGTH" D)
				list("DIRECTION" H)
				list("VERTICAL" V)
				list("INNER_DIAMETER" B)
				list("START_ANGLE" 0.0)
				list("END_ANGLE" 0.0)
				list("THICKNESS" 0.0)
				list("NUM_SPOKES" 0)
				list("SPOKE_WIDTH" 0.0)
				list("SPOKE_ANGLE" 0.0)
				list("SPOKE_OFFSET" 0.0)
				list("SPOKE_LIST" nil)
				list("USER_PARAMS" nil)
			))
		)
		axlDBCreatePropDictEntry(TempList)
		axlFlashMake(FlashName)
		axlMsgPut(sprintf(nil "Flash %s created successfully." FlashName))
	)
)
