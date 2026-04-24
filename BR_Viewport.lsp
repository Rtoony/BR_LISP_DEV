;;; ================================================================
;;; BR_Viewport.lsp  |  Brelje & Race CAD Tools  |  Viewport Creation
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_Viewport.dcl (dialog name "br_viewport")
;;; Command:  BR_VP
;;;
;;; Creates locked viewports on paper-space layouts using hardcoded
;;; title-block configurations derived from ViewportLayout.csv.
;;; ================================================================

(vl-load-com)

;;;; -- VIEWPORT CONFIGURATION DATABASE ------------------------------
;;;;
;;;; Each entry: (display-name x1 y1 x2 y2)
;;;; Coordinates are paper-space points for the MVIEW rectangle.
;;;; Parsed from ViewportLayout.csv (23 title block configurations).

(setq *BR:VP-CONFIGS*
  (list
    (list "TB-AXIA 24x36"        1.187  0.875  25.625  23.125)
    (list "TB-BAR 30x42"         1.775  1.375  31.138  28.625)
    (list "TB-BR 11x17"          1.400  0.900  14.403  10.107)
    (list "TB-BR 22x34"          1.644  1.142  22.780  20.939)
    (list "TB-BR 24X36"          1.865  1.265  24.780  22.735)
    (list "TB-BR 30x42"          1.765  1.465  30.680  28.535)
    (list "TB-BR 36x60"          1.720  1.050  48.725  35.000)
    (list "TB-DAN HARDIN 24x36"  1.837  1.155  24.245  22.825)
    (list "TB-DLM 30x42"         1.228  1.153  34.159  28.889)
    (list "TB-DSA 24x36"         1.845  1.200  24.200  22.780)
    (list "TB-DSA 30x42"         1.725  1.445  30.095  28.575)
    (list "TB-QKA 08x11-ADD"     1.000  1.890   7.660   8.160)
    (list "TB-QKA 11x17-ADD"     0.865  2.015  16.157  10.213)
    (list "TB-QKA 24x36"         1.850  1.252  24.972  22.746)
    (list "TB-QKA 24x36-SD"      1.750  1.750  29.000  21.500)
    (list "TB-QKA 30x42"         2.537  1.437  30.850  28.562)
    (list "TB-QKA 30x42-SD"      6.329  1.750  30.766  27.500)
    (list "TB-SCWA 22x34"        1.500  2.500  33.000  21.000)
    (list "TB-SR 22x34"          1.500  1.000  25.125  21.000)
    (list "TB-TLCD 24x36"        2.000  1.220  23.980  22.780)
    (list "TB-TLCD 30x42"        2.000  1.220  29.850  28.780)
    (list "TB-TOW 24x36"         2.660  5.100  34.340  22.340)
  )
)

;; Default viewport scale: 1"=10' => 1/10 = 0.1
(setq *BR:VP-SCALE* 0.1)


;;;; -- ACCESSORS ----------------------------------------------------

(defun BR:VP:Disp (e) (nth 0 e))   ; display name
(defun BR:VP:X1   (e) (nth 1 e))   ; lower-left X
(defun BR:VP:Y1   (e) (nth 2 e))   ; lower-left Y
(defun BR:VP:X2   (e) (nth 3 e))   ; upper-right X
(defun BR:VP:Y2   (e) (nth 4 e))   ; upper-right Y


