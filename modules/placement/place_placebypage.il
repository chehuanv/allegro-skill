;; ============================================================
;; File: place_placebypage.il
;; Purpose: Place components by page number
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "placebypage" `PlaceByPage)

defun( PlaceByPage ()
	(let ((selSet pageNum)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("COMPONENTS") ?onButtons '("COMPONENTS"))
		selSet = axlSelect()
		when(selSet
			pageNum = axlEnterString("Enter page number: ")
			foreach(comp selSet
				when(equal(comp->pageNum pageNum)
					axlTransformObject(comp ?move list(0 0))
				)
			)
		)
	)
)
