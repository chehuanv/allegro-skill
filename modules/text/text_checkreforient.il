;; ============================================================
;; File: text_checkreforient.il
;; Purpose: Check RefDes orientation
;; Encoding: ASCII
;; ============================================================

;              	Check Refdes Direction Reference Designators
;	      	--------------------------------------------

; run load "jkcheck_refdes_direction.il"
;File name: jkcheck_refdes_direction.il
;Revision:1	
;date:08/04/2001 
;Writen by: JIAKE/15924
;tel: 6540492

;
;This routine check the refdes direction . You can only type the command "ch_dir" , 
;and it will hilight the component which refdes is illegal to be placed.

;=====================================================================================


axlCmdRegister( "FY_CRD1" 'jkCheck_Refdes_Direction1)
;axlSetFunckey("sk" "skXXX")

defun( jkCheck_Refdes_Direction1 ()

        axlVisibleDesign(nil)
 	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
	axlVisibleLayer( "PIN/TOP" t )
	axlVisibleLayer( "PIN/BOTTOM" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )

	logfile = axlDMOpenLog("dir_error.log")
	fprintf(logfile "#Check the direction errores of refdes . \n\n")
	fprintf(logfile "REF_DES  COORDIRATION\n")
	
	setq(allsym axlDBGetDesign()->symbols)
	axlDehighlightObject(allsym)
	dir = nil	
	dircnt = 0
;	noref = nil
;	norefcnt = 0
	foreach(symbol allsym 	;n=0 ++n symbol=nthelem(n allsym)
		text= axlDBGetAttachedText(symbol)
		txt = nil
		foreach(find text
			if(find->layer == "REF DES/SILKSCREEN_TOP" || 
			find->layer == "REF DES/SILKSCREEN_BOTTOM" then 									
				txt = find			
			)								
		)
/*		if(txt == nil && symbol->refdes != nil then 
			axlHighlightObject(symbol)
			noref = cons(symbol noref)
			norefcnt = norefcnt + 1
		)
*/		
		if(txt != nil then
			if(symbol->refdes != nil then
				dir = txt->rotation
				if( dir != 0 && dir != 90 && dir != 180 && dir != 270 && 
				    dir != 360 && dir != 450 && dir != 540 && dir != 630 then
					axlHighlightObject(symbol)
					dircnt = dircnt + 1
					fprintf(logfile "%s  %L\n" symbol->refdes txt->xy)
				)
			)
		)
	)
	fprintf(logfile "\n\nTotal direction error: %d\n" dircnt)
	close(logfile)
	axlUIViewFileCreate("dir_error.log" "Refdes Direction Error" nil)
	axlMsgPut("Check complete! %d direction errors found." dircnt)
)

; Toolbox wrapper
procedure( ASTB_Text_CheckRefOrient()
  jkCheck_Refdes_Direction1()
)

ASTB_RegisterCommand("ASTB_Text_CheckRefOrient" "ASTB_Text_CheckRefOrient" "text" "Check RefDes orientation")
