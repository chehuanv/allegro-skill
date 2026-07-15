;; ============================================================
;; File: route_auto10deg.il
;; Purpose: Auto route at 10 degree angle
;; Encoding: ASCII
;; ============================================================

axlCmdRegister( "auto10deg" `Auto10Deg)

defun( Auto10Deg ()
	(let ((selSet)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("NETS") ?onButtons '("NETS"))
		selSet = axlSelect()
		when(selSet
			foreach(net selSet
				axlRouteAuto(list(net) ?angle 10)
			)
		)
	)
)
