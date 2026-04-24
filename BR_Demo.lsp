;;; ================================================================
;;; BR_Demo.lsp  |  Brelje & Race CAD Tools  |  Demolition Layer Mgmt
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; Commands:
;;;   BR_DEMO  -- Move selected objects to hidden -DEMO layers
;;;   BR_UNDEMO -- Restore selected objects from -DEMO to original layers
;;;
;;; Demo layers inherit linetype/lineweight from source, map color to
;;; the same pen-weight range per the BR CTB chart, and are created OFF.
;;; ================================================================


;;;; -- DEMO HELPERS --------------------------------------------------

;; Strip a suffix from the end of a string (case-insensitive match).
(defun BR:Demo:StripSuffix (str suffix / len slen)
  (setq len (strlen str) slen (strlen suffix))
  (if (and (> len slen)
           (= (strcase (substr str (1+ (- len slen))))
              (strcase suffix)))
    (substr str 1 (- len slen))
    str
  )
)

;; Map a source color to one in the same CTB pen-weight range.
;; Returns the mapped color, or the original if not in the chart.
(defun BR:Demo:MapColor (src-clr)
  (cond
    ;; 0.0625 mm range
    ((member src-clr '(37)) 37)
    ;; 0.125 mm range
    ((member src-clr '(8 9 49 75 191)) 8)
    ;; 0.175 mm range
    ((member src-clr '(10 13 45 83 175)) 13)
    ;; 0.25 mm range
    ((member src-clr '(11 14 105 205)) 11)
    ;; 0.35 mm range
    ((member src-clr '(12 15 146 235)) 15)
    ;; Fallback -- keep original
    (t src-clr)
  )
)

;; Create a -DEMO layer by copying properties from the source layer.
;; Maps color per CTB chart and creates the layer OFF (negative color).
(defun BR:Demo:CreateFromSource (source-name new-name / src-data lweight ltype clr demo-clr)
  (if (setq src-data (tblsearch "LAYER" source-name))
    (progn
      (setq clr     (abs (cdr (assoc 62 src-data)))
            ltype   (cdr (assoc 6 src-data))
            lweight (cdr (assoc 370 src-data))
            demo-clr (BR:Demo:MapColor clr))
      (entmake
        (append
          (list
            '(0 . "LAYER")
            '(100 . "AcDbSymbolTableRecord")
            '(100 . "AcDbLayerTableRecord")
            (cons 2 new-name)
            '(70 . 0)
            (cons 62 (* demo-clr -1))   ; negative = OFF
            (cons 6 ltype)
          )
          (if (and lweight (>= lweight 0))
            (list (cons 370 lweight))
            nil
          )
        )
      )
    )
    ;; Source layer doesn't exist -- create a default OFF layer
    (entmake
      (list '(0 . "LAYER")
            '(100 . "AcDbSymbolTableRecord")
            '(100 . "AcDbLayerTableRecord")
            (cons 2 new-name)
            '(70 . 0)
            '(62 . -7)
            '(6 . "Continuous")))
  )
)


;;;; -- MOVE TO DEMO --------------------------------------------------

(defun BR:DemoMove (/ ss i ename ent layName targetLay count)
  (setq count 0)
  (princ "\nSelect objects to move to DEMO layers...")
  (if (setq ss (ssget))
    (progn
      (repeat (setq i (sslength ss))
        (setq ename   (ssname ss (setq i (1- i)))
              ent     (entget ename)
              layName (cdr (assoc 8 ent)))
        (if (not (wcmatch (strcase layName) "*-DEMO"))
          (progn
            (setq targetLay (strcat layName "-DEMO"))
            (if (not (tblsearch "LAYER" targetLay))
              (BR:Demo:CreateFromSource layName targetLay)
            )
            (if (vl-catch-all-error-p
                  (vl-catch-all-apply 'entmod
                    (list (subst (cons 8 targetLay) (assoc 8 ent) ent))))
              (princ (strcat "\n  Skipped (locked layer): " layName))
              (setq count (1+ count))
            )
          )
        )
      )
      (princ (strcat "\n  " (itoa count) " object(s) moved to DEMO layers."))
    )
    (princ "\n  No objects selected.")
  )
)


;;;; -- RESTORE FROM DEMO ---------------------------------------------

(defun BR:DemoRestore (/ ss i ename ent layName targetLay count)
  (setq count 0)
  (princ "\nSelect objects to restore from DEMO layers...")
  (if (setq ss (ssget))
    (progn
      (repeat (setq i (sslength ss))
        (setq ename   (ssname ss (setq i (1- i)))
              ent     (entget ename)
              layName (cdr (assoc 8 ent)))
        (if (wcmatch (strcase layName) "*-DEMO")
          (progn
            (setq targetLay (BR:Demo:StripSuffix layName "-DEMO"))
            (if (not (tblsearch "LAYER" targetLay))
              (entmake
                (list '(0 . "LAYER")
                      '(100 . "AcDbSymbolTableRecord")
                      '(100 . "AcDbLayerTableRecord")
                      (cons 2 targetLay)
                      '(70 . 0)
                      '(62 . 7)
                      '(6 . "Continuous")))
            )
            (if (vl-catch-all-error-p
                  (vl-catch-all-apply 'entmod
                    (list (subst (cons 8 targetLay) (assoc 8 ent) ent))))
              (princ (strcat "\n  Skipped (locked layer): " layName))
              (setq count (1+ count))
            )
          )
        )
      )
      (princ (strcat "\n  " (itoa count) " object(s) restored from DEMO layers."))
    )
  )
)


;;;; -- COMMANDS ------------------------------------------------------

(defun C:BR_DEMO (/ *error* _olderr _saved _undoFlag)
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

  (BR:DemoMove)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)

(defun C:BR_UNDEMO (/ *error* _olderr _saved _undoFlag)
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

  (BR:DemoRestore)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED -------------------------------------------------

(princ "\n  BR_Demo module loaded.  Commands: BR_DEMO  BR_UNDEMO")
(princ)

;;; End of BR_Demo.lsp
