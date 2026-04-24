// ================================================================
// BR_Layers.dcl  |  Brelje & Race CAD Tools  |  Layer Tools
// ================================================================

br_layers : dialog {
  label = "BR : Layer Tools";

  // -- Mode selector ---------------------------------------------
  : boxed_column {
    label = " Action ";
    : radio_column {
      key = "layer_mode";
      : radio_button { key = "mode_apply";  label = "Apply standard layer set to current drawing"; }
      : radio_button { key = "mode_audit";  label = "Audit layers against BR standards"; }
      : radio_button { key = "mode_freeze"; label = "Freeze layers by category"; }
      : radio_button { key = "mode_thaw";   label = "Thaw layers by category"; }
    }
  }

  // -- Category / discipline filter ------------------------------
  : boxed_column {
    label = " Layer Category ";
    : list_box {
      key             = "layer_cat_list";
      height          = 10;
      width           = 56;
      multiple_select = false;
    }
  }

  // -- Status / preview ------------------------------------------
  : boxed_column {
    label = " Info ";
    : text {
      key       = "layer_status";
      label     = "Select a mode and category above.";
      alignment = left;
      width     = 66;
    }
    : text {
      key       = "layer_count";
      label     = "";
      alignment = left;
      width     = 66;
    }
  }

  // -- Buttons ---------------------------------------------------
  : row {
    : button {
      key        = "accept";
      label      = "  Run  ";
      is_default = true;
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
