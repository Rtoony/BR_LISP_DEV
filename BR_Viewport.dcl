// ================================================================
// BR_Viewport.dcl  |  Brelje & Race CAD Tools  |  Viewport Creation
// ================================================================

br_viewport : dialog {
  label = "BR : Create Viewport";

  // -- Title Block Selection --------------------------------------
  : boxed_column {
    label = " Title Block Configuration ";
    : list_box {
      key             = "vp_list";
      height          = 12;
      width           = 56;
      multiple_select = false;
    }
  }

  // -- Scale Selection --------------------------------------------
  : boxed_column {
    label = " Viewport Scale ";
    : row {
      : column {
        : radio_button { key = "sc_10";  label = "1\" = 10'";  }
        : radio_button { key = "sc_20";  label = "1\" = 20'";  }
        : radio_button { key = "sc_40";  label = "1\" = 40'";  }
      }
      : column {
        : radio_button { key = "sc_50";     label = "1\" = 50'";  }
        : radio_button { key = "sc_custom"; label = "Custom";     }
        : edit_box {
          key        = "sc_custom_val";
          label      = "1\" =";
          edit_width = 8;
          is_enabled = false;
        }
      }
    }
  }

  // -- Scope Selection --------------------------------------------
  : boxed_row {
    label = " Apply To ";
    : radio_button { key = "scope_all";     label = "All Layouts";          }
    : radio_button { key = "scope_current"; label = "Current Layout Only";  }
  }

  // -- Preview ----------------------------------------------------
  : boxed_column {
    label = " Preview ";
    : text {
      key       = "vp_preview";
      label     = "Select a title block configuration...";
      alignment = left;
      width     = 66;
    }
  }

  // -- Buttons ----------------------------------------------------
  : row {
    : button {
      key        = "accept";
      label      = "  Create Viewport  ";
      is_default = true;
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
