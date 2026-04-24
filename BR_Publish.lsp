;;; ================================================================
;;; BR_Publish.lsp  |  Brelje & Race CAD Tools  |  Batch Publish
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_Publish.dcl (dialog name "br_publish")
;;; Command:  BR_PUB
;;;
;;; Primary method: uses a saved DSD file from the project DATA folder.
;;; The saved DSD provides the sheet list and page setup information.
;;; ================================================================

(vl-load-com)

;;;; -- GLOBALS ----------------------------------------------------

(setq *BR:PUB-LAYOUTS*    nil)
(setq *BR:PUB-SHEETS*     nil)
(setq *BR:PUB-DSD-FILES*  nil)
(setq *BR:PUB-DSD-IDX*    0)
(setq *BR:PUB-DSD-PATH*   nil)
(setq *BR:PUB-DSD-LINES*  nil)
(setq *BR:PUB-SELECTED*   nil)
(setq *BR:PUB-FORMAT*     "PDF")
(setq *BR:PUB-DEST*       "MARKUPS")
(setq *BR:PUB-DESC*       "")
(setq *BR:MARKUPS-ROOT*   "J:\\Markups\\")
(setq *BR:T-ROOT*         "J:\\T\\")


;;;; -- UTILITY: Parse space-delimited index string ----------------

(defun BR:PUB:ParseIndices (s / result)
  (if (and s (/= s ""))
    (progn
      (setq result (vl-catch-all-apply
                     'read
                     (list (strcat "(" s ")"))))
      (if (vl-catch-all-error-p result) nil result)
    )
  )
)

(defun BR:PUB:StartsWith (s prefix)
  (setq s (BR:SafeStr s)
        prefix (BR:SafeStr prefix))
  (and (<= (strlen prefix) (strlen s))
       (= (substr s 1 (strlen prefix)) prefix))
)

