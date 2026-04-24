;;; ================================================================
;;; BR_SheetSet.lsp  |  Brelje & Race CAD Tools  |  Sheet Set DB
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_SheetSet.dcl (dialog name "br_sheetset")
;;; Commands: BR_SHEETSET, BR_SS
;;;
;;; Stores project sheet set metadata as flat JSON in:
;;;   J:\J\{main}\dwg\{main} {sub}\DATA\{proj}_SheetSet.json
;;;
;;; Saved DSD files are used only as an import/reference source for
;;; DWG, layout, sheet names, and page setups. Custom sheet index data
;;; lives here.
;;; ================================================================


;;;; -- CONFIGURATION ----------------------------------------------

(setq *BR:SS:SCHEMA* "BR_SheetSet_v1")
(setq *BR:SS:SHEET-FIELDS*
  '("include"
    "sheet_number"
    "sheet_title"
    "cad_sheet_name"
    "dwg_path"
    "layout_name"
    "page_setup"
    "original_sheet_path"
    "discipline"
    "index_group"
    "issue_status"
    "revision"
    "remarks"))


;;;; -- PATHS ------------------------------------------------------

(defun BR:SS:DataDir (proj)
  (BR:DataDir proj)
)

(defun BR:SS:FilePath (proj)
  (strcat (BR:SS:DataDir proj) proj "_SheetSet.json")
)

(defun BR:SS:IndexPath (proj)
  (strcat (BR:SS:DataDir proj) proj "_SheetIndex.csv")
)

(defun BR:SS:SheetKey (idx field)
  (strcat "sheet_" (BR:PadL (itoa idx) 3 "0") "_" field)
)


;;;; -- ALIST HELPERS ----------------------------------------------

(defun BR:SS:Get (alist key)
  (BR:SafeStr (cdr (assoc key alist)))
)

(defun BR:SS:Put (alist key val / pair)
  (setq val (BR:SafeStr val))
  (if (setq pair (assoc key alist))
    (subst (cons key val) pair alist)
    (append alist (list (cons key val)))
  )
)

(defun BR:SS:SheetGet (sheet key)
  (BR:SS:Get sheet key)
)

(defun BR:SS:SheetPut (sheet key val)
  (BR:SS:Put sheet key val)
)

(defun BR:SS:DefaultMeta (proj)
  (list
    (cons "schema" *BR:SS:SCHEMA*)
    (cons "project_number" proj)
    (cons "sheetset_name" (strcat proj " Sheet Set"))
    (cons "source_dsd" "")
    (cons "updated" "")
    (cons "notes" ""))
)

(defun BR:SS:MergeMeta (meta parsed / key val pair)
  (foreach key '("schema" "project_number" "sheetset_name" "source_dsd" "updated" "notes")
    (setq val (cdr (assoc key parsed)))
    (if val
      (progn
        (setq pair (assoc key meta))
        (setq meta (subst (cons key val) pair meta))
      )
    )
  )
  meta
)


;;;; -- FLAT JSON READ / WRITE -------------------------------------

(defun BR:SS:SheetFromFlat (flat idx / sheet field)
  (setq sheet nil)
  (foreach field *BR:SS:SHEET-FIELDS*
    (setq sheet
      (append sheet
        (list (cons field (BR:SS:Get flat (BR:SS:SheetKey idx field))))))
  )
  sheet
)

(defun BR:SS:LoadState (path proj / parsed meta sheets count idx)
  (setq meta   (BR:SS:DefaultMeta proj)
        sheets nil)
  (if (findfile path)
    (progn
      (setq parsed (BR:ReadJSON path))
      (if parsed
        (progn
          (setq meta (BR:SS:MergeMeta meta parsed))
          (setq count (atoi (BR:SS:Get parsed "sheet_count")))
          (setq idx 1)
          (while (<= idx count)
            (setq sheets (append sheets (list (BR:SS:SheetFromFlat parsed idx))))
            (setq idx (1+ idx))
          )
        )
      )
    )
  )
  (list meta sheets)
)

