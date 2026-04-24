;;; ================================================================
;;; BR_ProjectDB.lsp  |  Brelje & Race CAD Tools  |  Project Database
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_ProjectDB.dcl (dialog name "br_project_db")
;;; Commands: BR_DB (dialog)
;;;
;;; Stores project metadata as JSON in:
;;;   J:\J\{main}\dwg\{main} {sub}\DATA\{proj}_Project_DB.json
;;; ================================================================


;;;; -- CONFIGURATION LISTS ----------------------------------------
;;; Derived from *BR:CFG:* globals loaded by BR_Core.lsp.
;;; Each list prepends "" as the blank/unset first item for popup_lists.

(setq *BR:DB:CONFIGS*  (cons "" *BR:CFG:CONFIGS*))
(setq *BR:DB:TB-SIZES* (cons "" *BR:CFG:TB-SIZES*))
(setq *BR:DB:TB-TYPES* (cons "" *BR:CFG:TB-TYPES*))
(setq *BR:DB:STATUSES* (cons "" *BR:CFG:STATUSES*))


;;;; -- PATH BUILDER -----------------------------------------------

;; Return the DATA directory for a project.
;; Creates it if it does not exist.
(defun BR:DB:DataDir (proj / dir)
  (setq dir (strcat (BR:BaseDir proj) "DATA\\"))
  (if (not (vl-file-directory-p dir))
    (BR:Mkdirp dir)
  )
  dir
)

;; Full path to the project JSON file.
(defun BR:DB:FilePath (proj)
  (strcat (BR:DB:DataDir proj) proj "_Project_DB.json")
)


;;;; -- DEFAULT DATABASE -------------------------------------------

;; Return a fresh association list with empty defaults for a project.
(defun BR:DB:Defaults (proj / parts)
  (setq parts (BR:Split proj "."))
  (list
    (cons "project_number"        (car parts))
    (cons "project_subnumber"     (cadr parts))
    (cons "project_name_long"     "")
    (cons "project_date"          "")
    (cons "project_setup_config"  "")
    (cons "project_setup_tb_size" "")
    (cons "project_setup_tb_type" "")
    (cons "project_apn"           "")
    (cons "project_centroid"      "")
    (cons "project_area"          "")
    (cons "project_area_offset"   "500.0")
    (cons "project_manager"       "")
    (cons "lead_designer"         "")
    (cons "client_name"           "")
    (cons "project_status"        "")
    (cons "permit_number"         "")
    (cons "coordinate_system"     "")
    (cons "vertical_datum"        "")
  )
)

;; Merge parsed data into defaults. Unknown keys in parsed are ignored.
(defun BR:DB:Merge (defaults parsed / key val existing)
  (foreach pair parsed
    (setq key (car pair)
          val (cdr pair))
    (setq existing (assoc key defaults))
    (if (and existing val)
      (setq defaults (subst (cons key val) existing defaults))
    )
  )
  defaults
)


;;;; -- POPUP HELPERS ----------------------------------------------

;; Return the string index of VAL in LST (for set_tile).
;; If not found returns "0" (the blank first item).
(defun BR:DB:PopupIdx (val lst / i found)
  (setq i 0 found nil)
  (setq val (strcase (BR:SafeStr val)))
  (foreach item lst
    (if (and (null found) (= val (strcase item)))
      (setq found i)
    )
    (setq i (1+ i))
  )
  (itoa (if found found 0))
)

;; Populate a popup_list tile from a LISP list.
(defun BR:DB:FillPopup (key lst)
  (start_list key)
  (foreach item lst (add_list item))
  (end_list)
)


;;;; -- DCL DIALOG FLOW --------------------------------------------

