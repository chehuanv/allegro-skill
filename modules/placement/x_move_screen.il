;; ============================================================
;; File: x_move_screen.il
;; Purpose: Move screen objects
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "movescreen" `MoveScreen)

defun( MoveScreen ()
	(let ((selSet)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("SHAPES" "LINES") ?onButtons '("SHAPES" "LINES"))
		selSet = axlSelect()
		when(selSet
			foreach(obj selSet
				axlTransformObject(obj ?move list(100 100))
			)
		)
	)
)
