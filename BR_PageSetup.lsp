;;; ================================================================
;;; BR_PageSetup.lsp  |  Brelje & Race CAD Tools  |  Page Setup
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_PageSetup.dcl (dialog name "br_pagesetup")
;;; Command:  BR_PS
;;;
;;; Imports and applies page setups from BR standard library files.
;;; Wraps the PSETUPIN workflow into the BR Tools DCL interface.
;;; ================================================================

(vl-load-com)


;;;; -- GLOBAL DATA -----------------------------------------------
;;;;
;;;; Each entry: (display-label  actual-page-setup-name)

(setq *BR:PS-DWG2PDF*
  '(
    ("8.5x11 FULL"      "BR-Dwg to Pdf-08.5x11-FULLsize pen")
    ("8.5x11 HALF"      "BR-Dwg to Pdf-08.5x11-HALFsize pen")
    ("11x17 FULL"       "BR-Dwg to Pdf-11x17-FULLsize pen")
    ("11x17 HALF"       "BR-Dwg to Pdf-11x17-HALFsize pen")
    ("18x26 MONO"       "BR-Dwg to Pdf-18x26 MONO-FULLsize pen")
    ("22x34"            "BR-Dwg to Pdf-22x34")
    ("22x34->11x17"     "BR-Dwg to Pdf-22x34 to 11x17-HALFsize pen")
    ("24x36"            "BR-Dwg to Pdf-24x36")
    ("24x36->11x17"     "BR-Dwg to Pdf-24x36 to 11x17-HALFsize pen")
    ("30x42"            "BR-Dwg to Pdf-30x42")
    ("30x42->11x17"     "BR-Dwg to Pdf-30x42 to 11x17-HALFsize pen")
    ("30x42->15x21"     "BR-Dwg to Pdf-30x42 to 15x21-HALFsize pen")
    ("36x48"            "BR-Dwg to Pdf-36x48")
  )
)

(setq *BR:PS-BLUEBEAM*
  '(
    ("8.5x11-COLOR-FULL"        "BR-Bluebeam-08.5x11 COLOR-FULLsize pen")
    ("8.5x11-COLOR-HALF"        "BR-Bluebeam-08.5x11 COLOR-HALFsize pen")
    ("8.5x11-MONO-FULL"         "BR-Bluebeam-08.5x11 MONO-FULLsize pen")
    ("8.5x11-MONO-HALF"         "BR-Bluebeam-08.5x11 MONO-HALFsize pen")
    ("11x17-COLOR-FULL"         "BR-Bluebeam-11x17 COLOR-FULLsize pen")
    ("11x17-COLOR-HALF"         "BR-Bluebeam-11x17 COLOR-HALFsize pen")
    ("11x17-MONO-FULL"          "BR-Bluebeam-11x17 MONO-FULLsize pen")
    ("11x17-MONO-HALF"          "BR-Bluebeam-11x17 MONO-HALFsize pen")
    ("18x26-MONO-FULL"          "BR-Bluebeam-18x26 MONO-FULLsize pen")
    ("22x34-COLOR"              "BR-Bluebeam-22x34 COLOR")
    ("22x34-MONO"               "BR-Bluebeam-22x34 MONO")
    ("22x34->11x17-COLOR-HALF"  "BR-Bluebeam-22x34 to 11x17 COLOR-HALFsize pen")
    ("22x34->11x17-MONO-HALF"   "BR-Bluebeam-22x34 to 11x17 MONO-HALFsize pen")
    ("24x36-COLOR"              "BR-Bluebeam-24x36 COLOR")
    ("24x36-MONO"               "BR-Bluebeam-24x36 MONO")
    ("24x36->11x17-COLOR-HALF"  "BR-Bluebeam-24x36 to 11x17 COLOR-HALFsize pen")
    ("24x36->11x17-MONO-HALF"   "BR-Bluebeam-24x36 to 11x17 MONO-HALFsize pen")
    ("30x42-COLOR"              "BR-Bluebeam-30x42 COLOR")
    ("30x42-MONO"               "BR-Bluebeam-30x42 MONO")
    ("30x42->15x21-COLOR-HALF"  "BR-Bluebeam-30x42 to 15x21 COLOR-HALFsize pen")
    ("30x42->15x21-MONO-HALF"   "BR-Bluebeam-30x42 to 15x21 MONO-HALFsize pen")
    ("36x48-COLOR"              "BR-Bluebeam-36x48 COLOR")
    ("36x48-MONO"               "BR-Bluebeam-36x48 MONO")
    ("SCWA-22x34-MONO"          "SCWA-Bluebeam-22x34 MONO")
  )
)

;; Library source paths
(setq *BR:PS-SRC-DWG2PDF*  "J:\\LIB\\ACAD-custom\\$Page Setups\\DWG to PDF.dwg")
(setq *BR:PS-SRC-BLUEBEAM* "J:\\LIB\\ACAD-custom\\$Page Setups\\Bluebeam.dwg")

