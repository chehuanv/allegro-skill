;; ============================================================
;; File: lgs_super_net_finder_v1_0.il
;; Purpose: Super Net Finder
;; Encoding: UTF-8 (may show ? in 16.6)
;; Source: 12-实用工具/lgs_super_net_finder_V1_0.il
;; ============================================================

;			Super Net Finder

;		------------------------------------------------

;

;

;File name: lgs_super_net_finder_V1_0.il

;Revision:1.0

;Date:June 8,2002

;Writen by:

;LiGuangsheng/24445

;Tel: 6540574

;E_mail: liguangsheng@huawei.com

;CAD Group Fundamental Dept R&D Engineer

;HUAWEI TECHNOLOGIES CO., LTD.





;===============REGIST COMMAND LINE=========================================================================================

;===========================================================================================================================



axlCmdRegister( "super_net_finder" `_lgs_super_net_find )



;***************************************************************************************************************************

;		_lgs_super_net_find()

;***************************************************************************************************************************

(defun _lgs_super_net_find ()

lgs_sn_length_min_sw = nil

lgs_sn_length_max_sw = nil

lgs_sn_pmanhattan_min_sw = nil

lgs_sn_pmanhattan_max_sw = nil

lgs_sn_via_min_sw = nil

lgs_sn_via_max_sw = nil



lgs_sn_length_min = 200

lgs_sn_length_max = 2000

lgs_sn_pmanhattan_min = 11

lgs_sn_pmanhattan_max = 1000

lgs_sn_via_min = 4

lgs_sn_via_max = 20



_lgs_build_super_net_find_form()

lgs_sn_mainlist = _lgs_sn_read_data()

lgs_sn_filter_list = lgs_sn_mainlist

_lgs_sn_setform()



);end (defun _lgs_super_net_find ()





;***************************************************************************************************************************

;		_lgs_match_net()

;***************************************************************************************************************************

(defun _lgs_match_net (net_name)



	lgs_sn_filter_list = nil

	foreach(item lgs_sn_mainlist

		when((net_name == "" || rexMatchp(strcat(".*" net_name ".*") car(item)))

			lgs_sn_filter_list = cons(item lgs_sn_filter_list)

		)

	)

	_lgs_sn_setform()



);end (defun _lgs_match_net ()





;***************************************************************************************************************************

;		_lgs_sn_read_data()

;***************************************************************************************************************************

(defun _lgs_sn_read_data ()

	prog((net_list net_name net_length net_manhattan net_via_count net_item)

		net_list = nil

		foreach(net axlDBGetDesign()->nets

			net_name = net->name

			net_length = axlDBNetLength(net)

			net_manhattan = axlDBNetManhattan(net)

			net_via_count = length(axlDBNetVias(net))

			net_item = list(net_name net_length net_manhattan net_via_count)

			net_list = cons(net_item net_list)

		)

		return(net_list)

	)

);end (defun _lgs_sn_read_data ()





;***************************************************************************************************************************

;		_lgs_sn_setform()

;***************************************************************************************************************************

(defun _lgs_sn_setform ()

	prog((form_list item)

		form_list = nil

		foreach(item lgs_sn_filter_list

			form_list = cons(car(item) form_list)

		)

		axlFormSetField(lgs_sn_form "net_list" reverse(form_list))

	)

);end (defun _lgs_sn_setform ()





;***************************************************************************************************************************

;		_lgs_build_super_net_find_form()

;***************************************************************************************************************************

(defun _lgs_build_super_net_find_form ()

	prog((form_file)

		form_file = axlTempFile()

		p = outfile(form_file "w")

		
		fprintf(p "FILE_TYPE=FORM_DEFN VERSION=2\n")

		fprintf(p "FORM\n")

		fprintf(p "FIXED\n")

		fprintf(p "PORT 40 30\n")

		fprintf(p "HEADER \"Super Net Finder\"\n")

		fprintf(p "TILE\n")

		
		fprintf(p "TEXT \"Net Name Filter:\"\n")

		fprintf(p "TLOC 1 1\n")

		fprintf(p "ENDTEXT\n")

		fprintf(p "FIELD net_name\n")

		fprintf(p "FLOC 15 1\n")

		fprintf(p "STRFILLIN 20 1\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD match\n")

		fprintf(p "FLOC 36 1\n")

		fprintf(p "MENUBUTTON \"Match\"\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD length_min_sw\n")

		fprintf(p "FLOC 1 4\n")

		fprintf(p "CHECKLIST \"Length Min\"\n")

		fprintf(p "ENDFIELD\n")

		fprintf(p "FIELD length_min\n")

		fprintf(p "FLOC 15 4\n")

		fprintf(p "REALFILLIN 8 8\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD length_max_sw\n")

		fprintf(p "FLOC 1 6\n")

		fprintf(p "CHECKLIST \"Length Max\"\n")

		fprintf(p "ENDFIELD\n")

		fprintf(p "FIELD length_max\n")

		fprintf(p "FLOC 15 6\n")

		fprintf(p "REALFILLIN 8 8\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD pmanhattan_min_sw\n")

		fprintf(p "FLOC 1 8\n")

		fprintf(p "CHECKLIST \"Manhattan Min\"\n")

		fprintf(p "ENDFIELD\n")

		fprintf(p "FIELD pmanhattan_min\n")

		fprintf(p "FLOC 15 8\n")

		fprintf(p "REALFILLIN 8 8\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD pmanhattan_max_sw\n")

		fprintf(p "FLOC 1 10\n")

		fprintf(p "CHECKLIST \"Manhattan Max\"\n")

		fprintf(p "ENDFIELD\n")

		fprintf(p "FIELD pmanhattan_max\n")

		fprintf(p "FLOC 15 10\n")

		fprintf(p "REALFILLIN 8 8\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD via_min_sw\n")

		fprintf(p "FLOC 1 12\n")

		fprintf(p "CHECKLIST \"Via Min\"\n")

		fprintf(p "ENDFIELD\n")

		fprintf(p "FIELD via_min\n")

		fprintf(p "FLOC 15 12\n")

		fprintf(p "REALFILLIN 8 8\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD via_max_sw\n")

		fprintf(p "FLOC 1 14\n")

		fprintf(p "CHECKLIST \"Via Max\"\n")

		fprintf(p "ENDFIELD\n")

		fprintf(p "FIELD via_max\n")

		fprintf(p "FLOC 15 14\n")

		fprintf(p "REALFILLIN 8 8\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD net_list\n")

		fprintf(p "FLOC 1 16\n")

		fprintf(p "LIST \"Net List\" 38 10\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD Done\n")

		fprintf(p "FLOC 10 28\n")

		fprintf(p "MENUBUTTON \"Done\"\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "FIELD Cancel\n")

		fprintf(p "FLOC 25 28\n")

		fprintf(p "MENUBUTTON \"Cancel\"\n")

		fprintf(p "ENDFIELD\n")

		
		fprintf(p "ENDTILE\n")

		fprintf(p "ENDFORM\n")

		close(p)

		
		lgs_sn_form = axlFormCreate((gensym) form_file '(e r) '_lgs_sn_form_callback nil)

		axlFormDisplay(lgs_sn_form)

	)

);end (defun _lgs_build_super_net_find_form ()





;***************************************************************************************************************************

;		_lgs_sn_form_callback()

;***************************************************************************************************************************

(defun _lgs_sn_form_callback (form)

	case(form->curField

		("match"

			_lgs_match_net(form->net_name)

		)

		("Done"

			axlFormClose(form)

			_lgs_sn_highlight_nets()

		)

		("Cancel"

			axlFormClose(form)

		)

	)

);end (defun _lgs_sn_form_callback ()





;***************************************************************************************************************************

;		_lgs_sn_highlight_nets()

;***************************************************************************************************************************

(defun _lgs_sn_highlight_nets ()

	prog((selected_net)

		selected_net = axlFormGetField(lgs_sn_form "net_list")

		when(selected_net

			axlClearSelSet()

			axlSetFindFilter(?enabled list("noall" "nets") ?onButtons list("noall" "nets"))

			axlSingleSelectName("net" selected_net)

			axlHighlightObject(axlGetSelSet())

		)

	)

);end (defun _lgs_sn_highlight_nets ()



; Toolbox wrapper
procedure( ASTB_Util_SuperNetFinder()
  _lgs_super_net_find()
)

ASTB_RegisterCommand("ASTB_Util_SuperNetFinder" "ASTB_Util_SuperNetFinder" "utilities" "Super Net Finder")
