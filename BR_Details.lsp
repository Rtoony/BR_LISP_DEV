;;; ================================================================
;;; BR_Details.lsp  |  Brelje & Race CAD Tools  |  Detail Insert
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_Details.dcl (dialog name "br_details")
;;; Command:  BR_DTL
;;;
;;; 124 construction details in 31 categories from the BR library.
;;; ================================================================


;;;; -- DETAIL DATABASE -------------------------------------------
;;;;
;;;; Each entry: (display-name detail-name category source-path letter-code number-code)
;;;;
;;;; display-name  -- shown in the list box
;;;; detail-name   -- detail name for identification
;;;; category      -- category string for filtering
;;;; source-path   -- full path to source DWG file
;;;; letter-code   -- detail letter code (or "" if none)
;;;; number-code   -- detail number code (or "" if none)

(setq *BR:DTL-ROOT* "J:\\LIB\\BR\\")

(setq *BR:DETAILS*
  (list
    ;; -- Abbreaviations -----------------------------------------
    (list "ABB-1 -- Abbreviations"     "Abbreviations"     "Abbreaviations"   "$ - Abbreviations.dwg"                                              "ABB" "1")
    ;; -- Legend --------------------------------------------------
    (list "Legend  Notes  Water Pollution Control  Compilation"  "Legend  Notes  Water Pollution Control  Compilation"  "Legend"  "$ - Legend & Notes - Water Pollution Control - Compilation.dwg"  "" "")
    (list "LGND-2 -- Legend  Basic"     "Legend  Basic"     "Legend"  "$ - Legend - Basic.dwg"                                                      "LGND" "2")
    (list "Legend  Erosion"             "Legend  Erosion"   "Legend"  "$ - Legend - Erosion.dwg"                                                    "" "")
    (list "Legend  Hydrology"           "Legend  Hydrology" "Legend"  "$ - Legend - Hydrology.dwg"                                                  "" "")
    (list "LIPIPE -- Legend  Piping"    "Legend  Piping"    "Legend"  "$ - Legend - Piping.dwg"                                                     "LIPIPE" "")
    (list "LSYMB -- Legend  Symbols"    "Legend  Symbols"   "Legend"  "$ - Legend - Symbols.dwg"                                                    "LSYMB" "")
    (list "LTOPO -- Legend  Topo"       "Legend  Topo"      "Legend"  "$ - Legend - Topo.dwg"                                                       "LTOPO" "")
    (list "Legend  Water Pollution Control"  "Legend  Water Pollution Control"  "Legend"  "$ - Legend - Water Pollution Control.dwg"                 "" "")
    ;; -- Notes ---------------------------------------------------
    (list "Notes  Fire Protection Notes  Compilation"   "Notes  Fire Protection Notes  Compilation"   "Notes"  "$ - Notes - Fire Protection Notes - Compilation.dwg"            "" "")
    (list "Notes  General Notes1"       "Notes  General Notes1"       "Notes"  "$ - Notes - General Notes1.dwg"                                    "" "")
    (list "Notes  General Notes2"       "Notes  General Notes2"       "Notes"  "$ - Notes - General Notes2.dwg"                                    "" "")
    (list "Notes  List of Codes  Standards"  "Notes  List of Codes  Standards"  "Notes"  "$ - Notes - List of Codes & Standards.dwg"               "" "")
    (list "Notes  Roof Drain Notes  Details"  "Notes  Roof Drain Notes  Details"  "Notes"  "$ - Notes - Roof Drain Notes & Details.dwg"            "" "")
    (list "Notes  Santa Rosa"           "Notes  Santa Rosa"           "Notes"  "$ - Notes - Santa Rosa.dwg"                                        "" "")
    (list "Notes  Sonoma County  See Tool Palette"  "Notes  Sonoma County  See Tool Palette"  "Notes"  "$ - Notes - Sonoma County - See Tool Palette.dwg"  "" "")
    (list "Notes  Town of Windsor"      "Notes  Town of Windsor"      "Notes"  "$ - Notes - Town of Windsor.dwg"                                   "" "")
    (list "Notes  Water Pollution Control"  "Notes  Water Pollution Control"  "Notes"  "$ - Notes - Water Pollution Control.dwg"                   "" "")
    ;; -- Stamp ---------------------------------------------------
    (list "Stamp  Fire Authority Review"  "Stamp  Fire Authority Review"  "Stamp"  "$ - Stamp - Fire Authority Review.dwg"                        "" "")
    (list "Stamp  Liability Clause"     "Stamp  Liability Clause"     "Stamp"  "$ - Stamp - Liability Clause.dwg"                                  "" "")
    (list "Stamp  USA"                  "Stamp  USA"                  "Stamp"  "$ - Stamp - USA.dwg"                                               "" "")
    (list "Record Drawing Stamp  use stamp from Tool Palette"  "Record Drawing Stamp  use stamp from Tool Palette"  "Stamp"  "Record Drawing Stamp - use stamp from Tool Palette.dwg"  "" "")
    ;; -- Asphalt -------------------------------------------------
    (list "AC  Dike"                    "AC  Dike"                    "Asphalt"  "AC - Dike.dwg"                                                   "" "")
    (list "Pavement  AC  Edge"          "Pavement  AC  Edge"          "Asphalt"  "Pavement - AC - Edge.dwg"                                        "" "")
    (list "Pavement  Conforms"          "Pavement  Conforms"          "Asphalt"  "Pavement - Conforms.dwg"                                         "" "")
    (list "Pavement  Section"           "Pavement  Section"           "Asphalt"  "Pavement - Section.dwg"                                          "" "")
    (list "Pavement  Speed Bump"        "Pavement  Speed Bump"        "Asphalt"  "Pavement - Speed Bump.dwg"                                       "" "")
    (list "Pavement  Speed Table"       "Pavement  Speed Table"       "Asphalt"  "Pavement - Speed Table.dwg"                                      "" "")
    ;; -- ADA -----------------------------------------------------
    (list "ADA  Compilation"            "ADA  Compilation"            "ADA"  "ADA - Compilation.dwg"                                               "" "")
    (list "Detectable Warning Surface  SEE ADACOMPLIATION"  "Detectable Warning Surface  SEE ADACOMPLIATION"  "ADA"  "Detectable Warning Surface - SEE ADA-COMPLIATION.dwg"  "" "")
    (list "Wheel Stop"                  "Wheel Stop"                  "ADA"  "Wheel Stop.dwg"                                                      "" "")
    ;; -- Anchor --------------------------------------------------
    (list "Anchor  Aeration Chain Anchor"  "Anchor  Aeration Chain Anchor"  "Anchor"  "Anchor - Aeration Chain Anchor.dwg"                        "" "")
    (list "Anchor  Screw Anchor"        "Anchor  Screw Anchor"        "Anchor"  "Anchor - Screw Anchor.dwg"                                        "" "")
    ;; -- Site Features -------------------------------------------
    (list "Barricade"                   "Barricade"                   "Site Features"  "Barricade.dwg"                                             "" "")
    (list "Bike Rack"                   "Bike Rack"                   "Site Features"  "Bike Rack.dwg"                                             "" "")
    (list "Brick Paver"                 "Brick Paver"                 "Site Features"  "Brick Paver.dwg"                                           "" "")
    (list "Chain"                       "Chain"                       "Site Features"  "Chain.dwg"                                                  "" "")
    (list "Driveway  Private"           "Driveway  Private"           "Site Features"  "Driveway - Private.dwg"                                    "" "")
    (list "Mail Box"                    "Mail Box"                    "Site Features"  "Mail Box.dwg"                                               "" "")
    (list "Map  State"                  "Map  State"                  "Site Features"  "Map - State.dwg"                                            "" "")
    ;; -- Bollard -------------------------------------------------
    (list "Bollard  Compilation"        "Bollard  Compilation"        "Bollard"  "Bollard - Compilation.dwg"                                       "" "")
    ;; -- Bore and Jack -------------------------------------------
    (list "Bore and Jack"               "Bore and Jack"               "Bore and Jack"  "Bore and Jack.dwg"                                         "" "")
    ;; -- Building ------------------------------------------------
    (list "Building  Bus Shelter"       "Building  Bus Shelter"       "Building"  "Building - Bus Shelter.dwg"                                     "" "")
    (list "Building  Cabinets"          "Building  Cabinets"          "Building"  "Building - Cabinets.dwg"                                        "" "")
    (list "Building  Footing Wall"      "Building  Footing Wall"      "Building"  "Building - Footing Wall.dwg"                                    "" "")
    (list "Building  Masonry"           "Building  Masonry"           "Building"  "Building - Masonry.dwg"                                         "" "")
    (list "Building  Modular Backfill  Compilation"  "Building  Modular Backfill  Compilation"  "Building"  "Building - Modular Backfill - Compilation.dwg"  "" "")
    (list "Building  Portable  Flashing and Paving  Compilation"  "Building  Portable  Flashing and Paving  Compilation"  "Building"  "Building - Portable - Flashing and Paving - Compilation.dwg"  "" "")
    (list "Building  Roof"              "Building  Roof"              "Building"  "Building - Roof.dwg"                                             "" "")
    ;; -- Chemical Injection --------------------------------------
    (list "Chemical Injection"          "Chemical Injection"          "Chemical Injection"  "Chemical Injection.dwg"                                "" "")
    ;; -- Cleanout ------------------------------------------------
    (list "Cleanout  Compilation"       "Cleanout  Compilation"       "Cleanout"  "Cleanout - Compilation.dwg"                                     "" "")
    ;; -- Concrete ------------------------------------------------
    (list "Concrete  Apron  Roll Up Door"  "Concrete  Apron  Roll Up Door"  "Concrete"  "Concrete - Apron - Roll Up Door.dwg"                     "" "")
    (list "Concrete  Encasement"        "Concrete  Encasement"        "Concrete"  "Concrete - Encasement.dwg"                                      "" "")
    (list "Concrete  Epoxy Anchor"      "Concrete  Epoxy Anchor"      "Concrete"  "Concrete - Epoxy Anchor.dwg"                                    "" "")
    (list "Concrete  Foundation 12in Slab"  "Concrete  Foundation 12in Slab"  "Concrete"  "Concrete - Foundation 12in Slab.dwg"                    "" "")
    (list "Concrete  FoundationSidewalk Doweling  Compilation"  "Concrete  FoundationSidewalk Doweling  Compilation"  "Concrete"  "Concrete - Foundation-Sidewalk Doweling - Compilation.dwg"  "" "")
    (list "Concrete  Landing"           "Concrete  Landing"           "Concrete"  "Concrete - Landing.dwg"                                         "" "")
    (list "Concrete  Moisture Barrier"  "Concrete  Moisture Barrier"  "Concrete"  "Concrete - Moisture Barrier.dwg"                                "" "")
    (list "Concrete  Paving or Thickened Edge  Compilation"  "Concrete  Paving or Thickened Edge  Compilation"  "Concrete"  "Concrete - Paving or Thickened Edge - Compilation.dwg"  "" "")
    (list "Concrete  PCC Section  Compilation"  "Concrete  PCC Section  Compilation"  "Concrete"  "Concrete - PCC Section - Compilation.dwg"      "" "")
    (list "Concrete  Pipe Penetration"  "Concrete  Pipe Penetration"  "Concrete"  "Concrete - Pipe Penetration.dwg"                                "" "")
    (list "Concrete  Skateboard Deterrent"  "Concrete  Skateboard Deterrent"  "Concrete"  "Concrete - Skateboard Deterrent.dwg"                   "" "")
    (list "Concrete  Splash Block"      "Concrete  Splash Block"      "Concrete"  "Concrete - Splash Block.dwg"                                    "" "")
    (list "Concrete  Trash Pad"         "Concrete  Trash Pad"         "Concrete"  "Concrete - Trash Pad.dwg"                                       "" "")
    (list "Concrete  Utility Trench and Cover"  "Concrete  Utility Trench and Cover"  "Concrete"  "Concrete - Utility Trench and Cover.dwg"       "" "")
    (list "Concrete  VDitch"            "Concrete  VDitch"            "Concrete"  "Concrete - V-Ditch.dwg"                                         "" "")
    (list "Concrete  Valley Gutter  Compilation"  "Concrete  Valley Gutter  Compilation"  "Concrete"  "Concrete - Valley Gutter - Compilation.dwg" "" "")
    (list "Wall  Concrete"              "Wall  Concrete"              "Concrete"  "Wall - Concrete.dwg"                                            "" "")
    ;; -- Storm Drain ---------------------------------------------
    (list "Culvert Eliptical"           "Culvert Eliptical"           "Storm Drain"  "Culvert- Eliptical.dwg"                                     "" "")
    (list "SD  1K"                      "SD  1K"                      "Storm Drain"  "SD - 1K.dwg"                                                 "" "")
    (list "SD  1R"                      "SD  1R"                      "Storm Drain"  "SD - 1R.dwg"                                                 "" "")
    (list "SD  2KR Modified"            "SD  2KR Modified"            "Storm Drain"  "SD - 2KR Modified.dwg"                                       "" "")
    (list "SD  2KR"                     "SD  2KR"                     "Storm Drain"  "SD - 2KR.dwg"                                                "" "")
    (list "SD  Bioretention  Compilation"  "SD  Bioretention  Compilation"  "Storm Drain"  "SD - Bioretention - Compilation.dwg"                   "" "")
    (list "SD  Blind Connection"        "SD  Blind Connection"        "Storm Drain"  "SD - Blind Connection.dwg"                                   "" "")
    (list "SD  Cast in Place"           "SD  Cast in Place"           "Storm Drain"  "SD - Cast in Place.dwg"                                      "" "")
    (list "SD  CMP Outlet"              "SD  CMP Outlet"              "Storm Drain"  "SD - CMP Outlet.dwg"                                         "" "")
    (list "SD  Concrete Collar"         "SD  Concrete Collar"         "Storm Drain"  "SD - Concrete Collar.dwg"                                    "" "")
    (list "SD  Dissipator  Compilation" "SD  Dissipator  Compilation" "Storm Drain"  "SD - Dissipator - Compilation.dwg"                           "" "")
    (list "SD  Drainage Emitter"        "SD  Drainage Emitter"        "Storm Drain"  "SD - Drainage Emitter.dwg"                                   "" "")
    (list "SD  Edge Drain"              "SD  Edge Drain"              "Storm Drain"  "SD - Edge Drain.dwg"                                         "" "")
    (list "SD  Flared End"              "SD  Flared End"              "Storm Drain"  "SD - Flared End.dwg"                                         "" "")
    (list "SD  Headwall"                "SD  Headwall"                "Storm Drain"  "SD - Headwall.dwg"                                           "" "")
    (list "SD  Manhole Access"          "SD  Manhole Access"          "Storm Drain"  "SD - Manhole Access.dwg"                                     "" "")
    (list "SD  Outfall"                 "SD  Outfall"                 "Storm Drain"  "SD - Outfall.dwg"                                            "" "")
    (list "SD  Outlet Structure"        "SD  Outlet Structure"        "Storm Drain"  "SD - Outlet Structure.dwg"                                   "" "")
    (list "SD  OutletRip Rap"           "SD  OutletRip Rap"           "Storm Drain"  "SD - Outlet-Rip Rap.dwg"                                     "" "")
    (list "SD  Outlet"                  "SD  Outlet"                  "Storm Drain"  "SD - Outlet.dwg"                                             "" "")
    (list "SD  Paving Notch"            "SD  Paving Notch"            "Storm Drain"  "SD - Paving Notch.dwg"                                       "" "")
    (list "SD  Pipe Protection  Compilation"  "SD  Pipe Protection  Compilation"  "Storm Drain"  "SD - Pipe Protection - Compilation.dwg"          "" "")
    (list "SD  Planter Drain  SEE   Notes  Roof Drain Notes  Details"  "SD  Planter Drain  SEE   Notes  Roof Drain Notes  Details"  "Storm Drain"  "SD - Planter Drain - SEE -$ - Notes - Roof Drain Notes & Details.dwg"  "" "")
    (list "SD  RD PD Detail  SEE   Notes  Roof Drain Notes  Details"  "SD  RD PD Detail  SEE   Notes  Roof Drain Notes  Details"  "Storm Drain"  "SD - RD PD Detail - SEE -$ - Notes - Roof Drain Notes & Details.dwg"  "" "")
    (list "SD  RD Sleeve Connection to UG SD"  "SD  RD Sleeve Connection to UG SD"  "Storm Drain"  "SD - RD Sleeve Connection to UG SD.dwg"      "" "")
    (list "SD  Redwood Drain"           "SD  Redwood Drain"           "Storm Drain"  "SD - Redwood Drain.dwg"                                      "" "")
    (list "SD  Rock Slope"              "SD  Rock Slope"              "Storm Drain"  "SD - Rock Slope.dwg"                                         "" "")
    (list "SD  SDAD  NDS"               "SD  SDAD  NDS"               "Storm Drain"  "SD - SDAD - NDS.dwg"                                        "" "")
    (list "SD  SDDI  P6P8"              "SD  SDDI  P6P8"              "Storm Drain"  "SD - SDDI - P6-P8.dwg"                                       "" "")
    (list "SD  SDDI  With Check Valve"  "SD  SDDI  With Check Valve"  "Storm Drain"  "SD - SDDI - With Check Valve.dwg"                           "" "")
    (list "SD  SDMH  Shallow Manhole"   "SD  SDMH  Shallow Manhole"  "Storm Drain"  "SD - SDMH - Shallow Manhole.dwg"                             "" "")
    (list "SD  Side Inlet"              "SD  Side Inlet"              "Storm Drain"  "SD - Side Inlet.dwg"                                         "" "")
    (list "SD  Sidewalk Drain  Compilation"  "SD  Sidewalk Drain  Compilation"  "Storm Drain"  "SD - Sidewalk Drain - Compilation.dwg"             "" "")
    (list "SD  Subdrain"                "SD  Subdrain"                "Storm Drain"  "SD - Subdrain.dwg"                                           "" "")
    (list "SD  Trench Drain  Compilation"  "SD  Trench Drain  Compilation"  "Storm Drain"  "SD - Trench Drain - Compilation.dwg"                  "" "")
    (list "SD  Yard Drain  Private"     "SD  Yard Drain  Private"     "Storm Drain"  "SD - Yard Drain - Private.dwg"                               "" "")
    ;; -- Curb ----------------------------------------------------
    (list "Curb  Compilation"           "Curb  Compilation"           "Curb"  "Curb - Compilation.dwg"                                             "" "")
    ;; -- Water ---------------------------------------------------
    (list "Drinking Fountain Sump"      "Drinking Fountain Sump"      "Water"  "Drinking Fountain Sump.dwg"                                       "" "")
    ;; -- Erosion Control -----------------------------------------
    (list "Erosion  Compilation"        "Erosion  Compilation"        "Erosion Control"  "Erosion - Compilation.dwg"                               "" "")
    ;; -- Fencing -------------------------------------------------
    (list "Fence  Compilation"          "Fence  Compilation"          "Fencing"  "Fence - Compilation.dwg"                                         "" "")
    (list "FencingCompilation PT"       "FencingCompilation PT"       "Fencing"  "Fencing-Compilation PT.dwg"                                      "" "")
    ;; -- Gates ---------------------------------------------------
    (list "Gate  Compilation"           "Gate  Compilation"           "Gates"  "Gate - Compilation.dwg"                                             "" "")
    ;; -- Grading -------------------------------------------------
    (list "Grading  Keyway Subdrain"    "Grading  Keyway Subdrain"    "Grading"  "Grading - Keyway Subdrain.dwg"                                   "" "")
    (list "Grading  Slope Rounding"     "Grading  Slope Rounding"     "Grading"  "Grading - Slope Rounding.dwg"                                    "" "")
    ;; -- Handrails -----------------------------------------------
    (list "Handrail  Compilation"       "Handrail  Compilation"       "Handrails"  "Handrail - Compilation.dwg"                                    "" "")
    ;; -- Header Boards -------------------------------------------
    (list "Header  Redwood"             "Header  Redwood"             "Header Boards"  "Header - Redwood.dwg"                                      "" "")
    ;; -- Hoist Boards --------------------------------------------
    (list "Hoist"                       "Hoist"                       "Hoist Boards"  "Hoist.dwg"                                                  "" "")
    ;; -- Lights --------------------------------------------------
    (list "Light  Decorative"           "Light  Decorative"           "Lights"  "Light - Decorative.dwg"                                           "" "")
    ;; -- Demolition ----------------------------------------------
    (list "Pipe Abandon  Compilation"   "Pipe Abandon  Compilation"   "Demolition"  "Pipe Abandon - Compilation.dwg"                               "" "")
    ;; -- Pipe Support --------------------------------------------
    (list "Pipe Support  Compilation"   "Pipe Support  Compilation"   "Pipe Support"  "Pipe Support - Compilation.dwg"                             "" "")
    ;; -- Pond ----------------------------------------------------
    (list "Pond  Float Intake"          "Pond  Float Intake"          "Pond"  "Pond - Float Intake.dwg"                                            "" "")
    (list "Pond  Slope Protection"      "Pond  Slope Protection"      "Pond"  "Pond - Slope Protection.dwg"                                        "" "")
    ;; -- Pump ----------------------------------------------------
    (list "Pump  Air Vent"              "Pump  Air Vent"              "Pump"  "Pump - Air Vent.dwg"                                                 "" "")
    (list "Pump  Extinguisher"          "Pump  Extinguisher"          "Pump"  "Pump - Extinguisher.dwg"                                             "" "")
    (list "Pumper"                      "Pumper"                      "Pump"  "Pumper.dwg"                                                         "" "")
    ;; -- City of Santa Rosa --------------------------------------
    (list "Santa Rosa  Sewer  Water Lateral"  "Santa Rosa  Sewer  Water Lateral"  "City of Santa Rosa"  "Santa Rosa - Sewer & Water Lateral.dwg"  "" "")
  )
)