(defun BR:PUB:EndsWith (s suffix / start)
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

(defun BR:PUB:Trim (s)
  (vl-string-trim " \t\r\n" (BR:SafeStr s))
)

(defun BR:PUB:LineValue (line key / prefix)
  (setq prefix (strcat key "="))
  (if (BR:PUB:StartsWith (strcase (BR:SafeStr line)) (strcase prefix))
    (substr line (1+ (strlen prefix)))
    nil
  )
)

(defun BR:PUB:SectionName (line)
  (setq line (BR:SafeStr line))
  (if (and (BR:PUB:StartsWith line "[")
           (BR:PUB:EndsWith line "]")
           (> (strlen line) 2))
    (substr line 2 (- (strlen line) 2))
    nil
  )
)

(defun BR:PUB:SheetHeader? (line)
  (and (BR:PUB:StartsWith line "[DWF6Sheet:")
       (BR:PUB:EndsWith line "]"))
)

(defun BR:PUB:SheetNameFromHeader (line / section prefix)
  (setq section (BR:PUB:SectionName line)
        prefix  "DWF6Sheet:")
  (if (and section (BR:PUB:StartsWith section prefix))
    (substr section (1+ (strlen prefix)))
    (BR:SafeStr section)
  )
)


;;;; -- UTILITY: DSD FILES -----------------------------------------

(defun BR:PUB:GeneratedDSD? (name / upper)
  (setq upper (strcase (BR:SafeStr name)))
  (member upper '("BR_PUBLISH_RUN.DSD" "BR_PUBLISH_LASTRUN.DSD"))
)

(defun BR:PUB:FindDSDFiles (/ dir names result)
  (setq dir (BR:CurrentDataDir)
        result nil)
  (if (and dir (vl-file-directory-p dir))
    (progn
      (setq names (vl-sort (vl-directory-files dir "*.dsd" 1) '<))
      (foreach name names
        (if (not (BR:PUB:GeneratedDSD? name))
          (setq result (append result (list (strcat dir name))))
        )
      )
    )
  )
  result
)

(defun BR:PUB:ReadLines (path / fp line lines)
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

(defun BR:PUB:MakeSheet (name dwg layout start end / dwg-base display)
  (setq dwg    (BR:SafeStr dwg)
        layout (BR:SafeStr layout))
  (setq dwg-base
    (if (> (strlen dwg) 0)
      (vl-filename-base dwg)
      ""
    )
  )
  (setq display
    (cond
      ((and (> (strlen dwg-base) 0) (> (strlen layout) 0))
       (strcat dwg-base " | " layout))
      ((> (strlen layout) 0) layout)
      ((> (strlen (BR:SafeStr name)) 0) name)
      (t "<unnamed sheet>")
    )
  )
  (list
    (cons "name"    (BR:SafeStr name))
    (cons "dwg"     dwg)
    (cons "layout"  layout)
    (cons "display" display)
    (cons "start"   start)
    (cons "end"     end)
  )
)

(defun BR:PUB:SheetDisplay (sheet)
  (BR:SafeStr (cdr (assoc "display" sheet)))
)

(defun BR:PUB:ParseDSDSheets (lines / sheets idx line name start dwg layout)
  (setq sheets nil
        idx    0
        name   nil
        start  nil
        dwg    ""
        layout "")
  (foreach line lines
    (if (BR:PUB:SheetHeader? line)
      (progn
        (if name
          (setq sheets
            (cons (BR:PUB:MakeSheet name dwg layout start (1- idx)) sheets))
        )
        (setq name   (BR:PUB:SheetNameFromHeader line)
              start  idx
              dwg    ""
              layout "")
      )
      (if name
        (progn
          (if (BR:PUB:LineValue line "DWG")
            (setq dwg (BR:PUB:LineValue line "DWG"))
          )
          (if (BR:PUB:LineValue line "Layout")
            (setq layout (BR:PUB:LineValue line "Layout"))
          )
        )
      )
    )
    (setq idx (1+ idx))
  )
  (if name
    (setq sheets
      (cons (BR:PUB:MakeSheet name dwg layout start (1- idx)) sheets))
  )
  (reverse sheets)
)

(defun BR:PUB:FormatFromDSD (lines / section line target-type val)
  (setq section nil
        target-type nil)
  (foreach line lines
    (if (BR:PUB:SectionName line)
      (setq section (strcase (BR:PUB:SectionName line)))
      (if (= section "TARGET")
        (progn
          (setq val (BR:PUB:LineValue line "Type"))
          (if val (setq target-type (BR:PUB:Trim val)))
        )
      )
    )
  )
  (if (= target-type "0") "DWF" "PDF")
)


;;;; -- UTILITY: Dated folder name ---------------------------------

(defun BR:PUB:FolderName (desc / date-str)
  (setq date-str (BR:DateStr))
  (strcat date-str
    (if (and desc (/= desc ""))
      (strcat "-" (BR:SanitizeNamePart desc))
      ""
    )
  )
)


;;;; -- UTILITY: Next available folder path ------------------------

(defun BR:PUB:NextAvailable (base-path / candidate seq)
  (if (not (vl-file-directory-p base-path))
    base-path
    (progn
      (setq seq 2)
      (setq candidate (strcat base-path "_" (itoa seq)))
      (while (vl-file-directory-p candidate)
        (setq seq (1+ seq))
        (setq candidate (strcat base-path "_" (itoa seq)))
      )
      candidate
    )
  )
)


;;;; -- UTILITY: Preview / Build output path -----------------------

(defun BR:PUB:RootForDest (dest)
  (cond
    ((= dest "T") *BR:T-ROOT*)
    (t            *BR:MARKUPS-ROOT*)
  )
)

(defun BR:PUB:DestLabel (dest)
  (cond
    ((= dest "T") "T")
    (t            "Markups")
  )
)

(defun BR:PUB:PreviewOutputPath (proj desc dest / root proj-dir folder-name base-path)
  (if (null proj)
    nil
    (progn
      (setq root        (BR:PUB:RootForDest dest))
      (setq proj-dir    (strcat root proj))
      (setq folder-name (BR:PUB:FolderName desc))
      (setq base-path   (strcat proj-dir "\\" folder-name))
      (strcat (BR:PUB:NextAvailable base-path) "\\")
    )
  )
)

(defun BR:PUB:BuildOutputPath (proj desc dest / root proj-dir folder-name
                                base-path out-dir)
  (if (null proj)
    nil
    (progn
      (setq root     (BR:PUB:RootForDest dest))
      (setq proj-dir (strcat root proj))
      (if (not (vl-file-directory-p proj-dir))
        (BR:Mkdirp proj-dir)
      )
      (setq folder-name (BR:PUB:FolderName desc))
      (setq base-path   (strcat proj-dir "\\" folder-name))
      (setq out-dir     (BR:PUB:NextAvailable base-path))
      (BR:Mkdirp out-dir)
      (strcat out-dir "\\")
    )
  )
)

(defun BR:PUB:PreviewMarkupPath (proj desc)
  (BR:PUB:PreviewOutputPath proj desc "MARKUPS")
)

(defun BR:PUB:BuildMarkupPath (proj desc)
  (BR:PUB:BuildOutputPath proj desc "MARKUPS")
)


;;;; -- UTILITY: Open Explorer to folder ---------------------------

(defun BR:PUB:Explore (directory / shell result)
  (setq shell (vla-getInterfaceObject
                (vlax-get-Acad-Object) "Shell.Application"))
  (setq result (vl-catch-all-apply
                 'vlax-invoke (list shell 'Explore directory)))
  (vlax-release-object shell)
  (not (vl-catch-all-error-p result))
)


;;;; -- DIALOG HELPERS ---------------------------------------------

(defun BR:PUB:RefreshCount (/ idx-list cnt)
  (setq idx-list (BR:PUB:ParseIndices *BR:PUB-SELECTED*))
  (setq cnt (if idx-list (length idx-list) 0))
  (set_tile "pub_count"
    (strcat "Selected: " (itoa cnt) " sheet(s)"))
)

(defun BR:PUB:RefreshOutdir (/ proj preview-path)
  (if (member *BR:PUB-DEST* '("MARKUPS" "T"))
    (progn
      (setq proj (BR:DetectProj))
      (if proj
        (progn
          (setq preview-path
            (BR:PUB:PreviewOutputPath proj *BR:PUB-DESC* *BR:PUB-DEST*))
          (set_tile "pub_outdir"
            (strcat "Output (" (BR:PUB:DestLabel *BR:PUB-DEST*) "): "
                    (BR:SafeStr preview-path)))
        )
        (set_tile "pub_outdir"
          "Output: ** Project not detected -- will use drawing folder **")
      )
    )
    (set_tile "pub_outdir"
      (strcat "Output: " (getvar "DWGPREFIX")))
  )
)

(defun BR:PUB:SetFormatTiles ()
  (set_tile "fmt_pdf" (if (= *BR:PUB-FORMAT* "PDF") "1" "0"))
  (set_tile "fmt_dwf" (if (= *BR:PUB-FORMAT* "DWF") "1" "0"))
)

(defun BR:PUB:RefreshDSDStatus (/ file count)
  (setq count (length *BR:PUB-DSD-FILES*)
        file  (if *BR:PUB-DSD-PATH* (vl-filename-base *BR:PUB-DSD-PATH*) ""))
  (set_tile "pub_dsd_status"
    (cond
      ((= count 1) (strcat "Using saved DSD: " file ".dsd"))
      ((> count 1) "Multiple DSD files found. Choose the publish set above.")
      (t "No DSD files found in DATA."))
    )
  (set_tile "pub_method"
    (strcat "Method: Saved DSD"
            (if (> (strlen file) 0) (strcat " - " file ".dsd") "")))
)

(defun BR:PUB:FillSheetList ()
  (setq *BR:PUB-LAYOUTS* (mapcar 'BR:PUB:SheetDisplay *BR:PUB-SHEETS*))
  (start_list "pub_layouts")
  (foreach item *BR:PUB-LAYOUTS*
    (add_list item)
  )
  (end_list)
  (BR:PUB:SelectAll)
)

(defun BR:PUB:FillDSDList (/ idx)
  (start_list "pub_dsd")
  (foreach path *BR:PUB-DSD-FILES*
    (add_list (strcat (vl-filename-base path) ".dsd"))
  )
  (end_list)
  (setq idx (if *BR:PUB-DSD-IDX* *BR:PUB-DSD-IDX* 0))
  (set_tile "pub_dsd" (itoa idx))
  (if (<= (length *BR:PUB-DSD-FILES*) 1)
    (mode_tile "pub_dsd" 1)
    (mode_tile "pub_dsd" 0)
  )
  (BR:PUB:RefreshDSDStatus)
)

(defun BR:PUB:SetActiveDSD (idx / path lines sheets)
  (if (or (null idx)
          (< idx 0)
          (>= idx (length *BR:PUB-DSD-FILES*)))
    (setq idx 0)
  )
  (setq path   (nth idx *BR:PUB-DSD-FILES*)
        lines  (if path (BR:PUB:ReadLines path) nil)
        sheets (if lines (BR:PUB:ParseDSDSheets lines) nil))
  (setq *BR:PUB-DSD-IDX*   idx
        *BR:PUB-DSD-PATH*  path
        *BR:PUB-DSD-LINES* lines
        *BR:PUB-SHEETS*    sheets
        *BR:PUB-FORMAT*    (if lines (BR:PUB:FormatFromDSD lines) "PDF"))
  sheets
)

(defun BR:PUB:ChooseDSD (idx)
  (BR:PUB:SetActiveDSD idx)
  (BR:PUB:SetFormatTiles)
  (BR:PUB:RefreshDSDStatus)
  (BR:PUB:FillSheetList)
)

(defun BR:PUB:SelectAll (/ i num-layouts sel-str)
  (setq num-layouts (length *BR:PUB-LAYOUTS*))
  (setq sel-str "" i 0)
  (repeat num-layouts
    (setq sel-str (strcat sel-str (itoa i) " "))
    (setq i (1+ i))
  )
  (setq sel-str (vl-string-right-trim " " sel-str))
  (set_tile "pub_layouts" sel-str)
  (setq *BR:PUB-SELECTED* sel-str)
  (BR:PUB:RefreshCount)
)

(defun BR:PUB:SelectNone ()
  (set_tile "pub_layouts" "")
  (setq *BR:PUB-SELECTED* "")
  (BR:PUB:RefreshCount)
)

(defun BR:PUB:Invert (/ sel-indices i num-layouts sel-str)
  (setq sel-indices (BR:PUB:ParseIndices *BR:PUB-SELECTED*))
  (if (null sel-indices) (setq sel-indices '()))
  (setq num-layouts (length *BR:PUB-LAYOUTS*))
  (setq sel-str "" i 0)
  (repeat num-layouts
    (if (not (member i sel-indices))
      (setq sel-str (strcat sel-str (itoa i) " "))
    )
    (setq i (1+ i))
  )
  (setq sel-str (vl-string-right-trim " " sel-str))
  (set_tile "pub_layouts" sel-str)
  (setq *BR:PUB-SELECTED* sel-str)
  (BR:PUB:RefreshCount)
)


;;;; -- RESOLVE OUTPUT DIRECTORY -----------------------------------

(defun BR:PUB:ResolveOutDir (/ proj markup-path)
  (if (member *BR:PUB-DEST* '("MARKUPS" "T"))
    (progn
      (setq proj (BR:DetectProj))
      (if proj
        (progn
          (setq markup-path
            (BR:PUB:BuildOutputPath proj *BR:PUB-DESC* *BR:PUB-DEST*))
          (if markup-path markup-path (getvar "DWGPREFIX"))
        )
        (getvar "DWGPREFIX")
      )
    )
    (getvar "DWGPREFIX")
  )
)


;;;; -- DSD FILE GENERATOR -----------------------------------------
;;; Writes a run DSD from the selected saved DATA DSD.
;;; The original DSD is never modified.
;;;
;;; format:  "PDF" or "DWF"

(defun BR:PUB:OutputBase (selected-indices / sheet dwg)
  (setq sheet (if selected-indices (nth (car selected-indices) *BR:PUB-SHEETS*) nil)
        dwg   (if sheet (cdr (assoc "dwg" sheet)) ""))
  (cond
    ((> (strlen (BR:SafeStr dwg)) 0) (vl-filename-base dwg))
    (*BR:PUB-DSD-PATH*              (vl-filename-base *BR:PUB-DSD-PATH*))
    (t                              (vl-filename-base (getvar "DWGNAME")))
  )
)

(defun BR:PUB:WriteRunDSD (selected-indices out-dir format
                         / data-dir dsd-path fp line section sheet-idx
                           include-sheet skip-sheet out-file type-val
                           output-base target-seen)
  (setq data-dir (BR:CurrentDataDir))
  (setq dsd-path
    (if data-dir
      (strcat data-dir "BR_Publish_Run.dsd")
      (strcat (getvar "TEMPPREFIX") "BR_Publish.dsd")
    )
  )
  (setq type-val (if (= format "DWF") "0" "6"))
  (setq output-base (BR:PUB:OutputBase selected-indices))
  (setq out-file (strcat out-dir output-base "." (strcase format t)))

  (setq fp (open dsd-path "w"))
  (if (null fp)
    (progn (princ "\n  [ERROR] Cannot create run DSD file.") nil)
    (progn
      (setq sheet-idx    -1
            skip-sheet   nil
            section      nil
            target-seen  nil)

      (foreach line *BR:PUB-DSD-LINES*
        (cond
          ((BR:PUB:SheetHeader? line)
           (setq sheet-idx     (1+ sheet-idx)
                 include-sheet (member sheet-idx selected-indices)
                 skip-sheet    (not include-sheet)
                 section       (BR:PUB:SectionName line))
           (if include-sheet (write-line line fp))
          )
          ((BR:PUB:SectionName line)
           (setq skip-sheet nil
                 section    (strcase (BR:PUB:SectionName line)))
           (if (= section "TARGET") (setq target-seen T))
           (write-line line fp)
          )
          (skip-sheet
           nil)
          ((= section "TARGET")
           (cond
             ((BR:PUB:LineValue line "Type")
              (write-line (strcat "Type=" type-val) fp))
             ((BR:PUB:LineValue line "DWF")
              (write-line (strcat "DWF=" out-file) fp))
             ((BR:PUB:LineValue line "OUT")
              (write-line (strcat "OUT=" out-dir) fp))
             (t
              (write-line line fp))
           )
          )
          (t
           (write-line line fp))
        )
      )

      (if (not target-seen)
        (progn
          (write-line "[Target]" fp)
          (write-line (strcat "Type=" type-val) fp)
          (write-line (strcat "DWF=" out-file) fp)
          (write-line (strcat "OUT=" out-dir) fp)
          (write-line "PWD=" fp)
        )
      )

      (close fp)
      (princ (strcat "\n  Run DSD generated: " dsd-path))
      dsd-path
    )
  )
)


;;;; -- DSD PUBLISH ------------------------------------------------
;;; Call -PUBLISH with the run DSD file.
;;; Returns T on success, nil on failure.

(defun BR:PUB:PublishViaDSD (dsd-path / result)
  (princ "\n  Running PUBLISH via DSD...")
  (setq result
    (vl-catch-all-apply
      '(lambda ()
         (command "._-PUBLISH" dsd-path)
         (while (> (getvar "CMDACTIVE") 0) (command ""))
         T
       )
    )
  )
  (if (vl-catch-all-error-p result)
    (progn
      (princ (strcat "\n  [ERROR] Publish failed: "
                     (vl-catch-all-error-message result)))
      nil
    )
    (progn
      (princ "\n  Publish command completed.")
      T
    )
  )
)


;;;; -- DIALOG FLOW ------------------------------------------------

(defun BR:PublishDCL (/ dcl-path dcl-id result sel-indices proj data-dir)
  (setq *BR:PUB-DSD-FILES* (BR:PUB:FindDSDFiles))
  (cond
    ((null *BR:PUB-DSD-FILES*)
     (setq data-dir (BR:CurrentDataDir))
     (alert
       (strcat
         "No DSD files were found in the project DATA folder.\n\n"
         (BR:SafeStr data-dir)
         "\n\nSave a publish DSD file there, then run BR_PUB again."))
     nil)

    ((null (setq dcl-path (findfile "BR_Publish.dcl")))
     (alert
       (strcat
         "BR_Publish.dcl not found.\n\n"
         "Make sure BR_Publish.dcl is in the same folder as the LSP files\n"
         "and that folder is on AutoCAD's support path."))
     nil)

    ((< (setq dcl-id (load_dialog dcl-path)) 0)
     (alert (strcat "Cannot load DCL file:\n" dcl-path))
     nil)

    ((not (new_dialog "br_publish" dcl-id))
     (unload_dialog dcl-id)
     (alert "Cannot initialize br_publish dialog.")
     nil)

    (t
     ;; Initialize state
     (setq *BR:PUB-DSD-IDX*    0)
     (setq *BR:PUB-SELECTED*   "")
     (setq *BR:PUB-DEST*       "MARKUPS")
     (setq *BR:PUB-DESC*       "")
     (BR:PUB:SetActiveDSD 0)

     (if (null *BR:PUB-SHEETS*)
       (progn
         (unload_dialog dcl-id)
         (alert
           (strcat
             "No publish sheets were found in the selected DSD file.\n\n"
             (BR:SafeStr *BR:PUB-DSD-PATH*)))
         nil
       )
       (progn
         (BR:PUB:FillDSDList)
         (BR:PUB:FillSheetList)

         ;; Defaults
         (BR:PUB:SetFormatTiles)
         (set_tile "dest_markups" "1")
         (set_tile "dest_tfolder" "0")

         (setq proj (BR:DetectProj))
         (set_tile "pub_proj"
           (strcat "Project: "
             (if proj proj "** not detected **")))

         (BR:PUB:RefreshDSDStatus)
         (BR:PUB:RefreshOutdir)

         ;; -- Action tiles --
         (action_tile "pub_layouts"
           "(setq *BR:PUB-SELECTED* (BR:SafeStr $value))(BR:PUB:RefreshCount)")
         (action_tile "pub_dsd"
           "(BR:PUB:ChooseDSD (BR:DCL:SafeIndex $value))")
         (action_tile "btn_all"    "(BR:PUB:SelectAll)")
         (action_tile "btn_none"   "(BR:PUB:SelectNone)")
         (action_tile "btn_invert" "(BR:PUB:Invert)")

         (action_tile "fmt_pdf"
           "(setq *BR:PUB-FORMAT* \"PDF\")")
         (action_tile "fmt_dwf"
           "(setq *BR:PUB-FORMAT* \"DWF\")")

         (action_tile "dest_markups"
           "(setq *BR:PUB-DEST* \"MARKUPS\")(BR:PUB:RefreshOutdir)")
         (action_tile "dest_tfolder"
           "(setq *BR:PUB-DEST* \"T\")(BR:PUB:RefreshOutdir)")

         (action_tile "pub_desc"
           "(setq *BR:PUB-DESC* (BR:SafeStr $value))(BR:PUB:RefreshOutdir)")

         (action_tile "accept" "(done_dialog 1)")
         (action_tile "cancel" "(done_dialog 0)")

         (setq result (start_dialog))
         (unload_dialog dcl-id)

         (if (= result 1)
           (progn
             (setq sel-indices (BR:PUB:ParseIndices *BR:PUB-SELECTED*))
             (if sel-indices
               sel-indices
               (progn (alert "No sheets selected.") nil)
             )
           )
           nil
         )
       )
     )
    )
  )
)


;;;; -- COMMAND: C:BR_PUB ------------------------------------------

(defun C:BR_PUB (/ *error* _olderr _saved _undoFlag
                   sel-indices out-dir ext dsd-path pub-ok)
  (vl-load-com)
  (setq _saved  (BR:SaveSysvars '("CMDECHO" "CTAB" "BACKGROUNDPLOT"))
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
  (setvar "BACKGROUNDPLOT" 0)
  (setq _undoFlag (BR:BeginUndo))

  ;; Run dialog
  (setq sel-indices (BR:PublishDCL))

  (if sel-indices
    (progn
      ;; Resolve output directory
      (setq out-dir (BR:PUB:ResolveOutDir))
      (setq ext (strcase *BR:PUB-FORMAT* t))

      (princ
        (strcat "\n  Publishing " (itoa (length sel-indices))
                " sheet(s) from " (vl-filename-base *BR:PUB-DSD-PATH*) ".dsd"
                " as " (strcase ext t) " to: " out-dir))

      ;; Primary method: saved DSD filtered to the selected sheets.
      (setq dsd-path
        (BR:PUB:WriteRunDSD sel-indices out-dir *BR:PUB-FORMAT*))
      (if dsd-path
        (progn
          (setq pub-ok (BR:PUB:PublishViaDSD dsd-path))
          (if pub-ok
            (princ "\n  DSD publish complete.")
            (princ "\n  DSD publish failed.")
          )
        )
        (princ "\n  Run DSD generation failed.")
      )

      (princ "\n  BR_Publish complete.")
      ;; Open Explorer to output folder
      (BR:PUB:Explore out-dir)
    )
    (princ "\n  Publish cancelled.")
  )

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED ----------------------------------------------

(princ "\n  BR_Publish module loaded.  Command: BR_PUB")
(princ)

;;; End of BR_Publish.lsp