(defun BR:SS:StateToFlat (meta sheets / flat idx sheet field)
  (setq flat nil)
  (foreach pair meta
    (setq flat (append flat (list pair)))
  )
  (setq flat (BR:SS:Put flat "schema" *BR:SS:SCHEMA*))
  (setq flat (BR:SS:Put flat "sheet_count" (itoa (length sheets))))
  (setq idx 1)
  (foreach sheet sheets
    (foreach field *BR:SS:SHEET-FIELDS*
      (setq flat
        (BR:SS:Put flat
          (BR:SS:SheetKey idx field)
          (BR:SS:SheetGet sheet field)))
    )
    (setq idx (1+ idx))
  )
  flat
)

(defun BR:SS:SaveState (path meta sheets)
  (BR:WriteJSON path (BR:SS:StateToFlat meta sheets))
)


;;;; -- DSD PARSING ------------------------------------------------

(defun BR:SS:StartsWith (s prefix)
  (setq s (BR:SafeStr s)
        prefix (BR:SafeStr prefix))
  (and (<= (strlen prefix) (strlen s))
       (= (substr s 1 (strlen prefix)) prefix))
)

(defun BR:SS:EndsWith (s suffix / start)
  (setq s (BR:SafeStr s)
        suffix (BR:SafeStr suffix))
  (if (> (strlen suffix) (strlen s))
    nil
    (progn
      (setq start (+ (- (strlen s) (strlen suffix)) 1))
      (= (substr s start) suffix)
    )
  )
)

(defun BR:SS:LineValue (line key / prefix)
  (setq prefix (strcat key "="))
  (if (BR:SS:StartsWith (strcase (BR:SafeStr line)) (strcase prefix))
    (substr line (1+ (strlen prefix)))
    nil
  )
)

(defun BR:SS:SectionName (line)
  (setq line (BR:SafeStr line))
  (if (and (BR:SS:StartsWith line "[")
           (BR:SS:EndsWith line "]")
           (> (strlen line) 2))
    (substr line 2 (- (strlen line) 2))
    nil
  )
)

(defun BR:SS:SheetHeader? (line)
  (and (BR:SS:StartsWith line "[DWF6Sheet:")
       (BR:SS:EndsWith line "]"))
)

(defun BR:SS:SheetNameFromHeader (line / section prefix)
  (setq section (BR:SS:SectionName line)
        prefix  "DWF6Sheet:")
  (if (and section (BR:SS:StartsWith section prefix))
    (substr section (1+ (strlen prefix)))
    (BR:SafeStr section)
  )
)

(defun BR:SS:ReadLines (path / fp line lines)
  (setq fp (open path "r")
        lines nil)
  (if fp
    (progn
      (while (setq line (read-line fp))
        (setq lines (cons line lines))
      )
      (close fp)
      (reverse lines)
    )
    nil
  )
)

(defun BR:SS:ParseName (name / pos)
  (setq name (vl-string-trim " " (BR:SafeStr name)))
  (setq pos (vl-string-search " " name))
  (if pos
    (list
      (substr name 1 pos)
      (vl-string-trim " " (substr name (+ pos 2))))
    (list name "")
  )
)

