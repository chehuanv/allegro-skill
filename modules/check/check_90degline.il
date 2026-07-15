;			Auto Check
;		------------------------------------------------
;
;
;File name: lgs_auto_check.il
;Revision:1.1
;Date:9-14,2002
;Writen by:
;LiGuangsheng/24445
;Tel: 26540574
;E_mail: liguangsheng@huawei.com
;CAD Group Fundamental Dept R&D Engineer
;HUAWEI TECHNOLOGIES CO., LTD.


axlCmdRegister( "loop90 Check" `_lgs_auto_check )

lgs_debug = nil


lgs_filter = "*"
lgs_degree_length = 0.00
declare( lgs_crosstalk_data[12])
lgs_temp = '(nil 5 3000 nil 6 4000 nil 8 8000 nil 10 12000)
for(i 0 11
	lgs_crosstalk_data[i] = nth( i lgs_temp)
);end for


;***************************************************************************************************************************
;***************************************************************************************************************************

;				MAIN FUNCTION
;			==============================

;***************************************************************************************************************************
;		_lgs_auto_check()
;***************************************************************************************************************************

(defun _lgs_auto_check ()

	lgs_number = 0		;?????????????????
	lgs_list_mode = "net"
	_lgs_make_acform()
	lgs_command = 0
	lgs_zoom = 0
	lgs_temp_xy = nil
	lgs_temp_bbox = nil
	lgs_netlist = _lgs_get_match_netname( lgs_filter)
	lgs_errlist = nil
	lgs_errlistxy = nil
	_lgs_first_setup_form()


);end defun _lgs_auto_check
;***************************************************************************************************************************
;		_lgs_first_setup_form()
;***************************************************************************************************************************
(defun _lgs_first_setup_form ()

	axlFormSetField( lgs_ac_form "lgs_net_err" "net")
	axlFormSetField( lgs_ac_form "Ref_Des_Filter" lgs_filter)
	_lgs_refresh_list()
	axlFormDisplay( lgs_ac_form)

);end defun _lgs_first_setup_form
;***************************************************************************************************************************
;		_lgs_get_match_netname()
;***************************************************************************************************************************
(defun _lgs_get_match_netname ( lgs_filter)

	lgs_list = nil
	foreach( lgs_netname axlGetNets()
		if( axlMatchAny( lgs_filter car( lgs_netname))
			lgs_list = cons( lgs_netname lgs_list)
		);end if
	);end foreach
	lgs_list

);end defun _lgs_get_match_netname
;***************************************************************************************************************************
;		_lgs_make_acform()
;***************************************************************************************************************************
(defun _lgs_make_acform ()

	lgs_ac_form = axlFormCreate( (gensym) "lgs_auto_check.form" '(e outside "Quit") '_lgs_acform_callback)

);end defun _lgs_make_acform
;***************************************************************************************************************************
;		_lgs_refresh_list()
;***************************************************************************************************************************
(defun _lgs_refresh_list ()

	axlFormSetField( lgs_ac_form "lgs_list" nil)
	if( lgs_list_mode == "net" then
		foreach( lgs_net lgs_netlist
			axlFormSetField( lgs_ac_form "lgs_list" car( lgs_net))
		);end foreach
	else
		foreach( lgs_err lgs_errlist
			axlFormSetField( lgs_ac_form "lgs_list" car( lgs_err))
		);end foreach
	);end if

);end defun _lgs_refresh_list
;***************************************************************************************************************************
;		_lgs_acform_callback()
;***************************************************************************************************************************
(defun _lgs_acform_callback ( lgs_form lgs_field)

	case( lgs_field
		("lgs_net_err"
			if( lgs_list_mode == "net" then
				lgs_list_mode = "err"
				axlFormSetField( lgs_ac_form "lgs_net_err" "err")
			else
				lgs_list_mode = "net"
				axlFormSetField( lgs_ac_form "lgs_net_err" "net")
			);end if
			_lgs_refresh_list()
		);end "lgs_net_err"
		("Ref_Des_Filter"
			lgs_filter = axlFormGetField( lgs_ac_form "Ref_Des_Filter")
			lgs_netlist = _lgs_get_match_netname( lgs_filter)
			lgs_errlist = nil
			lgs_errlistxy = nil
			_lgs_refresh_list()
		);end "Ref_Des_Filter"
		("lgs_list"
			lgs_select = axlFormGetField( lgs_ac_form "lgs_list")
			if( lgs_list_mode == "net" then
				lgs_temp = assoc( lgs_select lgs_netlist)
				lgs_temp_xy = cadr( lgs_temp)
				lgs_temp_bbox = caddr( lgs_temp)
				if( lgs_temp_xy then
					axlClearSelSet()
					axlSingleSelectPoint( lgs_temp_xy)
					if( lgs_zoom then
						axlZoomToSelSet()
					);end if
				);end if
			else
				lgs_temp = assoc( lgs_select lgs_errlist)
				lgs_temp_xy = cadr( lgs_temp)
				lgs_temp_bbox = caddr( lgs_temp)
				if( lgs_temp_xy then
					axlClearSelSet()
					axlSingleSelectPoint( lgs_temp_xy)
					if( lgs_zoom then
						axlZoomToSelSet()
					);end if
				);end if
			);end if
		);end "lgs_list"
		("lgs_check"
			lgs_command = 1
			lgs_number = 0
			lgs_errlist = nil
			lgs_errlistxy = nil
			_lgs_check_all()
			lgs_list_mode = "err"
			axlFormSetField( lgs_ac_form "lgs_net_err" "err")
			_lgs_refresh_list()
		);end "lgs_check"
		("lgs_zoom"
			if( lgs_zoom then
				lgs_zoom = 0
				axlFormSetField( lgs_ac_form "lgs_zoom" "")
			else
				lgs_zoom = 1
				axlFormSetField( lgs_ac_form "lgs_zoom" "Zoom")
			);end if
		);end "lgs_zoom"
		("lgs_next"
			lgs_command = 2
			lgs_number = lgs_number + 1
			_lgs_check_all()
		);end "lgs_next"
		("lgs_prev"
			lgs_command = 3
			lgs_number = lgs_number - 1
			_lgs_check_all()
		);end "lgs_prev"
		("lgs_report"
			lgs_command = 4
			_lgs_check_all()
		);end "lgs_report"
		("lgs_help"
			lgs_command = 5
			_lgs_check_all()
		);end "lgs_help"
		("Done"
			axlFormClose( lgs_ac_form)
			lgs_ac_form = nil
		);end "Done"
	);end case

);end defun _lgs_acform_callback
;***************************************************************************************************************************
;		_lgs_check_all()
;***************************************************************************************************************************
(defun _lgs_check_all ()

	case( lgs_command
		(1
			_lgs_check_90deg()
		);end 1
		(2
			_lgs_next_err()
		);end 2
		(3
			_lgs_prev_err()
		);end 3
		(4
			_lgs_report()
		);end 4
		(5
			_lgs_help()
		);end 5
	);end case

);end defun _lgs_check_all
;***************************************************************************************************************************
;		_lgs_check_90deg()
;***************************************************************************************************************************
(defun _lgs_check_90deg ()

	lgs_errlist = nil
	lgs_errlistxy = nil
	foreach( lgs_net lgs_netlist
		lgs_netname = car( lgs_net)
		lgs_netobj = cadr( lgs_net)
		lgs_netbbox = caddr( lgs_net)
		foreach( lgs_line axlDBGetShapes( lgs_netobj)
			lgs_lineobj = car( lgs_line)
			lgs_linebbox = cadr( lgs_line)
			if( lgs_linebbox then
				lgs_x1 = caar( lgs_linebbox)
				lgs_y1 = cadar( lgs_linebbox)
				lgs_x2 = caadr( lgs_linebbox)
				lgs_y2 = cadadr( lgs_linebbox)
				if( abs( lgs_x1 - lgs_x2) < lgs_degree_length && abs( lgs_y1 - lgs_y2) < lgs_degree_length then
					lgs_errlist = cons( list( lgs_netname lgs_lineobj lgs_linebbox) lgs_errlist)
					lgs_errlistxy = cons( lgs_linebbox lgs_errlistxy)
				);end if
			);end if
		);end foreach
	);end foreach
	lgs_number = 0

);end defun _lgs_check_90deg
;***************************************************************************************************************************
;		_lgs_next_err()
;***************************************************************************************************************************
(defun _lgs_next_err ()

	if( lgs_errlist then
		if( lgs_number >= length( lgs_errlist) then
			lgs_number = 0
		);end if
		if( lgs_number < 0 then
			lgs_number = length( lgs_errlist) - 1
		);end if
		lgs_err = nth( lgs_number lgs_errlist)
		lgs_errname = car( lgs_err)
		lgs_errobj = cadr( lgs_err)
		lgs_errbbox = caddr( lgs_err)
		axlClearSelSet()
		axlSingleSelectObject( lgs_errobj)
		if( lgs_zoom then
			axlZoomToSelSet()
		);end if
		axlFormSetField( lgs_ac_form "lgs_list" lgs_errname)
	);end if

);end defun _lgs_next_err
;***************************************************************************************************************************
;		_lgs_prev_err()
;***************************************************************************************************************************
(defun _lgs_prev_err ()

	if( lgs_errlist then
		if( lgs_number >= length( lgs_errlist) then
			lgs_number = 0
		);end if
		if( lgs_number < 0 then
			lgs_number = length( lgs_errlist) - 1
		);end if
		lgs_err = nth( lgs_number lgs_errlist)
		lgs_errname = car( lgs_err)
		lgs_errobj = cadr( lgs_err)
		lgs_errbbox = caddr( lgs_err)
		axlClearSelSet()
		axlSingleSelectObject( lgs_errobj)
		if( lgs_zoom then
			axlZoomToSelSet()
		);end if
		axlFormSetField( lgs_ac_form "lgs_list" lgs_errname)
	);end if

);end defun _lgs_prev_err
;***************************************************************************************************************************
;		_lgs_report()
;***************************************************************************************************************************
(defun _lgs_report ()

	if( lgs_errlist then
		lgs_reportfile = "lgs_auto_check.rpt"
		lgs_reportport = outfile( lgs_reportfile)
		fprintf( lgs_reportport "Auto Check Report\n")
		fprintf( lgs_reportport "=================\n\n")
		foreach( lgs_err lgs_errlist
			lgs_errname = car( lgs_err)
			lgs_errobj = cadr( lgs_err)
			lgs_errbbox = caddr( lgs_err)
			fprintf( lgs_reportport "Net: %s\n" lgs_errname)
			fprintf( lgs_reportport "Object: %s\n" lgs_errobj)
			fprintf( lgs_reportport "BBox: %s\n\n" lgs_errbbox)
		);end foreach
		close( lgs_reportport)
		axlUIConfirm( "Report saved to lgs_auto_check.rpt")
	);end if

);end defun _lgs_report
;***************************************************************************************************************************
;		_lgs_help()
;***************************************************************************************************************************
(defun _lgs_help ()

	axlUIConfirm( "Auto Check Help:\n\n1. Enter filter and click Check to find 90 degree lines\n2. Use Next/Prev to navigate errors\n3. Zoom toggles auto-zoom\n4. Report saves error list to file")

);end defun _lgs_help