;;;; -- VIEWPORT CREATION --------------------------------------------
;;;;
;;;; BR:VP:CreateOnLayouts
;;;;   layouts -- list of layout tab names
;;;;   pt1     -- lower-left corner (list x y)
;;;;   pt2     -- upper-right corner (list x y)
;;;;   scale   -- real number (e.g. 0.1 for 1"=10')

(defun BR:VP:CreateOnLayouts (layouts pt1 pt2 scale / lay prevEnt newEnt vpobj)
  (if (null layouts)
    (princ "\nNo target layouts.")
    (foreach lay layouts
      (setvar "CTAB" lay)
      (setvar "TILEMODE" 0)
      (command "._PSPACE")
      (setvar "CLAYER" "0")
      (setq prevEnt (entlast))
      (command "._MVIEW" pt1 pt2)
      (setq newEnt (entlast))
      (if (and newEnt (/= newEnt prevEnt)
               (eq (cdr (assoc 0 (entget newEnt))) "VIEWPORT"))
        (progn
          (setq vpobj (vlax-ename->vla-object newEnt))
          (vla-put-CustomScale   vpobj scale)
          (vla-put-DisplayLocked vpobj :vlax-true)
          (princ (strcat "\n  Viewport created on layout: " lay))
        )
        (princ (strcat "\nWarning: viewport not created on layout \"" lay "\"."))
      )
    )
  )
)


;;;; -- TARGET LAYOUT HELPERS ----------------------------------------

(defun BR:VP:TargetLayouts (scope / all out lay)
  (cond
    ((= scope "current")
      (setq lay (getvar "CTAB"))
      (if (/= (strcase lay) "MODEL")
        (list lay)
        (progn (princ "\nCurrent tab is MODEL - nothing to do.") nil)
      )
    )
    (T
      (setq all (layoutlist) out '())
      (foreach l all
        (if (/= (strcase l) "MODEL") (setq out (cons l out)))
      )
      (reverse out)
    )
  )
)


;;;; -- SCALE HELPERS ------------------------------------------------

(defun BR:VP:ScaleLabel (sc / val)
  (setq val (/ 1.0 sc))
  (strcat "1\" = " (rtos val 2 0) "'")
)


;;;; -- DCL DIALOG ---------------------------------------------------

(defun BR:VP:UpdatePreview (cfg-idx scale / cfg)
  (if (and (>= cfg-idx 0) (< cfg-idx (length *BR:VP-CONFIGS*)))
    (progn
      (setq cfg (nth cfg-idx *BR:VP-CONFIGS*))
      (set_tile "vp_preview"
        (strcat (BR:VP:Disp cfg)
                "  |  Scale: " (BR:VP:ScaleLabel scale)
                "  |  Rect: ("
                (rtos (BR:VP:X1 cfg) 2 3) ", " (rtos (BR:VP:Y1 cfg) 2 3)
                ") to ("
                (rtos (BR:VP:X2 cfg) 2 3) ", " (rtos (BR:VP:Y2 cfg) 2 3)
                ")"))
    )
    (set_tile "vp_preview" "Select a title block configuration...")
  )
)

(defun BR:ViewportDCL (/ dcl-path dcl-id done d-cfgidx d-scale d-scope
                         d-custom-str cfg pt1 pt2 targets)

  (setq dcl-path (findfile "BR_Viewport.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat "BR_Viewport.dcl not found.\n\n"
                "Make sure BR_Viewport.dcl is in the same folder as the LSP files\n"
                "and that folder is on AutoCAD's support path."))
      (exit)
    )
  )

  (setq d-cfgidx    -1
        d-scale     *BR:VP-SCALE*
        d-scope     "all"
        d-custom-str "10")

  (setq dcl-id (load_dialog dcl-path))
  (if (< dcl-id 0)
    (progn (alert (strcat "Cannot load DCL:\n" dcl-path)) (exit))
  )
  (if (not (new_dialog "br_viewport" dcl-id))
    (progn
      (unload_dialog dcl-id)
      (alert "Cannot initialize br_viewport dialog.")
      (exit)
    )
  )

  ;; Populate title block list
  (start_list "vp_list")
  (foreach cfg *BR:VP-CONFIGS*
    (add_list (BR:VP:Disp cfg))
  )
  (end_list)

  ;; Default scale radio = 1"=10'
  (set_tile "sc_10" "1")

  ;; Default scope = All Layouts
  (set_tile "scope_all" "1")

  ;; Default custom value
  (set_tile "sc_custom_val" "10")

  ;; -- List selection action --------------------------------------
  (action_tile "vp_list"
    (strcat
      "(setq d-cfgidx (BR:DCL:SafeIndex $value))"
      "(BR:VP:UpdatePreview d-cfgidx d-scale)"))

  ;; -- Scale radio actions ----------------------------------------
  (action_tile "sc_10"
    (strcat
      "(setq d-scale 0.1)"
      "(mode_tile \"sc_custom_val\" 1)"
      "(BR:VP:UpdatePreview d-cfgidx d-scale)"))

  (action_tile "sc_20"
    (strcat
      "(setq d-scale 0.05)"
      "(mode_tile \"sc_custom_val\" 1)"
      "(BR:VP:UpdatePreview d-cfgidx d-scale)"))

  (action_tile "sc_40"
    (strcat
      "(setq d-scale 0.025)"
      "(mode_tile \"sc_custom_val\" 1)"
      "(BR:VP:UpdatePreview d-cfgidx d-scale)"))

  (action_tile "sc_50"
    (strcat
      "(setq d-scale 0.02)"
      "(mode_tile \"sc_custom_val\" 1)"
      "(BR:VP:UpdatePreview d-cfgidx d-scale)"))

  (action_tile "sc_custom"
    (strcat
      "(mode_tile \"sc_custom_val\" 0)"
      "(setq d-scale (/ 1.0 (max 1.0 (BR:DCL:SafeReal d-custom-str))))"
      "(BR:VP:UpdatePreview d-cfgidx d-scale)"))

  (action_tile "sc_custom_val"
    (strcat
      "(setq d-custom-str (BR:SafeStr $value))"
      "(if (> (BR:DCL:SafeReal $value) 0.0)"
      "  (setq d-scale (/ 1.0 (BR:DCL:SafeReal $value)))"
      ")"
      "(BR:VP:UpdatePreview d-cfgidx d-scale)"))

  ;; -- Scope radio actions ----------------------------------------
  (action_tile "scope_all"     "(setq d-scope \"all\")")
  (action_tile "scope_current" "(setq d-scope \"current\")")

  ;; -- Accept / Cancel --------------------------------------------
  (action_tile "accept" "(done_dialog 1)")
  (action_tile "cancel" "(done_dialog 0)")

  (setq done (start_dialog))
  (unload_dialog dcl-id)

  ;; -- Act on result ----------------------------------------------
  (if (= done 1)
    (cond
      ((< d-cfgidx 0)
        (alert "Please select a title block configuration first."))
      (T
        (setq cfg     (nth d-cfgidx *BR:VP-CONFIGS*)
              pt1     (list (BR:VP:X1 cfg) (BR:VP:Y1 cfg))
              pt2     (list (BR:VP:X2 cfg) (BR:VP:Y2 cfg))
              targets (BR:VP:TargetLayouts d-scope))
        (if targets
          (progn
            (princ (strcat "\nCreating viewports: " (BR:VP:Disp cfg)
                           "  Scale: " (BR:VP:ScaleLabel d-scale)
                           "  Scope: " d-scope))
            (BR:VP:CreateOnLayouts targets pt1 pt2 d-scale)
            (princ "\nViewport creation complete.")
          )
          (princ "\nNo target layouts found.")
        )
      )
    )
  )
)


