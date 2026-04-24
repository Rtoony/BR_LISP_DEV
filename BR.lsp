;;; ================================================================
;;; BR.lsp  |  Brelje & Race CAD Tools Suite  |  Top-Level Launcher
;;; ================================================================
;;; Load this file via APPLOAD. It loads all modules and exposes:
;;;   C:BR        -- suite launcher dialog
;;;   C:BR_NEW    -- New Drawing            (from BR_New.lsp)
;;;   C:BR_C      -- command-line New Dwg   (from BR_New.lsp)
;;;   C:BR_LAY    -- Layer tools            (from BR_Layers.lsp)
;;;   C:BR_INS    -- Block insert           (from BR_Insert.lsp)
;;;   C:BR_DTL    -- Detail insert          (from BR_Details.lsp)
;;;   C:BR_AUD    -- Drawing audit          (from BR_Audit.lsp)
;;;   C:BR_VP     -- Viewport creation      (from BR_Viewport.lsp)
;;;   C:BR_PS     -- Page setup             (from BR_PageSetup.lsp)
;;;   C:BR_SNAP   -- Drawing snapshot       (from BR_Snapshot.lsp)
;;;   C:BR:SnapPro -- Enhanced snapshot     (from BR_SnapPro.lsp)
;;;   C:BR_PUB    -- Batch publish          (from BR_Publish.lsp)
;;;   C:BR_DEMO   -- Move objects to DEMO layers (from BR_Demo.lsp)
;;;   C:BR_UNDEMO -- Restore from DEMO layers    (from BR_Demo.lsp)
;;;   C:BR_DB     -- Project database editor     (from BR_ProjectDB.lsp)
;;; ================================================================
;;; DCL file: BR_Main.dcl (dialog name "br_main")
;;; ================================================================


;;;; -- LOAD MODULES ------------------------------------------------

;; Load core first -- everything depends on it.
(if (not (findfile "BR_Core.lsp"))
  (alert
    (strcat
      "BR_Core.lsp not found on AutoCAD's support path.\n\n"
      "All BR module files must be in the same folder,\n"
      "and that folder must be on the Support File Search Path."
    )
  )
  (progn
    (load (findfile "BR_Core.lsp"))

    ;; Load sub-modules using core helper
    (BR:LoadModule "BR_New.lsp")
    (BR:LoadModule "BR_Layers.lsp")
    (BR:LoadModule "BR_Insert.lsp")
    (BR:LoadModule "BR_Details.lsp")
    (BR:LoadModule "BR_Audit.lsp")
    (BR:LoadModule "BR_Viewport.lsp")
    (BR:LoadModule "BR_PageSetup.lsp")
    (BR:LoadModule "BR_Snapshot.lsp")
    (BR:LoadModule "BR_SnapPro.lsp")
    (BR:LoadModule "BR_Publish.lsp")
    (BR:LoadModule "BR_Demo.lsp")
    (BR:LoadModule "BR_ProjectDB.lsp")
  )
)


;;;; -- C:BR  -- SUITE LAUNCHER -------------------------------------

(defun BR:MainAccept ()
  (if (= (BR:SafeStr d-sel) "")
    (alert "Please select an operation first.")
    (done_dialog 1)
  )
)

(defun C:BR (/ dcl-path dcl-id done d-sel)
  (setq dcl-path (findfile "BR_Main.dcl"))

  (if (null dcl-path)
    (progn
      (alert
        (strcat
          "BR_Main.dcl not found on AutoCAD's support path.\n\n"
          "Place all BR files in the same folder and add that folder\n"
          "to Support File Search Path."
        )
      )
      (princ)
    )
    (progn
      (setq dcl-id (load_dialog dcl-path))
      (if (< dcl-id 0)
        (progn
          (alert (strcat "Cannot load DCL:\n" dcl-path))
          (princ)
        )
        (if (not (new_dialog "br_main" dcl-id))
          (progn
            (unload_dialog dcl-id)
            (alert "Cannot initialize br_main dialog.")
            (princ)
          )
          (progn
            ;; Populate operation list
            (start_list "op_list")
            (add_list "  NEW          Create a new drawing from template")
            (add_list "  LAYERS       Apply / audit standard layers  (360 layers)")
            (add_list "  INSERT       Insert standard block  (1077 blocks)")
            (add_list "  DETAILS      Insert standard detail  (124 details)")
            (add_list "  AUDIT        Scan drawing for standards compliance")
            (add_list "  VIEWPORTS    Create locked viewports from template")
            (add_list "  PAGE SETUP   Import & apply page setup")
            (add_list "  SNAPSHOT     Export drawing data for Claude analysis")
            (add_list "  SNAPSHOT+    Enhanced snapshot with geometry and bounds")
            (add_list "  PUBLISH      Batch publish layouts to PDF / DWF")
            (add_list "  DEMO MOVE    Move objects to demolition layers")
            (add_list "  DEMO RESTORE Restore objects from demolition layers")
            (add_list "  PROJECT DB   Edit project database (JSON)")
            (end_list)
            ;; Keep startup state blank so the Enter key used to launch BR
            ;; cannot immediately accept the default NEW command.
            (set_tile "op_list" "")
            (setq d-sel "")

            ;; Actions
            (action_tile "op_list"
              "(setq d-sel (BR:SafeStr $value)) (if (= $reason 4) (done_dialog 1))")
            (action_tile "accept" "(BR:MainAccept)")
            (action_tile "cancel" "(done_dialog 0)")

            (setq done (start_dialog))
            (unload_dialog dcl-id)

            ;; Dispatch
            (if (= done 1)
              (cond
                ((= d-sel "0") (BR:NewDCL))
                ((= d-sel "1") (BR:LayersDCL))
                ((= d-sel "2") (BR:InsertDCL))
                ((= d-sel "3") (BR:DetailsDCL))
                ((= d-sel "4") (BR:AuditDCL))
                ((= d-sel "5") (BR:ViewportDCL))
                ((= d-sel "6") (BR:PageSetupDCL))
                ((= d-sel "7") (BR:SnapshotDCL))
                ((= d-sel "8") (C:BR:SnapPro))
                ((= d-sel "9") (C:BR_PUB))
                ((= d-sel "10") (C:BR_DEMO))
                ((= d-sel "11") (C:BR_UNDEMO))
                ((= d-sel "12") (BR:ProjectDBDCL))
              )
            )
          )
        )
      )
    )
  )
  (princ)
)


;;;; -- LOADED ------------------------------------------------------

(princ
  (strcat
    "\n  BR Tools v" *BR:VER* " loaded."
    "\n  Commands: BR  BR_NEW  BR_C  BR_LAY  BR_INS  BR_DTL"
    "\n            BR_AUD  BR_VP  BR_PS  BR_SNAP  BR:SnapPro  BR_PUB"
    "\n            BR_DEMO  BR_UNDEMO  BR_DB"
  )
)
(princ)

;;; End of BR.lsp
