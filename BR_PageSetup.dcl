// ================================================================
// BR_PageSetup.dcl  |  Brelje & Race CAD Tools  |  Page Setup
// ================================================================

br_pagesetup : dialog {
  label = "BR : Page Setup Manager";

  // -- Library selector -------------------------------------------
  : boxed_column {
    label = " Page Setup Library ";
    : radio_row {
      key = "lib_group";
      : radio_button { key = "rb_dwg2pdf";  label = "DWG to PDF"; value = "1"; }
      : radio_button { key = "rb_bluebeam"; label = "Bluebeam"; }
    }
  }

  // -- Page setup list --------------------------------------------
  : boxed_column {
    label = " Available Page Setups ";
    : list_box {
      key             = "ps_list";
      height          = 14;
      width           = 56;
      multiple_select = false;
    }
  }

  // -- Scope selector ---------------------------------------------
  : boxed_column {
    label = " Apply To ";
    : radio_row {
      key = "scope_group";
      : radio_button { key = "rb_current"; label = "Current Layout"; value = "1"; }
      : radio_button { key = "rb_all";     label = "All Layouts"; }
    }
  }

  // -- Info text --------------------------------------------------
  : boxed_column {
    label = " Info ";
    : text {
      key       = "info_setup";
      label     = "Select a page setup above.";
      alignment = left;
      width     = 66;
    }
    : text {
      key       = "info_source";
      label     = "";
      alignment = left;
      width     = 66;
    }
  }

  // -- Buttons ----------------------------------------------------
  : row {
    : button {
      key        = "accept";
      label      = "  Import && Apply  ";
      is_default = true;
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