;;;; -- DETAIL CATEGORIES (auto-built from database) ---------------

(defun BR:DTL:Categories (/ cats)
  (setq cats '("ALL"))
  (foreach dtl *BR:DETAILS*
    (if (not (member (BR:DTL:Cat dtl) cats))
      (setq cats (append cats (list (BR:DTL:Cat dtl))))
    )
  )
  cats
)


;;;; -- DETAIL ACCESSORS -------------------------------------------

(defun BR:DTL:Disp   (e) (nth 0 e))   ; display name
(defun BR:DTL:Name   (e) (nth 1 e))   ; detail name
(defun BR:DTL:Cat    (e) (nth 2 e))   ; category
(defun BR:DTL:Source (e) (nth 3 e))   ; source file relative path
(defun BR:DTL:Letter (e) (nth 4 e))   ; letter code
(defun BR:DTL:Number (e) (nth 5 e))   ; number code


;;;; -- FILTER LOGIC -----------------------------------------------

;; Return filtered detail list based on category and search string.
;; Category "ALL" means no category filter.
;; Search is case-insensitive substring match on display name.
(defun BR:DTL:Filter (cat search / result dtl upsearch)
  (setq result   nil
        upsearch (strcase search))
  (foreach dtl *BR:DETAILS*
    (if (and
          (or (= cat "ALL") (= (BR:DTL:Cat dtl) cat))
          (or (= search "")
              (vl-string-search upsearch (strcase (BR:DTL:Disp dtl))))
        )
      (setq result (append result (list dtl)))
    )
  )
  result
)


;;;; -- INSERT OPERATION -------------------------------------------

;; Insert a detail DWG from the library.
;; - Constructs full path from root + source
;; - Uses -INSERT to bring in the detail
;; - Pauses for user placement
(defun BR:InsertDetail (dtl-entry / src-full)
  (setq src-full (BR:JoinPath *BR:DTL-ROOT* (BR:DTL:Source dtl-entry)))

  ;; Ensure source file exists
  (if (not (findfile src-full))
    (progn
      (alert
        (strcat "Detail source file not found:\n\n" src-full))
      nil
    )
    (progn
      ;; Insert -- AutoCAD will prompt for insertion point, scale, rotation
      (command "._-INSERT" src-full)
      ;; Wait for user to complete insertion
      (while (> (getvar "CMDACTIVE") 0) (command pause))
      (princ (strcat "\n  Inserted detail: " (BR:DTL:Name dtl-entry)))
      t
    )
  )
)


;;;; -- DCL DIALOG -------------------------------------------------

;; Filtered display list -- tracks which *BR:DETAILS* entries are shown
(setq *BR:DTL-FILTERED* nil)

(defun BR:DTL:RefreshList (cat search / filtered dtl disp)
  (setq filtered (BR:DTL:Filter cat search))
  (setq *BR:DTL-FILTERED* filtered)
  (start_list "dtl_list")
  (foreach dtl filtered
    (if (and (> (strlen (BR:DTL:Letter dtl)) 0)
             (> (strlen (BR:DTL:Number dtl)) 0))
      (setq disp (strcat "[" (BR:DTL:Cat dtl) "]  "
                         (BR:DTL:Letter dtl) "-" (BR:DTL:Number dtl)
                         " -- " (BR:DTL:Name dtl)))
      (if (> (strlen (BR:DTL:Letter dtl)) 0)
        (setq disp (strcat "[" (BR:DTL:Cat dtl) "]  "
                           (BR:DTL:Letter dtl)
                           " -- " (BR:DTL:Name dtl)))
        (setq disp (strcat "[" (BR:DTL:Cat dtl) "]  " (BR:DTL:Name dtl)))
      )
    )
    (add_list disp)
  )
  (end_list)
  ;; Clear info tiles
  (set_tile "dtl_name"   "Detail :  ...")
  (set_tile "dtl_codes"  "Codes :  ...")
  (set_tile "dtl_source" "Source :  ...")
)

(defun BR:DTL:ShowDetail (idx / dtl codes)
  (if (and (>= idx 0) (< idx (length *BR:DTL-FILTERED*)))
    (progn
      (setq dtl (nth idx *BR:DTL-FILTERED*))
      (set_tile "dtl_name"
        (strcat "Detail :  " (BR:DTL:Name dtl)))
      ;; Build codes display
      (cond
        ((and (> (strlen (BR:DTL:Letter dtl)) 0)
              (> (strlen (BR:DTL:Number dtl)) 0))
         (setq codes (strcat (BR:DTL:Letter dtl) "-" (BR:DTL:Number dtl))))
        ((> (strlen (BR:DTL:Letter dtl)) 0)
         (setq codes (BR:DTL:Letter dtl)))
        ((> (strlen (BR:DTL:Number dtl)) 0)
         (setq codes (BR:DTL:Number dtl)))
        (t (setq codes "(none)"))
      )
      (set_tile "dtl_codes"
        (strcat "Codes :  " codes))
      (set_tile "dtl_source"
        (strcat "Source :  " (BR:DTL:Source dtl)))
    )
  )
)

(defun BR:DetailsDCL (/ dcl-path dcl-id done d-catidx d-dtlidx d-search
                        cats cat-name dtl-entry)

  (setq dcl-path (findfile "BR_Details.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat "BR_Details.dcl not found.\n\n"
                "Make sure BR_Details.dcl is in the same folder as the LSP files\n"
                "and that folder is on AutoCAD's support path."))
      (exit)
    )
  )

  (setq d-catidx 0
        d-dtlidx -1
        d-search "")

  (setq dcl-id (load_dialog dcl-path))
  (if (< dcl-id 0)
    (progn (alert (strcat "Cannot load DCL:\n" dcl-path)) (exit))
  )
  (if (not (new_dialog "br_details" dcl-id))
    (progn
      (unload_dialog dcl-id)
      (alert "Cannot initialize br_details dialog.")
      (exit)
    )
  )

  ;; Populate category dropdown
  (setq cats (BR:DTL:Categories))
  (start_list "dtl_category")
  (foreach c cats (add_list c))
  (end_list)
  (set_tile "dtl_category" "0")

  ;; Initial detail list (all)
  (BR:DTL:RefreshList "ALL" "")

  ;; Actions
  (action_tile "dtl_category"
    (strcat
      "(setq d-catidx (BR:DCL:SafeIndex $value))"
      "(BR:DTL:RefreshList"
      "  (if (and (>= d-catidx 0) (< d-catidx (length cats)))"
      "    (nth d-catidx cats)"
      "    \"ALL\")"
      "  d-search)"))

  (action_tile "dtl_search"
    (strcat
      "(setq d-search (BR:SafeStr $value))"
      "(BR:DTL:RefreshList"
      "  (if (and (>= d-catidx 0) (< d-catidx (length cats)))"
      "    (nth d-catidx cats)"
      "    \"ALL\")"
      "  d-search)"))

  (action_tile "dtl_list"
    (strcat
      "(setq d-dtlidx (BR:DCL:SafeIndex $value))"
      "(BR:DTL:ShowDetail d-dtlidx)"
      "(if (= $reason 4) (done_dialog 1))"))

  (action_tile "accept" "(done_dialog 1)")
  (action_tile "cancel" "(done_dialog 0)")

  (setq done (start_dialog))
  (unload_dialog dcl-id)

  ;; -- Act on result --------------------------------------------
  (if (and (= done 1) (>= d-dtlidx 0) (< d-dtlidx (length *BR:DTL-FILTERED*)))
    (progn
      (setq dtl-entry (nth d-dtlidx *BR:DTL-FILTERED*))
      (BR:InsertDetail dtl-entry)
    )
    (if (and (= done 1) (< d-dtlidx 0))
      (alert "Please select a detail from the list first.")
    )
  )
)


;;;; -- COMMAND -----------------------------------------------------

(defun C:BR_DTL (/ *error* _olderr _saved _undoFlag)
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

  (BR:DetailsDCL)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED -----------------------------------------------

(princ "\n  BR_Details module loaded.  Command: BR_DTL")
(princ)

;;; End of BR_Details.lsp