(defun BR:SS:ParseDSDSheets (lines / sheets idx line name start dwg layout setup original)
  (setq sheets nil
        idx    0
        name   nil
        start  nil
        dwg    ""
        layout ""
        setup  ""
        original "")
  (foreach line lines
    (if (BR:SS:SheetHeader? line)
      (progn
        (if name
          (setq sheets
            (cons
              (list
                (cons "name" name)
                (cons "dwg" dwg)
                (cons "layout" layout)
                (cons "setup" setup)
                (cons "original" original))
              sheets))
        )
        (setq name     (BR:SS:SheetNameFromHeader line)
              start    idx
              dwg      ""
              layout   ""
              setup    ""
              original "")
      )
      (if name
        (progn
          (if (BR:SS:LineValue line "DWG")
            (setq dwg (BR:SS:LineValue line "DWG"))
          )
          (if (BR:SS:LineValue line "Layout")
            (setq layout (BR:SS:LineValue line "Layout"))
          )
          (if (BR:SS:LineValue line "Setup")
            (setq setup (BR:SS:LineValue line "Setup"))
          )
          (if (BR:SS:LineValue line "OriginalSheetPath")
            (setq original (BR:SS:LineValue line "OriginalSheetPath"))
          )
        )
      )
    )
    (setq idx (1+ idx))
  )
  (if name
    (setq sheets
      (cons
        (list
          (cons "name" name)
          (cons "dwg" dwg)
          (cons "layout" layout)
          (cons "setup" setup)
          (cons "original" original))
        sheets))
  )
  (reverse sheets)
)

