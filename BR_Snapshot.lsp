;;; ================================================================
;;; BR_Snapshot.lsp  |  Brelje & Race CAD Tools  |  Drawing Snapshot
;;; ================================================================
;;; Module: Drawing Portal -- snapshot exporter
;;; Description: Exports current drawing state to C:\CAD_IO\logs\ for Claude Code analysis
;;; Version: 2026-03-25
;;; Safety: READ-ONLY -- queries drawing data, writes only to CAD_IO export folder
;;;
;;; Commands:
;;;   BR:Snap     -- Full drawing snapshot (layers, entities, blocks, text, xrefs, sysvars)
;;;   BR:SnapSel  -- Detailed export of current selection set
;;;   BR:SnapQ    -- Quick snapshot (layers + entity counts only, fastest)
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first (when used as BR suite module).
;;; DCL file: BR_Snapshot.dcl (dialog name "br_snapshot")
;;; ================================================================

(vl-load-com)

;;; ===== CONFIGURATION =====
(setq *BR:Snap:OutputDir*   "C:\\CAD_IO\\logs\\"
      *BR:Snap:Separator*   "|"
      *BR:Snap:MaxTextLen*   200      ; truncate long text content
      *BR:Snap:MaxEntDetail* 5000    ; max entities for detailed export
)

;;; ===== FILE I/O HELPERS =====

(defun BR:Snap-OpenFile (filename / fp)
  "Open file for writing, return file pointer"
  (setq fp (open (strcat *BR:Snap:OutputDir* filename) "w"))
  (if (not fp)
    (progn
      (princ (strcat "\nERROR: Cannot write to " *BR:Snap:OutputDir* filename))
      nil
    )
    fp
  )
)

(defun BR:Snap-WriteLine (fp line)
  "Write a line to file"
  (write-line line fp)
)

(defun BR:Snap-Section (fp title)
  "Write a section header"
  (BR:Snap-WriteLine fp "")
  (BR:Snap-WriteLine fp (strcat "=== " title " ==="))
)

(defun BR:Snap-CloseFile (fp)
  "Close file pointer"
  (if fp (close fp))
)

;; Replace all occurrences of substring OLD with NEW in string STR.
(defun BR:Snap-StrReplace (str old new / pos result len-old)
  (setq result "" len-old (strlen old))
  (while (setq pos (vl-string-search old str))
    (setq result (strcat result (substr str 1 pos) new)
          str    (substr str (+ pos len-old 1)))
  )
  (strcat result str)
)

(defun BR:Snap-SafeStr (val / )
  "Convert any value to a safe string (no pipes, no newlines)"
  (if val
    (progn
      (setq val (vl-princ-to-string val))
      (setq val (vl-string-translate "\n" " " val))
      (setq val (vl-string-translate "\r" " " val))
      (setq val (vl-string-translate "|" "/" val))
      (if (> (strlen val) *BR:Snap:MaxTextLen*)
        (strcat (substr val 1 *BR:Snap:MaxTextLen*) "...")
        val
      )
    )
    ""
  )
)

(defun BR:Snap-Num (val precision)
  "Format number to string with given decimal places"
  (if val
    (rtos val 2 precision)
    "0"
  )
)

;;; ===== DATA COLLECTION =====

