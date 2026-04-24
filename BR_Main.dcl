// ================================================================
// BR_Main.dcl  |  Brelje & Race CAD Tools  |  Suite Launcher
// ================================================================

br_main : dialog {
  label = "BR Tools";

  : text {
    label     = "Select an operation:";
    alignment = left;
  }
  : spacer { height = 0.3; }
  : list_box {
    key             = "op_list";
    height          = 14;
    width           = 56;
    multiple_select = false;
  }
  : spacer { height = 0.3; }
  : row {
    : button {
      key   = "accept";
      label = "Open";
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
