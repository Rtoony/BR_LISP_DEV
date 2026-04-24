// ================================================================
// BR_Details.dcl  |  Brelje & Race CAD Tools  |  Detail Insert
// ================================================================

br_details : dialog {
  label = "BR : Insert Detail";

  // -- Category filter ------------------------------------------
  : boxed_row {
    label = " Filter ";
    : column {
      : text { label = "Category"; alignment = left; }
      : popup_list {
        key   = "dtl_category";
        width = 20;
      }
    }
    : spacer { width = 2; }
    : column {
      : text { label = "Search (type to filter)"; alignment = left; }
      : edit_box {
        key        = "dtl_search";
        edit_width = 30;
      }
    }
  }

  // -- Detail list ----------------------------------------------
  : boxed_column {
    label = " Available Details ";
    : list_box {
      key             = "dtl_list";
      height          = 14;
      width           = 70;
      multiple_select = false;
    }
  }

  // -- Info -----------------------------------------------------
  : boxed_column {
    label = " Detail Info ";
    : text {
      key       = "dtl_name";
      label     = "Detail :  ...";
      alignment = left;
      width     = 76;
    }
    : text {
      key       = "dtl_codes";
      label     = "Codes :  ...";
      alignment = left;
      width     = 76;
    }
    : text {
      key       = "dtl_source";
      label     = "Source :  ...";
      alignment = left;
      width     = 76;
    }
  }

  // -- Buttons --------------------------------------------------
  : row {
    : button {
      key        = "accept";
      label      = "  Insert  ";
      is_default = true;
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