;; Write all current state into the dialog tiles.
;; Called on initial open and each time the dialog re-opens after a pick.
;; Accesses dynamic-scope variables from BR:ProjectDBDCL.
(defun BR:DB:TilesToDialog ()
  ;; Project display
  (set_tile "proj_display" (strcat "Project: " d-proj))
  ;; Edit boxes
  (set_tile "proj_name"  (BR:SafeStr (cdr (assoc "project_name_long"     d-db))))
  (set_tile "proj_date"  (BR:SafeStr (cdr (assoc "project_date"          d-db))))
  (set_tile "manager"    (BR:SafeStr (cdr (assoc "project_manager"       d-db))))
  (set_tile "designer"   (BR:SafeStr (cdr (assoc "lead_designer"         d-db))))
  (set_tile "client"     (BR:SafeStr (cdr (assoc "client_name"           d-db))))
  (set_tile "apn"        (BR:SafeStr (cdr (assoc "project_apn"           d-db))))
  (set_tile "permit"     (BR:SafeStr (cdr (assoc "permit_number"         d-db))))
  (set_tile "offset"     (BR:SafeStr (cdr (assoc "project_area_offset"   d-db))))
  (set_tile "coord_sys"  (BR:SafeStr (cdr (assoc "coordinate_system"     d-db))))
  (set_tile "vert_datum" (BR:SafeStr (cdr (assoc "vertical_datum"        d-db))))
  ;; Popup lists
  (BR:DB:FillPopup "status"  *BR:DB:STATUSES*)
  (BR:DB:FillPopup "config"  *BR:DB:CONFIGS*)
  (BR:DB:FillPopup "tb_size" *BR:DB:TB-SIZES*)
  (BR:DB:FillPopup "tb_type" *BR:DB:TB-TYPES*)
  (set_tile "status"  (BR:DB:PopupIdx (cdr (assoc "project_status"        d-db)) *BR:DB:STATUSES*))
  (set_tile "config"  (BR:DB:PopupIdx (cdr (assoc "project_setup_config"  d-db)) *BR:DB:CONFIGS*))
  (set_tile "tb_size" (BR:DB:PopupIdx (cdr (assoc "project_setup_tb_size" d-db)) *BR:DB:TB-SIZES*))
  (set_tile "tb_type" (BR:DB:PopupIdx (cdr (assoc "project_setup_tb_type" d-db)) *BR:DB:TB-TYPES*))
  ;; GIS display
  (set_tile "centroid_val"
    (if (> (strlen (BR:SafeStr (cdr (assoc "project_centroid" d-db)))) 0)
      (strcat "Centroid: " (cdr (assoc "project_centroid" d-db)))
      "Centroid: (not set)"))
  (set_tile "area_val"
    (if (> (strlen (BR:SafeStr (cdr (assoc "project_area" d-db)))) 0)
      (strcat "Area: " (cdr (assoc "project_area" d-db)))
      "Area: (not set)"))
  ;; File path
  (set_tile "file_path" (strcat "File: " d-path))
)

;; Read the current tile values back into the d-db association list.
;; Called before dialog close (save) and before pick operations.
(defun BR:DB:DialogToDB (/ idx)
  ;; Edit boxes
  (setq d-db (subst (cons "project_name_long"     (get_tile "proj_name"))  (assoc "project_name_long"     d-db) d-db))
  (setq d-db (subst (cons "project_date"          (get_tile "proj_date"))  (assoc "project_date"          d-db) d-db))
  (setq d-db (subst (cons "project_manager"       (get_tile "manager"))    (assoc "project_manager"       d-db) d-db))
  (setq d-db (subst (cons "lead_designer"         (get_tile "designer"))   (assoc "lead_designer"         d-db) d-db))
  (setq d-db (subst (cons "client_name"           (get_tile "client"))     (assoc "client_name"           d-db) d-db))
  (setq d-db (subst (cons "project_apn"           (get_tile "apn"))        (assoc "project_apn"           d-db) d-db))
  (setq d-db (subst (cons "permit_number"         (get_tile "permit"))     (assoc "permit_number"         d-db) d-db))
  (setq d-db (subst (cons "project_area_offset"   (get_tile "offset"))     (assoc "project_area_offset"   d-db) d-db))
  (setq d-db (subst (cons "coordinate_system"     (get_tile "coord_sys"))  (assoc "coordinate_system"     d-db) d-db))
  (setq d-db (subst (cons "vertical_datum"        (get_tile "vert_datum")) (assoc "vertical_datum"        d-db) d-db))
  ;; Popup lists (convert index back to text)
  (setq idx (BR:DCL:SafeIndex (get_tile "status")))
  (if (and (>= idx 0) (< idx (length *BR:DB:STATUSES*)))
    (setq d-db (subst (cons "project_status" (nth idx *BR:DB:STATUSES*)) (assoc "project_status" d-db) d-db))
  )
  (setq idx (BR:DCL:SafeIndex (get_tile "config")))
  (if (and (>= idx 0) (< idx (length *BR:DB:CONFIGS*)))
    (setq d-db (subst (cons "project_setup_config" (nth idx *BR:DB:CONFIGS*)) (assoc "project_setup_config" d-db) d-db))
  )
  (setq idx (BR:DCL:SafeIndex (get_tile "tb_size")))
  (if (and (>= idx 0) (< idx (length *BR:DB:TB-SIZES*)))
    (setq d-db (subst (cons "project_setup_tb_size" (nth idx *BR:DB:TB-SIZES*)) (assoc "project_setup_tb_size" d-db) d-db))
  )
  (setq idx (BR:DCL:SafeIndex (get_tile "tb_type")))
  (if (and (>= idx 0) (< idx (length *BR:DB:TB-TYPES*)))
    (setq d-db (subst (cons "project_setup_tb_type" (nth idx *BR:DB:TB-TYPES*)) (assoc "project_setup_tb_type" d-db) d-db))
  )
)


;;;; -- MAIN DIALOG ------------------------------------------------

