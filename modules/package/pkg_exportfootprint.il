;; ============================================================
;; File: pkg_exportfootprint.il
;; Purpose: Export footprint to library
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "exportfootprint" `ExportFootprint)

defun( ExportFootprint ()
	(let ((fpName libPath)
		fpName = car(axlDBGetDesign()->name)
		libPath = axlTempFile()
		axlRunBatchDBProgram("allegro" list("-s" "placeholder"))
		axlMsgPut(sprintf(nil "Export footprint %s" fpName))
	)
)
