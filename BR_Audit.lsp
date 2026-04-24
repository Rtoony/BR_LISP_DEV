;;; ================================================================
;;; BR_Audit.lsp  |  Brelje & Race CAD Tools  |  Drawing Audit
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_Audit.dcl (dialog name "br_audit")
;;; Command:  BR_AUD
;;;
;;; Scans the current drawing and reports on:
;;;   - Layer compliance against BR standards
;;;   - Block inventory (all inserts with counts)
;;;   - Xref status
;;;   - Zero-length / empty geometry
;;;   - File naming compliance
;;; ================================================================


;;;; -- AUDIT RESULTS ACCUMULATOR -----------------------------------

(setq *BR:AUDIT-LINES* nil)

(defun BR:AUD:Clear ()
  (setq *BR:AUDIT-LINES* nil)
)

(defun BR:AUD:Add (line)
  (setq *BR:AUDIT-LINES*
    (append *BR:AUDIT-LINES* (list line)))
)

(defun BR:AUD:AddSection (title)
  (BR:AUD:Add (strcat "---- " title " ----"))
)


;;;; -- LAYER SCAN --------------------------------------------------

;; Build a flat list of all known layer names (uppercased) from *BR:LAYER-CATS*.
(defun BR:AUD:BuildKnownLayers (/ result cat ly)
  (setq result nil)
  (foreach cat *BR:LAYER-CATS*
    (foreach ly (BR:LC:Layers cat)
      (setq result (cons (strcase (BR:LY:Name ly)) result))
    )
  )
  result
)

;; Validate drawing layers against the BR standards database.
(defun BR:AUD:ScanLayers (/ doc layers count non-std known lobj lname lname-up)
  (BR:AUD:AddSection "LAYERS")
  (setq doc     (vla-get-activedocument (vlax-get-acad-object))
        layers  (vla-get-layers doc)
        count   0
        non-std 0
        known   (BR:AUD:BuildKnownLayers))
  (vlax-for lobj layers
    (setq lname    (vla-get-name lobj)
          lname-up (strcase lname)
          count    (1+ count))
    (if (and (not (= lname "0"))
             (not (= lname-up "DEFPOINTS"))
             (not (member lname-up known)))
      (progn
        (setq non-std (1+ non-std))
        (BR:AUD:Add (strcat "  [WARN] Non-standard: " lname))
      )
    )
  )
  (BR:AUD:Add
    (strcat "  [INFO] Total: " (itoa count)
            "  |  Non-standard: " (itoa non-std)))
)


;;;; -- BLOCK INVENTORY ---------------------------------------------

;; Count all block inserts in model space, grouped by name.
(defun BR:AUD:ScanBlocks (/ doc mspace count blk-counts ename obj bname pair)
  (BR:AUD:AddSection "BLOCKS")
  (setq doc      (vla-get-activedocument (vlax-get-acad-object))
        mspace   (vla-get-modelspace doc)
        count    0
        blk-counts nil)
  (vlax-for obj mspace
    (if (= (vla-get-objectname obj) "AcDbBlockReference")
      (progn
        (setq bname (vla-get-name obj)
              count (1+ count)
              pair  (assoc bname blk-counts))
        (if pair
          (setq blk-counts
            (subst (cons bname (1+ (cdr pair))) pair blk-counts))
          (setq blk-counts
            (append blk-counts (list (cons bname 1))))
        )
      )
    )
  )
  ;; Report
  (if (= count 0)
    (BR:AUD:Add "  [INFO] No block references found in model space.")
    (progn
      (foreach pair blk-counts
        (BR:AUD:Add
          (strcat "  [INFO] " (car pair) "  (" (itoa (cdr pair)) "x)"))
      )
      (BR:AUD:Add
        (strcat "  [INFO] Total inserts: " (itoa count)
                "  |  Unique blocks: " (itoa (length blk-counts))))
    )
  )
)


;;;; -- XREF SCAN ---------------------------------------------------

