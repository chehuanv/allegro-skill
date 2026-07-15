;; ============================================================
;; File: fanyskill_choosegrid.il
;; Purpose: Choose Grid
;; Encoding: UTF-8 (may show ? in 16.6)
;; Source: 03-网格与显示控制/FanySkill_ChooseGrid.il
;; ============================================================

/*

#############################################################################                                                                    

#                  	Command: FYCW                                     		#

#                  	Skill File: FanySkill_ChooseGrid.il                   	#

#                  	How To Load: Command> (load("FanySkill_ChooseGrid.il"))	#

#               	How To Execute: Command> FYCW  			   				#

#              	 	Write by: Richard L            							#

#############################################################################

*/



axlCmdRegister("FYCW" `FanySkill_ChooseGrid)



GridsZoomList='(200 100 50 39.37 31.5 25 10 5 1 0.1) 

GridsZoomName=nil



/*---------------------------------

CreateFormForGrids()

---------------------------------*/

defun(CreateFormForGrids (units)

	MainFormFile=axlTempFile()

	p=outfile(MainFormFile "w")



	GridsZoomName=nil

	for(i 0 length(GridsZoomList)-1

		sprintf(filename,"%g",cnv_factor*nth(i GridsZoomList))

		GridsZoomName=cons(filename,GridsZoomName)

	)



	totalWidth=0

	for(i 0 length(GridsZoomName)-1

		totalWidth=totalWidth+strlen(nth(i GridsZoomName))+3

	)

	

	sprintf(title,"Grids Tool - Units : %s",units)

	f_FormBegin(p totalWidth,0,title,"TOOLWINDOW")

	xpos=1

	for(i 0 length(GridsZoomList)-1

		f_CheckList(p nth(i GridsZoomName) xpos 0 nth(i GridsZoomName) "gg")

		xpos=xpos+strlen(nth(i GridsZoomName))+3

	)

	f_FormEnd(p)



	close(p)

	MainFormFile

);func



defun(FanySkill_ChooseGrid ()

; creates conversion factor based on current units

	if(axlDBGetDesign()->units=="mils" then

		cnv_factor=1.0

		units="mils"

	else

		cnv_factor=0.0254

		units="mm"

	)

	MainFormFile=CreateFormForGrids(units)

	form=axlFormCreate((gensym) MainFormFile '(e r) 'GridFormCallback nil)

	axlFormDisplay(form)

);func



/*---------------------------------

GridFormCallback()

---------------------------------*/

defun( GridFormCallback (form)

	case(form->curField

		("gg"

			for(i 0 length(GridsZoomList)-1

				when(form->curValue==nth(i GridsZoomName)

					axlSetParam("grid" list(

						list("x" nth(i GridsZoomList))

						list("y" nth(i GridsZoomList))

					))

					axlVisibleUpdate(t)

				)

			)

		)

	)

);func



; Toolbox wrapper
procedure( ASTB_Util_ChooseGrid()
  FanySkill_ChooseGrid()
)

ASTB_RegisterCommand("ASTB_Util_ChooseGrid" "ASTB_Util_ChooseGrid" "utilities" "Choose grid size")
