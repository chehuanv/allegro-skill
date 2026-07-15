;; ============================================================
;; File: fanyskill_place_inside.il
;; Purpose: Place components inside area
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "placeinside" `PlaceInside)

defun( PlaceInside ()
	(let ((selSet area)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("COMPONENTS") ?onButtons '("COMPONENTS"))
		selSet = axlSelect()
		when(selSet
			area = axlEnterBox()
			foreach(comp selSet
				axlTransformObject(comp ?move area)
			)
		)
	)
)
