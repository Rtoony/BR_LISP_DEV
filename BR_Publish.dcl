// ================================================================
// BR_Publish.dcl  |  Brelje & Race CAD Tools  |  Batch Publish
// ================================================================

br_publish : dialog {
  label = "BR : Publish";

  : boxed_column {
    label = " Layouts ";

    : list_box {
      key             = "pub_layouts";
      height          = 14;
      width           = 56;
      multiple_select = true;
    }

    : row {
      : button { key = "btn_all";    label = "Select All";  width = 14; }
      : button { key = "btn_none";   label = "Select None"; width = 14; }
      : button { key = "btn_invert"; label = "Invert";      width = 14; }
    }
  }

  : boxed_column {
    label = " Output ";

    : radio_row {
      key = "fmt_group";
      : radio_button { key = "fmt_pdf"; label = "PDF"; value = "1"; }
      : radio_button { key = "fmt_dwf"; label = "DWF"; }
    }

    : toggle {
      key   = "multi_sheet";
      label = "Multi-sheet (all layouts in one file)";
    }

    : radio_row {
      key = "dest_group";
      : radio_button { key = "dest_markups"; label = "Markups Folder"; value = "1"; }
      : radio_button { key = "dest_dwgdir";  label = "Drawing Folder"; }
    }

    : row {
      : text { label = "Description:"; width = 12; }
      : edit_box {
        key   = "pub_desc";
        width = 40;
        value = "";
      }
    }

    : text { key = "pub_outdir"; label = "Output folder: "; width = 60; }
  }

  : boxed_column {
    label = " Info ";

    : text { key = "pub_count"; label = "Selected: 0 layout(s)"; }
    : text { key = "pub_proj";  label = "Project: "; }
    : text { key = "pub_method"; label = "Method: DSD Batch Publish"; }
  }

  : row {
    : button {
      key        = "accept";
      label      = "  Publish  ";
      is_default = true;
      width      = 12;
    }
    : spacer { width = 2; }
    cancel_button;
  }
}
