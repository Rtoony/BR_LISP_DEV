;;; ================================================================
;;; BR_Layers.lsp  |  Brelje & Race CAD Tools  |  Layer Tools
;;; ================================================================
;;; Requires: BR_Core.lsp loaded first.
;;; DCL file: BR_Layers.dcl (dialog name "br_layers")
;;; Command:  BR_LAY
;;;
;;; Future: populate *BR:LAYER-CATS* with full 430-layer system data.
;;; ================================================================


;;;; -- LAYER CATEGORY DATABASE -------------------------------------
;;;;
;;;; Each entry: (category-label  layer-list)
;;;;
;;;; category-label -- display name for the category
;;;; layer-list     -- list of (layer-name  color  linetype  description)
;;;;
;;;; Data generated from layers.json (360 layers, 10 categories).
;;;;       Can also be loaded from an external file in the future.

(setq *BR:LAYER-CATS*
  (list
    (list "Annotation"
      (list
        (list "$AREA-design calc-T" 4 "CONTINUOUS" "Non-plottable text and labels for design calculations.")
        (list "$REV-GRAD-revision X or yymmdd whichever makes sense" 7 "CONTINUOUS" "Revision clouds and markers specific to grading changes.")
        (list "$REV-UTIL-revision X or yymmdd whichever makes sense" 7 "CONTINUOUS" "Revision clouds and markers specific to utility changes.")
        (list "ALN-BC-EC-T" 150 "CONTINUOUS" "Text labels for alignment geometry points like Begin Curve and End Curve.")
        (list "ALN-STA-T" 4 "CONTINUOUS" "Major and minor stationing text labels for an alignment.")
        (list "ALN-T" 231 "CONTINUOUS" "General text and labels associated with alignments, such as names or descript...")
        (list "CREEK-T" 4 "CONTINUOUS" "Text identifying creeks, rivers, or other natural watercourses.")
        (list "EX-AC-T" 13 "CONTINUOUS" "Labels for existing asphalt concrete.")
        (list "EX-BARRICADE-T" 83 "CONTINUOUS" "Labels for existing barricades.")
        (list "EX-BASKETBALL-T" 45 "CONTINUOUS" "Labels for existing basketball courts.")
        (list "EX-BDY-ap-T" 4 "CONTINUOUS" "Labels for existing assessor's parcel boundaries.")
        (list "EX-BDY-approx-T" 150 "CONTINUOUS" "Labels for approximate existing boundaries.")
        (list "EX-BDY-final-T" 7 "CONTINUOUS" "Labels for existing final boundary lines.")
        (list "EX-BENCH-T" 45 "CONTINUOUS" "Labels for existing benches.")
        (list "EX-BLDG-T" 105 "CONTINUOUS" "Labels for existing buildings, such as addresses or elevations.")
        (list "EX-BLDG-overhang-T" 8 "CONTINUOUS" "Labels for existing building overhangs.")
        (list "EX-BM-T" 181 "CONTINUOUS" "Labels for existing benchmarks, including elevation and description.")
        (list "EX-BOLLARD-T" 8 "CONTINUOUS" "Labels for existing bollards.")
        (list "EX-BOREHOLE-T" 13 "CONTINUOUS" "Labels for existing boreholes.")
        (list "EX-COLUMN-T" 45 "CONTINUOUS" "Labels for existing columns.")
        (list "EX-CONC-T" 83 "CONTINUOUS" "Labels for existing concrete surfaces.")
        (list "EX-CONTROL-T" 4 "CONTINUOUS" "Labels for existing survey control points.")
        (list "EX-CURB-FC-T" 45 "CONTINUOUS" "Labels for existing face of curb.")
        (list "EX-CURB-LIP-T" 13 "CONTINUOUS" "Labels for existing lip of gutter.")
        (list "EX-DECK-T" 75 "CONTINUOUS" "Labels for existing decks.")
        (list "EX-DIKE-T" 9 "CONTINUOUS" "Labels for existing dikes.")
        (list "EX-DIRT ROAD-T" 13 "CONTINUOUS" "Labels for existing dirt roads.")
        (list "EX-DOOR-T" 45 "CONTINUOUS" "Labels for existing doors.")
        (list "EX-DW-T" 13 "CONTINUOUS" "Labels for existing driveways.")
        (list "EX-ELEC-T" 45 "CONTINUOUS" "Labels for existing electrical features.")
        (list "EX-EP-T" 45 "CONTINUOUS" "Labels for existing edge of pavement.")
        (list "EX-ESMT-ELEC-T" 3 "CONTINUOUS" "Labels for existing electrical easements.")
        (list "EX-ESMT-LANDSCAPE-T" 4 "CONTINUOUS" "Labels for existing landscape easements.")
        (list "EX-ESMT-PUE-T" 21 "CONTINUOUS" "Labels for existing Public Utility Easements.")
        (list "EX-ESMT-SD-T" 21 "CONTINUOUS" "Labels for existing storm drain easements.")
        (list "EX-ESMT-SEWER-T" 63 "CONTINUOUS" "Labels for existing sewer easements.")
        (list "EX-ESMT-SW-T" 63 "CONTINUOUS" "Labels for existing sidewalk easements.")
        (list "EX-ESMT-WATER-T" 3 "CONTINUOUS" "Labels for existing water easements.")
        (list "EX-FENCE-T" 83 "CONTINUOUS" "Labels for existing fences.")
        (list "EX-FF-T" 205 "CONTINUOUS" "Labels for existing finished floor elevations.")
        (list "EX-FIRE-T" 45 "CONTINUOUS" "Labels for existing fire water systems.")
        (list "EX-FL-T" 45 "CONTINUOUS" "Labels for existing flowlines.")
        (list "EX-FLAG-T" 9 "CONTINUOUS" "Labels for existing flagpoles.")
        (list "EX-GAS-T" 83 "CONTINUOUS" "Labels for existing natural gas systems.")
        (list "EX-GATE-T" 45 "CONTINUOUS" "Labels for existing gates.")
        (list "EX-GRAVEL-T" 83 "CONTINUOUS" "Labels for existing gravel areas.")
        (list "EX-GUY-T" 191 "CONTINUOUS" "Labels for existing guy wires.")
        (list "EX-HB-T" 83 "CONTINUOUS" "Labels for existing hose bibbs.")
        (list "EX-IRR-T" 45 "CONTINUOUS" "Labels for existing irrigation systems.")
        (list "EX-JT-T" 83 "CONTINUOUS" "Labels for existing joint trenches.")
        (list "EX-LIGHT-T" 9 "CONTINUOUS" "Labels for existing lights.")
        (list "EX-MAIL-T" 45 "CONTINUOUS" "Labels for existing mailboxes.")
        (list "EX-MBGR-T" 45 "CONTINUOUS" "Labels for existing guardrails.")
        (list "EX-MON-T" 30 "CONTINUOUS" "Labels for existing survey monuments.")
        (list "EX-MOW-T" 9 "CONTINUOUS" "Labels for existing mow strips.")
        (list "EX-OWNER-T" 4 "CONTINUOUS" "Text identifying property owners.")
        (list "EX-PAD-T" 175 "CONTINUOUS" "Labels for existing pads.")
        (list "EX-PATCH-T" 75 "CONTINUOUS" "Labels for existing patches.")
        (list "EX-PATH-T" 191 "CONTINUOUS" "Labels for existing paths.")
        (list "EX-PL-T" 45 "CONTINUOUS" "Labels for existing property lines (bearings, distances).")
        (list "EX-PL-lot area-T" 105 "CONTINUOUS" "Text showing the area of an existing lot.")
        (list "EX-PL-lot no-T" 146 "CONTINUOUS" "Text showing an existing lot number.")
        (list "EX-PLANTER-T" 45 "CONTINUOUS" "Labels for existing planters.")
        (list "EX-PLAYGROUND-T" 191 "CONTINUOUS" "Labels for existing playgrounds.")
        (list "EX-UTIL-raise-T" 231 "CONTINUOUS" "Notes and labels for existing utilities to be adjusted or raised.")
        (list "FUT-T  create AND name as needed" 3 "CONTINUOUS" "Text and labels for future improvements.")
        (list "N-BARRICATE-T" 7 "CONTINUOUS" "Text and labels for proposed barricades.")
        (list "N-BDY-T" 7 "CONTINUOUS" "Bearing, distance, and other labels for proposed boundary lines.")
        (list "N-BLDG-T" 41 "CONTINUOUS" "Labels for proposed buildings, such as finished floor elevations.")
        (list "N-BOLLARD-T" 30 "CONTINUOUS" "Labels for proposed bollards.")
        (list "N-CL-intersection-T" 1 "CONTINUOUS" "Text labels for intersection centerlines, including elevations and stationing.")
        (list "N-CONC-T" 63 "CONTINUOUS" "Labels for proposed concrete areas, including type or thickness.")
        (list "N-DAYLIGHT-T" 230 "CONTINUOUS" "Labels for proposed daylight lines.")
        (list "N-DEMO-T" 150 "CONTINUOUS" "General demolition notes and callouts.")
        (list "N-DW-T" 2 "CONTINUOUS" "Labels for proposed driveways, such as slope or material type.")
        (list "N-ELEC-T" 150 "CONTINUOUS" "General text and labels for proposed electrical systems.")
        (list "N-ELEC-struct-T" 140 "CONTINUOUS" "Labels for proposed electrical structures, such as vaults or pull boxes.")
        (list "N-EP-from SAWCUT-T" 30 "CONTINUOUS" "Labels indicating 'match existing' at a sawcut line.")
        (list "N-EROSION-T" 150 "CONTINUOUS" "Text and labels for proposed erosion control measures.")
        (list "N-ESMT-ELEC-T" 2 "CONTINUOUS" "Labels for proposed electrical easements.")
        (list "N-ESMT-PUE-T" 21 "CONTINUOUS" "Labels for proposed Public Utility Easements (PUE).")
        (list "N-ESMT-SD-T" 21 "CONTINUOUS" "Labels for proposed storm drain easements.")
        (list "N-ESMT-SEWER-T" 63 "CONTINUOUS" "Labels for proposed sanitary sewer easements.")
        (list "N-ESMT-SW-T" 63 "CONTINUOUS" "Labels for proposed sidewalk easements.")
        (list "N-ESMT-WATER-T" 3 "CONTINUOUS" "Labels for proposed water line easements.")
        (list "N-EXHIBIT-T" 1 "CONTINUOUS" "Text and labels specific to exhibits.")
        (list "N-FF-T" 1 "CONTINUOUS" "Labels indicating proposed finished floor elevations.")
        (list "N-FIRE-T" 181 "CONTINUOUS" "Labels for proposed fire protection systems.")
        (list "N-GAS-T" 181 "CONTINUOUS" "Labels for proposed natural gas systems.")
        (list "N-GRAD-T" 181 "CONTINUOUS" "General text and labels related to grading, such as spot elevations and slope...")
        (list "N-HB-T" 7 "CONTINUOUS" "Labels for proposed hose bibbs.")
        (list "N-IRR-T" 4 "CONTINUOUS" "Labels for proposed irrigation systems.")
        (list "N-KEY-T" 41 "CONTINUOUS" "Text and labels on a keymap sheet.")
        (list "N-LAYOUT-T" 231 "CONTINUOUS" "General layout text and callouts for site plans.")
        (list "N-LIGHT-T" 150 "CONTINUOUS" "Labels for proposed site lighting.")
        (list "N-LIMIT OF WORK-T" 6 "CONTINUOUS" "Text labeling the limit of work.")
        (list "N-NOTE-T-caution" 1 "CONTINUOUS" "High-importance notes or caution text.")
        (list "N-PAD-T" 6 "CONTINUOUS" "Labels for proposed pads, such as pad elevation.")
        (list "N-PL-T" 7 "CONTINUOUS" "General labels for proposed property lines.")
        (list "N-PL-lot area-T" 4 "CONTINUOUS" "Text indicating the area of proposed lots or parcels.")
        (list "N-PL-lot no-T" 5 "CONTINUOUS" "Text labels for proposed lot or parcel numbers.")
        (list "N-PL-phase-T" 1 "CONTINUOUS" "Text labels for construction phases.")
        (list "N-PLANTER-T" 30 "CONTINUOUS" "Labels for proposed planter areas.")
        (list "N-PUMP-T" 30 "CONTINUOUS" "Labels for proposed pumps or pump stations.")
        (list "N-RD-T" 181 "CONTINUOUS" "Labels for proposed roof drains.")
        (list "N-RW-T" 230 "CONTINUOUS" "Labels for proposed Right-of-Way lines.")
        (list "N-SAWCUT-grad-T" 150 "CONTINUOUS" "Labels for proposed grading-related sawcut lines.")
        (list "N-SAWCUT-util-T" 230 "CONTINUOUS" "Labels for proposed utility-related sawcut lines.")
        (list "N-SD-T" 150 "CONTINUOUS" "General text and labels for proposed storm drain systems.")
        (list "N-SD-bioretention-T" 30 "CONTINUOUS" "Labels for proposed bioretention basins.")
        (list "N-SD-sleeve-T" 3 "CONTINUOUS" "Labels for proposed storm drain sleeves.")
        (list "N-SD-subdrain-T" 181 "CONTINUOUS" "Labels for proposed subdrains.")
        (list "N-SD-trench drain-T" 7 "CONTINUOUS" "Labels for proposed trench drains.")
        (list "N-SETBACK-BSL-T" 181 "CONTINUOUS" "Labels for proposed Building Setback Lines.")
        (list "N-SETBACK-CSL-T" 230 "CONTINUOUS" "Labels for proposed Creek Setback Lines.")
        (list "N-SETBACK-GSL-T" 150 "CONTINUOUS" "Labels for proposed Geologic Setback Lines.")
        (list "N-SEWER-T" 30 "CONTINUOUS" "General labels for proposed sanitary sewer systems.")
        (list "N-SEWER-force main-T" 231 "CONTINUOUS" "Labels for proposed sewer force mains.")
        (list "N-SIGN-T" 30 "CONTINUOUS" "Labels for proposed signs.")
        (list "N-SLOPE-SYM" 181 "CONTINUOUS" "Symbols indicating direction of slope, such as slope arrows or tadpoles.")
        (list "N-STRIPE-T" 4 "CONTINUOUS" "Labels for proposed pavement striping and markings.")
        (list "N-TANK-T" 30 "CONTINUOUS" "Labels for proposed tanks.")
        (list "N-TRASH-T" 150 "CONTINUOUS" "Labels for proposed trash enclosures.")
        (list "N-VG-T" 150 "CONTINUOUS" "Labels for proposed v-gutters, such as flowlines and slopes.")
        (list "N-VINErow-T" 63 "CONTINUOUS" "Labels for proposed vineyard rows.")
        (list "N-WATER-T" 7 "CONTINUOUS" "General labels for proposed domestic water systems.")
        (list "N-WATER-recycled-T" 4 "CONTINUOUS" "Labels for proposed recycled water systems.")
        (list "NA-SCALE" 150 "CONTINUOUS" "Text indicating that a detail or view is 'Not to Scale'.")
        (list "PRO-EX-T" 143 "CONTINUOUS" "Text and labels for existing features within a profile view.")
        (list "PRO-N-T" 150 "CONTINUOUS" "Text and labels for proposed features within a profile view.")
        (list "STREET-T" 5 "CONTINUOUS" "Street name labels.")
        (list "TABLE-T" 7 "CONTINUOUS" "Text, lines, and blocks used in tables and schedules.")
      )
    )
    (list "Boundaries & Alignments"
      (list
        (list "ALN-CL" 3 "CENTER2" "Proposed centerline geometry for roads, channels, or utility alignments.")
        (list "ALN-OFFSET" 150 "DASHED" "Offset lines related to a primary alignment, such as right-of-way or construc...")
        (list "EX-BDY-ap" 140 "PHANTOM2" "Existing boundary lines from an assessor's parcel map.")
        (list "EX-BDY-approx" 1 "PHANTOM2" "Approximate existing boundary lines.")
        (list "EX-BDY-final" 5 "PHANTOM2" "Existing boundary lines from a final map or record of survey.")
        (list "EX-BDY-parcel" 43 "CONTINUOUS" "Existing parcel boundary lines.")
        (list "EX-BDY-tik" 181 "CONTINUOUS" "Tick marks on existing boundary lines.")
        (list "EX-BM" 7 "CONTINUOUS" "Existing survey benchmarks.")
        (list "EX-CL" 2 "CENTER2" "Existing centerlines of roads, creeks, etc.")
        (list "EX-CONTROL" 7 "CONTINUOUS" "Existing survey control points.")
        (list "EX-ESMT-ELEC" 2 "HIDDEN2" "Existing electrical easement.")
        (list "EX-ESMT-LANDSCAPE" 3 "HIDDEN2" "Existing landscape easement.")
        (list "EX-ESMT-PUE" 2 "HIDDEN2" "Existing Public Utility Easement (PUE).")
        (list "EX-ESMT-SD" 2 "HIDDEN2" "Existing storm drain easement.")
        (list "EX-ESMT-SEWER" 3 "HIDDEN2" "Existing sewer easement.")
        (list "EX-ESMT-SW" 3 "HIDDEN2" "Existing sidewalk easement.")
        (list "EX-ESMT-WATER" 63 "HIDDEN2" "Existing water easement.")
        (list "EX-MON" 7 "CONTINUOUS" "Existing survey monuments found.")
        (list "EX-PL" 175 "PHANTOM2" "Existing property lines.")
        (list "EX-PL-tik" 83 "CONTINUOUS" "Tick marks on existing property lines.")
        (list "N-BDY" 41 "PHANTOM2" "Proposed boundary lines, such as project limits or property lines.")
        (list "N-BDY-tik" 30 "CONTINUOUS" "Tick marks or symbols used on proposed boundary lines.")
        (list "N-CL" 2 "CENTER2" "Proposed centerlines for general features like roads, parking aisles, or pipes.")
        (list "N-CL-tik" 3 "CONTINUOUS" "Tick marks for stationing along a proposed centerline.")
        (list "N-ESMT-ELEC" 21 "HIDDEN2" "Proposed electrical easement boundaries.")
        (list "N-ESMT-PUE" 2 "HIDDEN2" "Proposed Public Utility Easement (PUE) boundaries.")
        (list "N-ESMT-SD" 2 "HIDDEN2" "Proposed storm drain easement boundaries.")
        (list "N-ESMT-SEWER" 3 "HIDDEN2" "Proposed sanitary sewer easement boundaries.")
        (list "N-ESMT-SW" 3 "HIDDEN2" "Proposed sidewalk easement boundaries.")
        (list "N-ESMT-WATER" 2 "HIDDEN2" "Proposed water line easement boundaries.")
        (list "N-LIMIT OF WORK" 1 "DASHED" "Line defining the limit of construction work.")
        (list "N-MON" 7 "CONTINUOUS" "Proposed survey monuments to be set.")
        (list "N-PL" 30 "CONTINUOUS" "Proposed property lines or parcel lines.")
        (list "N-PL-phase" 251 "HIDDEN" "Linework delineating different construction phases on a lot.")
        (list "N-PL-tik" 181 "CONTINUOUS" "Tick marks on proposed property lines.")
        (list "N-RW" 6 "PHANTOM2" "Proposed Right-of-Way (ROW) lines.")
        (list "N-RW-tik" 7 "CONTINUOUS" "Tick marks on proposed Right-of-Way lines.")
        (list "N-SETBACK-BSL" 2 "DASHED2" "Proposed Building Setback Line (BSL).")
        (list "N-SETBACK-CSL" 3 "DASHED2" "Proposed Creek Setback Line (CSL).")
        (list "N-SETBACK-GSL" 21 "DASHED2" "Proposed Geologic Setback Line (GSL).")
      )
    )
    (list "General"
      (list
        (list "0" 7 "CONTINUOUS" "Default layer; usage is generally discouraged in favor of specific layers.")
        (list "0riginal layer name -APPROX  create as needed" 7 "CONTINUOUS" "Placeholder for creating layers showing approximate locations of items.")
        (list "0riginal layer name -APPROX and -APPROX-T  create as needed" 7 "CONTINUOUS" "Placeholder for creating layers showing approximate locations of items.")
        (list "DETAIL" 7 "CONTINUOUS" "General linework for standard construction details.")
        (list "FUT-  create AND name as needed" 231 "S05" "Placeholder for future improvements or phased construction elements.")
        (list "P-DESIGN" 7 "CONTINUOUS" "Preliminary design linework.")
        (list "P-LAYOUT" 6 "CONTINUOUS" "Preliminary layout linework.")
      )
    )
    (list "Grading & Surface"
      (list
        (list "CORRIDOR" 150 "CONTINUOUS" "Civil 3D corridor objects and their associated linework.")
        (list "EX-BOREHOLE" 205 "CONTINUOUS" "Locations of existing geotechnical boreholes or test pits.")
        (list "EX-CONT-MJR" 205 "DASHED" "Existing major elevation contours.")
        (list "EX-CONT-MNR" 9 "DASHED" "Existing minor elevation contours.")
        (list "EX-FL" 175 "SWALE2-NOARROW" "Existing flowlines of ditches, gutters, or swales.")
        (list "EX-GB" 45 "S05" "Existing grade breaks.")
        (list "FEATURELINE" 230 "CONTINUOUS" "Civil 3D feature lines used for grading design.")
        (list "N-CONT-MJR" 5 "CONTINUOUS" "Proposed major elevation contours.")
        (list "N-CONT-MNR" 4 "CONTINUOUS" "Proposed minor elevation contours.")
        (list "N-DAYLIGHT" 4 "S05" "Proposed daylight line where grading meets existing ground.")
        (list "N-EROSION" 7 "CONTINUOUS" "General linework for proposed erosion control measures (BMPs).")
        (list "N-GB" 3 "S05" "Proposed grade breaks.")
        (list "N-SWALE" 4 "SWALE2" "Proposed vegetated or earthen swales.")
        (list "N-TOE" 3 "HIDDEN" "Proposed toe of slope.")
        (list "N-TOP" 2 "HIDDEN" "Proposed top of slope, bank, or wall.")
        (list "SURFACE" 7 "CONTINUOUS" "General layer for Civil 3D surface objects.")
        (list "SURFACE-BDY" 1 "CONTINUOUS" "Non-plottable boundary defining the limits of a surface.")
        (list "SURFACE-FEATURLINE" 231 "CONTINUOUS" "Non-plottable feature lines used to build a surface model.")
      )
    )
    (list "Hatching & Visualization"
      (list
        (list "HATCH-ac" 63 "CONTINUOUS" "Hatch pattern for areas of asphalt concrete (AC) pavement.")
        (list "HATCH-aisle-drive" 63 "CONTINUOUS" "Hatch pattern for drive aisles in parking lots.")
        (list "HATCH-aisle-parking" 21 "CONTINUOUS" "Hatch pattern for parking stall areas.")
        (list "HATCH-bumps" 143 "CONTINUOUS" "Hatch pattern for truncated domes or detectable warning surfaces.")
        (list "HATCH-conc" 143 "CONTINUOUS" "Hatch pattern for areas of concrete.")
        (list "HATCH-conc-vehicular" 30 "CONTINUOUS" "Hatch pattern for heavy-duty concrete pavement subject to vehicular traffic.")
        (list "HATCH-const entrance" 143 "CONTINUOUS" "Hatch pattern for stabilized construction entrances.")
        (list "HATCH-edge grind" 21 "CONTINUOUS" "Hatch pattern indicating areas of pavement to be edge grinded.")
        (list "HATCH-pad" 8 "CONTINUOUS" "Hatch pattern for building pads or equipment pads.")
        (list "HATCH-parking" 2 "CONTINUOUS" "General hatch pattern for parking lot areas.")
        (list "N-DEMO-hatch-HARDSCAPE" 3 "CONTINUOUS" "Hatch pattern indicating hardscape (pavement, concrete) to be demolished.")
        (list "N-DEMO-hatch-VEGETATION" 2 "CONTINUOUS" "Hatch pattern indicating vegetation to be cleared and grubbed.")
        (list "N-DEMO-hatch-_____" 21 "CONTINUOUS" "Placeholder for various demolition hatch patterns.")
        (list "PRO-HATCH-EX" 9 "CONTINUOUS" "Hatch patterns for existing features in a profile or section view.")
        (list "PRO-HATCH-N" 143 "CONTINUOUS" "Hatch patterns for proposed features in a profile or section view (e.g., tren...")
      )
    )
    (list "Profiles & Sections"
      (list
        (list "ALN-SECTION" 41 "CONTINUOUS" "Sample lines used for generating cross-sections along an alignment.")
        (list "N-SECTION" 5 "CONTINUOUS" "General linework for drawn cross-sections.")
        (list "PRO" 7 "CONTINUOUS" "General linework within a profile view.")
        (list "PRO-EG" 12 "HIDDEN" "Existing ground surface shown in a profile view.")
        (list "PRO-EX-FIRE" 14 "CONTINUOUS" "Existing fire pipelines shown in a profile view.")
        (list "PRO-EX-SD" 105 "CONTINUOUS" "Existing storm drain pipelines shown in a profile view.")
        (list "PRO-EX-SEWER" 205 "CONTINUOUS" "Existing sewer pipelines shown in a profile view.")
        (list "PRO-EX-WATER" 11 "CONTINUOUS" "Existing water pipelines shown in a profile view.")
        (list "PRO-N WATER" 140 "CONTINUOUS" "Proposed water pipelines shown in a profile view.")
        (list "PRO-N-FG" 41 "CONTINUOUS" "Proposed finished grade surface shown in a profile view.")
        (list "PRO-N-FIRE" 1 "CONTINUOUS" "Proposed fire pipelines shown in a profile view.")
        (list "PRO-N-FITTING" 143 "CONTINUOUS" "Proposed pipe fittings (bends, tees) shown in a profile view.")
        (list "PRO-N-SD" 60 "CONTINUOUS" "Proposed storm drain pipelines shown in a profile view.")
        (list "PRO-N-SEWER" 6 "CONTINUOUS" "Proposed sewer pipelines shown in a profile view.")
      )
    )
    (list "Sheet Layout"
      (list
        (list "$AREA-design calc" 150 "CONTINUOUS" "Non-plottable layer for design calculations and temporary geometry.")
        (list "$NOPLOT" 101 "CONTINUOUS" "General purpose non-plottable layer for construction lines or helper objects.")
        (list "Defpoints" 101 "CONTINUOUS" "System layer for definition points of dimensions; non-plottable.")
        (list "HATCH-bdy" 101 "CONTINUOUS" "Non-plottable boundaries used to define hatch areas.")
        (list "LEGEND" 7 "CONTINUOUS" "Linework and text for sheet legends.")
        (list "MATCHLINE-model space" 101 "CONTINUOUS" "Non-plottable lines in model space defining the limits of sheet views.")
        (list "N-EXHIBIT-misc" 6 "CONTINUOUS" "Miscellaneous linework used for creating special exhibits or diagrams.")
        (list "N-KEY-MSVIEW" 1 "DASHED2" "Keymap viewport outlines shown on a keymap sheet.")
        (list "zzMSVIEW" 101 "CONTINUOUS" "Non-plottable layer for paper space viewports.")
      )
    )
    (list "Site Elements"
      (list
        (list "EX-AC" 175 "HIDDEN2" "Existing asphalt concrete pavement.")
        (list "EX-BARRICADE" 175 "S05" "Existing barricades.")
        (list "EX-BASKETBALL-court" 83 "CONTINUOUS" "Existing basketball court outlines.")
        (list "EX-BASKETBALL-hoop" 13 "CONTINUOUS" "Existing basketball hoops.")
        (list "EX-BENCH" 191 "CONTINUOUS" "Existing benches.")
        (list "EX-BOLLARD" 9 "CONTINUOUS" "Existing bollards.")
        (list "EX-BRUSH" 83 "S03" "Existing brush or dense vegetation driplines.")
        (list "EX-CONC" 45 "CONTINUOUS" "Existing concrete surfaces.")
        (list "EX-CURB-BC" 8 "HIDDEN2" "Existing back of curb.")
        (list "EX-CURB-FC" 205 "HIDDEN2" "Existing face of curb.")
        (list "EX-CURB-LIP" 9 "HIDDEN2" "Existing lip of gutter.")
        (list "EX-DIKE" 191 "CONTINUOUS" "Existing dikes or berms.")
        (list "EX-DIRT ROAD" 45 "HIDDEN2" "Existing dirt or gravel roads.")
        (list "EX-DW" 45 "CONTINUOUS" "Existing driveways.")
        (list "EX-EP" 13 "HIDDEN2" "Existing edge of pavement.")
        (list "EX-FENCE" 9 "FENCE2" "Existing fences.")
        (list "EX-FLAG" 83 "CONTINUOUS" "Existing flagpoles.")
        (list "EX-GATE" 11 "S05" "Existing gates.")
        (list "EX-GRAVEL" 191 "HIDDEN2" "Existing gravel areas.")
        (list "EX-LAWN" 83 "CONTINUOUS" "Existing lawn or turf areas.")
        (list "EX-MAIL" 9 "CONTINUOUS" "Existing mailboxes.")
        (list "EX-MBGR" 175 "S03" "Existing Metal Beam Guard Rail (MBGR).")
        (list "EX-MOW" 8 "S07" "Existing mow strips.")
        (list "EX-PATCH" 49 "DASHED" "Existing asphalt or concrete patches.")
        (list "EX-PATH-description-dirt-etc" 8 "HIDDEN2" "Existing paths (dirt, gravel, etc.).")
        (list "EX-PAVER" 9 "CONTINUOUS" "Existing paver surfaces.")
        (list "EX-PLANTER" 11 "S07" "Existing planter boxes or landscape areas.")
        (list "EX-PLAYGROUND" 45 "CONTINUOUS" "Existing playground equipment or areas.")
        (list "EX-POST" 45 "CONTINUOUS" "Existing posts (fence, sign, etc.).")
        (list "N-AC" 3 "CONTINUOUS" "Linework for proposed asphalt concrete pavement edges.")
        (list "N-BARRICADE" 30 "CONTINUOUS" "Proposed barricades or traffic control devices.")
        (list "N-BOLLARD" 21 "CONTINUOUS" "Proposed bollards.")
        (list "N-CONC" 2 "CONTINUOUS" "Linework for proposed concrete flatwork, such as sidewalks or patios.")
        (list "N-CURB-BC" 21 "CONTINUOUS" "Linework for the proposed back of curb.")
        (list "N-CURB-FC" 5 "CONTINUOUS" "Linework for the proposed face of curb.")
        (list "N-CURB-LIP" 63 "CONTINUOUS" "Linework for the proposed lip of gutter.")
        (list "N-DEMO-sawcut" 2 "HIDDEN" "Lines indicating sawcut limits for pavement or concrete removal.")
        (list "N-DIKE" 181 "CONTINUOUS" "Proposed earth dikes or berms.")
        (list "N-DW" 63 "CONTINUOUS" "Proposed driveways.")
        (list "N-EDGE GRIND" 3 "HIDDENX2" "Linework indicating the limits of proposed pavement edge grinding.")
        (list "N-EP" 4 "CONTINUOUS" "Proposed edge of pavement.")
        (list "N-EP-from SAWCUT" 3 "CONTINUOUS" "Proposed edge of new pavement that joins an existing sawcut line.")
        (list "N-EQUIPMENT" 30 "CONTINUOUS" "Proposed site equipment, such as HVAC units, transformers, or pumps.")
        (list "N-EROSION-const entrance" 143 "CONTINUOUS" "Outline of proposed stabilized construction entrance.")
        (list "N-EROSION-fiber roll" 4 "FIBERROLL" "Proposed fiber rolls or wattles for erosion control.")
        (list "N-FENCE" 4 "FENCE2" "Proposed fences.")
        (list "N-FENCE-TREE protection" 7 "TREEFENCE_LINE" "Proposed temporary tree protection fencing.")
        (list "N-FENCE-silt" 140 "SILTFENCE_LINE" "Proposed silt fences for erosion control.")
        (list "N-FURNITURE" 21 "CONTINUOUS" "Proposed site furniture such as benches, bike racks, and trash receptacles.")
        (list "N-GRAVEL" 30 "CONTINUOUS" "Outlines of proposed gravel or aggregate surface areas.")
        (list "N-MAIL" 2 "CONTINUOUS" "Proposed mailboxes or cluster box units.")
        (list "N-MECHANICAL" 1 "CONTINUOUS" "Proposed mechanical equipment.")
        (list "N-MOW" 21 "CONTINUOUS" "Proposed mow strips or curb.")
        (list "N-ROCK" 3 "CONTINUOUS" "Proposed rock, rip-rap, or decorative boulders.")
        (list "N-SAWCUT-grad" 2 "HIDDEN" "Proposed sawcut lines related to grading and pavement removal.")
        (list "N-SD-bioretention" 231 "HIDDEN2" "Outlines of proposed bioretention or biofiltration basins.")
        (list "N-SD-riprap" 2 "CONTINUOUS" "Proposed rip-rap or rock slope protection for storm drain outlets.")
        (list "N-SHOULDER" 3 "CONTINUOUS" "Proposed road shoulders.")
        (list "N-SIGN" 7 "CONTINUOUS" "Proposed signs and sign posts.")
        (list "N-SKID" 4 "CONTINUOUS" "Proposed equipment skids.")
        (list "N-STRIPE" 63 "CONTINUOUS" "Proposed pavement striping and markings.")
        (list "N-STRIPE-pavement marker" 231 "CONTINUOUS" "Proposed reflective pavement markers.")
        (list "N-STRIPE-red curb" 251 "CONTINUOUS" "Proposed red curb (no parking zones).")
        (list "N-SW" 4 "CONTINUOUS" "Proposed sidewalks.")
        (list "N-SW-handrail" 43 "CONTINUOUS" "Proposed handrails along sidewalks or ramps.")
        (list "N-SW-joint" 143 "CONTINUOUS" "Proposed expansion or contraction joints in sidewalks.")
        (list "N-TRASH" 230 "CONTINUOUS" "Proposed trash enclosures.")
        (list "N-VG" 7 "CONTINUOUS" "Proposed v-gutters or concrete drainage channels.")
        (list "N-VINErow" 21 "CONTINUOUS" "Proposed vineyard rows or agricultural plantings.")
        (list "N-WHEEL STOP" 7 "CONTINUOUS" "Proposed wheel stops in parking stalls.")
        (list "TREE-SYM-remove" 150 "CONTINUOUS" "Symbols for existing trees to be removed.")
        (list "TREE-SYM-save" 30 "CONTINUOUS" "Symbols for existing trees to be saved and protected.")
      )
    )
    (list "Structural Elements"
      (list
        (list "EX-BLDG" 235 "HIDDEN" "Outlines of existing buildings.")
        (list "EX-BLDG-overhang" 75 "S05" "Drip lines or overhangs of existing buildings.")
        (list "EX-COLUMN" 75 "CONTINUOUS" "Existing structural columns.")
        (list "EX-DECK" 191 "CONTINUOUS" "Existing decks or patios.")
        (list "EX-DOOR" 75 "S03" "Existing exterior doors on buildings.")
        (list "EX-PAD" 205 "DASHED" "Existing building or equipment pads.")
        (list "N-BLDG" 5 "CONTINUOUS" "Outlines of proposed buildings or structures.")
        (list "N-DOOR" 2 "CONTINUOUS" "Location of proposed exterior doors on buildings.")
        (list "N-PAD" 1 "DASHED" "Outlines of proposed building pads or equipment pads.")
        (list "N-WALL" 150 "CONTINUOUS" "General proposed walls.")
        (list "N-WALL-headwall" 140 "CONTINUOUS" "Proposed headwalls at pipe outlets.")
        (list "N-WALL-retaining" 181 "CONTINUOUS" "Proposed retaining walls.")
      )
    )
    (list "Utilities"
      (list
        (list "EX-ELEC" 175 "ELECTRIC" "Existing underground electrical lines.")
        (list "EX-ELEC-overhead" 205 "OVERHEAD2" "Existing overhead electrical lines.")
        (list "EX-ELEC-struct" 14 "CONTINUOUS" "Existing electrical structures like vaults, pull boxes, or transformers.")
        (list "EX-FIRE" 11 "FIRE" "Existing fire water pipelines.")
        (list "EX-GAS" 13 "GAS" "Existing natural gas pipelines.")
        (list "EX-GUY" 13 "CONTINUOUS" "Existing guy wires for utility poles.")
        (list "EX-HB" 175 "S07" "Existing hose bibbs.")
        (list "EX-IRR" 75 "IRRIGATION" "Existing irrigation lines.")
        (list "EX-JT" 45 "JOINT_TRENCH" "Existing joint utility trenches.")
        (list "EX-LIGHT" 45 "CONTINUOUS" "Existing light poles.")
        (list "EX-UTIL-raise" 230 "CONTINUOUS" "Indicates existing utility manholes or structures to be raised to new grade.")
        (list "N-DEMO-utility cap" 1 "CONTINUOUS" "Symbols indicating utility lines to be capped and abandoned.")
        (list "N-DEMO-utility protect" 181 "P P P P P P P P" "Lines indicating existing utilities to be protected in place during construct...")
        (list "N-DEMO-utility remove" 150 "X X X X" "Lines indicating existing utilities to be removed.")
        (list "N-ELEC" 4 "ELECTRIC" "Proposed underground electrical conduit or direct-bury cable.")
        (list "N-FIRE" 42 "CONTINUOUS" "Proposed fire protection pipelines.")
        (list "N-GAS" 30 "CONTINUOUS" "Proposed natural gas pipelines.")
        (list "N-HB" 181 "CONTINUOUS" "Proposed hose bibb locations.")
        (list "N-IRR" 230 "CONTINUOUS" "Proposed irrigation system piping.")
        (list "N-LIGHT" 7 "CONTINUOUS" "Proposed light poles and fixtures.")
        (list "N-PUMP" 4 "CONTINUOUS" "Proposed pump equipment.")
        (list "N-PUMP-STA" 4 "CONTINUOUS" "Proposed pump station structure or building.")
        (list "N-RD" 1 "CONTINUOUS" "Proposed roof drains.")
        (list "N-SAWCUT-util" 21 "HIDDEN" "Proposed sawcut lines for utility trenching.")
        (list "N-SD" 30 "CONTINUOUS" "Proposed storm drain pipes and structures.")
        (list "N-SD-sleeve" 2 "HIDDEN" "Proposed sleeves for storm drain pipes passing through walls or structures.")
        (list "N-SD-struct" 4 "CONTINUOUS" "Proposed storm drain structures such as manholes, catch basins, or inlets.")
        (list "N-SD-subdrain" 1 "HIDDEN" "Proposed subdrains or perforated pipes.")
        (list "N-SD-trench drain" 4 "CONTINUOUS" "Proposed trench drains.")
        (list "N-SEWER" 6 "CONTINUOUS" "Proposed sanitary sewer gravity mains.")
        (list "N-SEWER-force main" 140 "CONTINUOUS" "Proposed sanitary sewer force mains.")
        (list "N-SEWER-lateral" 150 "CONTINUOUS" "Proposed sanitary sewer laterals.")
        (list "N-SEWER-struct" 1 "CONTINUOUS" "Proposed sanitary sewer structures, such as manholes or cleanouts.")
        (list "N-TANK" 5 "CONTINUOUS" "Proposed tanks (e.g., water, fuel, chemical).")
        (list "N-TANK-appurtenance" 4 "CONTINUOUS" "Proposed appurtenances associated with tanks, such as valves or hatches.")
        (list "N-UTIL-poc" 101 "HIDDEN" "Non-plottable points of connection for utilities at a building.")
        (list "N-WATER" 140 "CONTINUOUS" "Proposed domestic water pipelines.")
        (list "N-WATER-lateral" 181 "CONTINUOUS" "Proposed domestic water laterals or service lines.")
        (list "N-WATER-pollution control" 7 "CONTINUOUS" "Proposed water pollution control devices, such as backflow preventers.")
        (list "N-WATER-recycled" 6 "RECYCLED WATER" "Proposed recycled water pipelines.")
        (list "N-WATER-struct" 181 "CONTINUOUS" "Proposed water structures, such as valves, meters, or hydrants.")
      )
    )
  )
)


