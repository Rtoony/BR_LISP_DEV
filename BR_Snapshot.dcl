// ================================================================
// BR_Snapshot.dcl  |  Brelje & Race CAD Tools  |  Drawing Snapshot
// ================================================================

br_snapshot : dialog {
  label = "BR : Drawing Snapshot";

  // -- Mode selector ---------------------------------------------
  : boxed_column {
    label = " Snapshot Type ";
    : radio_column {
      key = "snap_mode";
      : radio_button { key = "mode_full";  label = "Full Snapshot  (layers, entities, blocks, text, xrefs, styles)"; }
      : radio_button { key = "mode_quick"; label = "Quick Snapshot  (layers + entity counts only -- fastest)"; }
      : radio_button { key = "mode_sel";   label = "Selection Snapshot  (select entities, then export detail)"; }
      : radio_button { key = "mode_pro";   label = "Pro Snapshot  (full + geometry metrics, text bounds, viewports, dims)"; }
    }
  }

  // -- Description ----------------------------------------------
  : boxed_column {
    label = " Info ";
    : text {
      key       = "snap_desc";
      label     = "Select a snapshot type above.";
      alignment = left;
      width     = 66;
    }
    : text {
      key       = "snap_output";
      label     = "Output: project DATA folder";
      alignment = left;
      width     = 66;
    }
  }

  // -- Buttons ---------------------------------------------------
  : row {
    : button {
      key        = "accept";
      label      = "  Run Snapshot  ";
      is_default = true;
    }
    : spacer { width = 1; }
    cancel_button;
  }
}