(defun BR:SS:FindDSDFiles (proj / dir names result upper)
  (setq dir (BR:SS:DataDir proj)
        result nil)
  (if (and dir (vl-file-directory-p dir))
    (progn
      (setq names (vl-sort (vl-directory-files dir "*.dsd" 1) '<))
      (foreach name names
        (setq upper (strcase name))
        (if (not (member upper '("BR_PUBLISH_RUN.DSD" "BR_PUBLISH_LASTRUN.DSD")))
          (setq result (append result (list (strcat dir name))))
        )
      )
    )
  )
  result
)


;;;; -- IMPORT / MERGE ---------------------------------------------

(defun BR:SS:MatchKey (sheet)
  (strcat (strcase (BR:SS:SheetGet sheet "dwg_path"))
          "|"
          (strcase (BR:SS:SheetGet sheet "layout_name")))
)

(defun BR:SS:ExistingByKey (sheets key / found)
  (setq found nil)
  (foreach sheet sheets
    (if (and (null found) (= (BR:SS:MatchKey sheet) key))
      (setq found sheet)
    )
  )
  found
)

(defun BR:SS:FromDSDSheet (dsd-sheet existing / parsed sheet)
  (setq parsed (BR:SS:ParseName (BR:SS:Get dsd-sheet "name")))
  (setq sheet
    (list
      (cons "include" "1")
      (cons "sheet_number" (car parsed))
      (cons "sheet_title" (cadr parsed))
      (cons "cad_sheet_name" (BR:SS:Get dsd-sheet "name"))
      (cons "dwg_path" (BR:SS:Get dsd-sheet "dwg"))
      (cons "layout_name" (BR:SS:Get dsd-sheet "layout"))
      (cons "page_setup" (BR:SS:Get dsd-sheet "setup"))
      (cons "original_sheet_path" (BR:SS:Get dsd-sheet "original"))
      (cons "discipline" "")
      (cons "index_group" "")
      (cons "issue_status" "")
      (cons "revision" "")
      (cons "remarks" "")))
  ;; Preserve custom index fields when the DWG/layout still matches.
  (if existing
    (foreach field '("include" "sheet_number" "sheet_title"
                     "discipline" "index_group" "issue_status"
                     "revision" "remarks")
      (setq sheet (BR:SS:SheetPut sheet field (BR:SS:SheetGet existing field)))
    )
  )
  sheet
)

(defun BR:SS:ImportDSD (dsd-path existing-sheets / lines dsd-sheets result imported key existing)
  (setq lines (BR:SS:ReadLines dsd-path))
  (if (null lines)
    nil
    (progn
      (setq dsd-sheets (BR:SS:ParseDSDSheets lines)
            result nil)
      (foreach imported dsd-sheets
        (setq key
          (strcat (strcase (BR:SS:Get imported "dwg"))
                  "|"
                  (strcase (BR:SS:Get imported "layout"))))
        (setq existing (BR:SS:ExistingByKey existing-sheets key))
        (setq result
          (append result
            (list (BR:SS:FromDSDSheet imported existing))))
      )
      result
    )
  )
)


;;;; -- DIALOG HELPERS ---------------------------------------------

(defun BR:SS:SheetDisplay (sheet / inc num title group)
  (setq inc   (if (= (BR:SS:SheetGet sheet "include") "0") " " "x")
        num   (BR:SS:SheetGet sheet "sheet_number")
        title (BR:SS:SheetGet sheet "sheet_title")
        group (BR:SS:SheetGet sheet "index_group"))
  (strcat "[" inc "] "
          num
          (if (> (strlen title) 0) (strcat "  " title) "")
          (if (> (strlen group) 0) (strcat "  {" group "}") ""))
)

(defun BR:SS:FillSheetList (/ idx)
  (start_list "sheet_list")
  (foreach sheet d-sheets
    (add_list (BR:SS:SheetDisplay sheet))
  )
  (end_list)
  (setq idx (if d-current d-current 0))
  (if (and d-sheets (< idx (length d-sheets)))
    (set_tile "sheet_list" (itoa idx))
  )
  (set_tile "sheet_count" (strcat "Sheets: " (itoa (length d-sheets))))
)

(defun BR:SS:CurrentSheet ()
  (if (and d-sheets d-current (>= d-current 0) (< d-current (length d-sheets)))
    (nth d-current d-sheets)
    nil
  )
)

(defun BR:SS:ReplaceCurrent (sheet / idx result)
  (setq idx 0 result nil)
  (foreach item d-sheets
    (if (= idx d-current)
      (setq result (append result (list sheet)))
      (setq result (append result (list item)))
    )
    (setq idx (1+ idx))
  )
  (setq d-sheets result)
)

(defun BR:SS:SheetToTiles (/ sheet)
  (setq sheet (BR:SS:CurrentSheet))
  (if sheet
    (progn
      (set_tile "include" (if (= (BR:SS:SheetGet sheet "include") "0") "0" "1"))
      (set_tile "sheet_number" (BR:SS:SheetGet sheet "sheet_number"))
      (set_tile "sheet_title"  (BR:SS:SheetGet sheet "sheet_title"))
      (set_tile "discipline"   (BR:SS:SheetGet sheet "discipline"))
      (set_tile "index_group"  (BR:SS:SheetGet sheet "index_group"))
      (set_tile "issue_status" (BR:SS:SheetGet sheet "issue_status"))
      (set_tile "revision"     (BR:SS:SheetGet sheet "revision"))
      (set_tile "remarks"      (BR:SS:SheetGet sheet "remarks"))
      (set_tile "cad_name"     (strcat "CAD sheet: " (BR:SS:SheetGet sheet "cad_sheet_name")))
      (set_tile "dwg_path"     (strcat "DWG: " (BR:SS:SheetGet sheet "dwg_path")))
      (set_tile "layout_name"  (strcat "Layout: " (BR:SS:SheetGet sheet "layout_name")))
      (set_tile "page_setup"   (strcat "Page setup: " (BR:SS:SheetGet sheet "page_setup")))
    )
    (progn
      (set_tile "include" "0")
      (set_tile "sheet_number" "")
      (set_tile "sheet_title" "")
      (set_tile "discipline" "")
      (set_tile "index_group" "")
      (set_tile "issue_status" "")
      (set_tile "revision" "")
      (set_tile "remarks" "")
      (set_tile "cad_name" "CAD sheet:")
      (set_tile "dwg_path" "DWG:")
      (set_tile "layout_name" "Layout:")
      (set_tile "page_setup" "Page setup:")
    )
  )
)

(defun BR:SS:TilesToSheet (/ sheet)
  (setq sheet (BR:SS:CurrentSheet))
  (if sheet
    (progn
      (setq sheet (BR:SS:SheetPut sheet "include" (if (= (get_tile "include") "1") "1" "0")))
      (setq sheet (BR:SS:SheetPut sheet "sheet_number" (get_tile "sheet_number")))
      (setq sheet (BR:SS:SheetPut sheet "sheet_title"  (get_tile "sheet_title")))
      (setq sheet (BR:SS:SheetPut sheet "discipline"   (get_tile "discipline")))
      (setq sheet (BR:SS:SheetPut sheet "index_group"  (get_tile "index_group")))
      (setq sheet (BR:SS:SheetPut sheet "issue_status" (get_tile "issue_status")))
      (setq sheet (BR:SS:SheetPut sheet "revision"     (get_tile "revision")))
      (setq sheet (BR:SS:SheetPut sheet "remarks"      (get_tile "remarks")))
      (BR:SS:ReplaceCurrent sheet)
    )
  )
)

(defun BR:SS:MetaToTiles ()
  (set_tile "proj_display" (strcat "Project: " d-proj))
  (set_tile "sheetset_name" (BR:SS:Get d-meta "sheetset_name"))
  (set_tile "notes" (BR:SS:Get d-meta "notes"))
  (set_tile "source_dsd" (strcat "Source DSD: " (BR:SS:Get d-meta "source_dsd")))
  (set_tile "file_path" (strcat "File: " d-path))
)

(defun BR:SS:TilesToMeta ()
  (setq d-meta (BR:SS:Put d-meta "sheetset_name" (get_tile "sheetset_name")))
  (setq d-meta (BR:SS:Put d-meta "notes" (get_tile "notes")))
)

(defun BR:SS:SelectAll (/ result)
  (BR:SS:TilesToSheet)
  (setq result nil)
  (foreach sheet d-sheets
    (setq result (append result (list (BR:SS:SheetPut sheet "include" "1"))))
  )
  (setq d-sheets result)
  (BR:SS:FillSheetList)
  (BR:SS:SheetToTiles)
)

(defun BR:SS:SelectNone (/ result)
  (BR:SS:TilesToSheet)
  (setq result nil)
  (foreach sheet d-sheets
    (setq result (append result (list (BR:SS:SheetPut sheet "include" "0"))))
  )
  (setq d-sheets result)
  (BR:SS:FillSheetList)
  (BR:SS:SheetToTiles)
)

(defun BR:SS:PickSheet (idx)
  (BR:SS:TilesToSheet)
  (if (and (>= idx 0) (< idx (length d-sheets)))
    (setq d-current idx)
  )
  (BR:SS:FillSheetList)
  (BR:SS:SheetToTiles)
)


;;;; -- INDEX EXPORT -----------------------------------------------

(defun BR:SS:CSV (txt / result i ch)
  (setq txt (BR:SafeStr txt)
        result "\""
        i 1)
  (while (<= i (strlen txt))
    (setq ch (substr txt i 1))
    (if (= ch "\"")
      (setq result (strcat result "\"\""))
      (setq result (strcat result ch))
    )
    (setq i (1+ i))
  )
  (strcat result "\"")
)

(defun BR:SS:WriteIndexCSV (path sheets / fp sheet first)
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "Include,Number,Title,Discipline,Group,Status,Revision,Remarks,DWG,Layout" fp)
      (foreach sheet sheets
        (write-line
          (strcat
            (BR:SS:CSV (BR:SS:SheetGet sheet "include")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "sheet_number")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "sheet_title")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "discipline")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "index_group")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "issue_status")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "revision")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "remarks")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "dwg_path")) ","
            (BR:SS:CSV (BR:SS:SheetGet sheet "layout_name")))
          fp)
      )
      (close fp)
      T
    )
    nil
  )
)