;; Runtime state (set during dialog interaction)
(setq *BR:PS-ACTIVE-LIB*   nil)   ; "DWG2PDF" or "BLUEBEAM"
(setq *BR:PS-ACTIVE-LIST*  nil)   ; current data list
(setq *BR:PS-ACTIVE-SRC*   nil)   ; current source path
(setq *BR:PS-SEL-INDEX*    nil)   ; selected list index
(setq *BR:PS-SCOPE*        nil)   ; "CURRENT" or "ALL"


;;;; -- IMPORT FUNCTION -------------------------------------------

;; Import a named page setup from a library DWG via PSETUPIN.
;; Returns T on success, nil on failure.
(defun BR:PS:Import (library-path setup-name / result)
  (setq result
    (vl-catch-all-apply
      '(lambda ()
         (command "._-PSETUPIN" library-path setup-name)
         (command)  ; clear command line
         t
       )
    )
  )
  (if (vl-catch-all-error-p result)
    (progn
      (princ (strcat "\nError importing page setup: "
                     (vl-catch-all-error-message result)))
      nil
    )
    result
  )
)


;;;; -- APPLY TO CURRENT LAYOUT -----------------------------------

;; Apply a named page setup to the active layout.
;; Returns T on success, nil on failure.
(defun BR:PS:ApplyCurrent (doc setup-name / result)
  (setq result
    (vl-catch-all-apply
      '(lambda ()
         (vla-copyfrom
           (vla-get-activelayout doc)
           (vla-item (vla-get-plotconfigurations doc) setup-name)
         )
         t
       )
    )
  )
  (if (vl-catch-all-error-p result)
    (progn
      (princ (strcat "\nError applying page setup to current layout: "
                     (vl-catch-all-error-message result)))
      nil
    )
    result
  )
)


;;;; -- APPLY TO ALL LAYOUTS --------------------------------------

;; Apply a named page setup to all non-Model layouts.
;; Returns count of layouts updated.
(defun BR:PS:ApplyAll (doc setup-name / layouts layout-item count result)
  (setq layouts (vla-get-layouts doc)
        count   0)
  (if layouts
    (vlax-for layout-item layouts
      (if (/= (vla-get-name layout-item) "Model")
        (progn
          (setq result
            (vl-catch-all-apply
              '(lambda ()
                 (vla-copyfrom
                   layout-item
                   (vla-item (vla-get-plotconfigurations doc) setup-name)
                 )
                 t
               )
            )
          )
          (if (not (vl-catch-all-error-p result))
            (setq count (1+ count))
            (princ (strcat "\nWarning: could not apply to layout '"
                           (vla-get-name layout-item) "': "
                           (vl-catch-all-error-message result)))
          )
        )
      )
    )
  )
  count
)


;;;; -- REFRESH LIST HELPER ---------------------------------------

;; Rebuild the DCL list box for the given library key.
;; library-key: "DWG2PDF" or "BLUEBEAM"
;; Updates global state and the "ps_list" tile.
(defun BR:PS:RefreshList (library-key /)
  (cond
    ((= library-key "DWG2PDF")
     (setq *BR:PS-ACTIVE-LIB*  "DWG2PDF"
           *BR:PS-ACTIVE-LIST* *BR:PS-DWG2PDF*
           *BR:PS-ACTIVE-SRC*  *BR:PS-SRC-DWG2PDF*)
    )
    ((= library-key "BLUEBEAM")
     (setq *BR:PS-ACTIVE-LIB*  "BLUEBEAM"
           *BR:PS-ACTIVE-LIST* *BR:PS-BLUEBEAM*
           *BR:PS-ACTIVE-SRC*  *BR:PS-SRC-BLUEBEAM*)
    )
  )
  ;; Populate the list box with display labels
  (start_list "ps_list")
  (mapcar 'add_list (mapcar 'car *BR:PS-ACTIVE-LIST*))
  (end_list)
  ;; Reset selection state
  (setq *BR:PS-SEL-INDEX* nil)
  (set_tile "ps_list" "")
  (set_tile "info_setup"  "Select a page setup above.")
  (set_tile "info_source" (strcat "Source: " *BR:PS-ACTIVE-SRC*))
)


;;;; -- DCL DIALOG FLOW -------------------------------------------

