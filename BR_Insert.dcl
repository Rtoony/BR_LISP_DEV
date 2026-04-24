// ================================================================
// BR_Insert.dcl  |  Brelje & Race CAD Tools  |  Block/Detail Insert
// ================================================================

br_insert : dialog {
  label = "BR : Insert Block / Detail";

  // -- Category filter -------------------------------------------
  : boxed_row {
    label = " Filter ";
    : column {
      : text { label = "Category"; alignment = left; }
      : popup_list {
        key   = "blk_category";
        width = 20;
      }
    }
    : spacer { width = 2; }
    : column {
      : text { label = "Search (type to filter)"; alignment = left; }
      : edit_box {
        key        = "blk_search";
        edit_width = 30;
      }
    }
  }

  // -- Block list ------------------------------------------------
  : boxed_column {
    label = " Available Blocks ";
    : list_box {
      key             = "blk_list";
      height          = 14;
      width           = 56;
      multiple_select = false;
    }
  }

  // -- Info -------------------------------------------------------
  : boxed_column {
    label = " Details ";
    : text {
      key       = "blk_name";
      label     = "Block :  ...";
      alignment = left;
      width     = 66;
    }
    : text {
      key       = "blk_layer";
      label     = "Layer :  ...";
      alignment = left;
      width     = 66;
    }
    : text {
      key       = "blk_source";
      label     = "Source :  ...";
      alignment = left;
      width     = 66;
    }
  }

  // -- Buttons ---------------------------------------------------
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