;;;; -- COMMAND ------------------------------------------------------

(defun C:BR_VP (/ *error* _olderr _restore
                  oldCtab oldClayer oldTile oldEcho undoStarted)

  (vl-load-com)

  ;; Save system variables
  (setq oldCtab   (getvar "CTAB")
        oldClayer (getvar "CLAYER")
        oldTile   (getvar "TILEMODE")
        oldEcho   (getvar "CMDECHO")
        _olderr   *error*)

  ;; Restore function
  (defun _restore ()
    (if undoStarted (command "._UNDO" "_END"))
    (if oldEcho   (setvar "CMDECHO"  oldEcho))
    (if oldClayer (setvar "CLAYER"   oldClayer))
    (if oldTile   (setvar "TILEMODE" oldTile))
    (if oldCtab   (setvar "CTAB"     oldCtab))
  )

  ;; Error handler
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*")))
      (princ (strcat "\nError: " msg))
    )
    (_restore)
    (setq *error* _olderr)
    (princ)
  )

  ;; Suppress command echo
  (setvar "CMDECHO" 0)

  ;; UNDO group
  (command "._UNDO" "_BEGIN")
  (setq undoStarted T)

  ;; Run dialog
  (BR:ViewportDCL)

  ;; Clean up
  (_restore)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED ------------------------------------------------

(princ "\n  BR_Viewport module loaded.  Command: BR_VP")
(princ)

;;; End of BR_Viewport.lsp