(defun BR:Snap-DrawingInfo (fp / doc)
  "Write drawing metadata"
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (BR:Snap-Section fp "DRAWING INFO")
  (BR:Snap-WriteLine fp (strcat "FileName|" (BR:Snap-SafeStr (vla-get-Name doc))))
  (BR:Snap-WriteLine fp (strcat "FullPath|" (BR:Snap-SafeStr (vla-get-FullName doc))))
  (BR:Snap-WriteLine fp (strcat "Saved|" (BR:Snap-SafeStr (menucmd "M=$(edtime,$(getvar,tdupdate),MON DD YYYY HH:MM)"))))
  (BR:Snap-WriteLine fp (strcat "Units|" (itoa (getvar "LUNITS"))))
  (BR:Snap-WriteLine fp (strcat "InsUnits|" (itoa (getvar "INSUNITS"))))
  (BR:Snap-WriteLine fp (strcat "LimMin|" (BR:Snap-Num (car (getvar "LIMMIN")) 2) "," (BR:Snap-Num (cadr (getvar "LIMMIN")) 2)))
  (BR:Snap-WriteLine fp (strcat "LimMax|" (BR:Snap-Num (car (getvar "LIMMAX")) 2) "," (BR:Snap-Num (cadr (getvar "LIMMAX")) 2)))
  (BR:Snap-WriteLine fp (strcat "ExtMin|" (BR:Snap-Num (car (getvar "EXTMIN")) 2) "," (BR:Snap-Num (cadr (getvar "EXTMIN")) 2) "," (BR:Snap-Num (caddr (getvar "EXTMIN")) 2)))
  (BR:Snap-WriteLine fp (strcat "ExtMax|" (BR:Snap-Num (car (getvar "EXTMAX")) 2) "," (BR:Snap-Num (cadr (getvar "EXTMAX")) 2) "," (BR:Snap-Num (caddr (getvar "EXTMAX")) 2)))
  (BR:Snap-WriteLine fp (strcat "CurrentLayer|" (getvar "CLAYER")))
  (BR:Snap-WriteLine fp (strcat "CurrentSpace|" (if (= (getvar "TILEMODE") 1) "Model" "Paper")))
  (BR:Snap-WriteLine fp (strcat "SnapTimestamp|" (menucmd "M=$(edtime,$(getvar,date),YYYY-MO-DD HH:MM:SS)")))
)

(defun BR:Snap-Layers (fp / doc layers count i layer lyr-name ss ent-count)
  "Write layer table with entity counts"
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq layers (vla-get-Layers doc))
  (setq count (vla-get-Count layers))
  
  (BR:Snap-Section fp "LAYERS")
  (BR:Snap-WriteLine fp "Name|Color|Linetype|LineWeight|On|Frozen|Locked|Plottable|EntityCount")
  
  (setq i 0)
  (while (< i count)
    (setq layer (vla-Item layers i))
    (setq lyr-name (vla-get-Name layer))
    
    ;; Count entities on this layer
    (setq ss (ssget "X" (list (cons 8 lyr-name))))
    (setq ent-count (if ss (sslength ss) 0))
    
    (BR:Snap-WriteLine fp
      (strcat
        (BR:Snap-SafeStr lyr-name) "|"
        (itoa (vla-get-Color layer)) "|"
        (BR:Snap-SafeStr (vla-get-Linetype layer)) "|"
        (itoa (vla-get-LineWeight layer)) "|"
        (if (= (vla-get-LayerOn layer) :vlax-true) "ON" "OFF") "|"
        (if (= (vla-get-Freeze layer) :vlax-true) "FROZEN" "-") "|"
        (if (= (vla-get-Lock layer) :vlax-true) "LOCKED" "-") "|"
        (if (= (vla-get-Plottable layer) :vlax-true) "YES" "NO") "|"
        (itoa ent-count)
      )
    )
    (setq i (1+ i))
  )
)

(defun BR:Snap-EntitySummary (fp / entity-counts ss i ent ed etype elayer key)
  "Write entity type/layer summary"
  (setq entity-counts '())
  (setq ss (ssget "X"))
  
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq etype (cdr (assoc 0 ed)))
        (setq elayer (cdr (assoc 8 ed)))
        (setq key (strcat etype "|" elayer))
        
        ;; Increment count
        (if (assoc key entity-counts)
          (setq entity-counts
            (subst
              (cons key (1+ (cdr (assoc key entity-counts))))
              (assoc key entity-counts)
              entity-counts
            )
          )
          (setq entity-counts (cons (cons key 1) entity-counts))
        )
        (setq i (1+ i))
      )
      
      (BR:Snap-Section fp "ENTITY SUMMARY")
      (BR:Snap-WriteLine fp "EntityType|Layer|Count")
      
      (foreach item (vl-sort entity-counts
                      (function (lambda (a b) (< (car a) (car b)))))
        (BR:Snap-WriteLine fp
          (strcat (car item) "|" (itoa (cdr item)))
        )
      )
      
      (BR:Snap-Section fp "ENTITY TOTALS")
      (BR:Snap-WriteLine fp (strcat "TotalEntities|" (itoa (sslength ss))))
    )
    (progn
      (BR:Snap-Section fp "ENTITY SUMMARY")
      (BR:Snap-WriteLine fp "TotalEntities|0")
    )
  )
)

