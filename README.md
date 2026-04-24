# BR LISP Dev

Development repo for the BR AutoLISP/DCL tool suite.

This repo currently preserves the working toolset in its existing form: company-specific standards, library paths, block/detail catalogs, layer definitions, page setups, and viewport presets are still embedded in Lisp. The intended direction is to move those catalogs into a company database and make the Lisp code consume that source of truth.

## Current Toolset

Load `BR.lsp` with APPLOAD or from an AutoCAD startup loader. `BR.lsp` loads the shared core plus the tool modules and exposes the main launcher:

- `BR` - suite launcher
- `BR_NEW`, `BR_C` - new drawing workflows
- `BR_LAY` - layer tools
- `BR_INS` - block insert
- `BR_DTL` - detail insert
- `BR_AUD` - drawing audit
- `BR_VP` - viewport creation
- `BR_PS` - page setup import/apply
- `BR_SNAP`, `BR_SNAPQ`, `BR_SNAPSEL`, `BR_SNAPPRO` - drawing snapshots
- `BR_PUB` - batch publish
- `BR_DEMO`, `BR_UNDEMO` - demolition layer workflows
- `BR_DB` - project metadata JSON editor

## Repository Scope

The initial public baseline tracks the production `.lsp` and `.dcl` files at the repo root. The historical `Examples/` folder is ignored for now because it contains backups, experiments, generated files, and binary CAD assets. Specific examples can be cleaned and promoted later.

## Project Data Output

Per-project generated support files are written to the subproject `DATA` folder:

```text
J:\J\<main>\dwg\<main> <sub>\DATA\
```

Current examples are the project metadata JSON, drawing snapshot text exports, and saved `.dsd` publish definitions. `BR_PUB` reads saved `.dsd` files from this folder for sheet/page setup references, selects all DSD sheets by default, and writes a clean `BR_Publish_Run.dsd` for the active publish run using the output folder chosen in the BR dialog. If a project number cannot be detected from the drawing name, tools fall back to a `DATA` folder under the current drawing folder.

## Development Direction

Near-term work:

- Stabilize the current embedded-data implementation.
- Fix path handling and invalid filename/folder character issues.
- Make layer operations update existing layers instead of only adding missing layers.
- Improve audit coverage across model space and paper space.
- Add lightweight validation checks for catalogs, DCL files, and load order.

Long-term work:

- Move block/detail/layer/page setup/viewport catalogs out of Lisp.
- Use the company database as the source of truth.
- Keep AutoLISP focused on AutoCAD execution, UI, and command orchestration.
- Add automated generation or export of `.lsp` runtime data from validated database records where direct DB access is not practical.

## Developer Checks

Run the lightweight source validator before committing changes:

```powershell
python .\tools\validate_repo.py
```

The validator does not require AutoCAD. It checks basic Lisp balance, DCL tile references, catalog duplicates, invalid layer colors, and remaining hardcoded drive paths.
