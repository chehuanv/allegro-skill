;; ============================================================
;; File: place_gathercomps.il
;; Purpose: Gather components to a point
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "gathercomps" `GatherComps)

defun( GatherComps ()
	(let ((selSet targetPt)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("COMPONENTS") ?onButtons '("COMPONENTS"))
		selSet = axlSelect()
		when(selSet
			targetPt = axlEnterPoint()
			foreach(comp selSet
				axlTransformObject(comp ?move targetPt)
			)
		)
	)
)