(defun BR:ProjectDBDCL (/ dcl-path dcl-id action
                          d-proj d-path d-db parsed
                          pt p1 p2 cstr astr)

  ;; -- Determine project number -----------------------------------
  (setq d-proj (BR:DetectProj))
  (if (null d-proj) (setq d-proj ""))

  ;; If no project detected, prompt
  (if (= d-proj "")
    (progn
      (setq d-proj (getstring "\n  Project number (####.##): "))
      (if (not (BR:ValidProj? d-proj))
        (progn
          (alert
            (strcat "Invalid project number.\n\n"
                    "Required format: ####.##\n"
                    "Example: 5212.00"))
          (exit)
        )
      )
    )
  )

  ;; -- Build path and load/create DB ------------------------------
  (setq d-path (BR:DB:FilePath d-proj))
  (setq d-db   (BR:DB:Defaults d-proj))

  (if (findfile d-path)
    (progn
      (princ (strcat "\n  Reading: " d-path))
      (setq parsed (BR:ReadJSON d-path))
      (if parsed
        (setq d-db (BR:DB:Merge d-db parsed))
        (princ "\n  [WARN] Could not parse JSON -- using defaults.")
      )
    )
    (princ (strcat "\n  New DB will be created at: " d-path))
  )

  ;; -- Locate DCL -------------------------------------------------
  (setq dcl-path (findfile "BR_ProjectDB.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat "BR_ProjectDB.dcl not found.\n\n"
                "Make sure it is in the same folder as the LSP files\n"
                "and that folder is on AutoCAD's support path."))
      (exit)
    )
  )

  ;; -- Dialog loop (re-opens after graphical picks) ---------------
  ;; Return codes: 0=cancel, 1=save, 2=pick centroid, 3=pick area
  (setq action 2)  ;; seed to enter loop

  (while (> action 1)

    ;; Open dialog
    (setq dcl-id (load_dialog dcl-path))
    (if (< dcl-id 0)
      (progn (alert (strcat "Cannot load DCL:\n" dcl-path)) (exit))
    )
    (if (not (new_dialog "br_project_db" dcl-id))
      (progn
        (unload_dialog dcl-id)
        (alert "Cannot initialize br_project_db dialog.")
        (exit)
      )
    )

    ;; Populate tiles from current state
    (BR:DB:TilesToDialog)

    ;; Bind actions
    (action_tile "accept"
      "(BR:DB:DialogToDB) (done_dialog 1)")
    (action_tile "cancel" "(done_dialog 0)")
    (action_tile "pick_centroid"
      "(BR:DB:DialogToDB) (done_dialog 2)")
    (action_tile "pick_area"
      "(BR:DB:DialogToDB) (done_dialog 3)")

    (setq action (start_dialog))
    (unload_dialog dcl-id)

    ;; -- Handle graphical picks -----------------------------------
    (cond
      ;; Pick centroid
      ((= action 2)
       (setq pt (getpoint "\n  Pick project center point: "))
       (if pt
         (progn
           (setq cstr (strcat (rtos (car pt) 2 4) ","
                              (rtos (cadr pt) 2 4)))
           (setq d-db (subst (cons "project_centroid" cstr)
                             (assoc "project_centroid" d-db) d-db))
           (princ (strcat "\n  Centroid set: " cstr))
         )
         (princ "\n  No point selected -- centroid unchanged.")
       )
      )

      ;; Pick area (two corners)
      ((= action 3)
       (setq p1 (getpoint "\n  Pick first corner of project area: "))
       (if p1
         (progn
           (setq p2 (getcorner p1 "\n  Pick opposite corner: "))
           (if p2
             (progn
               (setq astr
                 (strcat (rtos (min (car p1) (car p2)) 2 4) ","
                         (rtos (min (cadr p1) (cadr p2)) 2 4) "|"
                         (rtos (max (car p1) (car p2)) 2 4) ","
                         (rtos (max (cadr p1) (cadr p2)) 2 4)))
               (setq d-db (subst (cons "project_area" astr)
                                 (assoc "project_area" d-db) d-db))
               (princ (strcat "\n  Area set: " astr))
             )
             (princ "\n  No opposite corner -- area unchanged.")
           )
         )
         (princ "\n  No first corner -- area unchanged.")
       )
      )
    ) ;; cond
  ) ;; while

  ;; -- Save or cancel ---------------------------------------------
  (if (= action 1)
    (progn
      (if (BR:WriteJSON d-path d-db)
        (princ (strcat "\n  Saved: " d-path))
        (alert (strcat "Failed to write file:\n" d-path))
      )
    )
    (princ "\n  Cancelled -- no changes saved.")
  )
)


;;;; -- COMMANDS ---------------------------------------------------

(defun C:BR_DB (/ *error* _olderr _saved _undoFlag)
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

  (BR:ProjectDBDCL)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED ----------------------------------------------

(princ "\n  BR_ProjectDB module loaded.  Command: BR_DB")
(princ)

;;; End of BR_ProjectDB.lsp
