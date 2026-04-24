;;; ================================================================
;;; BR_Publish.lsp  |  Brelje & Race CAD Tools  |  Batch Publish
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_Publish.dcl (dialog name "br_publish")
;;; Command:  BR_PUB
;;;
;;; Primary method: generates a DSD file and calls -PUBLISH.
;;; Fallback: individual -PLOT per layout (legacy support).
;;; ================================================================

(vl-load-com)

;;;; -- GLOBALS ----------------------------------------------------

(setq *BR:PUB-LAYOUTS*    nil)
(setq *BR:PUB-SELECTED*   nil)
(setq *BR:PUB-FORMAT*     "PDF")
(setq *BR:PUB-DEST*       "MARKUPS")
(setq *BR:PUB-DESC*       "")
(setq *BR:PUB-MULTISHEET* nil)
(setq *BR:MARKUPS-ROOT*   "J:\\Markups\\")


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


;;;; -- UTILITY: Dated folder name ---------------------------------

(defun BR:PUB:FolderName (desc / date-str)
  (setq date-str (BR:DateStr))
  (strcat date-str
    (if (and desc (/= desc ""))
      (strcat "-" desc)
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


;;;; -- UTILITY: Preview / Build Markups path ----------------------

(defun BR:PUB:PreviewMarkupPath (proj desc / proj-dir folder-name base-path)
  (if (null proj)
    nil
    (progn
      (setq proj-dir    (strcat *BR:MARKUPS-ROOT* proj))
      (setq folder-name (BR:PUB:FolderName desc))
      (setq base-path   (strcat proj-dir "\\" folder-name))
      (strcat (BR:PUB:NextAvailable base-path) "\\")
    )
  )
)

(defun BR:PUB:BuildMarkupPath (proj desc / proj-dir folder-name
                                base-path out-dir)
  (if (null proj)
    nil
    (progn
      (setq proj-dir (strcat *BR:MARKUPS-ROOT* proj))
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


;;;; -- UTILITY: Open Explorer to folder ---------------------------

(defun BR:PUB:Explore (directory / shell result)
  (setq shell (vla-getInterfaceObject
                (vlax-get-Acad-Object) "Shell.Application"))
  (setq result (vl-catch-all-apply
                 'vlax-invoke (list shell 'Explore directory)))
  (vlax-release-object shell)
  (not (vl-catch-all-error-p result))
)


;;;; -- BR:PUB:GetLayouts ------------------------------------------

(defun BR:PUB:GetLayouts (/ doc layouts layout-list)
  (setq doc     (vla-get-ActiveDocument (vlax-get-Acad-Object)))
  (setq layouts (vla-get-Layouts doc))
  (vlax-for lay layouts
    (if (/= (strcase (vla-get-Name lay)) "MODEL")
      (setq layout-list (cons (vla-get-Name lay) layout-list))
    )
  )
  (if layout-list
    (vl-sort layout-list '<)
  )
)


;;;; -- DIALOG HELPERS ---------------------------------------------

(defun BR:PUB:RefreshCount (/ idx-list cnt)
  (setq idx-list (BR:PUB:ParseIndices *BR:PUB-SELECTED*))
  (setq cnt (if idx-list (length idx-list) 0))
  (set_tile "pub_count"
    (strcat "Selected: " (itoa cnt) " layout(s)"))
)

(defun BR:PUB:RefreshOutdir (/ proj preview-path)
  (if (= *BR:PUB-DEST* "MARKUPS")
    (progn
      (setq proj (BR:DetectProj))
      (if proj
        (progn
          (setq preview-path
            (BR:PUB:PreviewMarkupPath proj *BR:PUB-DESC*))
          (set_tile "pub_outdir"
            (strcat "Output: " (BR:SafeStr preview-path)))
        )
        (set_tile "pub_outdir"
          "Output: ** Project not detected -- will use drawing folder **")
      )
    )
    (set_tile "pub_outdir"
      (strcat "Output: " (getvar "DWGPREFIX")))
  )
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
  (if (= *BR:PUB-DEST* "MARKUPS")
    (progn
      (setq proj (BR:DetectProj))
      (if proj
        (progn
          (setq markup-path (BR:PUB:BuildMarkupPath proj *BR:PUB-DESC*))
          (if markup-path markup-path (getvar "DWGPREFIX"))
        )
        (getvar "DWGPREFIX")
      )
    )
    (getvar "DWGPREFIX")
  )
)


;;;; -- DSD FILE GENERATOR -----------------------------------------
;;; Generates a temporary DSD (Drawing Set Description) file for
;;; the PUBLISH command.  Returns the path to the DSD, or nil.
;;;
;;; format:  "PDF" or "DWF"
;;; multi:   T for multi-sheet output, nil for individual sheets

(defun BR:PUB:WriteDSD (layouts out-dir format multi
                         / dsd-path fp dwg-path dwg-base
                           layout-name out-file type-val)
  (setq dsd-path (strcat (getvar "TEMPPREFIX") "BR_Publish.dsd"))
  (setq dwg-path (strcat (getvar "DWGPREFIX") (getvar "DWGNAME")))
  (setq dwg-base (vl-filename-base (getvar "DWGNAME")))
  (setq type-val (if (= format "DWF") "0" "6"))

  ;; Output filename for multi-sheet mode
  (setq out-file
    (if multi
      (strcat out-dir dwg-base "." (strcase format t))
      (strcat out-dir dwg-base "." (strcase format t))
    )
  )

  (setq fp (open dsd-path "w"))
  (if (null fp)
    (progn (princ "\n  [ERROR] Cannot create DSD temp file.") nil)
    (progn
      ;; -- Header --
      (write-line "[DWF6Version]" fp)
      (write-line "Ver=1" fp)
      (write-line "[DWF6MinorVersion]" fp)
      (write-line "MinorVer=1" fp)

      ;; -- Sheet entries --
      (foreach layout-name layouts
        (write-line (strcat "[DWF6Sheet:" dwg-base "-" layout-name "]") fp)
        (write-line (strcat "DWG=" dwg-path) fp)
        (write-line (strcat "Layout=" layout-name) fp)
        (write-line "Setup=" fp)
        (write-line (strcat "OriginalSheetPath=" dwg-path) fp)
        (write-line "Has Plot Port=0" fp)
        (write-line "Has3DDWF=0" fp)
      )

      ;; -- Target --
      (write-line "[Target]" fp)
      (write-line (strcat "Type=" type-val) fp)
      (write-line (strcat "DWF=" out-file) fp)
      (write-line (strcat "OUT=" out-dir) fp)
      (write-line "PWD=" fp)

      ;; -- Sheet Set Properties --
      (write-line "[SheetSet Properties]" fp)
      (write-line "IsSheetSet=FALSE" fp)
      (write-line "IsHomogeneous=FALSE" fp)
      (write-line "SheetSet Name=" fp)
      (write-line "NoOfCopies=1" fp)
      (write-line "PlotStampOn=FALSE" fp)
      (write-line "ViewFile=FALSE" fp)
      (write-line "JobID=0" fp)
      (write-line "SelectionSetName=" fp)
      (write-line "AcadProfile=" fp)
      (write-line "CategoryName=" fp)
      (write-line "LogFilePath=" fp)
      (write-line "IncludeLayer=FALSE" fp)
      (write-line "LineMerge=FALSE" fp)
      (write-line "CurrentPrecision=" fp)
      (write-line "PromptForDwfName=FALSE" fp)
      (write-line "PwdProtectPublishedDWF=FALSE" fp)
      (write-line "PromptForPwd=FALSE" fp)
      (write-line "RepublishingMarkups=FALSE" fp)
      (write-line "DSTPath=" fp)

      (close fp)
      (princ (strcat "\n  DSD generated: " dsd-path))
      dsd-path
    )
  )
)


;;;; -- DSD PUBLISH ------------------------------------------------
;;; Call -PUBLISH with the generated DSD file.
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


;;;; -- LEGACY: Individual -PLOT (fallback) ------------------------

(defun BR:PUB:PlotLayout (layout-name output-path / result)
  (setvar "CTAB" layout-name)
  (setq result
    (vl-catch-all-apply
      '(lambda ()
         (command "._-PLOT"
           "No" "" "" output-path "No" "Yes")
         (while (> (getvar "CMDACTIVE") 0) (command ""))
         T
       )
    )
  )
  (if (vl-catch-all-error-p result)
    (progn
      (princ (strcat "\n  [FAIL] " layout-name ": "
                     (vl-catch-all-error-message result)))
      nil
    )
    (progn
      (princ (strcat "\n  [OK] " layout-name " -> " output-path))
      T
    )
  )
)

(defun BR:PUB:PublishIndividual (layout-names out-dir ext / dwg-name
                                 layout-name output-path count ok)
  (setq dwg-name (vl-filename-base (getvar "DWGNAME")))
  (setq count 0)
  (foreach layout-name layout-names
    (setq output-path
      (strcat out-dir dwg-name "-" layout-name "." ext))
    (princ (strcat "\n  Plotting: " layout-name "..."))
    (setq ok (BR:PUB:PlotLayout layout-name output-path))
    (if ok (setq count (1+ count)))
  )
  (princ (strcat "\n  Plotted " (itoa count) " of "
                 (itoa (length layout-names)) " file(s)."))
  count
)


;;;; -- DIALOG FLOW ------------------------------------------------

(defun BR:PublishDCL (/ dcl-path dcl-id result sel-indices sel-names proj)
  (setq dcl-path (findfile "BR_Publish.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat
          "BR_Publish.dcl not found.\n\n"
          "Make sure BR_Publish.dcl is in the same folder as the LSP files\n"
          "and that folder is on AutoCAD's support path."))
      nil
    )
    (progn
      (setq dcl-id (load_dialog dcl-path))
      (if (< dcl-id 0)
        (progn (alert (strcat "Cannot load DCL file:\n" dcl-path)) nil)
        (if (not (new_dialog "br_publish" dcl-id))
          (progn
            (unload_dialog dcl-id)
            (alert "Cannot initialize br_publish dialog.")
            nil
          )
          (progn
            ;; Initialize state
            (setq *BR:PUB-LAYOUTS*    (BR:PUB:GetLayouts))
            (setq *BR:PUB-SELECTED*   "")
            (setq *BR:PUB-FORMAT*     "PDF")
            (setq *BR:PUB-DEST*       "MARKUPS")
            (setq *BR:PUB-DESC*       "")
            (setq *BR:PUB-MULTISHEET* nil)

            (if (null *BR:PUB-LAYOUTS*)
              (progn
                (unload_dialog dcl-id)
                (alert "No paper-space layouts found in current drawing.")
                nil
              )
              (progn
                ;; Fill layout list
                (start_list "pub_layouts")
                (mapcar 'add_list *BR:PUB-LAYOUTS*)
                (end_list)

                ;; Set defaults
                (set_tile "fmt_pdf" "1")
                (set_tile "fmt_dwf" "0")
                (set_tile "multi_sheet" "0")
                (set_tile "dest_markups" "1")
                (set_tile "dest_dwgdir"  "0")

                ;; Show project
                (setq proj (BR:DetectProj))
                (set_tile "pub_proj"
                  (strcat "Project: "
                    (if proj proj "** not detected **")))

                ;; Method display
                (set_tile "pub_method" "Method: DSD Batch Publish")

                (BR:PUB:RefreshCount)
                (BR:PUB:RefreshOutdir)

                ;; -- Action tiles --
                (action_tile "pub_layouts"
                  "(setq *BR:PUB-SELECTED* (BR:SafeStr $value))(BR:PUB:RefreshCount)")
                (action_tile "btn_all"    "(BR:PUB:SelectAll)")
                (action_tile "btn_none"   "(BR:PUB:SelectNone)")
                (action_tile "btn_invert" "(BR:PUB:Invert)")

                (action_tile "fmt_pdf"
                  "(setq *BR:PUB-FORMAT* \"PDF\")")
                (action_tile "fmt_dwf"
                  "(setq *BR:PUB-FORMAT* \"DWF\")")

                (action_tile "multi_sheet"
                  "(setq *BR:PUB-MULTISHEET* (= (BR:SafeStr $value) \"1\"))")

                (action_tile "dest_markups"
                  "(setq *BR:PUB-DEST* \"MARKUPS\")(BR:PUB:RefreshOutdir)")
                (action_tile "dest_dwgdir"
                  "(setq *BR:PUB-DEST* \"DWGDIR\")(BR:PUB:RefreshOutdir)")

                (action_tile "pub_desc"
                  "(setq *BR:PUB-DESC* (BR:SafeStr $value))(BR:PUB:RefreshOutdir)")

                (action_tile "accept" "(done_dialog 1)")
                (action_tile "cancel" "(done_dialog 0)")

                ;; -- Run --
                (setq result (start_dialog))
                (unload_dialog dcl-id)

                ;; -- Return selected layout names --
                (if (= result 1)
                  (progn
                    (setq sel-indices (BR:PUB:ParseIndices *BR:PUB-SELECTED*))
                    (if sel-indices
                      (mapcar
                        '(lambda (i) (nth i *BR:PUB-LAYOUTS*))
                        sel-indices)
                      (progn (alert "No layouts selected.") nil)
                    )
                  )
                  nil
                )
              )
            )
          )
        )
      )
    )
  )
)


;;;; -- COMMAND: C:BR_PUB ------------------------------------------

(defun C:BR_PUB (/ *error* _olderr _saved _undoFlag
                   sel-layouts out-dir ext dsd-path pub-ok)
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
  (setq sel-layouts (BR:PublishDCL))

  (if sel-layouts
    (progn
      ;; Resolve output directory
      (setq out-dir (BR:PUB:ResolveOutDir))
      (setq ext (strcase *BR:PUB-FORMAT* t))

      (princ
        (strcat "\n  Publishing " (itoa (length sel-layouts))
                " layout(s) as " (strcase ext t)
                " to: " out-dir))

      ;; Primary method: DSD batch publish
      (setq dsd-path
        (BR:PUB:WriteDSD sel-layouts out-dir
                         *BR:PUB-FORMAT* *BR:PUB-MULTISHEET*))
      (if dsd-path
        (progn
          (setq pub-ok (BR:PUB:PublishViaDSD dsd-path))
          ;; Clean up temp DSD
          (if (findfile dsd-path)
            (vl-file-delete dsd-path)
          )
          (if pub-ok
            (princ "\n  DSD publish complete.")
            (progn
              ;; Fallback to individual -PLOT if DSD fails
              (princ "\n  DSD publish failed -- falling back to individual -PLOT...")
              (BR:PUB:PublishIndividual sel-layouts out-dir ext)
            )
          )
        )
        ;; DSD generation failed -- fall back
        (progn
          (princ "\n  DSD generation failed -- using individual -PLOT...")
          (BR:PUB:PublishIndividual sel-layouts out-dir ext)
        )
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
