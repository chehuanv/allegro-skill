;; ============================================================
;; File: place_movetogrid.il
;; Purpose: Move components to grid
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "movetogrid" `MoveToGrid)

defun( MoveToGrid ()
	(let ((selSet gridSize)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("COMPONENTS") ?onButtons '("COMPONENTS"))
		selSet = axlSelect()
		when(selSet
			gridSize = axlEnterString("Enter grid size: ")
			foreach(comp selSet
				let ((x y)
					x = round(car(comp->xy) / atof(gridSize)) * atof(gridSize)
					y = round(cadr(comp->xy) / atof(gridSize)) * atof(gridSize)
					axlTransformObject(comp ?move list(x y))
				)
			)
		)
	)
)