(defun BR:Snap-Blocks (fp / doc blocks count i blk blk-name refs j ref)
  "Write block definitions and insertion summary"
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq blocks (vla-get-Blocks doc))
  (setq count (vla-get-Count blocks))
  
  ;; Block definitions
  (BR:Snap-Section fp "BLOCK DEFINITIONS")
  (BR:Snap-WriteLine fp "Name|EntityCount|IsXref|IsLayout|Origin")
  
  (setq i 0)
  (while (< i count)
    (setq blk (vla-Item blocks i))
    (setq blk-name (vla-get-Name blk))
    
    ;; Skip model/paper space blocks and anonymous blocks
    (if (and (not (wcmatch blk-name "*Model*,*Paper*"))
             (/= (substr blk-name 1 1) "*"))
      (BR:Snap-WriteLine fp
        (strcat
          (BR:Snap-SafeStr blk-name) "|"
          (itoa (vla-get-Count blk)) "|"
          (if (= (vla-get-IsXRef blk) :vlax-true) "YES" "NO") "|"
          (if (= (vla-get-IsLayout blk) :vlax-true) "YES" "NO") "|"
          (BR:Snap-Num (vlax-safearray-get-element (vlax-variant-value (vla-get-Origin blk)) 0) 2)
          ","
          (BR:Snap-Num (vlax-safearray-get-element (vlax-variant-value (vla-get-Origin blk)) 1) 2)
        )
      )
    )
    (setq i (1+ i))
  )
  
  ;; Block insertions (references in model space)
  (BR:Snap-Section fp "BLOCK INSERTIONS")
  (BR:Snap-WriteLine fp "BlockName|Layer|X|Y|Z|Rotation|XScale|YScale|AttrCount")
  
  (setq ss (ssget "X" '((0 . "INSERT"))))
  (if ss
    (progn
      (setq i 0)
      (while (and (< i (sslength ss)) (< i *BR:Snap:MaxEntDetail*))
        (setq ent (ssname ss i))
        (setq ref (vlax-ename->vla-object ent))
        (setq ed (entget ent))
        
        (BR:Snap-WriteLine fp
          (strcat
            (BR:Snap-SafeStr (vla-get-Name ref)) "|"
            (BR:Snap-SafeStr (cdr (assoc 8 ed))) "|"
            (BR:Snap-Num (vlax-safearray-get-element (vlax-variant-value (vla-get-InsertionPoint ref)) 0) 2) "|"
            (BR:Snap-Num (vlax-safearray-get-element (vlax-variant-value (vla-get-InsertionPoint ref)) 1) 2) "|"
            (BR:Snap-Num (vlax-safearray-get-element (vlax-variant-value (vla-get-InsertionPoint ref)) 2) 2) "|"
            (BR:Snap-Num (vla-get-Rotation ref) 2) "|"
            (BR:Snap-Num (vla-get-XScaleFactor ref) 4) "|"
            (BR:Snap-Num (vla-get-YScaleFactor ref) 4) "|"
            (if (= (vla-get-HasAttributes ref) :vlax-true)
              (itoa (length (vlax-invoke ref 'GetAttributes)))
              "0"
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
)

(defun BR:Snap-TextContent (fp / ss i ent ed etype content layer x y height rotation)
  "Write all text/mtext content with positions"
  (BR:Snap-Section fp "TEXT CONTENT")
  (BR:Snap-WriteLine fp "Type|Layer|X|Y|Height|Rotation|Content")
  
  ;; Get TEXT and MTEXT entities
  (setq ss (ssget "X" '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (-4 . "OR>"))))
  
  (if ss
    (progn
      (setq i 0)
      (while (and (< i (sslength ss)) (< i *BR:Snap:MaxEntDetail*))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq etype (cdr (assoc 0 ed)))
        (setq layer (cdr (assoc 8 ed)))
        
        (cond
          ((= etype "TEXT")
           (setq content (cdr (assoc 1 ed)))
           (setq x (BR:Snap-Num (car (cdr (assoc 10 ed))) 2))
           (setq y (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 2))
           (setq height (BR:Snap-Num (cdr (assoc 40 ed)) 4))
           (setq rotation (BR:Snap-Num (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0) 2))
          )
          ((= etype "MTEXT")
           (setq content (cdr (assoc 1 ed)))
           ;; Strip MText paragraph breaks for readability
           (setq content (BR:Snap-StrReplace content "\\P" " | "))
           (setq x (BR:Snap-Num (car (cdr (assoc 10 ed))) 2))
           (setq y (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 2))
           (setq height (BR:Snap-Num (cdr (assoc 40 ed)) 4))
           (setq rotation (BR:Snap-Num (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0) 2))
          )
        )
        
        (BR:Snap-WriteLine fp
          (strcat etype "|" layer "|" x "|" y "|" height "|" rotation "|" (BR:Snap-SafeStr content))
        )
        (setq i (1+ i))
      )
    )
  )
)

(defun BR:Snap-Xrefs (fp / doc blocks count i blk)
  "Write external reference status"
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq blocks (vla-get-Blocks doc))
  (setq count (vla-get-Count blocks))
  
  (BR:Snap-Section fp "EXTERNAL REFERENCES")
  (BR:Snap-WriteLine fp "Name|Path|Loaded|Type")
  
  (setq i 0)
  (while (< i count)
    (setq blk (vla-Item blocks i))
    (if (= (vla-get-IsXRef blk) :vlax-true)
      (BR:Snap-WriteLine fp
        (strcat
          (BR:Snap-SafeStr (vla-get-Name blk)) "|"
          (BR:Snap-SafeStr (vla-get-Path blk)) "|"
          "YES" "|"
          "XREF"
        )
      )
    )
    (setq i (1+ i))
  )
)

(defun BR:Snap-Styles (fp / doc tstyles dstyles count i style)
  "Write text styles and dimension styles"
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  
  ;; Text styles
  (setq tstyles (vla-get-TextStyles doc))
  (setq count (vla-get-Count tstyles))
  (BR:Snap-Section fp "TEXT STYLES")
  (BR:Snap-WriteLine fp "Name|Font|Height|WidthFactor")
  (setq i 0)
  (while (< i count)
    (setq style (vla-Item tstyles i))
    (BR:Snap-WriteLine fp
      (strcat
        (BR:Snap-SafeStr (vla-get-Name style)) "|"
        (BR:Snap-SafeStr (vla-get-fontFile style)) "|"
        (BR:Snap-Num (vla-get-Height style) 4) "|"
        (BR:Snap-Num (vla-get-Width style) 4)
      )
    )
    (setq i (1+ i))
  )
  
  ;; Dimension styles
  (setq dstyles (vla-get-DimStyles doc))
  (setq count (vla-get-Count dstyles))
  (BR:Snap-Section fp "DIMENSION STYLES")
  (BR:Snap-WriteLine fp "Name")
  (setq i 0)
  (while (< i count)
    (setq style (vla-Item dstyles i))
    (BR:Snap-WriteLine fp (BR:Snap-SafeStr (vla-get-Name style)))
    (setq i (1+ i))
  )
)

(defun BR:Snap-Linetypes (fp / doc ltypes count i lt)
  "Write loaded linetypes"
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq ltypes (vla-get-Linetypes doc))
  (setq count (vla-get-Count ltypes))
  
  (BR:Snap-Section fp "LINETYPES")
  (BR:Snap-WriteLine fp "Name|Description")
  
  (setq i 0)
  (while (< i count)
    (setq lt (vla-Item ltypes i))
    (BR:Snap-WriteLine fp
      (strcat
        (BR:Snap-SafeStr (vla-get-Name lt)) "|"
        (BR:Snap-SafeStr (vla-get-Description lt))
      )
    )
    (setq i (1+ i))
  )
)

;;; ===== SELECTED ENTITIES DETAIL =====

(defun BR:Snap-SelectedEntities (fp ss / i ent ed obj etype props)
  "Write detailed properties of selected entities"
  (BR:Snap-Section fp "SELECTED ENTITIES")
  (BR:Snap-WriteLine fp "Index|Type|Layer|Color|Linetype|Handle")
  
  (setq i 0)
  (while (and (< i (sslength ss)) (< i *BR:Snap:MaxEntDetail*))
    (setq ent (ssname ss i))
    (setq ed (entget ent))
    (setq etype (cdr (assoc 0 ed)))
    
    (BR:Snap-WriteLine fp
      (strcat
        (itoa i) "|"
        etype "|"
        (BR:Snap-SafeStr (cdr (assoc 8 ed))) "|"
        (if (assoc 62 ed) (itoa (cdr (assoc 62 ed))) "BYLAYER") "|"
        (if (assoc 6 ed) (BR:Snap-SafeStr (cdr (assoc 6 ed))) "BYLAYER") "|"
        (cdr (assoc 5 ed))
      )
    )
    (setq i (1+ i))
  )
  
  ;; Detailed geometry per entity
  (BR:Snap-Section fp "SELECTED GEOMETRY DETAIL")
  
  (setq i 0)
  (while (and (< i (sslength ss)) (< i 500))
    (setq ent (ssname ss i))
    (setq ed (entget ent))
    (setq etype (cdr (assoc 0 ed)))
    
    (BR:Snap-WriteLine fp (strcat "--- Entity " (itoa i) " [" etype "] ---"))
    
    (cond
      ;; LINE
      ((= etype "LINE")
       (BR:Snap-WriteLine fp (strcat "Start|" 
         (BR:Snap-Num (car (cdr (assoc 10 ed))) 4) "," 
         (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4)))
       (BR:Snap-WriteLine fp (strcat "End|" 
         (BR:Snap-Num (car (cdr (assoc 11 ed))) 4) "," 
         (BR:Snap-Num (cadr (cdr (assoc 11 ed))) 4)))
       (BR:Snap-WriteLine fp (strcat "Length|" 
         (BR:Snap-Num (distance (cdr (assoc 10 ed)) (cdr (assoc 11 ed))) 4)))
      )
      
      ;; LWPOLYLINE
      ((= etype "LWPOLYLINE")
       (setq obj (vlax-ename->vla-object ent))
       (BR:Snap-WriteLine fp (strcat "Closed|" (if (= (vla-get-Closed obj) :vlax-true) "YES" "NO")))
       (BR:Snap-WriteLine fp (strcat "Area|" (BR:Snap-Num (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-get-Area (list obj))) 0.0 (vla-get-Area obj)) 2)))
       (BR:Snap-WriteLine fp (strcat "Length|" (BR:Snap-Num (vla-get-Length obj) 4)))
       (BR:Snap-WriteLine fp (strcat "Vertices|" (itoa (fix (/ (cdr (assoc 90 ed)) 1)))))
      )
      
      ;; CIRCLE
      ((= etype "CIRCLE")
       (BR:Snap-WriteLine fp (strcat "Center|" 
         (BR:Snap-Num (car (cdr (assoc 10 ed))) 4) "," 
         (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4)))
       (BR:Snap-WriteLine fp (strcat "Radius|" (BR:Snap-Num (cdr (assoc 40 ed)) 4)))
      )
      
      ;; ARC
      ((= etype "ARC")
       (BR:Snap-WriteLine fp (strcat "Center|" 
         (BR:Snap-Num (car (cdr (assoc 10 ed))) 4) "," 
         (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4)))
       (BR:Snap-WriteLine fp (strcat "Radius|" (BR:Snap-Num (cdr (assoc 40 ed)) 4)))
       (BR:Snap-WriteLine fp (strcat "StartAngle|" (BR:Snap-Num (* (/ (cdr (assoc 50 ed)) pi) 180.0) 2)))
       (BR:Snap-WriteLine fp (strcat "EndAngle|" (BR:Snap-Num (* (/ (cdr (assoc 51 ed)) pi) 180.0) 2)))
      )
      
      ;; INSERT (block reference)
      ((= etype "INSERT")
       (setq obj (vlax-ename->vla-object ent))
       (BR:Snap-WriteLine fp (strcat "BlockName|" (BR:Snap-SafeStr (cdr (assoc 2 ed)))))
       (BR:Snap-WriteLine fp (strcat "InsPoint|" 
         (BR:Snap-Num (car (cdr (assoc 10 ed))) 4) "," 
         (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4)))
       (BR:Snap-WriteLine fp (strcat "Rotation|" (BR:Snap-Num (cdr (assoc 50 ed)) 2)))
       (BR:Snap-WriteLine fp (strcat "Scale|" (BR:Snap-Num (cdr (assoc 41 ed)) 4)))
       ;; Attributes
       (if (= (vla-get-HasAttributes obj) :vlax-true)
         (foreach att (vlax-invoke obj 'GetAttributes)
           (BR:Snap-WriteLine fp (strcat "Attr:" 
             (BR:Snap-SafeStr (vla-get-TagString att)) "|" 
             (BR:Snap-SafeStr (vla-get-TextString att))))
         )
       )
      )
      
      ;; TEXT
      ((= etype "TEXT")
       (BR:Snap-WriteLine fp (strcat "Content|" (BR:Snap-SafeStr (cdr (assoc 1 ed)))))
       (BR:Snap-WriteLine fp (strcat "Height|" (BR:Snap-Num (cdr (assoc 40 ed)) 4)))
       (BR:Snap-WriteLine fp (strcat "Position|" 
         (BR:Snap-Num (car (cdr (assoc 10 ed))) 4) "," 
         (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4)))
      )
      
      ;; MTEXT
      ((= etype "MTEXT")
       (BR:Snap-WriteLine fp (strcat "Content|" (BR:Snap-SafeStr (cdr (assoc 1 ed)))))
       (BR:Snap-WriteLine fp (strcat "Height|" (BR:Snap-Num (cdr (assoc 40 ed)) 4)))
       (BR:Snap-WriteLine fp (strcat "Width|" (BR:Snap-Num (cdr (assoc 41 ed)) 4)))
       (BR:Snap-WriteLine fp (strcat "Position|" 
         (BR:Snap-Num (car (cdr (assoc 10 ed))) 4) "," 
         (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4)))
      )
      
      ;; Default -- dump key DXF groups
      (T
       (foreach pair ed
         (if (member (car pair) '(10 11 40 41 42 50 51 62 8 2 1))
           (BR:Snap-WriteLine fp (strcat "DXF" (itoa (car pair)) "|" (BR:Snap-SafeStr (cdr pair))))
         )
       )
      )
    )
    (setq i (1+ i))
  )
)

;;; ===== MAIN COMMANDS =====

(defun c:BR:Snap (/ *error* old_cmdecho fp t1)
  "Full drawing snapshot -- exports everything to snapshot.txt"
  (setq old_cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (defun *error* (msg)
    (if fp (BR:Snap-CloseFile fp))
    (setvar "CMDECHO" old_cmdecho)
    (if (/= msg "Function cancelled") (princ (strcat "\nSnapshot error: " msg)))
    (princ)
  )
  
  (setq t1 (getvar "MILLISECS"))
  (princ "\nBR:Snap -- Exporting drawing snapshot...")
  
  (setq fp (BR:Snap-OpenFile "snapshot.txt"))
  (if fp
    (progn
      (BR:Snap-DrawingInfo fp)
      (princ " layers")
      (BR:Snap-Layers fp)
      (princ " entities")
      (BR:Snap-EntitySummary fp)
      (princ " blocks")
      (BR:Snap-Blocks fp)
      (princ " text")
      (BR:Snap-TextContent fp)
      (princ " xrefs")
      (BR:Snap-Xrefs fp)
      (princ " styles")
      (BR:Snap-Styles fp)
      (BR:Snap-Linetypes fp)
      
      ;; Footer
      (BR:Snap-Section fp "END")
      (BR:Snap-WriteLine fp (strcat "GeneratedBy|BR:Snap v1.0"))
      (BR:Snap-WriteLine fp (strcat "ElapsedMs|" (itoa (- (getvar "MILLISECS") t1))))
      
      (BR:Snap-CloseFile fp)
      (princ (strcat "\nSnapshot saved: C:\\CAD_IO\\logs\\snapshot.txt ("
                     (itoa (- (getvar "MILLISECS") t1)) "ms)"))
    )
  )
  
  (setvar "CMDECHO" old_cmdecho)
  (princ)
)

(defun c:BR:SnapQ (/ *error* old_cmdecho fp t1)
  "Quick snapshot -- layers + entity counts only"
  (setq old_cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (defun *error* (msg)
    (if fp (BR:Snap-CloseFile fp))
    (setvar "CMDECHO" old_cmdecho)
    (if (/= msg "Function cancelled") (princ (strcat "\nSnapshot error: " msg)))
    (princ)
  )
  
  (setq t1 (getvar "MILLISECS"))
  (princ "\nBR:SnapQ -- Quick snapshot...")
  
  (setq fp (BR:Snap-OpenFile "snapshot_quick.txt"))
  (if fp
    (progn
      (BR:Snap-DrawingInfo fp)
      (BR:Snap-Layers fp)
      (BR:Snap-EntitySummary fp)
      (BR:Snap-Section fp "END")
      (BR:Snap-WriteLine fp (strcat "GeneratedBy|BR:SnapQ v1.0"))
      (BR:Snap-CloseFile fp)
      (princ (strcat "\nQuick snapshot saved (" (itoa (- (getvar "MILLISECS") t1)) "ms)"))
    )
  )
  
  (setvar "CMDECHO" old_cmdecho)
  (princ)
)

(defun c:BR:SnapSel (/ *error* old_cmdecho fp ss t1)
  "Snapshot selected entities -- select first, then run"
  (setq old_cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (defun *error* (msg)
    (if fp (BR:Snap-CloseFile fp))
    (setvar "CMDECHO" old_cmdecho)
    (if (/= msg "Function cancelled") (princ (strcat "\nSnapshot error: " msg)))
    (princ)
  )
  
  (princ "\nBR:SnapSel -- Select entities to snapshot: ")
  (setq ss (ssget))
  
  (if (and ss (> (sslength ss) 0))
    (progn
      (setq t1 (getvar "MILLISECS"))
      (setq fp (BR:Snap-OpenFile "snapshot_selection.txt"))
      (if fp
        (progn
          (BR:Snap-DrawingInfo fp)
          (BR:Snap-Section fp "SELECTION INFO")
          (BR:Snap-WriteLine fp (strcat "EntityCount|" (itoa (sslength ss))))
          (BR:Snap-SelectedEntities fp ss)
          (BR:Snap-Section fp "END")
          (BR:Snap-WriteLine fp (strcat "GeneratedBy|BR:SnapSel v1.0"))
          (BR:Snap-CloseFile fp)
          (princ (strcat "\nSelection snapshot saved: " (itoa (sslength ss)) 
                         " entities (" (itoa (- (getvar "MILLISECS") t1)) "ms)"))
        )
      )
    )
    (princ "\nNo entities selected.")
  )
  
  (setvar "CMDECHO" old_cmdecho)
  (princ)
)

;;; ===== HOT RELOAD =====

(defun c:BR:Reload (/ main-path files f count)
  "Reload BR.lsp first, then fall back to module-by-module reload."
  (setq main-path "C:\\CAD_IO\\lisp\\BR.lsp"
        count     0)
  (princ "\nReloading BR tools from C:\\CAD_IO\\lisp\\:")
  (cond
    ((findfile main-path)
     (princ "\n  Loading: BR.lsp")
     (load main-path)
     (setq count 1)
    )
    (t
     (setq files (vl-directory-files "C:\\CAD_IO\\lisp" "BR_*.lsp" 1))
     (if files
       (foreach f files
         (princ (strcat "\n  Loading: " f))
         (load (strcat "C:\\CAD_IO\\lisp\\" f))
         (setq count (1+ count))
       )
       (princ "\n  No BR.lsp or BR_*.lsp files found.")
     )
    )
  )
  (if (> count 0)
    (princ (strcat "\n" (itoa count) " BR load target(s) processed."))
  )
  (princ)
)

;;;; -- DCL DIALOG (BR Suite integration) --------------------------

(defun BR:SnapshotDCL (/ dcl-path dcl-id done d-mode)

  (setq dcl-path (findfile "BR_Snapshot.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat "BR_Snapshot.dcl not found.\n\n"
                "Make sure BR_Snapshot.dcl is in the same folder as the LSP files\n"
                "and that folder is on AutoCAD's support path."))
      (exit)
    )
  )

  (setq d-mode "mode_full")

  (setq dcl-id (load_dialog dcl-path))
  (if (< dcl-id 0)
    (progn (alert (strcat "Cannot load DCL:\n" dcl-path)) (exit))
  )
  (if (not (new_dialog "br_snapshot" dcl-id))
    (progn
      (unload_dialog dcl-id)
      (alert "Cannot initialize br_snapshot dialog.")
      (exit)
    )
  )

  ;; Default mode
  (set_tile "mode_full" "1")
  (set_tile "snap_desc"
    "Full snapshot: layers, entities, blocks, text, xrefs, styles, linetypes.")

  ;; Actions -- update description on radio change
  (action_tile "mode_full"
    (strcat "(setq d-mode \"mode_full\")"
            "(set_tile \"snap_desc\""
            "  \"Full snapshot: layers, entities, blocks, text, xrefs, styles, linetypes.\")"))

  (action_tile "mode_quick"
    (strcat "(setq d-mode \"mode_quick\")"
            "(set_tile \"snap_desc\""
            "  \"Quick snapshot: layers + entity counts only. Fastest option.\")"))

  (action_tile "mode_sel"
    (strcat "(setq d-mode \"mode_sel\")"
            "(set_tile \"snap_desc\""
            "  \"Selection snapshot: prompts you to select entities, then exports detail.\")"))

  (action_tile "mode_pro"
    (strcat "(setq d-mode \"mode_pro\")"
            "(set_tile \"snap_desc\""
            "  \"Pro snapshot: everything + geometry metrics, text bounds, viewports, dims.\")"))

  (action_tile "accept" "(done_dialog 1)")
  (action_tile "cancel" "(done_dialog 0)")

  (setq done (start_dialog))
  (unload_dialog dcl-id)

  ;; -- Dispatch -------------------------------------------------
  (if (= done 1)
    (cond
      ((= d-mode "mode_full")  (c:BR:Snap))
      ((= d-mode "mode_quick") (c:BR:SnapQ))
      ((= d-mode "mode_sel")   (c:BR:SnapSel))
      ((= d-mode "mode_pro")
       ;; SnapPro depends on BR_SnapPro.lsp being loaded
       (if (fboundp 'c:BR:SnapPro)
         (c:BR:SnapPro)
         (alert "BR_SnapPro module not loaded.\nLoad BR_SnapPro.lsp first.")
       )
      )
    )
  )
)


;;;; -- COMMANDS --------------------------------------------------

(defun C:BR_SNAP (/)
  (c:BR:Snap)
  (princ)
)

(defun C:BR_SNAPQ (/)
  (c:BR:SnapQ)
  (princ)
)

(defun C:BR_SNAPSEL (/)
  (c:BR:SnapSel)
  (princ)
)


;;;; -- MODULE LOADED ---------------------------------------------

(princ "\n  BR_Snapshot module loaded.  Commands: BR:Snap  BR:SnapQ  BR:SnapSel  BR:Reload")
(princ)