;;;; -- LAYER ACCESSORS ---------------------------------------------

(defun BR:LC:Label  (e) (nth 0 e))    ; category label
(defun BR:LC:Layers (e) (nth 1 e))    ; list of layer entries

(defun BR:LY:Name   (e) (nth 0 e))    ; layer name
(defun BR:LY:Color  (e) (nth 1 e))    ; color number
(defun BR:LY:LType  (e) (nth 2 e))    ; linetype name
(defun BR:LY:Desc   (e) (nth 3 e))    ; description


;;;; -- LAYER OPERATIONS --------------------------------------------

;; Create a layer if it doesn't exist, set color and linetype.
;; Returns T on success.
(defun BR:MakeLayer (lname lcolor ltype / doc layers lobj)
  (setq doc    (vla-get-activedocument (vlax-get-acad-object))
        layers (vla-get-layers doc))
  (setq lobj
    (vl-catch-all-apply
      'vla-add (list layers lname)))
  (if (not (vl-catch-all-error-p lobj))
    (progn
      (vla-put-color lobj lcolor)
      ;; Only set linetype if it's loaded
      (if (not (equal (strcase ltype) "CONTINUOUS"))
        (vl-catch-all-apply
          'vla-put-linetype (list lobj ltype))
      )
      t
    )
    nil
  )
)

;; Apply all layers from a category to the current drawing.
;; Returns count of layers created/updated.
(defun BR:ApplyLayerSet (cat-entry / layers count)
  ;; Ensure linetypes are loaded before creating layers
  (BR:LoadAllLinetypes)
  (setq layers (BR:LC:Layers cat-entry)
        count  0)
  (foreach ly layers
    (if (BR:MakeLayer (BR:LY:Name ly) (BR:LY:Color ly) (BR:LY:LType ly))
      (setq count (1+ count))
    )
  )
  count
)

;; Audit current drawing layers against a category.
;; Returns list of (layer-name status) where status is "OK" "MISSING" "NON-STD-COLOR" etc.
(defun BR:AuditLayers (cat-entry / doc layers results lname lobj std-color act-color)
  (setq doc     (vla-get-activedocument (vlax-get-acad-object))
        layers  (vla-get-layers doc)
        results nil)
  (foreach ly (BR:LC:Layers cat-entry)
    (setq lname     (BR:LY:Name ly)
          std-color (BR:LY:Color ly))
    (setq lobj
      (vl-catch-all-apply
        'vla-item (list layers lname)))
    (if (vl-catch-all-error-p lobj)
      (setq results (append results (list (list lname "MISSING"))))
      (progn
        (setq act-color (vla-get-color lobj))
        (if (= act-color std-color)
          (setq results (append results (list (list lname "OK"))))
          (setq results
            (append results
              (list (list lname
                (strcat "COLOR: " (itoa act-color)
                        " (std: " (itoa std-color) ")")))))
        )
      )
    )
  )
  results
)

;; Bulk freeze all layers in a category.
(defun BR:FreezeCatLayers (cat-entry / doc layers lobj count)
  (setq doc    (vla-get-activedocument (vlax-get-acad-object))
        layers (vla-get-layers doc)
        count  0)
  (foreach ly (BR:LC:Layers cat-entry)
    (setq lobj
      (vl-catch-all-apply
        'vla-item (list layers (BR:LY:Name ly))))
    (if (not (vl-catch-all-error-p lobj))
      (progn
        (vl-catch-all-apply
          'vla-put-freeze (list lobj :vlax-true))
        (setq count (1+ count))
      )
    )
  )
  count
)

;; Bulk thaw all layers in a category.
(defun BR:ThawCatLayers (cat-entry / doc layers lobj count)
  (setq doc    (vla-get-activedocument (vlax-get-acad-object))
        layers (vla-get-layers doc)
        count  0)
  (foreach ly (BR:LC:Layers cat-entry)
    (setq lobj
      (vl-catch-all-apply
        'vla-item (list layers (BR:LY:Name ly))))
    (if (not (vl-catch-all-error-p lobj))
      (progn
        (vl-catch-all-apply
          'vla-put-freeze (list lobj :vlax-false))
        (setq count (1+ count))
      )
    )
  )
  count
)


;;;; -- DCL DIALOG --------------------------------------------------

(defun BR:LayersDCL (/ dcl-path dcl-id done d-mode d-catidx cat count results msg)

  (setq dcl-path (findfile "BR_Layers.dcl"))
  (if (null dcl-path)
    (progn
      (alert
        (strcat "BR_Layers.dcl not found.\n\n"
                "Make sure BR_Layers.dcl is in the same folder as the LSP files\n"
                "and that folder is on AutoCAD's support path."))
      (exit)
    )
  )

  (setq d-mode   "mode_apply"
        d-catidx -1)

  (setq dcl-id (load_dialog dcl-path))
  (if (< dcl-id 0)
    (progn (alert (strcat "Cannot load DCL:\n" dcl-path)) (exit))
  )
  (if (not (new_dialog "br_layers" dcl-id))
    (progn
      (unload_dialog dcl-id)
      (alert "Cannot initialize br_layers dialog.")
      (exit)
    )
  )

  ;; Populate category list -- index 0 is ALL, then individual categories
  (start_list "layer_cat_list")
  (add_list "ALL CATEGORIES  (360 layers)")
  (foreach cat *BR:LAYER-CATS*
    (add_list
      (strcat (BR:LC:Label cat)
              "  (" (itoa (length (BR:LC:Layers cat))) " layers)"))
  )
  (end_list)

  ;; Default mode
  (set_tile "mode_apply" "1")

  ;; Actions
  (action_tile "mode_apply"  "(setq d-mode \"mode_apply\")")
  (action_tile "mode_audit"  "(setq d-mode \"mode_audit\")")
  (action_tile "mode_freeze" "(setq d-mode \"mode_freeze\")")
  (action_tile "mode_thaw"   "(setq d-mode \"mode_thaw\")")

  (action_tile "layer_cat_list"
    "(setq d-catidx (BR:DCL:SafeIndex $value))")

  (action_tile "accept" "(done_dialog 1)")
  (action_tile "cancel" "(done_dialog 0)")

  (setq done (start_dialog))
  (unload_dialog dcl-id)

  ;; -- Act on result ---------------------------------------------
  ;; Index 0 = ALL CATEGORIES, index >= 1 = (nth (1- d-catidx) *BR:LAYER-CATS*)
  (if (and (= done 1) (>= d-catidx 0))
    (cond
      ;; -- Apply mode --
      ((= d-mode "mode_apply")
       (if (= d-catidx 0)
         ;; ALL CATEGORIES
         (progn
           (setq count 0)
           (foreach cat *BR:LAYER-CATS*
             (setq count (+ count (BR:ApplyLayerSet cat)))
           )
           (alert (strcat "Applied " (itoa count) " layers (all categories)."))
         )
         ;; Single category
         (progn
           (setq cat (nth (1- d-catidx) *BR:LAYER-CATS*))
           (setq count (BR:ApplyLayerSet cat))
           (alert (strcat "Applied " (itoa count) " layers from \""
                          (BR:LC:Label cat) "\"."))
         )
       )
      )
      ;; -- Audit mode --
      ((= d-mode "mode_audit")
       (if (= d-catidx 0)
         (alert "For a full drawing audit, use the BR_AUD command.\nSelect a specific category here.")
         (progn
           (setq cat (nth (1- d-catidx) *BR:LAYER-CATS*))
           (setq results (BR:AuditLayers cat))
           (setq msg "Layer Audit Results:\n\n")
           (foreach r results
             (setq msg (strcat msg (car r) "  --  " (cadr r) "\n"))
           )
           (alert msg)
         )
       )
      )
      ;; -- Freeze mode --
      ((= d-mode "mode_freeze")
       (if (= d-catidx 0)
         (progn
           (setq count 0)
           (foreach cat *BR:LAYER-CATS*
             (setq count (+ count (BR:FreezeCatLayers cat)))
           )
           (alert (strcat "Froze " (itoa count) " layers (all categories)."))
         )
         (progn
           (setq cat (nth (1- d-catidx) *BR:LAYER-CATS*))
           (setq count (BR:FreezeCatLayers cat))
           (alert (strcat "Froze " (itoa count) " layers in \""
                          (BR:LC:Label cat) "\"."))
         )
       )
      )
      ;; -- Thaw mode --
      ((= d-mode "mode_thaw")
       (if (= d-catidx 0)
         (progn
           (setq count 0)
           (foreach cat *BR:LAYER-CATS*
             (setq count (+ count (BR:ThawCatLayers cat)))
           )
           (alert (strcat "Thawed " (itoa count) " layers (all categories)."))
         )
         (progn
           (setq cat (nth (1- d-catidx) *BR:LAYER-CATS*))
           (setq count (BR:ThawCatLayers cat))
           (alert (strcat "Thawed " (itoa count) " layers in \""
                          (BR:LC:Label cat) "\"."))
         )
       )
      )
    )
    (if (and (= done 1) (< d-catidx 0))
      (alert "Please select a layer category first.")
    )
  )
)


;;;; -- COMMAND ------------------------------------------------------

(defun C:BR_LAY (/ *error* _olderr _saved _undoFlag)
  (vl-load-com)
  (setq _saved  (BR:SaveSysvars '("CMDECHO" "CLAYER"))
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

  (BR:LayersDCL)

  (BR:EndUndo _undoFlag)
  (BR:RestoreSysvars _saved)
  (setq *error* _olderr)
  (princ)
)


;;;; -- MODULE LOADED -----------------------------------------------

(princ "\n  BR_Layers module loaded.  Command: BR_LAY")
(princ)

;;; End of BR_Layers.lsp
