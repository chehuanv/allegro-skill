;; ============================================================
;; File: text_checkoverlap.il
;; Purpose: Check text overlap
;; Encoding: ASCII
;; ============================================================


axlCmdRegister( "ch_text_overlap" `check_text_overlap)

layer = "TOP"
clearance = 3
text_pad = t
text_testpoint = nil
text_text = nil
barcode_overlap = nil
refdes_component = nil
formname = nil
location = makeTable("loc" 0)
num = 0
cnt = 0

(defun check_text_overlap ()
    axlVisibleDesign(nil)
    turn_on_layer( layer)
    formname = "./refdes_over.form"
    biuld_form(formname)
)

(defun biuld_form (formname)
(prog ()
   pform = outfile(formname "w")

   fprintf(pform "FILE_TYPE=FORM_DEFN VERSION=2\n")

   fprintf(pform "FORM\n")

   fprintf(pform "FIXED\n")

   fprintf(pform "PORT 26 10\n")

   fprintf(pform "HEADER \"Checking Text Overlap Form\"\n")

   fprintf(pform "POPUP <Layer_Names>")

   fprintf(pform "\"TOP\" \"TOP\",\"BOTTOM\" \"BOTTOM\".\n")

   fprintf(pform "TILE\n")


   fprintf(pform "TEXT \"Select Checking Layer:\"\n")

   fprintf(pform "TLOC 3 1\n")

   fprintf(pform "ENDTEXT\n")

   fprintf(pform "FIELD check_layer\n")

   fprintf(pform "FLOC 6 3\n")

   fprintf(pform "ENUMSET 11\n")

   fprintf(pform "POP \"Layer_Names\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "TEXT \"Clearance:\"\n")

   fprintf(pform "TLOC 3 6\n")

   fprintf(pform "ENDTEXT\n")

   fprintf(pform "FIELD clearance\n")

   fprintf(pform "FLOC 12 6\n")

   fprintf(pform "REALFILLIN 6 6\n")

   fprintf(pform "REALMIN -50.0\n")

   fprintf(pform "REALMAX 100.0\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "FIELD text_pad\n")

   fprintf(pform "FLOC 6 9\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Text and Pad Overlap\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "FIELD text_testpoint\n")

   fprintf(pform "FLOC 6 12\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Text and Testpoint Overlap\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "FIELD text_text\n")

   fprintf(pform "FLOC 6 15\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Text and Text Overlap\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "FIELD barcode_overlap\n")

   fprintf(pform "FLOC 6 18\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Barcode Overlap\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "FIELD refdes_component\n")

   fprintf(pform "FLOC 6 21\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Refdes and Component Overlap\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "FIELD Done\n")

   fprintf(pform "FLOC 6 24\n")

   fprintf(pform "MENUBUTTON \"Done\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "ENDTILE\n")

   fprintf(pform "ENDFORM\n")

   close(pform)

   form = axlFormCreate( (gensym) formname '(e r) 'form_callback 0)

   axlFormDisplay( form)

)

(defun form_callback (form)
(case form->curField
   ("check_layer"
      layer = form->curValue
   )
   ("clearance"
      clearance = atoi(form->curValue)
   )
   ("text_pad"
      text_pad = form->curValue
   )
   ("text_testpoint"
      text_testpoint = form->curValue
   )
   ("text_text"
      text_text = form->curValue
   )
   ("barcode_overlap"
      barcode_overlap = form->curValue
   )
   ("refdes_component"
      refdes_component = form->curValue
   )
   ("Done"
      axlFormClose( form)
      check_overlap()
   )
)
)

(defun check_overlap ()
   axlClearSelSet()
   axlSetFindFilter( ?enabled list("noall" "text") ?onButtons list("noall" "text"))
   axlSingleSelectName("refdes" "*")
   all_refdes = axlGetSelSet()
   axlDehighlightObject(all_refdes)
   num = 0
   cnt = 0
   foreach(refdes all_refdes
      cnt = cnt + 1
      axlClearSelSet()
      axlSetFindFilter( ?enabled list("noall" "text") ?onButtons list("noall" "text"))
      axlSingleSelectName("refdes" refdes->name)
      refdes_dbid = axlGetSelSet()
      refdes_xy = refdes_dbid->xy
      refdes_layer = refdes_dbid->layer
      refdes_text = refdes_dbid->text
      refdes_rotation = refdes_dbid->rotation
      refdes_width = refdes_dbid->width
      refdes_height = refdes_dbid->height
      
      if(text_pad then
         check_text_pad_overlap(refdes_xy refdes_layer refdes_text refdes_rotation refdes_width refdes_height)
      )
      if(text_testpoint then
         check_text_testpoint_overlap(refdes_xy refdes_layer refdes_text refdes_rotation refdes_width refdes_height)
      )
      if(text_text then
         check_text_text_overlap(refdes_xy refdes_layer refdes_text refdes_rotation refdes_width refdes_height)
      )
      if(barcode_overlap then
         check_barcode_overlap(refdes_xy refdes_layer refdes_text refdes_rotation refdes_width refdes_height)
      )
      if(refdes_component then
         check_refdes_component_overlap(refdes_xy refdes_layer refdes_text refdes_rotation refdes_width refdes_height)
      )
   )
   axlMsgPut("Check complete! %d refdes checked." cnt)
)

(defun check_text_pad_overlap (xy layer text rotation width height)
   axlClearSelSet()
   axlSetFindFilter( ?enabled list("noall" "pins") ?onButtons list("noall" "pins"))
   axlAddSelectAll()
   all_pins = axlGetSelSet()
   foreach(pin all_pins
      pin_xy = pin->xy
      pin_layer = pin->layer
      if(layer == pin_layer then
         distance = axlDistance(xy pin_xy)
         if(distance < clearance then
            axlHighlightObject(pin)
            num = num + 1
         )
      )
   )
)

(defun check_text_testpoint_overlap (xy layer text rotation width height)
   axlClearSelSet()
   axlSetFindFilter( ?enabled list("noall" "testpoints") ?onButtons list("noall" "testpoints"))
   axlAddSelectAll()
   all_testpoints = axlGetSelSet()
   foreach(testpoint all_testpoints
      testpoint_xy = testpoint->xy
      testpoint_layer = testpoint->layer
      if(layer == testpoint_layer then
         distance = axlDistance(xy testpoint_xy)
         if(distance < clearance then
            axlHighlightObject(testpoint)
            num = num + 1
         )
      )
   )
)

(defun check_text_text_overlap (xy layer text rotation width height)
   axlClearSelSet()
   axlSetFindFilter( ?enabled list("noall" "text") ?onButtons list("noall" "text"))
   axlAddSelectAll()
   all_text = axlGetSelSet()
   foreach(text_obj all_text
      text_obj_xy = text_obj->xy
      text_obj_layer = text_obj->layer
      if(layer == text_obj_layer && text_obj->name != text then
         distance = axlDistance(xy text_obj_xy)
         if(distance < clearance then
            axlHighlightObject(text_obj)
            num = num + 1
         )
      )
   )
)

(defun check_barcode_overlap (xy layer text rotation width height)
   axlClearSelSet()
   axlSetFindFilter( ?enabled list("noall" "shapes") ?onButtons list("noall" "shapes"))
   axlAddSelectAll()
   all_shapes = axlGetSelSet()
   foreach(shape all_shapes
      shape_layer = shape->layer
      if(layer == shape_layer then
         shape_bbox = shape->bbox
         text_bbox = list(car(xy) - width/2 cadr(xy) - height/2 car(xy) + width/2 cadr(xy) + height/2)
         if(axlBBoxOverlap(shape_bbox text_bbox) then
            axlHighlightObject(shape)
            num = num + 1
         )
      )
   )
)

(defun check_refdes_component_overlap (xy layer text rotation width height)
   axlClearSelSet()
   axlSetFindFilter( ?enabled list("noall" "symbols") ?onButtons list("noall" "symbols"))
   axlAddSelectAll()
   all_symbols = axlGetSelSet()
   foreach(symbol all_symbols
      symbol_bbox = symbol->bbox
      text_bbox = list(car(xy) - width/2 cadr(xy) - height/2 car(xy) + width/2 cadr(xy) + height/2)
      if(axlBBoxOverlap(symbol_bbox text_bbox) then
         axlHighlightObject(symbol)
         num = num + 1
      )
   )
)

(defun turn_on_layer (layer)
   axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
   axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t)
   axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t)
   axlVisibleLayer("REF DES/SILKSCREEN_TOP" t)
   axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM" t)
   axlVisibleLayer("PIN/TOP" t)
   axlVisibleLayer("PIN/BOTTOM" t)
   axlVisibleLayer("VIA CLASS/TOP" t)
   axlVisibleLayer("VIA CLASS/BOTTOM" t)
   axlVisibleLayer("ETCH/TOP" t)
   axlVisibleLayer("ETCH/BOTTOM" t)
   axlVisibleUpdate(t)
)