;;;; -- MAIN DIALOG ------------------------------------------------

(defun BR:SheetSetDCL (/ dcl-path dcl-id action state parsed
                         d-proj d-path d-meta d-sheets d-current
                         dsd-path imported csv-path)

  (setq d-proj (BR:DetectProj))
  (if (null d-proj) (setq d-proj ""))

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

  (setq d-path (BR:SS:FilePath d-proj))
  (setq state (BR:SS:LoadState d-path d-proj))
  (setq d-meta (car state)
        d-sheets (cadr state)
        d-current 0)

  (setq dcl-path (findfile "BR_SheetSet.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat "BR_SheetSet.dcl not found.\n\n"
                "Make sure it is in the same folder as the LSP files\n"
                "and that folder is on AutoCAD's support path."))
      (exit)
    )
  )

  ;; Return codes: 0=cancel, 1=save, 2=import DSD, 3=export index CSV
  (setq action 2)
  (while (> action 1)
    (setq dcl-id (load_dialog dcl-path))
    (if (< dcl-id 0)
      (progn (alert (strcat "Cannot load DCL:\n" dcl-path)) (exit))
    )
    (if (not (new_dialog "br_sheetset" dcl-id))
      (progn
        (unload_dialog dcl-id)
        (alert "Cannot initialize br_sheetset dialog.")
        (exit)
      )
    )

    (BR:SS:MetaToTiles)
    (BR:SS:FillSheetList)
    (BR:SS:SheetToTiles)

    (action_tile "sheet_list" "(BR:SS:PickSheet (BR:DCL:SafeIndex $value))")
    (action_tile "btn_all" "(BR:SS:SelectAll)")
    (action_tile "btn_none" "(BR:SS:SelectNone)")
    (action_tile "import_dsd" "(BR:SS:TilesToMeta)(BR:SS:TilesToSheet)(done_dialog 2)")
    (action_tile "export_index" "(BR:SS:TilesToMeta)(BR:SS:TilesToSheet)(done_dialog 3)")
    (action_tile "accept" "(BR:SS:TilesToMeta)(BR:SS:TilesToSheet)(done_dialog 1)")
    (action_tile "cancel" "(done_dialog 0)")

    (setq action (start_dialog))
    (unload_dialog dcl-id)

    (cond
      ((= action 2)
       (setq dsd-path
         (getfiled
           "Select DSD to import"
           (BR:SS:DataDir d-proj)
           "dsd"
           0))
       (if dsd-path
         (progn
           (setq imported (BR:SS:ImportDSD dsd-path d-sheets))
           (if imported
             (progn
               (setq d-sheets imported)
               (setq d-current 0)
               (setq d-meta (BR:SS:Put d-meta "source_dsd" dsd-path))
               (setq d-meta
                 (BR:SS:Put d-meta "updated"
                   (menucmd "M=$(edtime,$(getvar,date),YYYY-MO-DD HH:MM:SS)")))
               (princ (strcat "\n  Imported " (itoa (length d-sheets)) " sheet(s)."))
             )
             (alert (strcat "No sheets could be imported from:\n" dsd-path))
           )
         )
       )
      )
      ((= action 3)
       (setq csv-path (BR:SS:IndexPath d-proj))
       (if (BR:SS:WriteIndexCSV csv-path d-sheets)
         (princ (strcat "\n  Sheet index exported: " csv-path))
         (alert (strcat "Failed to write sheet index:\n" csv-path))
       )
      )
    )
  )

  (if (= action 1)
    (progn
      (setq d-meta
        (BR:SS:Put d-meta "updated"
          (menucmd "M=$(edtime,$(getvar,date),YYYY-MO-DD HH:MM:SS)")))
      (if (BR:SS:SaveState d-path d-meta d-sheets)
        (princ (strcat "\n  Saved: " d-path))
        (alert (strcat "Failed to write sheet set:\n" d-path))
      )
    )
    (princ "\n  Cancelled -- no changes saved.")
  )
)


;;;; -- COMMANDS ---------------------------------------------------

(defun C:BR_SHEETSET (/ *error* _olderr _saved _undoFlag)
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

  (BR:SheetSetDCL)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)

(defun C:BR_SS (/)
  (C:BR_SHEETSET)
)


;;;; -- MODULE LOADED ----------------------------------------------

(princ "\n  BR_SheetSet module loaded.  Commands: BR_SHEETSET  BR_SS")
(princ)

;;; End of BR_SheetSet.lsp
