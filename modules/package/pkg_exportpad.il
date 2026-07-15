;; ============================================================
;; File: pkg_exportpad.il
;; Purpose: Export padstack to library
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "exportpad" `ExportPad)

defun( ExportPad ()
	(let ((padName)
		padName = car(axlSelectByName("PADSTACK" ""))
		axlMsgPut(sprintf(nil "Export padstack %s" padName))
	)
)
