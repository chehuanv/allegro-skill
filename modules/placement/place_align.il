;; ============================================================
;; File: place_align.il
;; Purpose: Align components
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "placealign" `PlaceAlign)

defun( PlaceAlign ()
	(let ((selSet refObj)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("COMPONENTS") ?onButtons '("COMPONENTS"))
		selSet = axlSelect()
		when(selSet
			refObj = car(selSet)
			foreach(comp cdr(selSet)
				axlTransformObject(comp ?move list(car(refObj->xy) cadr(comp->xy)))
			)
		)
	)
)
