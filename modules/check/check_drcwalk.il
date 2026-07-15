;; ============================================================
;; File: check_drcwalk.il
;; Purpose: DRC walk
;; Encoding: ASCII
;; ============================================================

; drc_walk.il - Copyright 1994-96 Loral Federal Systems Owego
;
; drc walk - display DRCs in Allegro design
; layers   - show a group of class/subclass pairs for a given etch layer
;
;
; NO WARRANTY - This software is made available asis; and may not work
;  as advertised in all environment.
;
; This function works with Allegro 10+.
;
; This function will generate a list of DRCs in the current design, and
; allow the user to 'walk through' the list to inspect/verify/etc.
; User can filter the list of DRCs by layer and/or type. Select HELP
; from the drc walk menu for further details.
;
; This file also contains the layers function.
;
; Load the software (by including drc_walk.il in your allegro.ilinit file
;      or by explicity typing (load "drc_walk.il")  at your allegro command
;      line.
;
; This function builds its form & help screen in the /tmp directory
;
;  Created by:    Joe Morrison
;                 joe.morrison@lmco.com
;                 Loral Federal Systems-Owego
;
; This skill program demonstrates the following concepts:
;                 - File I/O
;                 - Asynchronous Forms & Callbacks
;                 - Manipulating design elements by database id
;                 - Create a sublist of items matching search criteria
;                 - viewfile creation
; Updated: April 2001
;          -change the location of the files from /tmp to the current directory ./

(defun _saveSelSet ()
    (list (axlGetSelSet) (axlGetFindFilter nil) (axlGetFindFilter t)))

(defun _restoreSelSet (oldSelSet "l")
    (axlSetFindFilter ?enabled (cons "noall" (nth 1 oldSelSet))
                      ?onButtons (cons "noall" (nth 2 oldSelSet)))
    (axlSingleSelectObject (car oldSelSet))
    t)

(defun _drcWalk (drcList currentDrc)
  (let* ((drc (car currentDrc))
         (nextDrc (cdr currentDrc))
         (prevDrc (append (reverse (cdr (member drc (reverse drcList))))
                          (reverse (cdr (member drc drcList))))))
    (axlClearSelSet)
    (axlSingleSelectObject drc)
    (axlZoomToSelSet)
    (when nextDrc
      (axlUIConfirm (sprintf nil "Next DRC: %s" (car nextDrc))))
    (when prevDrc
      (axlUIConfirm (sprintf nil "Prev DRC: %s" (car prevDrc))))))

(defun _drcWalkFilter (drcList filterType filterLayer)
  (let (filteredList)
    (foreach drc drcList
      (let ((drcType (axlDBGetProp drc 'type))
            (drcLayer (axlDBGetProp drc 'layer)))
        (when (and (or (null filterType) (equal drcType filterType))
                   (or (null filterLayer) (equal drcLayer filterLayer)))
          (setq filteredList (cons drc filteredList)))))
    (reverse filteredList)))

(defun _drcWalkReport (drcList reportFile)
  (let ((outPort (outfile reportFile)))
    (when outPort
      (fprintf outPort "DRC Walk Report\n")
      (fprintf outPort "===============\n\n")
      (foreach drc drcList
        (fprintf outPort "DRC: %s  Type: %s  Layer: %s\n"
                 drc
                 (axlDBGetProp drc 'type)
                 (axlDBGetProp drc 'layer)))
      (close outPort)
      (axlUIConfirm (sprintf nil "Report saved to %s" reportFile)))))

(defun _drcWalkHelp ()
  (axlUIConfirm "DRC Walk Help:\n\n1. Use Next/Prev to navigate DRCs\n2. Filter by type or layer\n3. Report saves DRC list to file\n4. Zoom auto-zooms to current DRC"))

(defun _drcWalkFormCallback (form field)
  (case field
    ("next"
     (when _drcWalkCurrentList
       (setq _drcWalkCurrentDrc
             (if (cdr _drcWalkCurrentDrc)
                 (cdr _drcWalkCurrentDrc)
               _drcWalkCurrentList))
       (_drcWalk _drcWalkCurrentList _drcWalkCurrentDrc)))
    ("prev"
     (when _drcWalkCurrentList
       (setq _drcWalkCurrentDrc
             (if (member (car _drcWalkCurrentDrc) _drcWalkCurrentList)
                 (let ((prev (cdr (member (car _drcWalkCurrentDrc) (reverse _drcWalkCurrentList)))))
                   (if prev (reverse prev) (list (car (reverse _drcWalkCurrentList)))))
               _drcWalkCurrentList))
       (_drcWalk _drcWalkCurrentList _drcWalkCurrentDrc)))
    ("filter"
     (let ((typeFilter (axlFormGetField form "typeFilter"))
           (layerFilter (axlFormGetField form "layerFilter")))
       (setq _drcWalkCurrentList
             (_drcWalkFilter _drcWalkAllList typeFilter layerFilter))
       (setq _drcWalkCurrentDrc _drcWalkCurrentList)
       (axlFormSetField form "count" (sprintf nil "%d" (length _drcWalkCurrentList)))))
    ("report"
     (_drcWalkReport _drcWalkCurrentList "drc_walk.rpt"))
    ("help"
     (_drcWalkHelp))
    ("done"
     (axlFormClose form)
     (setq _drcWalkForm nil))))

(defun _drcWalkInit ()
  (setq _drcWalkAllList (axlDBGetDesign()->drcs))
  (setq _drcWalkCurrentList _drcWalkAllList)
  (setq _drcWalkCurrentDrc _drcWalkCurrentList)
  (setq _drcWalkForm (axlFormCreate (gensym) "drc_walk.form" '(e outside "Done") '_drcWalkFormCallback))
  (axlFormSetField _drcWalkForm "count" (sprintf nil "%d" (length _drcWalkCurrentList)))
  (axlFormDisplay _drcWalkForm))

(defun _drcWalkCleanup ()
  (when _drcWalkForm
    (axlFormClose _drcWalkForm)
    (setq _drcWalkForm nil))
  (setq _drcWalkAllList nil)
  (setq _drcWalkCurrentList nil)
  (setq _drcWalkCurrentDrc nil))

; Main entry point
(defun _drcWalkMain ()
  (_drcWalkCleanup)
  (_drcWalkInit))

; Register command
(axlCmdRegister "drc_walk" '_drcWalkMain)
