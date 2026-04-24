// ================================================================
// BR_SheetSet.dcl  |  Brelje & Race CAD Tools  |  Sheet Set DB
// ================================================================

br_sheetset : dialog {
  label = "BR : Sheet Set";

  : boxed_column {
    label = " Project Sheet Set ";
    : row {
      : text {
        key       = "proj_display";
        label     = "Project: ...";
        width     = 24;
        alignment = left;
      }
      : text {
        key       = "sheet_count";
        label     = "Sheets: 0";
        width     = 14;
        alignment = left;
      }
    }
    : edit_box {
      key        = "sheetset_name";
      label      = "Name";
      edit_width = 42;
    }
    : edit_box {
      key        = "notes";
      label      = "Notes";
      edit_width = 42;
    }
    : text {
      key       = "source_dsd";
      label     = "Source DSD: ";
      width     = 70;
      alignment = left;
    }
    : text {
      key       = "file_path";
      label     = "File: ";
      width     = 70;
      alignment = left;
    }
  }

  : row {
    : boxed_column {
      label = " Sheets ";
      : list_box {
        key             = "sheet_list";
        height          = 16;
        width           = 38;
        multiple_select = false;
      }
      : row {
        : button { key = "btn_all";  label = "Include All";  width = 12; }
        : button { key = "btn_none"; label = "Include None"; width = 12; }
      }
      : button {
        key   = "import_dsd";
        label = " Import / Refresh From DSD ";
      }
      : button {
        key   = "export_index";
        label = " Export Index CSV ";
      }
    }

    : boxed_column {
      label = " Sheet Index Fields ";
      : toggle {
        key   = "include";
        label = "Include in index / publish set";
      }
      : row {
        : edit_box {
          key        = "sheet_number";
          label      = "Number";
          edit_width = 10;
        }
        : edit_box {
          key        = "revision";
          label      = "Rev";
          edit_width = 6;
        }
      }
      : edit_box {
        key        = "sheet_title";
        label      = "Title";
        edit_width = 36;
      }
      : row {
        : edit_box {
          key        = "discipline";
          label      = "Discipline";
          edit_width = 12;
        }
        : edit_box {
          key        = "index_group";
          label      = "Group";
          edit_width = 12;
        }
      }
      : edit_box {
        key        = "issue_status";
        label      = "Status";
        edit_width = 24;
      }
      : edit_box {
        key        = "remarks";
        label      = "Remarks";
        edit_width = 36;
      }

      : spacer { height = 0.4; }
      : text { key = "cad_name";    label = "CAD sheet:";  width = 48; alignment = left; }
      : text { key = "dwg_path";    label = "DWG:";        width = 48; alignment = left; }
      : text { key = "layout_name"; label = "Layout:";     width = 48; alignment = left; }
      : text { key = "page_setup";  label = "Page setup:"; width = 48; alignment = left; }
    }
  }

  : row {
    : button {
      key        = "accept";
      label      = "  Save  ";
      is_default = true;
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
