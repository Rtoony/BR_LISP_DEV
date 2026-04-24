# Roadmap

## Phase 1 - Repo Baseline

- Put the production AutoLISP/DCL files under Git.
- Keep examples, backups, binary CAD assets, and generated output out of the public baseline.
- Document load commands, module ownership, and known risks.

## Phase 2 - Current-Form Stabilization

- Centralize path helpers and make absolute vs relative source paths safe.
- Sanitize user-provided file and folder name components.
- Make layer creation idempotent: create missing layers and update existing layer standards.
- Ensure snapshot/audit output folders are created consistently.
- Improve audit scans to include model space and paper space where appropriate.

## Phase 3 - Catalog Validation

- Add a developer command or script that checks embedded catalogs for duplicate names, broken source paths, invalid layers, and missing DCL files.
- Add clear output suitable for pre-release review.

## Phase 4 - Database Transition

- Define catalog schemas for layers, blocks, details, page setups, viewport presets, project setup options, and titleblock metadata.
- Build read adapters that can use database exports while keeping AutoCAD runtime simple.
- Gradually replace hardcoded catalog lists with generated or loaded data.

## Phase 5 - New Tools

- Standards doctor: one command to scan and report drawing health.
- Project setup wizard: create DB record, drawing folder, titleblock/xref shell, layouts, page setups, and viewports.
- Library maintenance tool: validate block/detail libraries against the database.
