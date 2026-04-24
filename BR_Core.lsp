;;; ================================================================
;;; BR_Core.lsp  |  Brelje & Race CAD Tools Suite  |  Shared Core
;;; ================================================================
;;; Contains: configuration, file type database, accessors,
;;;           string/path helpers, project detection, path builders,
;;;           folder creation, drawing creation, open helpers.
;;;
;;; Source of truth: original BR.lsp v1.0
;;; ================================================================
(vl-load-com)

;;;; -- CONFIGURATION -----------------------------------------------

(setq *BR:TEMPLATE*
      "J:\\LIB\\ACAD-custom\\Drawing Template-dwt\\$$$BR TEMPLATE-3D-2026.dwt")

(setq *BR:ROOT* "J:\\J\\")

(setq *BR:VER* "2.0")


;;;; -- FILE TYPE DATABASE ------------------------------------------
;;;;
;;;; Each real entry:
;;;;   (display-label  type-code  subfolder  multi-p  desc-req-p)
;;;;
;;;;   display-label  -- string shown in the list box / CMD list
;;;;   type-code      -- exact string used in the filename
;;;;   subfolder      -- "" = place in root project/sub folder
;;;;                    anything else = subfolder name under root
;;;;   multi-p        -- T = multiple files of this type are allowed
;;;;   desc-req-p     -- T = description field is mandatory
;;;;
;;;; Separator entries (category headers, not selectable):
;;;;   (display-label  nil  nil  nil  nil)
;;;;

(setq *BR:FT*
  (list
  ;;  Display                           Code                      Folder              Mlt   Req
  ;;  -----------------------------------------------------------------------------------------
  ;;  Plot / Sheet Drawings  (root of project/sub folder)
  ;;  -----------------------------------------------------------------------------------------
    (list "COVER"                        "COVER"                   ""                  nil   nil)
    (list "DEMO"                         "DEMO"                    ""                  nil   nil)
    (list "DETAIL"                       "DETAIL"                  ""                  nil   nil)
    (list "ELEC"                         "ELEC"                    ""                  nil   nil)
    (list "EROSION"                      "EROSION"                 ""                  nil   nil)
    (list "GRAD"                         "GRAD"                    ""                  nil   nil)
    (list "HYDRO"                        "HYDRO"                   ""                  nil   nil)
    (list "KEY"                          "KEY"                     ""                  nil   nil)
    (list "LAYOUT"                       "LAYOUT"                  ""                  nil   nil)
    (list "NOTE"                         "NOTE"                    ""                  nil   nil)
    (list "PAVEMENT"                     "PAVEMENT"                ""                  nil   nil)
    (list "PLAN"                         "PLAN"                    ""                  nil   nil)
    (list "PLAN-PROFILE"                 "PLAN-PROFILE"            ""                  nil   nil)
    (list "SCHEMATIC"                    "SCHEMATIC"               ""                  nil   nil)
    (list "SECTION"                      "SECTION"                 ""                  nil   nil)
    (list "SIGN-STRIPE"                  "SIGN-STRIPE"             ""                  nil   nil)
    (list "SITE"                         "SITE"                    ""                  nil   nil)
    (list "TANK"                         "TANK"                    ""                  nil   nil)
    (list "TENT"                         "TENT"                    ""                  nil   nil)
    (list "UTIL"                         "UTIL"                    ""                  nil   nil)
    (list "WATER POLLUTION CONTROL"      "WATER POLLUTION CONTROL" ""                  nil   nil)
  ;;  -----------------------------------------------------------------------------------------
  ;;  Separator
    (list "  --  BR  ---------------------------------------------" nil nil nil nil)
  ;;  BR Subfolder
  ;;  -----------------------------------------------------------------------------------------
    (list "[BR]  $MASTER XREF"           "$MASTER XREF"            "BR"                nil   nil)
    (list "[BR]  BR-GRAD"                "BR-GRAD"                 "BR"                nil   nil)
    (list "[BR]  BR-IMAGE"               "BR-IMAGE"                "BR"                t     nil)
    (list "[BR]  BR-MSVIEW"              "BR-MSVIEW"               "BR"                nil   nil)
    (list "[BR]  BR-NOTE"                "BR-NOTE"                 "BR"                nil   nil)
    (list "[BR]  BR-PROFILE VIEW"        "BR-PROFILE VIEW"         "BR"                nil   nil)
    (list "[BR]  BR-SITE"                "BR-SITE"                 "BR"                nil   nil)
    (list "[BR]  BR-TREE-Save & Remove"  "BR-TREE-Save & Remove"   "BR"                nil   nil)
    (list "[BR]  BR-UTIL"                "BR-UTIL"                 "BR"                nil   nil)
  ;;  -----------------------------------------------------------------------------------------
  ;;  Separator
    (list "  --  DESIGN  ------------------------------------------" nil nil nil nil)
  ;;  DESIGN Subfolder
  ;;  -----------------------------------------------------------------------------------------
    (list "[DESIGN]  DESIGN"             "DESIGN"                  "DESIGN"            nil   nil)
  ;;  -----------------------------------------------------------------------------------------
  ;;  Separator
    (list "  --  EXHIBIT  -----------------------------------------" nil nil nil nil)
  ;;  EXHIBIT Subfolder
  ;;  -----------------------------------------------------------------------------------------
    (list "[EXHIBIT]  EXHIBIT"           "EXHIBIT"                 "EXHIBIT"           t     t)
  ;;  -----------------------------------------------------------------------------------------
  ;;  Separator
    (list "  --  OBJECT  ------------------------------------------" nil nil nil nil)
  ;;  OBJECT Subfolder
  ;;  -----------------------------------------------------------------------------------------
    (list "[OBJECT]  Alignment"          "OBJECT-Alignment"        "OBJECT"            t     t)
    (list "[OBJECT]  Corridor"           "OBJECT-Corridor"         "OBJECT"            t     t)
    (list "[OBJECT]  Grading"            "OBJECT-Grading"          "OBJECT"            t     t)
    (list "[OBJECT]  Pipe Network"       "OBJECT-Pipe Network"     "OBJECT"            t     t)
    (list "[OBJECT]  Surface"            "OBJECT-Surface"          "OBJECT"            t     t)
  ;;  -----------------------------------------------------------------------------------------
  ;;  Separator
    (list "  --  VEHICLE TRACKING  --------------------------------" nil nil nil nil)
  ;;  VEHICLE TRACKING Subfolder
  ;;  -----------------------------------------------------------------------------------------
    (list "[VEH TRACKING]  VEHICLE TRACKING" "VEHICLE TRACKING"   "VEHICLE TRACKING"  t     t)
  )
)


