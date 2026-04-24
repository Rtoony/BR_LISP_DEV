// ================================================================
// BR_ProjectDB.dcl  |  Brelje & Race CAD Tools  |  Project Database
// ================================================================

br_project_db : dialog {
  label = "BR : Project Database";

  // -- Project Info ------------------------------------------------
  : boxed_column {
    label = " Project ";
    : row {
      : text {
        key       = "proj_display";
        label     = "Project: ...";
        width     = 28;
        alignment = left;
      }
      : popup_list {
        key   = "status";
        label = "Status";
        width = 10;
      }
    }
    : edit_box {
      key        = "proj_name";
      label      = "Name";
      edit_width = 44;
    }
    : edit_box {
      key        = "proj_date";
      label      = "Date (YYYY-MM-DD)";
      edit_width = 14;
      fixed_width = true;
    }
  }

  // -- Drawing Setup -----------------------------------------------
  : boxed_row {
    label = " Drawing Setup ";
    : popup_list { key = "config";  label = "Config"; width = 20; }
    : popup_list { key = "tb_size"; label = "TB Size"; width = 10; }
    : popup_list { key = "tb_type"; label = "TB Type"; width = 10; }
  }

  // -- Team & Permits ----------------------------------------------
  : boxed_column {
    label = " Team & Permits ";
    : row {
      : edit_box { key = "manager";  label = "PM";       edit_width = 18; }
      : edit_box { key = "designer"; label = "Designer"; edit_width = 18; }
    }
    : edit_box { key = "client"; label = "Client"; edit_width = 44; }
    : row {
      : edit_box { key = "apn";    label = "APN";      edit_width = 14; }
      : edit_box { key = "permit"; label = "Permit #"; edit_width = 14; }
    }
  }

  // -- GIS / Location ----------------------------------------------
  : boxed_column {
    label = " GIS / Location ";
    : row {
      : text {
        key       = "centroid_val";
        label     = "Centroid: ...";
        width     = 42;
        alignment = left;
      }
      : button {
        key         = "pick_centroid";
        label       = " Pick ";
        width       = 8;
        fixed_width = true;
      }
    }
    : row {
      : text {
        key       = "area_val";
        label     = "Area: ...";
        width     = 42;
        alignment = left;
      }
      : button {
        key         = "pick_area";
        label       = " Pick ";
        width       = 8;
        fixed_width = true;
      }
    }
    : edit_box {
      key        = "offset";
      label      = "Area Offset (ft)";
      edit_width = 10;
      fixed_width = true;
    }
    : edit_box {
      key        = "coord_sys";
      label      = "Coord System";
      edit_width = 36;
    }
    : edit_box {
      key        = "vert_datum";
      label      = "Vert Datum";
      edit_width = 20;
    }
  }

  // -- File path preview -------------------------------------------
  : text {
    key       = "file_path";
    label     = "File: ...";
    alignment = left;
    width     = 62;
  }

  // -- Buttons -----------------------------------------------------
  : row {
    : button {
      key   = "accept";
      label = "  Save  ";
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
