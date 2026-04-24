;;; ================================================================
;;; BR_SnapPro.lsp  |  Brelje & Race CAD Tools  |  Enhanced Snapshot
;;; ================================================================
;;; Module: Drawing Portal -- Enhanced Snapshot Exporter
;;; Description: Extended export with geometry metrics, text bounds, attributes, viewports
;;; Version: 2026-03-25
;;; Safety: READ-ONLY -- queries drawing data only
;;;
;;; Commands:
;;;   BR:SnapPro  -- Full enhanced snapshot (everything BR:Snap does + geometry, text bounds, attrs, viewports)
;;;
;;; Output: C:\CAD_IO\logs\snapshot_pro.txt
;;; Depends: BR_Snapshot.lsp (for base helpers)
;;; ================================================================

(vl-load-com)

;;; ===== GEOMETRY METRICS =====

(defun BR:SnapPro-Geometry (fp / ss i ent ed obj etype elayer len area closed pts
                              line-lengths poly-lengths circle-data arc-data spline-data
                              key total-length count item)
  "Export geometry measurements: lengths, areas, vertex counts by layer"
  
  ;; Collect polyline metrics
  (BR:Snap-Section fp "POLYLINE METRICS")
  (BR:Snap-WriteLine fp "Layer|Closed|Length|Area|Vertices|Handle")
  
  (setq ss (ssget "X" '((0 . "LWPOLYLINE"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq obj (vlax-ename->vla-object ent))
        (setq elayer (cdr (assoc 8 ed)))
        (setq closed (if (= (vla-get-Closed obj) :vlax-true) "YES" "NO"))
        (setq len (vla-get-Length obj))
        (setq area (if (= closed "YES")
                     (if (vl-catch-all-error-p 
                           (vl-catch-all-apply 'vla-get-Area (list obj)))
                       0.0
                       (vla-get-Area obj))
                     0.0))
        (setq pts (fix (cdr (assoc 90 ed))))
        
        (BR:Snap-WriteLine fp
          (strcat
            (BR:Snap-SafeStr elayer) "|"
            closed "|"
            (BR:Snap-Num len 4) "|"
            (BR:Snap-Num area 2) "|"
            (itoa pts) "|"
            (cdr (assoc 5 ed))
          )
        )
        (setq i (1+ i))
      )
    )
  )
  
  ;; Aggregate lengths by layer
  (BR:Snap-Section fp "LENGTH SUMMARY BY LAYER")
  (BR:Snap-WriteLine fp "Layer|TotalLength|Count|AvgLength")
  
  (setq line-lengths '())
  
  ;; Lines
  (setq ss (ssget "X" '((0 . "LINE"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq elayer (cdr (assoc 8 ed)))
        (setq len (distance (cdr (assoc 10 ed)) (cdr (assoc 11 ed))))
        
        (if (assoc elayer line-lengths)
          (setq line-lengths
            (subst
              (cons elayer (list (+ (cadr (assoc elayer line-lengths)) len)
                                (1+ (caddr (assoc elayer line-lengths)))))
              (assoc elayer line-lengths)
              line-lengths
            )
          )
          (setq line-lengths (cons (cons elayer (list len 1)) line-lengths))
        )
        (setq i (1+ i))
      )
    )
  )
  
  ;; Polylines
  (setq ss (ssget "X" '((0 . "LWPOLYLINE"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq obj (vlax-ename->vla-object ent))
        (setq elayer (cdr (assoc 8 ed)))
        (setq len (vla-get-Length obj))
        
        (if (assoc elayer line-lengths)
          (setq line-lengths
            (subst
              (cons elayer (list (+ (cadr (assoc elayer line-lengths)) len)
                                (1+ (caddr (assoc elayer line-lengths)))))
              (assoc elayer line-lengths)
              line-lengths
            )
          )
          (setq line-lengths (cons (cons elayer (list len 1)) line-lengths))
        )
        (setq i (1+ i))
      )
    )
  )
  
  ;; Write sorted summary
  (foreach item (vl-sort line-lengths
                  (function (lambda (a b) (> (cadr a) (cadr b)))))
    (setq total-length (cadr item))
    (setq count (caddr item))
    (BR:Snap-WriteLine fp
      (strcat
        (BR:Snap-SafeStr (car item)) "|"
        (BR:Snap-Num total-length 2) "|"
        (itoa count) "|"
        (BR:Snap-Num (/ total-length count) 2)
      )
    )
  )
  
  ;; Closed polyline areas by layer
  (BR:Snap-Section fp "AREA SUMMARY BY LAYER")
  (BR:Snap-WriteLine fp "Layer|TotalArea|TotalAreaSF|TotalAreaAC|Count")
  
  (setq poly-lengths '())
  (setq ss (ssget "X" '((0 . "LWPOLYLINE"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq obj (vlax-ename->vla-object ent))
        (setq elayer (cdr (assoc 8 ed)))
        
        (if (= (vla-get-Closed obj) :vlax-true)
          (progn
            (setq area (if (vl-catch-all-error-p
                             (vl-catch-all-apply 'vla-get-Area (list obj)))
                         0.0
                         (vla-get-Area obj)))
            (if (> area 0)
              (if (assoc elayer poly-lengths)
                (setq poly-lengths
                  (subst
                    (cons elayer (list (+ (cadr (assoc elayer poly-lengths)) area)
                                      (1+ (caddr (assoc elayer poly-lengths)))))
                    (assoc elayer poly-lengths)
                    poly-lengths
                  )
                )
                (setq poly-lengths (cons (cons elayer (list area 1)) poly-lengths))
              )
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
  
  (foreach item (vl-sort poly-lengths
                  (function (lambda (a b) (> (cadr a) (cadr b)))))
    (setq area (cadr item))
    (setq count (caddr item))
    (BR:Snap-WriteLine fp
      (strcat
        (BR:Snap-SafeStr (car item)) "|"
        (BR:Snap-Num area 2) "|"
        (BR:Snap-Num area 2) "|"
        (BR:Snap-Num (/ area 43560.0) 4) "|"
        (itoa count)
      )
    )
  )
)

;;; ===== TEXT WITH BOUNDING BOXES =====

(defun BR:SnapPro-TextBounds (fp / ss i ent ed obj etype elayer content
                                height width rotation x y
                                minpt maxpt bb)
  "Export text with bounding boxes for overlap detection"
  
  (BR:Snap-Section fp "TEXT WITH BOUNDS")
  (BR:Snap-WriteLine fp "Type|Layer|Content|X|Y|Height|Rotation|BBox_MinX|BBox_MinY|BBox_MaxX|BBox_MaxY|Handle")
  
  ;; TEXT entities
  (setq ss (ssget "X" '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (-4 . "OR>"))))
  (if ss
    (progn
      (setq i 0)
      (while (and (< i (sslength ss)) (< i 5000))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq obj (vlax-ename->vla-object ent))
        (setq etype (cdr (assoc 0 ed)))
        (setq elayer (cdr (assoc 8 ed)))
        (setq content (cdr (assoc 1 ed)))
        
        ;; Get bounding box
        (if (not (vl-catch-all-error-p
                   (vl-catch-all-apply 'vla-GetBoundingBox
                     (list obj 'minpt 'maxpt))))
          (progn
            (setq minpt (vlax-safearray->list minpt))
            (setq maxpt (vlax-safearray->list maxpt))
            
            (cond
              ((= etype "TEXT")
               (setq x (BR:Snap-Num (car (cdr (assoc 10 ed))) 4))
               (setq y (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4))
               (setq height (BR:Snap-Num (cdr (assoc 40 ed)) 4))
               (setq rotation (BR:Snap-Num (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0) 4))
              )
              ((= etype "MTEXT")
               (setq x (BR:Snap-Num (car (cdr (assoc 10 ed))) 4))
               (setq y (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4))
               (setq height (BR:Snap-Num (cdr (assoc 40 ed)) 4))
               (setq rotation (BR:Snap-Num (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0) 4))
              )
            )
            
            (BR:Snap-WriteLine fp
              (strcat
                etype "|"
                (BR:Snap-SafeStr elayer) "|"
                (BR:Snap-SafeStr content) "|"
                x "|" y "|"
                height "|" rotation "|"
                (BR:Snap-Num (car minpt) 4) "|"
                (BR:Snap-Num (cadr minpt) 4) "|"
                (BR:Snap-Num (car maxpt) 4) "|"
                (BR:Snap-Num (cadr maxpt) 4) "|"
                (cdr (assoc 5 ed))
              )
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
)

;;; ===== BLOCK ATTRIBUTES FULL DUMP =====

(defun BR:SnapPro-BlockAttribs (fp / ss i ent ed obj blkname elayer atts att
                                   tag val x y)
  "Export all block insertions with full attribute tag/value pairs"
  
  (BR:Snap-Section fp "BLOCK ATTRIBUTES")
  (BR:Snap-WriteLine fp "BlockName|Layer|X|Y|Handle|Tag|Value")
  
  (setq ss (ssget "X" '((0 . "INSERT"))))
  (if ss
    (progn
      (setq i 0)
      (while (and (< i (sslength ss)) (< i 5000))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq obj (vlax-ename->vla-object ent))
        (setq blkname (cdr (assoc 2 ed)))
        (setq elayer (cdr (assoc 8 ed)))
        (setq x (BR:Snap-Num (car (cdr (assoc 10 ed))) 4))
        (setq y (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4))
        
        (if (= (vla-get-HasAttributes obj) :vlax-true)
          (progn
            (setq atts (vlax-invoke obj 'GetAttributes))
            (foreach att atts
              (setq tag (vla-get-TagString att))
              (setq val (vla-get-TextString att))
              (BR:Snap-WriteLine fp
                (strcat
                  (BR:Snap-SafeStr blkname) "|"
                  (BR:Snap-SafeStr elayer) "|"
                  x "|" y "|"
                  (cdr (assoc 5 ed)) "|"
                  (BR:Snap-SafeStr tag) "|"
                  (BR:Snap-SafeStr val)
                )
              )
            )
          )
          ;; No attributes -- still log the block
          (BR:Snap-WriteLine fp
            (strcat
              (BR:Snap-SafeStr blkname) "|"
              (BR:Snap-SafeStr elayer) "|"
              x "|" y "|"
              (cdr (assoc 5 ed)) "|"
              "(none)|(no attributes)"
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
)

;;; ===== VIEWPORT DATA =====

(defun BR:SnapPro-Viewports (fp / layouts layout-count li layout layout-name
                                ss i ent obj ed vp-center vp-height vp-width
                                vp-scale vp-layer twist
                                paper-w paper-h frozen-str)
  "Export paper space viewport configurations"
  (setq layouts (vla-get-Layouts (vla-get-ActiveDocument (vlax-get-acad-object))))
  (setq layout-count (vla-get-Count layouts))

  (BR:Snap-Section fp "LAYOUTS")
  (BR:Snap-WriteLine fp "Name|TabOrder|PaperWidth|PaperHeight")

  (setq li 0)
  (while (< li layout-count)
    (setq layout (vla-Item layouts li))
    (setq layout-name (vla-get-Name layout))
    (if (/= layout-name "Model")
      (progn
        ;; GetPaperSize returns dims through out-params
        (setq paper-w 0.0 paper-h 0.0)
        (if (not (vl-catch-all-error-p
                   (vl-catch-all-apply 'vla-GetPaperSize
                     (list layout 'paper-w 'paper-h))))
          nil  ; paper-w and paper-h are now set
        )
        (BR:Snap-WriteLine fp
          (strcat
            (BR:Snap-SafeStr layout-name) "|"
            (itoa (vla-get-TabOrder layout)) "|"
            (BR:Snap-Num paper-w 2) "|"
            (BR:Snap-Num paper-h 2)
          )
        )
      )
    )
    (setq li (1+ li))
  )
  
  ;; Viewports
  (BR:Snap-Section fp "VIEWPORTS")
  (BR:Snap-WriteLine fp "Layout|VPHandle|CenterX|CenterY|ViewHeight|ViewWidth|CustomScale|TwistAngle|Layer|Frozen")
  
  ;; Get all viewport entities
  (setq ss (ssget "X" '((0 . "VIEWPORT"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq obj (vlax-ename->vla-object ent))
        
        ;; Skip the paper space viewport (VP #1)
        (if (/= (cdr (assoc 69 ed)) 1)
          (progn
            ;; Get viewport properties safely
            (setq vp-center
              (if (not (vl-catch-all-error-p
                         (vl-catch-all-apply 'vla-get-ViewCenter (list obj))))
                (vlax-safearray->list (vlax-variant-value (vla-get-ViewCenter obj)))
                '(0 0)
              )
            )
            (setq vp-height
              (if (not (vl-catch-all-error-p
                         (vl-catch-all-apply 'vla-get-ViewHeight (list obj))))
                (vla-get-ViewHeight obj)
                0.0
              )
            )
            (setq vp-width
              (if (not (vl-catch-all-error-p
                         (vl-catch-all-apply 'vla-get-Width (list obj))))
                (vla-get-Width obj)
                0.0
              )
            )
            (setq vp-scale
              (if (not (vl-catch-all-error-p
                         (vl-catch-all-apply 'vla-get-CustomScale (list obj))))
                (vla-get-CustomScale obj)
                0.0
              )
            )
            (setq twist
              (if (not (vl-catch-all-error-p
                         (vl-catch-all-apply 'vla-get-TwistAngle (list obj))))
                (vla-get-TwistAngle obj)
                0.0
              )
            )
            (setq vp-layer (cdr (assoc 8 ed)))
            
            ;; Frozen layer list for this viewport
            (setq frozen-str
              (if (not (vl-catch-all-error-p
                         (vl-catch-all-apply 'vla-GetXData
                           (list obj "ACAD" 'xtypes 'xvals))))
                "(see xdata)"
                ""
              )
            )
            
            (BR:Snap-WriteLine fp
              (strcat
                (BR:Snap-SafeStr vp-layer) "|"
                (cdr (assoc 5 ed)) "|"
                (BR:Snap-Num (car vp-center) 2) "|"
                (BR:Snap-Num (cadr vp-center) 2) "|"
                (BR:Snap-Num vp-height 4) "|"
                (BR:Snap-Num vp-width 4) "|"
                (BR:Snap-Num vp-scale 6) "|"
                (BR:Snap-Num (* (/ twist pi) 180.0) 2) "|"
                (BR:Snap-SafeStr vp-layer) "|"
                frozen-str
              )
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
)

;;; ===== DIMENSION VALUES =====

(defun BR:SnapPro-Dimensions (fp / ss i ent ed obj dim-type measurement
                                dim-style layer override-text)
  "Export dimension measurements and styles"
  
  (BR:Snap-Section fp "DIMENSIONS")
  (BR:Snap-WriteLine fp "DimType|Layer|Style|Measurement|OverrideText|X|Y|Handle")
  
  (setq ss (ssget "X" '((0 . "DIMENSION"))))
  (if ss
    (progn
      (setq i 0)
      (while (and (< i (sslength ss)) (< i 5000))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq obj (vlax-ename->vla-object ent))
        (setq layer (cdr (assoc 8 ed)))
        
        ;; Dimension type from group code 70
        (setq dim-type
          (cond
            ((= (logand (cdr (assoc 70 ed)) 7) 0) "LINEAR")
            ((= (logand (cdr (assoc 70 ed)) 7) 1) "ALIGNED")
            ((= (logand (cdr (assoc 70 ed)) 7) 2) "ANGULAR")
            ((= (logand (cdr (assoc 70 ed)) 7) 3) "DIAMETER")
            ((= (logand (cdr (assoc 70 ed)) 7) 4) "RADIUS")
            ((= (logand (cdr (assoc 70 ed)) 7) 5) "ANGULAR3PT")
            ((= (logand (cdr (assoc 70 ed)) 7) 6) "ORDINATE")
            (T "OTHER")
          )
        )
        
        ;; Measurement value
        (setq measurement
          (if (not (vl-catch-all-error-p
                     (vl-catch-all-apply 'vla-get-Measurement (list obj))))
            (vla-get-Measurement obj)
            0.0
          )
        )
        
        ;; Dim style
        (setq dim-style (cdr (assoc 3 ed)))
        
        ;; Override text (group 1)
        (setq override-text (if (assoc 1 ed) (cdr (assoc 1 ed)) ""))
        
        (BR:Snap-WriteLine fp
          (strcat
            dim-type "|"
            (BR:Snap-SafeStr layer) "|"
            (BR:Snap-SafeStr dim-style) "|"
            (BR:Snap-Num measurement 4) "|"
            (BR:Snap-SafeStr override-text) "|"
            (BR:Snap-Num (car (cdr (assoc 10 ed))) 2) "|"
            (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 2) "|"
            (cdr (assoc 5 ed))
          )
        )
        (setq i (1+ i))
      )
    )
  )
)

;;; ===== HATCH DATA =====

(defun BR:SnapPro-Hatches (fp / ss i ent ed obj layer pattern area)
  "Export hatch patterns and areas"
  
  (BR:Snap-Section fp "HATCHES")
  (BR:Snap-WriteLine fp "Layer|Pattern|Area|Handle")
  
  (setq ss (ssget "X" '((0 . "HATCH"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq obj (vlax-ename->vla-object ent))
        (setq layer (cdr (assoc 8 ed)))
        (setq pattern (cdr (assoc 2 ed)))
        (setq area
          (if (not (vl-catch-all-error-p
                     (vl-catch-all-apply 'vla-get-Area (list obj))))
            (vla-get-Area obj)
            0.0
          )
        )
        
        (BR:Snap-WriteLine fp
          (strcat
            (BR:Snap-SafeStr layer) "|"
            (BR:Snap-SafeStr pattern) "|"
            (BR:Snap-Num area 2) "|"
            (cdr (assoc 5 ed))
          )
        )
        (setq i (1+ i))
      )
    )
  )
)

;;; ===== VIEWPORT CONTENT ANALYSIS =====

(defun BR:SnapPro-ViewportContents (fp / doc layouts layout-count layers-coll
                                       lyr-count lyr-states lyr-obj
                                       ms-block ms-data ms-item
                                       en ed etype obj elyr hndl
                                       blk px py att-list atts att tg vl
                                       minpt maxpt
                                       li layout layout-name layout-block
                                       vp-ens vp-en vp-ed vp-obj vp-hndl
                                       vp-pw vp-ph vp-cx vp-cy vp-vh vp-vw
                                       vp-asp vp-sc vp-center
                                       bb-x1 bb-y1 bb-x2 bb-y2
                                       vpf-lyrs pair layer-ename
                                       ps-lyr-cts vp-lyr-cts
                                       ex1 ey1 ex2 ey2
                                       intersect-p vis-p lyr-state
                                       item lname att-pair)
  "Export full viewport contents: PS blocks/layers + model-space blocks/layers per VP"

  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq layouts (vla-get-Layouts doc))
  (setq layout-count (vla-get-Count layouts))
  (setq layers-coll (vla-get-Layers doc))

  ;; Pre-cache global layer states (ON/OFF, Frozen)
  (setq lyr-states '())
  (setq lyr-count (vla-get-Count layers-coll))
  (setq li 0)
  (while (< li lyr-count)
    (setq lyr-obj (vla-Item layers-coll li))
    (setq lyr-states
      (cons (list (vla-get-Name lyr-obj)
                  (= (vla-get-LayerOn lyr-obj) :vlax-true)
                  (= (vla-get-Freeze lyr-obj) :vlax-false))
            lyr-states))
    (setq li (1+ li))
  )

  ;; Pre-collect ALL model space entities with bounding boxes
  ;; For INSERT entities, also capture block name, position, and attribute tag/value pairs
  (princ " collecting-ms")
  (setq ms-data '())
  (setq ms-block (vla-get-Block (vla-Item layouts "Model")))
  (vlax-for obj ms-block
    (setq en (vlax-vla-object->ename obj))
    (if en
      (progn
        (setq ed (entget en))
        (setq etype (cdr (assoc 0 ed)))
        (setq elyr (cdr (assoc 8 ed)))
        (setq hndl (cdr (assoc 5 ed)))

        ;; Get bounding box
        (if (not (vl-catch-all-error-p
                   (vl-catch-all-apply 'vla-GetBoundingBox (list obj 'minpt 'maxpt))))
          (progn
            (setq minpt (vlax-safearray->list minpt))
            (setq maxpt (vlax-safearray->list maxpt))

            (if (= etype "INSERT")
              (progn
                (setq blk (cdr (assoc 2 ed)))
                (setq px (car (cdr (assoc 10 ed))))
                (setq py (cadr (cdr (assoc 10 ed))))
                (setq att-list nil)
                (if (= (vla-get-HasAttributes obj) :vlax-true)
                  (progn
                    (setq atts (vlax-invoke obj 'GetAttributes))
                    (foreach att atts
                      (setq att-list
                        (cons (cons (vla-get-TagString att)
                                    (vla-get-TextString att))
                              att-list))
                    )
                    (setq att-list (reverse att-list))
                  )
                )
                (setq ms-data
                  (cons (list etype elyr
                             (car minpt) (cadr minpt)
                             (car maxpt) (cadr maxpt)
                             hndl blk px py att-list)
                        ms-data))
              )
              ;; Non-INSERT: store type/layer/bbox only
              (setq ms-data
                (cons (list etype elyr
                           (car minpt) (cadr minpt)
                           (car maxpt) (cadr maxpt)
                           hndl nil nil nil nil)
                      ms-data))
            )
          )
        )
      )
    )
  )
  (setq ms-data (reverse ms-data))
  (princ (strcat "(" (itoa (length ms-data)) " ents)"))

  (BR:Snap-Section fp "VIEWPORT CONTENTS")

  ;; Process each layout (skip Model)
  (setq li 0)
  (while (< li layout-count)
    (setq layout (vla-Item layouts li))
    (setq layout-name (vla-get-Name layout))

    (if (/= layout-name "Model")
      (progn
        (BR:Snap-WriteLine fp (strcat "#LAYOUT|" (BR:Snap-SafeStr layout-name)))
        (princ (strcat " [" layout-name "]"))

        (setq layout-block (vla-get-Block layout))
        (setq vp-ens '())
        (setq ps-lyr-cts '())

        ;; -- Paper Space Blocks --
        (BR:Snap-WriteLine fp (strcat "#PS_BLOCKS|" (BR:Snap-SafeStr layout-name)))
        (BR:Snap-WriteLine fp "BlockName|Layer|X|Y|Handle|Tag|Value")

        (vlax-for obj layout-block
          (setq en (vlax-vla-object->ename obj))
          (if en
            (progn
              (setq ed (entget en))
              (setq etype (cdr (assoc 0 ed)))
              (setq elyr (cdr (assoc 8 ed)))

              ;; Accumulate PS layer entity counts
              (if (assoc elyr ps-lyr-cts)
                (setq ps-lyr-cts
                  (subst (cons elyr (1+ (cdr (assoc elyr ps-lyr-cts))))
                         (assoc elyr ps-lyr-cts)
                         ps-lyr-cts))
                (setq ps-lyr-cts (cons (cons elyr 1) ps-lyr-cts))
              )

              ;; Collect viewport enames for later
              (if (= etype "VIEWPORT")
                (setq vp-ens (cons en vp-ens))
              )

              ;; Write INSERT blocks with all attribute tag/value pairs
              (if (= etype "INSERT")
                (progn
                  (setq blk (cdr (assoc 2 ed)))
                  (setq px (BR:Snap-Num (car (cdr (assoc 10 ed))) 4))
                  (setq py (BR:Snap-Num (cadr (cdr (assoc 10 ed))) 4))
                  (setq hndl (cdr (assoc 5 ed)))

                  (if (= (vla-get-HasAttributes obj) :vlax-true)
                    (progn
                      (setq atts (vlax-invoke obj 'GetAttributes))
                      (foreach att atts
                        (setq tg (vla-get-TagString att))
                        (setq vl (vla-get-TextString att))
                        (BR:Snap-WriteLine fp
                          (strcat (BR:Snap-SafeStr blk) "|"
                                  (BR:Snap-SafeStr elyr) "|"
                                  px "|" py "|" hndl "|"
                                  (BR:Snap-SafeStr tg) "|"
                                  (BR:Snap-SafeStr vl)))
                      )
                    )
                    (BR:Snap-WriteLine fp
                      (strcat (BR:Snap-SafeStr blk) "|"
                              (BR:Snap-SafeStr elyr) "|"
                              px "|" py "|" hndl "|(none)|(no attributes)"))
                  )
                )
              )
            )
          )
        )

        ;; -- Paper Space Layers --
        (BR:Snap-WriteLine fp (strcat "#PS_LAYERS|" (BR:Snap-SafeStr layout-name)))
        (BR:Snap-WriteLine fp "Layer|EntityCount")
        (foreach item (vl-sort ps-lyr-cts
                        (function (lambda (a b) (> (cdr a) (cdr b)))))
          (BR:Snap-WriteLine fp
            (strcat (BR:Snap-SafeStr (car item)) "|" (itoa (cdr item))))
        )

        ;; -- Process each viewport in this layout --
        (foreach vp-en (reverse vp-ens)
          (setq vp-ed (entget vp-en))
          (setq vp-obj (vlax-ename->vla-object vp-en))

          ;; Skip VP #1 (overall paper space viewport)
          (if (/= (cdr (assoc 69 vp-ed)) 1)
            (progn
              (setq vp-hndl (cdr (assoc 5 vp-ed)))

              ;; VP paper-space dimensions (DXF 40=width, 41=height)
              (setq vp-pw (cdr (assoc 40 vp-ed)))
              (setq vp-ph (cdr (assoc 41 vp-ed)))

              ;; Model-space view center
              (setq vp-cx 0.0 vp-cy 0.0 vp-vh 0.0 vp-sc 0.0)
              (setq vp-center
                (vl-catch-all-apply 'vla-get-ViewCenter (list vp-obj)))
              (if (not (vl-catch-all-error-p vp-center))
                (progn
                  (setq vp-center (vlax-safearray->list (vlax-variant-value vp-center)))
                  (setq vp-cx (car vp-center))
                  (setq vp-cy (cadr vp-center))
                )
              )

              ;; Model-space view height
              (setq vp-vh
                (if (not (vl-catch-all-error-p
                           (vl-catch-all-apply 'vla-get-ViewHeight (list vp-obj))))
                  (vla-get-ViewHeight vp-obj) 0.0))

              ;; Custom scale
              (setq vp-sc
                (if (not (vl-catch-all-error-p
                           (vl-catch-all-apply 'vla-get-CustomScale (list vp-obj))))
                  (vla-get-CustomScale vp-obj) 0.0))

              ;; Compute model-space bounding box from view center + height + aspect ratio
              (setq vp-asp (if (and vp-ph (> vp-ph 0.0)) (/ vp-pw vp-ph) 1.0))
              (setq vp-vw (* vp-vh vp-asp))
              (setq bb-x1 (- vp-cx (/ vp-vw 2.0)))
              (setq bb-y1 (- vp-cy (/ vp-vh 2.0)))
              (setq bb-x2 (+ vp-cx (/ vp-vw 2.0)))
              (setq bb-y2 (+ vp-cy (/ vp-vh 2.0)))

              ;; Write VP metadata line
              ;; #VP|LayoutName|Handle|CenterX|CenterY|ViewH|ViewW|Scale|BBMinX|BBMinY|BBMaxX|BBMaxY
              (BR:Snap-WriteLine fp
                (strcat "#VP|" (BR:Snap-SafeStr layout-name) "|" vp-hndl "|"
                        (BR:Snap-Num vp-cx 4) "|" (BR:Snap-Num vp-cy 4) "|"
                        (BR:Snap-Num vp-vh 4) "|" (BR:Snap-Num vp-vw 4) "|"
                        (BR:Snap-Num vp-sc 6) "|"
                        (BR:Snap-Num bb-x1 4) "|" (BR:Snap-Num bb-y1 4) "|"
                        (BR:Snap-Num bb-x2 4) "|" (BR:Snap-Num bb-y2 4)))

              ;; VP frozen layers (DXF group 331 = soft-pointer to frozen layer records)
              (setq vpf-lyrs '())
              (foreach pair vp-ed
                (if (= (car pair) 331)
                  (progn
                    (setq layer-ename (cdr pair))
                    (if (and layer-ename (entget layer-ename))
                      (setq vpf-lyrs
                        (cons (cdr (assoc 2 (entget layer-ename)))
                              vpf-lyrs))
                    )
                  )
                )
              )
              (foreach lname vpf-lyrs
                (BR:Snap-WriteLine fp
                  (strcat "#VP_FROZEN|" vp-hndl "|" (BR:Snap-SafeStr lname)))
              )

              ;; -- Model-space blocks visible in this viewport --
              (BR:Snap-WriteLine fp (strcat "#VP_BLOCKS|" vp-hndl))
              (BR:Snap-WriteLine fp "BlockName|Layer|X|Y|Handle|Tag|Value")

              (setq vp-lyr-cts '())

              (foreach ms-item ms-data
                ;; ms-item structure:
                ;; (etype elyr minx miny maxx maxy handle blkname px py att-list)
                ;; indices: 0     1    2    3    4    5     6       7      8  9  10
                (setq ex1 (nth 2 ms-item))
                (setq ey1 (nth 3 ms-item))
                (setq ex2 (nth 4 ms-item))
                (setq ey2 (nth 5 ms-item))
                (setq elyr (nth 1 ms-item))

                ;; Bounding box intersection test
                (setq intersect-p
                  (not (or (> ex1 bb-x2) (< ex2 bb-x1)
                           (> ey1 bb-y2) (< ey2 bb-y1))))

                ;; Check layer visibility
                (setq vis-p intersect-p)
                (if vis-p
                  (progn
                    ;; VP-frozen check
                    (if (member elyr vpf-lyrs)
                      (setq vis-p nil))
                    ;; Global layer state check
                    (if vis-p
                      (progn
                        (setq lyr-state (assoc elyr lyr-states))
                        (if lyr-state
                          (if (or (not (cadr lyr-state))
                                  (not (caddr lyr-state)))
                            (setq vis-p nil))
                        )
                      )
                    )
                  )
                )

                (if vis-p
                  (progn
                    ;; Accumulate layer entity count for this VP
                    (if (assoc elyr vp-lyr-cts)
                      (setq vp-lyr-cts
                        (subst (cons elyr (1+ (cdr (assoc elyr vp-lyr-cts))))
                               (assoc elyr vp-lyr-cts)
                               vp-lyr-cts))
                      (setq vp-lyr-cts (cons (cons elyr 1) vp-lyr-cts))
                    )

                    ;; Write block insertions with attributes
                    (if (= (nth 0 ms-item) "INSERT")
                      (progn
                        (setq blk (nth 7 ms-item))
                        (setq px (BR:Snap-Num (nth 8 ms-item) 4))
                        (setq py (BR:Snap-Num (nth 9 ms-item) 4))
                        (setq hndl (nth 6 ms-item))
                        (setq att-list (nth 10 ms-item))

                        (if att-list
                          (foreach att-pair att-list
                            (BR:Snap-WriteLine fp
                              (strcat (BR:Snap-SafeStr blk) "|"
                                      (BR:Snap-SafeStr elyr) "|"
                                      px "|" py "|" hndl "|"
                                      (BR:Snap-SafeStr (car att-pair)) "|"
                                      (BR:Snap-SafeStr (cdr att-pair))))
                          )
                          (BR:Snap-WriteLine fp
                            (strcat (BR:Snap-SafeStr blk) "|"
                                    (BR:Snap-SafeStr elyr) "|"
                                    px "|" py "|" hndl "|(none)|(no attributes)"))
                        )
                      )
                    )
                  )
                )
              )

              ;; -- Model-space layers visible in this viewport --
              (BR:Snap-WriteLine fp (strcat "#VP_LAYERS|" vp-hndl))
              (BR:Snap-WriteLine fp "Layer|EntityCount")
              (foreach item (vl-sort vp-lyr-cts
                              (function (lambda (a b) (> (cdr a) (cdr b)))))
                (BR:Snap-WriteLine fp
                  (strcat (BR:Snap-SafeStr (car item)) "|" (itoa (cdr item))))
              )
            )
          )
        )

        (BR:Snap-WriteLine fp (strcat "#LAYOUT_END|" (BR:Snap-SafeStr layout-name)))
      )
    )
    (setq li (1+ li))
  )
)

;;; ===== MAIN COMMAND =====

(defun c:BR:SnapPro (/ *error* old_cmdecho fp t1)
  "Enhanced drawing snapshot with geometry metrics, text bounds, attributes, viewports"
  (setq old_cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (defun *error* (msg)
    (if fp (BR:Snap-CloseFile fp))
    (setvar "CMDECHO" old_cmdecho)
    (if (/= msg "Function cancelled") (princ (strcat "\nSnapPro error: " msg)))
    (princ)
  )
  
  (setq t1 (getvar "MILLISECS"))
  (princ "\nBR:SnapPro -- Enhanced snapshot export...")
  
  (setq fp (BR:Snap-OpenFile "snapshot_pro.txt"))
  (if fp
    (progn
      ;; Base data (reuse BR:Snap functions)
      (princ " info")
      (BR:Snap-DrawingInfo fp)
      (princ " layers")
      (BR:Snap-Layers fp)
      (princ " entities")
      (BR:Snap-EntitySummary fp)
      (princ " blocks")
      (BR:Snap-Blocks fp)
      (princ " xrefs")
      (BR:Snap-Xrefs fp)
      (princ " styles")
      (BR:Snap-Styles fp)
      (BR:Snap-Linetypes fp)
      
      ;; Enhanced data
      (princ " geometry")
      (BR:SnapPro-Geometry fp)
      (princ " text-bounds")
      (BR:SnapPro-TextBounds fp)
      (princ " attributes")
      (BR:SnapPro-BlockAttribs fp)
      (princ " viewports")
      (BR:SnapPro-Viewports fp)
      (princ " dimensions")
      (BR:SnapPro-Dimensions fp)
      (princ " hatches")
      (BR:SnapPro-Hatches fp)
      (princ " vp-contents")
      (BR:SnapPro-ViewportContents fp)

      ;; Footer
      (BR:Snap-Section fp "END")
      (BR:Snap-WriteLine fp (strcat "GeneratedBy|BR:SnapPro v1.0"))
      (BR:Snap-WriteLine fp (strcat "ElapsedMs|" (itoa (- (getvar "MILLISECS") t1))))
      
      (BR:Snap-CloseFile fp)
      (princ (strcat "\nPro snapshot saved: C:\\CAD_IO\\logs\\snapshot_pro.txt ("
                     (itoa (- (getvar "MILLISECS") t1)) "ms)"))
    )
  )
  
  (setvar "CMDECHO" old_cmdecho)
  (princ)
)

;;;; -- COMMAND ALIAS ---------------------------------------------

(defun C:BR_SNAPPRO (/)
  (c:BR:SnapPro)
  (princ)
)


;;;; -- MODULE LOADED ---------------------------------------------

(princ "\n  BR_SnapPro module loaded.  Command: BR:SnapPro")
(princ)