;;;; -- FILE TYPE ACCESSORS -----------------------------------------

(defun BR:FT:Disp    (e) (nth 0 e))          ; display label
(defun BR:FT:Code    (e) (nth 1 e))          ; filename type code
(defun BR:FT:Folder  (e) (nth 2 e))          ; subfolder (or "")
(defun BR:FT:Multi?  (e) (nth 3 e))          ; multiple instances allowed?
(defun BR:FT:Req?    (e) (nth 4 e))          ; description required?
(defun BR:FT:Sep?    (e) (null (nth 1 e)))   ; is this a separator row?


;;;; -- STRING / PATH UTILITIES ------------------------------------

;; Split string STR on single-character delimiter DELIM.
;; Returns a list of substrings.
(defun BR:Split (str delim / tok res i ch)
  (setq tok "" res nil i 1)
  (while (<= i (strlen str))
    (setq ch (substr str i 1))
    (if (= ch delim)
      (progn (setq res (append res (list tok)) tok ""))
      (setq tok (strcat tok ch))
    )
    (setq i (1+ i))
  )
  (append res (list tok))
)

;; Left-pad string S to minimum length W using fill character C.
(defun BR:PadL (s w c)
  (while (< (strlen s) w) (setq s (strcat c s)))
  s
)

;; Normalize a value to a string for UI/path assembly.
;; Non-string inputs become "" so DCL callback booleans do not break strcat.
(defun BR:SafeStr (val)
  (if (= (type val) 'STR) val "")
)

;; Safely parse a DCL list-box index. Invalid/non-string values become -1.
(defun BR:DCL:SafeIndex (val / txt)
  (setq txt (BR:SafeStr val))
  (if (> (strlen txt) 0)
    (atoi txt)
    -1
  )
)

;; Like BR:DCL:SafeIndex, but returns nil when the tile has no valid value.
(defun BR:DCL:SafeIndexOrNil (val / txt)
  (setq txt (BR:SafeStr val))
  (if (> (strlen txt) 0)
    (atoi txt)
    nil
  )
)

;; Safely parse a DCL numeric input. Invalid/non-string values become 0.0.
(defun BR:DCL:SafeReal (val / txt)
  (setq txt (BR:SafeStr val))
  (if (> (strlen txt) 0)
    (atof txt)
    0.0
  )
)

;; Remove trailing backslash from path string.
(defun BR:Strip\ (p)
  (if (and (> (strlen p) 0) (= (substr p (strlen p) 1) "\\"))
    (substr p 1 (1- (strlen p)))
    p
  )
)

;; Return T if S is a non-empty string composed entirely of digits 0-9.
(defun BR:Digits? (s / i ok ch)
  (if (= (strlen s) 0)
    nil
    (progn
      (setq i 1 ok t)
      (while (and ok (<= i (strlen s)))
        (setq ch (substr s i 1))
        (if (not (member ch '("0" "1" "2" "3" "4" "5" "6" "7" "8" "9")))
          (setq ok nil)
        )
        (setq i (1+ i))
      )
      ok
    )
  )
)

;; Validate that S is a project number in digits.digits format
;; (one or more digits, dot, one or more digits).
;; NOTE: Flexible -- does NOT enforce fixed digit counts.
(defun BR:ValidProj? (s / p)
  (and (= (type s) 'STR)
       (> (strlen s) 2)
       (setq p (BR:Split s "."))
       (= (length p) 2)
       (BR:Digits? (car p))
       (BR:Digits? (cadr p))
  )
)

;; Create the full directory tree for PATH (equivalent to mkdir -p).
;; Safely handles already-existing segments.
(defun BR:Mkdirp (path / parts acc)
  (setq path  (BR:Strip\ path)
        parts (BR:Split path "\\")
        acc   "")
  (foreach seg parts
    (setq acc (if (= acc "") seg (strcat acc "\\" seg)))
    ;; Skip drive root (e.g. "J:") -- can't mkdir that
    (if (and (> (strlen acc) 2)
             (not (vl-file-directory-p acc)))
      (vl-mkdir acc)
    )
  )
  ;; Return T if directory now exists
  (vl-file-directory-p path)
)


;;;; -- JSON UTILITIES ----------------------------------------------

;; Escape a string for safe inclusion in a JSON value.
(defun BR:JSONEscape (s / result i ch)
  (setq result "" i 1)
  (while (<= i (strlen s))
    (setq ch (substr s i 1))
    (cond
      ((= ch "\\") (setq result (strcat result "\\\\")))
      ((= ch "\"") (setq result (strcat result "\\\"")))
      (t           (setq result (strcat result ch)))
    )
    (setq i (1+ i))
  )
  result
)

;; Unescape a JSON string value.
(defun BR:JSONUnescape (s / result i ch nxt)
  (setq result "" i 1)
  (while (<= i (strlen s))
    (setq ch (substr s i 1))
    (if (and (= ch "\\") (<= (1+ i) (strlen s)))
      (progn
        (setq nxt (substr s (1+ i) 1))
        (cond
          ((= nxt "\\") (setq result (strcat result "\\")))
          ((= nxt "\"") (setq result (strcat result "\"")))
          ((= nxt "n")  (setq result (strcat result "\n")))
          (t (setq result (strcat result ch nxt)))
        )
        (setq i (+ i 2))
      )
      (progn
        (setq result (strcat result ch))
        (setq i (1+ i))
      )
    )
  )
  result
)

;; Parse one JSON line like:  "key": "value",
;; Returns (key . value) or nil for non-data lines.
(defun BR:ParseJSONLine (line / sep key vstart vlen)
  (setq line (vl-string-trim " \t\r\n" line))
  (if (member line '("{" "}" ""))
    nil
    (progn
      (if (= (substr line (strlen line) 1) ",")
        (setq line (substr line 1 (1- (strlen line))))
      )
      (setq sep (vl-string-search "\": \"" line))
      (if sep
        (progn
          (setq key    (substr line 2 (1- sep)))
          (setq vstart (+ sep 5))
          (setq vlen   (- (strlen line) vstart))
          (if (>= vlen 0)
            (cons key (BR:JSONUnescape (substr line vstart vlen)))
            (cons key "")
          )
        )
        nil
      )
    )
  )
)

;; Read a flat JSON file into an association list.
(defun BR:ReadJSON (path / fp line pair alist)
  (setq fp (open path "r"))
  (if fp
    (progn
      (while (setq line (read-line fp))
        (setq pair (BR:ParseJSONLine line))
        (if pair (setq alist (cons pair alist)))
      )
      (close fp)
      (reverse alist)
    )
    nil
  )
)

;; Write an association list as a flat JSON file.
(defun BR:WriteJSON (path alist / fp i count pair)
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "{" fp)
      (setq i 0 count (length alist))
      (foreach pair alist
        (setq i (1+ i))
        (write-line
          (strcat "  \"" (car pair) "\": \""
                  (BR:JSONEscape (BR:SafeStr (cdr pair)))
                  "\""
                  (if (< i count) "," ""))
          fp)
      )
      (write-line "}" fp)
      (close fp)
      t
    )
    nil
  )
)


;;;; -- CONFIGURATION LOADER ---------------------------------------
;;; Reads BR_Config.json from C:\CAD_IO\data\ and populates globals.
;;; List values are pipe-delimited strings split into LISP lists.
;;; If the config file is missing, hardcoded fallbacks are used.

(setq *BR:CFG-PATH* "C:\\CAD_IO\\data\\BR_Config.json")

;; Split a pipe-delimited string into a list.
(defun BR:PipeSplit (s / result)
  (if (and s (> (strlen s) 0))
    (BR:Split s "|")
    nil
  )
)

;; Load configuration. Call once during BR_Core initialization.
(defun BR:LoadConfig (/ cfg val)
  (setq cfg nil)
  (if (findfile *BR:CFG-PATH*)
    (setq cfg (BR:ReadJSON *BR:CFG-PATH*))
  )
  ;; Lookup tables -- pipe-delimited in JSON, split into lists.
  ;; Each has a hardcoded fallback if the key is missing or file absent.
  (setq val (if cfg (cdr (assoc "project_setup_configs" cfg)) nil))
  (setq *BR:CFG:CONFIGS*
    (if val (BR:PipeSplit val)
      '("School_Small" "School_Large" "BR_Plan" "BR_PlanProfile"
        "SR_Plan" "SR_PlanProfile")))

  (setq val (if cfg (cdr (assoc "tb_sizes" cfg)) nil))
  (setq *BR:CFG:TB-SIZES*
    (if val (BR:PipeSplit val)
      '("11x17" "22x34" "24x36" "30x42")))

  (setq val (if cfg (cdr (assoc "tb_types" cfg)) nil))
  (setq *BR:CFG:TB-TYPES*
    (if val (BR:PipeSplit val)
      '("BR" "EXHIBIT" "DSA" "QKA" "SR")))

  (setq val (if cfg (cdr (assoc "project_statuses" cfg)) nil))
  (setq *BR:CFG:STATUSES*
    (if val (BR:PipeSplit val)
      '("SD" "DD" "CD")))

  (princ (strcat "\n  BR Config: "
    (if cfg "loaded from BR_Config.json" "using defaults")))
)

;; Run config loader at startup
(BR:LoadConfig)


;;;; -- PROJECT NUMBER DETECTION ------------------------------------

;; Attempt to read the project number from the filename of the
;; currently active drawing.  The first space-delimited token of a
;; properly named B&R drawing is always the project number.
;; Returns the string (e.g. "5212.00") or nil if not detectable.
(defun BR:DetectProj (/ nm base tok)
  (setq nm (getvar "DWGNAME"))
  (if (and nm
           (> (strlen nm) 0)
           (not (= (strcase (vl-filename-base nm)) "DRAWING")))
    (progn
      (setq base (vl-filename-base nm)
            tok  (car (BR:Split base " ")))
      (if (BR:ValidProj? tok) tok nil)
    )
    nil
  )
)


;;;; -- PATH BUILDERS -----------------------------------------------

;; Base folder for a project/subnumber.
;; "5212.00"  ->  J:\J\5212\dwg\5212 00\
(defun BR:BaseDir (proj / p pn su)
  (setq p  (BR:Split proj ".")
        pn (car p)
        su (cadr p))
  (strcat *BR:ROOT* pn "\\dwg\\" pn " " su "\\")
)

;; Full target directory: base + optional subfolder.
(defun BR:TargetDir (proj sub)
  (setq proj (BR:SafeStr proj)
        sub  (BR:SafeStr sub))
  (if (or (null sub) (= sub ""))
    (BR:BaseDir proj)
    (strcat (BR:BaseDir proj) sub "\\")
  )
)

;; Assemble the filename only (no path, no extension).
;; Pattern:  ####.## [PHASE-]TYPECODE[-description]
(defun BR:BuildName (proj phase code desc)
  (setq proj  (BR:SafeStr proj)
        phase (BR:SafeStr phase)
        code  (BR:SafeStr code)
        desc  (BR:SafeStr desc))
  (strcat
    proj " "
    (if (and phase (> (strlen phase) 0))
      (strcat (strcase phase) "-")
      ""
    )
    code
    (if (and desc (> (strlen desc) 0))
      (strcat "-" desc)
      ""
    )
  )
)

;; Complete .dwg target path.
(defun BR:FullPath (proj phase code desc sub)
  (strcat (BR:TargetDir proj sub)
          (BR:BuildName proj phase code desc)
          ".dwg")
)


;;;; -- CORE CREATE FUNCTION ----------------------------------------

;; Create a new drawing by copying the BR template to the correct
;; location with the correct name.
;; Returns the full path string on success, nil on failure.
(defun BR:Create (proj phase code desc sub / dir path)
  (setq dir  (BR:TargetDir proj sub)
        path (BR:FullPath  proj phase code desc sub))
  (cond
    ;; File already exists -- warn, do nothing
    ((findfile path)
     (alert
       (strcat
         "FILE ALREADY EXISTS -- nothing was created.\n\n"
         path
       )
     )
     nil
    )
    ;; Template missing -- abort
    ((not (findfile *BR:TEMPLATE*))
     (alert
       (strcat
         "TEMPLATE FILE NOT FOUND -- check configuration in BR_Core.lsp.\n\n"
         *BR:TEMPLATE*
       )
     )
     nil
    )
    ;; All clear -- create directory tree and copy template
    (t
     (if (not (BR:Mkdirp dir))
       (progn
         (alert (strcat "CANNOT CREATE FOLDER -- check permissions:\n\n" dir))
         nil
       )
       (if (vl-file-copy *BR:TEMPLATE* path nil)
         (progn
           (princ (strcat "\n  Created: " path))
           path
         )
         (progn
           (alert
             (strcat "FILE COPY FAILED -- check permissions:\n\n" dir))
           nil
         )
       )
     )
    )
  )
)

;; Open a .dwg file in AutoCAD without triggering prompts.
;; Wraps errors gracefully (e.g. file already open, locked).
(defun BR:Open (path / result)
  (setq result
    (vl-catch-all-apply
      'vla-open
      (list (vla-get-documents (vlax-get-acad-object)) path :vlax-false)
    )
  )
  (if (vl-catch-all-error-p result)
    (princ
      (strcat "\n  Note: Auto-open failed.  "
              "Open manually from:\n  " path))
  )
)

;; Prompt the user and open if desired.
(defun BR:OfferOpen (path)
  (initget "Yes No")
  (if (not (= (getkword "\n  Open the new drawing? [Yes/No] <Yes>: ") "No"))
    (BR:Open path)
  )
)


;;;; -- COMMAND FRAMEWORK HELPERS ----------------------------------

;; Save a list of system variable names.
;; Returns an assoc list of (name . value).
;; Usage: (setq saved (BR:SaveSysvars '("CMDECHO" "CLAYER" "CTAB")))
(defun BR:SaveSysvars (varnames / result vn val)
  (setq result nil)
  (foreach vn varnames
    (setq val (getvar vn))
    (if val (setq result (cons (cons vn val) result)))
  )
  (reverse result)
)

;; Restore system variables from an assoc list produced by BR:SaveSysvars.
;; Uses vl-catch-all-apply to handle cases where a sysvar can't be set
;; (e.g., CLAYER pointing to a frozen layer, CTAB to a deleted layout).
(defun BR:RestoreSysvars (saved / pair)
  (foreach pair saved
    (if (cdr pair)
      (vl-catch-all-apply 'setvar (list (car pair) (cdr pair)))
    )
  )
)

;; Begin an undo group. Returns T (for use as undoStarted flag).
(defun BR:BeginUndo ()
  (vla-StartUndoMark
    (vla-get-ActiveDocument (vlax-get-Acad-Object)))
  T
)

;; End an undo group if flag is non-nil.
(defun BR:EndUndo (flag)
  (if flag
    (vla-EndUndoMark
      (vla-get-ActiveDocument (vlax-get-Acad-Object)))
  )
)

;; Return current date as YYMMDD string.
;; Useful for naming output files, folders, etc.
(defun BR:DateStr (/ cdate)
  (setq cdate (rtos (getvar "CDATE") 2 0))
  (strcat (substr cdate 3 2) (substr cdate 5 2) (substr cdate 7 2))
)


;;;; -- LINETYPE LOADING ---------------------------------------------

;; Paths to custom linetype files (searched in order after acad.lin).
;; brlines.lin  -- fencing, erosion control, swales, hazard zones
;; brlines-UTIL.lin -- utility linetypes with pipe diameter variants
(setq *BR:LIN-FILES*
  (list
    "brlines.lin"
    "brlines-UTIL.lin"
  )
)

;; Load a single linetype by name. Search order:
;;   already loaded ? acad.lin ? acadiso.lin ? each custom .lin file
;; Returns T if available, nil if not found anywhere.
(defun BR:LoadLinetype (ltname / doc ltypes result found linfile)
  (setq doc    (vla-get-activedocument (vlax-get-acad-object))
        ltypes (vla-get-linetypes doc))
  ;; Check if already loaded
  (setq result (vl-catch-all-apply 'vla-item (list ltypes ltname)))
  (if (not (vl-catch-all-error-p result))
    T
    (progn
      ;; Try acad.lin
      (setq result (vl-catch-all-apply
        'vla-load (list ltypes ltname "acad.lin")))
      (if (not (vl-catch-all-error-p result))
        T
        (progn
          ;; Try acadiso.lin
          (setq result (vl-catch-all-apply
            'vla-load (list ltypes ltname "acadiso.lin")))
          (if (not (vl-catch-all-error-p result))
            T
            ;; Try each custom .lin file
            (progn
              (setq found nil)
              (foreach linfile *BR:LIN-FILES*
                (if (and (not found)
                         linfile
                         (> (strlen linfile) 0)
                         (findfile linfile))
                  (progn
                    (setq result (vl-catch-all-apply
                      'vla-load (list ltypes ltname linfile)))
                    (if (not (vl-catch-all-error-p result))
                      (setq found T)
                    )
                  )
                )
              )
              found
            )
          )
        )
      )
    )
  )
)

;; Load all linetypes referenced in *BR:LAYER-CATS*.
;; Skips CONTINUOUS and already-loaded types. Returns count loaded.
(defun BR:LoadAllLinetypes (/ seen count cat ly lt)
  (setq seen nil count 0)
  (foreach cat *BR:LAYER-CATS*
    (foreach ly (BR:LC:Layers cat)
      (setq lt (strcase (BR:LY:LType ly)))
      (if (and (not (= lt "CONTINUOUS"))
               (not (member lt seen)))
        (progn
          (setq seen (cons lt seen))
          (if (BR:LoadLinetype (BR:LY:LType ly))
            (setq count (1+ count))
            (princ (strcat "\n  BR Warning: Linetype not found: "
                           (BR:LY:LType ly)))
          )
        )
      )
    )
  )
  count
)


;;;; -- MODULE LOADER HELPER ----------------------------------------

(defun BR:LoadModule (filename / fpath)
  (setq fpath (findfile filename))
  (if fpath
    (progn (load fpath) t)
    (progn
      (princ (strcat "\n  BR Warning: Cannot find " filename
                     " on AutoCAD support path."))
      nil
    )
  )
)


;;;; -- CORE LOADED -------------------------------------------------

(princ (strcat "\n  BR_Core v" *BR:VER* " loaded."))
(princ)

;;; End of BR_Core.lsp
