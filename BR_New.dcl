// ================================================================
// BR_New.dcl  |  Brelje & Race CAD Tools  |  New Drawing Dialog
// ================================================================

br_new : dialog {
  label = "BR : New Drawing";

  // -- Row 1: Project number + Phase --------------------------------
  : boxed_row {
    label = " Project ";
    : column {
      : text { label = "Project Number  (####.##)"; alignment = left; }
      : edit_box {
        key         = "proj_num";
        edit_width  = 12;
        fixed_width = true;
      }
    }
    : spacer { width = 2; }
    : column {
      : text { label = "Phase  (optional -- DD  CD  BID  CONST...)"; alignment = left; }
      : edit_box {
        key         = "phase";
        edit_width  = 10;
        fixed_width = true;
      }
    }
  }

  // -- File type list -------------------------------------------------
  : boxed_column {
    label = " File Type ";
    : list_box {
      key             = "file_type_list";
      height          = 15;
      width           = 56;
      multiple_select = false;
    }
  }

  // -- Description ---------------------------------------------------
  : boxed_row {
    label = " Description ";
    : text {
      key       = "desc_status";
      label     = "Optional ";
      width     = 10;
      alignment = left;
    }
    : edit_box {
      key        = "description";
      edit_width = 40;
    }
  }

  // -- Live path preview ---------------------------------------------
  : boxed_column {
    label = " Preview ";
    : text {
      key       = "preview_folder";
      label     = "Folder :  ...";
      alignment = left;
      width     = 66;
    }
    : text {
      key       = "preview_file";
      label     = "File   :  ...";
      alignment = left;
      width     = 66;
    }
  }

  // -- Buttons -------------------------------------------------------
  : row {
    : button {
      key        = "accept";
      label      = "  Create Drawing  ";
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