(defun BR:PageSetupDCL (/ dcl-path dcl-id dlg-result
                          setup-name scope doc count)

  ;; --- Locate and load DCL ---
  (setq dcl-path (findfile "BR_PageSetup.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat
          "BR_PageSetup.dcl not found.\n\n"
          "Make sure BR_PageSetup.dcl is in the same folder as the LSP files\n"
          "and that folder is on AutoCAD's support path."
        )
      )
      (exit)
    )
  )

  (setq dcl-id (load_dialog dcl-path))
  (if (< dcl-id 0)
    (progn
      (alert (strcat "Cannot load DCL file:\n" dcl-path))
      (exit)
    )
  )

  (if (not (new_dialog "br_pagesetup" dcl-id))
    (progn
      (unload_dialog dcl-id)
      (alert "Cannot initialize br_pagesetup dialog.")
      (exit)
    )
  )

  ;; --- Initialize dialog state ---
  ;; Default to DWG2PDF library and Current scope
  (BR:PS:RefreshList "DWG2PDF")
  (setq *BR:PS-SCOPE* "CURRENT")

  ;; --- Tile actions: library radio buttons ---
  (action_tile "rb_dwg2pdf"
    "(BR:PS:RefreshList \"DWG2PDF\")"
  )
  (action_tile "rb_bluebeam"
    "(BR:PS:RefreshList \"BLUEBEAM\")"
  )

  ;; --- Tile action: list box selection ---
  (action_tile "ps_list"
    (strcat
      "(progn"
      "  (setq *BR:PS-SEL-INDEX* (BR:DCL:SafeIndexOrNil (get_tile \"ps_list\")))"
      "  (if (and *BR:PS-ACTIVE-LIST*"
      "           *BR:PS-SEL-INDEX*"
      "           (>= *BR:PS-SEL-INDEX* 0)"
      "           (< *BR:PS-SEL-INDEX* (length *BR:PS-ACTIVE-LIST*)))"
      "    (set_tile \"info_setup\""
      "      (strcat \"Setup: \""
      "        (cadr (nth *BR:PS-SEL-INDEX* *BR:PS-ACTIVE-LIST*))"
      "      )"
      "    )"
      "    (set_tile \"info_setup\" \"Setup: ...\")"
      "  )"
      ")"
    )
  )

  ;; --- Tile actions: scope radio buttons ---
  (action_tile "rb_current"
    "(setq *BR:PS-SCOPE* \"CURRENT\")"
  )
  (action_tile "rb_all"
    "(setq *BR:PS-SCOPE* \"ALL\")"
  )

  ;; --- Tile action: Import & Apply button ---
  (action_tile "accept"
    (strcat
      "(if (null *BR:PS-SEL-INDEX*)"
      "  (alert \"Please select a page setup first.\")"
      "  (done_dialog 1)"
      ")"
    )
  )

  ;; --- Run dialog ---
  (setq dlg-result (start_dialog))
  (unload_dialog dcl-id)

  ;; --- Process result ---
  (if (= dlg-result 1)
    (progn
      (setq setup-name (cadr (nth *BR:PS-SEL-INDEX* *BR:PS-ACTIVE-LIST*))
            scope      *BR:PS-SCOPE*
            doc        (vla-get-activedocument (vlax-get-acad-object)))

      ;; Verify library file exists
      (if (not (findfile *BR:PS-ACTIVE-SRC*))
        (progn
          (alert (strcat "Page setup library file not found:\n"
                         *BR:PS-ACTIVE-SRC*))
          (exit)
        )
      )

      ;; Step 1: Import the page setup
      (princ (strcat "\nImporting page setup: " setup-name " ..."))
      (if (BR:PS:Import *BR:PS-ACTIVE-SRC* setup-name)
        (progn
          (princ " Done.")

          ;; Step 2: Apply based on scope
          (cond
            ((= scope "CURRENT")
             (princ (strcat "\nApplying to current layout ..."))
             (if (BR:PS:ApplyCurrent doc setup-name)
               (princ " Done.")
               (princ " FAILED.")
             )
            )
            ((= scope "ALL")
             (princ (strcat "\nApplying to all layouts ..."))
             (setq count (BR:PS:ApplyAll doc setup-name))
             (princ (strcat " Done. (" (itoa count) " layouts updated)"))
            )
          )
        )
        ;; Import failed
        (princ "\nPage setup import FAILED.")
      )
    )
    ;; User cancelled
    (princ "\nBR_PS cancelled.")
  )
)


;;;; -- COMMAND ---------------------------------------------------

(defun C:BR_PS (/ *error* _olderr _saved _undoFlag)
  (vl-load-com)
  (setq _saved  (BR:SaveSysvars '("CMDECHO"))
        _olderr *error*)
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*")))
      (princ (strcat "\nError: " msg))
    )
    (BR:EndUndo _undoFlag)
    (BR:RestoreSysvars _saved)
    (setq *error* _olderr)
    (princ)
  )
  (setvar "CMDECHO" 0)
  (setq _undoFlag (BR:BeginUndo))

  (BR:PageSetupDCL)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED ---------------------------------------------

(princ "\n  BR_PageSetup module loaded.  Command: BR_PS")
(princ)

;;; End of BR_PageSetup.lsp