;; List all xrefs with path and status.
(defun BR:AUD:ScanXrefs (/ doc blocks count bdef bname)
  (BR:AUD:AddSection "XREFS")
  (setq doc    (vla-get-activedocument (vlax-get-acad-object))
        blocks (vla-get-blocks doc)
        count  0)
  (vlax-for bdef blocks
    (if (= (vla-get-isxref bdef) :vlax-true)
      (progn
        (setq bname (vla-get-name bdef)
              count (1+ count))
        (if (= (vla-get-isresolved bdef) :vlax-true)
          (BR:AUD:Add
            (strcat "  [INFO] " bname "  ->  " (vla-get-path bdef)))
          (BR:AUD:Add
            (strcat "  [FAIL] " bname "  ->  " (vla-get-path bdef) "  [UNRESOLVED]"))
        )
      )
    )
  )
  (if (= count 0)
    (BR:AUD:Add "  [INFO] No xrefs found.")
    (BR:AUD:Add (strcat "  [INFO] Total xrefs: " (itoa count)))
  )
)


;;;; -- ZERO-LENGTH / EMPTY ENTITY SCAN -----------------------------

;; Scan model space for zero-length lines, empty text, etc.
(defun BR:AUD:ScanZero (/ doc mspace count obj oname sp ep)
  (BR:AUD:AddSection "ZERO-LENGTH / EMPTY ENTITIES")
  (setq doc    (vla-get-activedocument (vlax-get-acad-object))
        mspace (vla-get-modelspace doc)
        count  0)
  (vlax-for obj mspace
    (setq oname (vla-get-objectname obj))
    (cond
      ;; Zero-length lines
      ((= oname "AcDbLine")
       (setq sp (vlax-get obj 'StartPoint)
             ep (vlax-get obj 'EndPoint))
       (if (and (equal (car sp) (car ep) 0.0001)
                (equal (cadr sp) (cadr ep) 0.0001)
                (equal (caddr sp) (caddr ep) 0.0001))
         (progn
           (setq count (1+ count))
           (BR:AUD:Add
             (strcat "  [FAIL] Zero-length line on layer: "
                     (vla-get-layer obj)))
         )
       )
      )
      ;; Empty text
      ((or (= oname "AcDbText") (= oname "AcDbMText"))
       (if (= (vla-get-textstring obj) "")
         (progn
           (setq count (1+ count))
           (BR:AUD:Add
             (strcat "  [FAIL] Empty text on layer: "
                     (vla-get-layer obj)))
         )
       )
      )
    )
  )
  (if (= count 0)
    (BR:AUD:Add "  [INFO] No issues found.")
    (BR:AUD:Add (strcat "  [INFO] Total issues: " (itoa count)))
  )
)


;;;; -- FILE NAMING CHECK -------------------------------------------

;; Check if current drawing name follows BR naming conventions.
(defun BR:AUD:ScanNaming (/ nm base tok)
  (BR:AUD:AddSection "FILE NAMING")
  (setq nm (getvar "DWGNAME"))
  (if (or (null nm) (= nm ""))
    (BR:AUD:Add "  [WARN] Drawing has not been saved yet.")
    (progn
      (setq base (vl-filename-base nm))
      (BR:AUD:Add (strcat "  [INFO] Filename: " base))
      ;; Check for project number prefix
      (setq tok (car (BR:Split base " ")))
      (if (BR:ValidProj? tok)
        (BR:AUD:Add (strcat "  [INFO] Project number: " tok))
        (BR:AUD:Add "  [WARN] Project number: NOT DETECTED")
      )
      ;; Check for spaces (required in BR naming)
      (if (not (vl-string-search " " base))
        (BR:AUD:Add "  [WARN] No spaces found -- may not follow BR naming convention.")
      )
    )
  )
)


;;;; -- EXPORT RESULTS ---------------------------------------------

;; Export audit results to a text file at C:\CAD_IO\logs\.
(defun BR:AUD:ExportResults (/ proj date-str filename filepath fp line)
  (if (null *BR:AUDIT-LINES*)
    (alert "No audit results to export.\nRun the audit first.")
    (progn
      (setq proj     (if (BR:DetectProj) (BR:DetectProj) "unknown")
            date-str (BR:DateStr)
            filename (strcat "audit_" proj "_" date-str ".txt")
            filepath (strcat "C:\\CAD_IO\\logs\\" filename))
      (BR:Mkdirp "C:\\CAD_IO\\logs")
      (setq fp (open filepath "w"))
      (if (null fp)
        (alert (strcat "Cannot write to:\n" filepath))
        (progn
          (write-line (strcat "BR Drawing Audit  --  " proj "  --  " date-str) fp)
          (write-line (strcat "Drawing: " (getvar "DWGNAME")) fp)
          (write-line (strcat "Path: " (getvar "DWGPREFIX")) fp)
          (write-line "================================================" fp)
          (foreach line *BR:AUDIT-LINES*
            (write-line line fp)
          )
          (close fp)
          (alert (strcat "Exported " (itoa (length *BR:AUDIT-LINES*))
                         " lines to:\n" filepath))
        )
      )
    )
  )
)


;;;; -- DCL DIALOG --------------------------------------------------

(defun BR:AuditDCL (/ dcl-path dcl-id done d-chk-layers d-chk-blocks
                      d-chk-xrefs d-chk-zero d-chk-naming total-checks)

  (setq dcl-path (findfile "BR_Audit.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat "BR_Audit.dcl not found.\n\n"
                "Make sure BR_Audit.dcl is in the same folder as the LSP files\n"
                "and that folder is on AutoCAD's support path."))
      (exit)
    )
  )

  (setq d-chk-layers "1"
        d-chk-blocks "1"
        d-chk-xrefs  "1"
        d-chk-zero   "1"
        d-chk-naming "1")

  (setq dcl-id (load_dialog dcl-path))
  (if (< dcl-id 0)
    (progn (alert (strcat "Cannot load DCL:\n" dcl-path)) (exit))
  )
  (if (not (new_dialog "br_audit" dcl-id))
    (progn
      (unload_dialog dcl-id)
      (alert "Cannot initialize br_audit dialog.")
      (exit)
    )
  )

  ;; Default all checks on
  (set_tile "chk_layers" "1")
  (set_tile "chk_blocks" "1")
  (set_tile "chk_xrefs"  "1")
  (set_tile "chk_zero"   "1")
  (set_tile "chk_naming" "1")

  ;; Actions
  (action_tile "chk_layers" "(setq d-chk-layers (BR:SafeStr $value))")
  (action_tile "chk_blocks" "(setq d-chk-blocks (BR:SafeStr $value))")
  (action_tile "chk_xrefs"  "(setq d-chk-xrefs (BR:SafeStr $value))")
  (action_tile "chk_zero"   "(setq d-chk-zero (BR:SafeStr $value))")
  (action_tile "chk_naming" "(setq d-chk-naming (BR:SafeStr $value))")

  ;; Run button -- runs the audit and populates results within the dialog
  (action_tile "btn_run"
    (strcat
      "(BR:AUD:Clear)"
      "(if (= d-chk-layers \"1\") (BR:AUD:ScanLayers))"
      "(if (= d-chk-blocks \"1\") (BR:AUD:ScanBlocks))"
      "(if (= d-chk-xrefs \"1\")  (BR:AUD:ScanXrefs))"
      "(if (= d-chk-zero \"1\")   (BR:AUD:ScanZero))"
      "(if (= d-chk-naming \"1\") (BR:AUD:ScanNaming))"
      "(start_list \"audit_results\")"
      "(foreach ln *BR:AUDIT-LINES* (add_list ln))"
      "(end_list)"
      "(set_tile \"audit_summary\""
      "  (strcat \"Scan complete -- \""
      "          (itoa (length *BR:AUDIT-LINES*)) \" lines reported.\"))"
    )
  )

  ;; Export button
  (action_tile "btn_export" "(BR:AUD:ExportResults)")

  (action_tile "accept" "(done_dialog 0)")

  (start_dialog)
  (unload_dialog dcl-id)
)


;;;; -- COMMAND ------------------------------------------------------

(defun C:BR_AUD (/ *error* _olderr _saved _undoFlag)
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

  (BR:AuditDCL)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED -----------------------------------------------

(princ "\n  BR_Audit module loaded.  Command: BR_AUD")
(princ)

;;; End of BR_Audit.lsp
