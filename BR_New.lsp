;;; ================================================================
;;; BR_New.lsp  |  Brelje & Race CAD Tools  |  New Drawing Module
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_New.dcl (dialog name "br_new")
;;; Commands: BR_NEW (dialog), BR_C (command-line)
;;;
;;; Source of truth: original BR.lsp v1.0
;;; ================================================================


;;;; -- DCL DIALOG CALLBACKS ----------------------------------------
;;;;
;;;; These three functions are called from action_tile strings inside
;;;; BR:NewDCL.  They access the following local variables of that
;;;; function via AutoCAD LISP's dynamic scoping -- the calling
;;;; function's frame remains live during start_dialog:
;;;;
;;;;   d-proj    current project number string
;;;;   d-phase   current phase string
;;;;   d-ftidx   selected file type index into *BR:FT*
;;;;   d-desc    current description string
;;;;

;; DCL callback values should be strings, but some startup/focus events can
;; arrive as non-strings. Normalize them before using string functions.
(defun BR:DCL:SafeText (val)
  (BR:SafeStr val)
)

;; Rebuild the Folder/File preview tiles from current dialog state.
(defun BR:DCL:Preview (/ ft)
  (if (and (BR:ValidProj? d-proj)
           (>= d-ftidx 0)
           (< d-ftidx (length *BR:FT*))
           (not (BR:FT:Sep? (nth d-ftidx *BR:FT*))))
    (progn
      (setq ft (nth d-ftidx *BR:FT*))
      (set_tile "preview_folder"
        (strcat "Folder :  " (BR:TargetDir d-proj (BR:FT:Folder ft))))
      (set_tile "preview_file"
        (strcat "File   :  "
                (BR:BuildName d-proj d-phase (BR:FT:Code ft) d-desc)
                ".dwg"))
    )
    (progn
      (set_tile "preview_folder" "Folder :  ...")
      (set_tile "preview_file"   "File   :  ...")
    )
  )
)

;; Update the "Optional / REQUIRED" label when file type selection changes.
(defun BR:DCL:DescState (/ ft)
  (if (and (>= d-ftidx 0)
           (< d-ftidx (length *BR:FT*))
           (not (BR:FT:Sep? (nth d-ftidx *BR:FT*))))
    (progn
      (setq ft (nth d-ftidx *BR:FT*))
      (set_tile "desc_status"
        (if (BR:FT:Req? ft) "REQUIRED " "Optional "))
    )
  )
)

;; Validate all inputs; close the dialog on success.
(defun BR:DCL:Accept ()
  (cond
    ((not (BR:ValidProj? d-proj))
     (alert
       (strcat "Invalid project number.\n\n"
               "Required format :  ####.##\n"
               "Example         :  5212.00"))
    )
    ((< d-ftidx 0)
     (alert "Please select a file type from the list.")
    )
    ((BR:FT:Sep? (nth d-ftidx *BR:FT*))
     (alert "That line is a category header.\nPlease select an actual file type.")
    )
    ((and (BR:FT:Req? (nth d-ftidx *BR:FT*)) (= d-desc ""))
     (alert
       (strcat "A description is REQUIRED for this file type.\n"
               "Enter it in the Description field before continuing."))
    )
    (t (done_dialog 1))
  )
)


;;;; -- BR:NewDCL -- DCL DIALOG FLOW ---------------------------------

(defun BR:NewDCL (/ dcl-path dcl-id done d-proj d-phase d-ftidx d-desc ft path)

  ;; Locate DCL file
  (setq dcl-path (findfile "BR_New.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat "BR_New.dcl not found.\n\n"
                "Make sure BR_New.dcl is in the same folder as the LSP files\n"
                "and that folder is on AutoCAD's support path\n"
                "(Options > Files > Support File Search Path)."))
      (exit)
    )
  )

  ;; Initialize state variables
  ;; (accessed dynamically by BR:DCL:Preview / DescState / Accept)
  (setq d-proj  (BR:SafeStr (BR:DetectProj))
        d-phase ""
        d-ftidx -1
        d-desc  "")

  ;; Load dialog
  (setq dcl-id (load_dialog dcl-path))
  (if (< dcl-id 0)
    (progn
      (alert (strcat "Cannot load DCL file:\n" dcl-path))
      (exit)
    )
  )
  (if (not (new_dialog "br_new" dcl-id))
    (progn
      (unload_dialog dcl-id)
      (alert "Cannot initialize br_new dialog.")
      (exit)
    )
  )

  ;; Populate file type list (includes separator rows for visual grouping)
  (start_list "file_type_list")
  (foreach ft *BR:FT* (add_list (BR:FT:Disp ft)))
  (end_list)
  ;; Keep startup state blank so an opening Enter key cannot create a drawing.
  (set_tile "file_type_list" "")

  ;; Pre-fill project number if detected
  (set_tile "proj_num" d-proj)
  (BR:DCL:DescState)
  (BR:DCL:Preview)

  ;; -- Bind action tiles ---------------------------------------------
  (action_tile "proj_num"
    "(setq d-proj (BR:DCL:SafeText $value)) (BR:DCL:Preview)")

  (action_tile "phase"
    "(setq d-phase (BR:DCL:SafeText $value)) (BR:DCL:Preview)")

  (action_tile "file_type_list"
    (strcat
      "(setq d-ftidx (BR:DCL:SafeIndex $value))"
      "(BR:DCL:DescState)"
      "(BR:DCL:Preview)"
      ;; Double-click fires Accept validation (same as clicking OK)
      "(if (= $reason 4) (BR:DCL:Accept))"
    )
  )

  (action_tile "description"
    "(setq d-desc (BR:DCL:SafeText $value)) (BR:DCL:Preview)")

  (action_tile "accept" "(BR:DCL:Accept)")
  (action_tile "cancel" "(done_dialog 0)")

  ;; -- Run dialog ----------------------------------------------------
  (setq done (start_dialog))
  (unload_dialog dcl-id)

  ;; -- Act on result -------------------------------------------------
  (if (= done 1)
    (progn
      (setq ft   (nth d-ftidx *BR:FT*)
            path (BR:Create d-proj d-phase
                            (BR:FT:Code ft) d-desc
                            (BR:FT:Folder ft)))
      (if path (BR:OfferOpen path))
    )
  )
)


