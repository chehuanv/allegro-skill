;; ============================================================
;; File: pkg_createdevfile.il
;; Purpose: Create device file
;; Encoding: ASCII
;; ============================================================

/*
#################################################################################                                                                    
#                  	Command: FYED                                     			#
#                  	Skill File: FanySkill_Export_Device.il                   	#
#                  	How To Load: Command> (load("FanySkill_Export_Device.il"))	#
#               	How To Execute: Command> FYED  			   					#
#              	 	Write by: deargds            								#
#################################################################################
*/
axlCmdRegister( "FYED" 'FanySkill_Export_Device ?cmdType "general")

defun( FanySkill_Export_Device ()
prog(()
        dra_list =  rexMatchList(".dra$" getDirFiles(".\\"))
        foreach( p dra_list
                when( axlOpenDesign(?design p ?mode "wf") 
                        when( axlDesignType(t) == "PACKAGE"
                                ScriptFileName = axlTempFile()
                                Script_File = axlDMOpenFile("TEMP", ScriptFileName, "w") 
                                        
                                fprintf(Script_File "scriptmode +i\n\n")
                                fprintf(Script_File "setwindow pcb \n")
                                fprintf(Script_File "create device \n")
                                fprintf(Script_File "setwindow form.crdevice \n")
                                fprintf(Script_File "FORM crdevice done \n")
                                fprintf(Script_File "setwindow pcb \n")
                                
                                axlDMClose(Script_File) 
                                axlShell(strcat("replay " ScriptFileName))
                                axlCloseDesign()
                                
                                deleteFile(ScriptFileName)
                        );when
                );when
        );foreach
        axlUIConfirm("Device File Create Finish!")
)


;; ============================================================
;; Toolbox wrapper
;; ============================================================

procedure( ASTB_Pkg_CreateDevFile()
  FanySkill_Export_Device()
)

ASTB_RegisterCommand("ASTB_Pkg_CreateDevFile" "ASTB_Pkg_CreateDevFile" ?cmdType 'interactive)

printf("[ASTB] pkg_createdevfile.il loaded.\n")