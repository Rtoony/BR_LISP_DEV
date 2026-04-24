// ================================================================
// BR_Audit.dcl  |  Brelje & Race CAD Tools  |  Drawing Audit
// ================================================================

br_audit : dialog {
  label = "BR : Drawing Audit";

  // -- Audit options ---------------------------------------------
  : boxed_column {
    label = " Scan Options ";
    : toggle { key = "chk_layers";  label = "Layer compliance (vs BR standards)"; }
    : toggle { key = "chk_blocks";  label = "Block inventory (list all inserts)"; }
    : toggle { key = "chk_xrefs";   label = "Xref status (attached, paths, loaded)"; }
    : toggle { key = "chk_zero";    label = "Zero-length / empty entities"; }
    : toggle { key = "chk_naming";  label = "File naming compliance"; }
  }

  : spacer { height = 0.5; }

  // -- Output ----------------------------------------------------
  : boxed_column {
    label = " Results ";
    : list_box {
      key             = "audit_results";
      height          = 15;
      width           = 66;
      multiple_select = false;
    }
  }

  // -- Summary ---------------------------------------------------
  : boxed_column {
    label = " Summary ";
    : text {
      key       = "audit_summary";
      label     = "Select options and click Run to scan.";
      alignment = left;
      width     = 66;
    }
  }

  // -- Buttons ---------------------------------------------------
  : row {
    : button {
      key   = "btn_run";
      label = "  Run Audit  ";
    }
    : spacer { width = 1; }
    : button {
      key   = "btn_export";
      label = "  Export  ";
    }
    : spacer { width = 1; }
    : button {
      key   = "accept";
      label = "  Close  ";
      is_default = true;
    }
  }
}