;;;; -- BR:NewCMD -- COMMAND-LINE FLOW -------------------------------

(defun BR:NewCMD (/ detected proj phase ft-real n ft sel desc path)

  (princ "\n")
  (princ "\n  ================================================")
  (princ (strcat "\n   B R  Tools  v" *BR:VER* "  --  New Drawing"))
  (princ "\n  ================================================")

  ;; -- Project number ------------------------------------------------
  (setq detected (BR:DetectProj))
  (if detected
    (progn
      (princ (strcat "\n\n  Detected project: " detected))
      (initget "Yes No")
      (if (= (getkword "  Use this project number? [Yes/No] <Yes>: ") "No")
        (setq detected nil)
      )
    )
  )
  (setq proj detected)
  (if (null proj)
    (progn
      (setq proj nil)
      (while (not (BR:ValidProj? proj))
        (setq proj (getstring "\n  Project number (####.##): "))
        (if (not (BR:ValidProj? proj))
          (princ "\n  Invalid -- format must be like:  5212.00")
        )
      )
    )
  )

  ;; -- Phase (optional) ----------------------------------------------
  (setq phase (getstring "\n  Phase code (DD, CD, BID...) or Enter to skip: "))

  ;; -- File type list ------------------------------------------------
  ;; Build a numbered list from real (non-separator) entries only.
  ;; Separators print as visual dividers without a number.
  (setq ft-real (vl-remove-if 'BR:FT:Sep? *BR:FT*))
  (princ "\n")
  (setq n 0)
  (foreach row *BR:FT*
    (if (BR:FT:Sep? row)
      (princ (strcat "\n  " (BR:FT:Disp row)))
      (progn
        (setq n (1+ n))
        (princ
          (strcat "\n  " (BR:PadL (itoa n) 3 " ") ".  " (BR:FT:Disp row)))
      )
    )
  )
  (princ "\n")

  (setq sel -1)
  (while (or (< sel 1) (> sel (length ft-real)))
    (setq sel (atoi (getstring "\n  Enter file type number: ")))
    (if (or (< sel 1) (> sel (length ft-real)))
      (princ (strcat "  Enter a number between 1 and " (itoa (length ft-real))))
    )
  )
  (setq ft (nth (1- sel) ft-real))

  ;; -- Description ---------------------------------------------------
  (cond
    ((BR:FT:Req? ft)
     (setq desc "")
     (while (= desc "")
       (setq desc
         (getstring t "\n  Description (REQUIRED for this type): "))
       (if (= desc "")
         (princ "  Cannot be blank -- enter a description.")
       )
     )
    )
    (t
     (setq desc
       (getstring t "\n  Description (optional -- Enter to skip): "))
    )
  )

  ;; -- Preview -------------------------------------------------------
  (princ "\n")
  (princ
    (strcat "\n  Folder : " (BR:TargetDir proj (BR:FT:Folder ft))))
  (princ
    (strcat "\n  File   : "
            (BR:BuildName proj phase (BR:FT:Code ft) desc)
            ".dwg"))
  (princ "\n")

  ;; -- Confirm and create --------------------------------------------
  (initget "Yes No")
  (if (not (= (getkword "\n  Create this drawing? [Yes/No] <Yes>: ") "No"))
    (progn
      (setq path
        (BR:Create proj phase
                   (BR:FT:Code ft) desc
                   (BR:FT:Folder ft)))
      (if path (BR:OfferOpen path))
    )
    (princ "\n  Cancelled.")
  )
)


;;;; -- COMMANDS ----------------------------------------------------

(defun C:BR_NEW (/ *error* _olderr _saved _undoFlag)
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

  (BR:NewDCL)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)

(defun C:BR_C (/ *error* _olderr _saved _undoFlag)
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

  (BR:NewCMD)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED -----------------------------------------------

(princ "\n  BR_New module loaded.  Commands: BR_NEW  BR_C")
(princ)

;;; End of BR_New.lsp
