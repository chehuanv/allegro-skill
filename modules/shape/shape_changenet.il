;; ============================================================
;; File: shape_changenet.il
;; Purpose: Change shape net
;; Encoding: ASCII
;; ============================================================

axlCmdRegister("changeshape" 'changeshape)
;saxlShellaxlShell("funckey F9 changeshape")

defun( changeshape ()

	axlSetFindFilter(?enabled list("noall" "shapes") ?onButtons list("noall" "shapes")) 
			
	while(axlSelect(?prompt "Please Select shapes to change nets or done to exit...")
		shapes = nil
		shapes = axlGetSelSet()
		println(shapes)				
		shape_netname = car(shapes)->net->name

		axlSetFindFilter(?enabled list("noall" "nets") ?onButtons list("noall" "nets")) 		
		if(axlSelect(?prompt "Please select net of cline/shape/pin/via\n") then	
			all = axlGetSelSet()
			net_name = car(all)->net->name
			println(net_name)		
			axlChangeNet(car(shapes) net_name)			
			axlVisibleUpdate(t)
		)
		
		axlSetFindFilter(?enabled list("noall" "shapes") ?onButtons list("noall" "shapes")) 
	)
	
	printf("done")
)

procedure( ASTB_Shape_ChangeNet()
  changeshape()
)

ASTB_RegisterCommand("ASTB_Shape_ChangeNet" "ASTB_Shape_ChangeNet" ?cmdType 'interactive)

printf("[ASTB] shape_changenet.il loaded.\n")