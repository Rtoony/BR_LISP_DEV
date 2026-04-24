#!/usr/bin/env python3
"""Lightweight repository checks for the BR AutoLISP tool suite.

This intentionally avoids AutoCAD dependencies. It checks the repo source files
for issues that are easy to catch before loading the tools in AutoCAD.
"""

from __future__ import annotations

import argparse
import re
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


@dataclass
class Report:
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    info: list[str] = field(default_factory=list)

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warn(self, message: str) -> None:
        self.warnings.append(message)

    def note(self, message: str) -> None:
        self.info.append(message)


def source_files(pattern: str) -> list[Path]:
    return sorted(p for p in ROOT.glob(pattern) if p.is_file())


def strip_lisp_comments_and_strings(line: str, in_string: bool) -> tuple[str, bool]:
    result: list[str] = []
    escaped = False
    for ch in line:
        if in_string:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            result.append(" ")
            continue

        if ch == ";":
            break
        if ch == '"':
            in_string = True
            result.append(" ")
            continue
        result.append(ch)
    return "".join(result), in_string


def check_lisp_balance(report: Report) -> None:
    for path in source_files("*.lsp"):
        balance = 0
        min_balance = 0
        min_line = 0
        in_string = False

        for line_no, line in enumerate(path.read_text(encoding="latin-1").splitlines(), 1):
            cleaned, in_string = strip_lisp_comments_and_strings(line, in_string)
            for ch in cleaned:
                if ch == "(":
                    balance += 1
                elif ch == ")":
                    balance -= 1
                if balance < min_balance:
                    min_balance = balance
                    min_line = line_no

        if min_balance < 0:
            report.error(f"{path.name}: extra closing paren near line {min_line}")
        if balance != 0:
            report.error(f"{path.name}: paren balance ended at {balance}")


DCL_KEY_RE = re.compile(r'\bkey\s*=\s*"([^"]+)"')
TILE_REF_RE = re.compile(
    r'\((?:action_tile|set_tile|get_tile|mode_tile|start_list)\s+"([^"]+)"'
)


def check_dcl_keys(report: Report) -> None:
    dcl_keys: dict[str, set[str]] = {}
    all_keys = {"accept", "cancel"}

    for path in source_files("*.dcl"):
        text = path.read_text(encoding="latin-1")
        keys = set(DCL_KEY_RE.findall(text))
        dcl_keys[path.name] = keys
        all_keys.update(keys)

        duplicates = [key for key, count in Counter(DCL_KEY_RE.findall(text)).items() if count > 1]
        for key in duplicates:
            report.warn(f"{path.name}: duplicate DCL key '{key}'")

    for path in source_files("*.lsp"):
        text = path.read_text(encoding="latin-1")
        for key in sorted(set(TILE_REF_RE.findall(text))):
            if key not in all_keys:
                report.error(f"{path.name}: references DCL tile '{key}' not found in root DCL files")

    report.note(f"DCL keys indexed: {sum(len(keys) for keys in dcl_keys.values())}")


STRING_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')


def lisp_strings(expr: str) -> list[str]:
    return [s.replace(r"\\", "\\") for s in STRING_RE.findall(expr)]


def parse_list_rows(path: Path, expected_strings: int) -> list[tuple[int, list[str]]]:
    rows: list[tuple[int, list[str]]] = []
    for line_no, line in enumerate(path.read_text(encoding="latin-1").splitlines(), 1):
        stripped = line.strip()
        if not stripped.startswith("(list "):
            continue
        strings = lisp_strings(stripped)
        if len(strings) == expected_strings:
            rows.append((line_no, strings))
    return rows


ABS_PATH_RE = re.compile(r"^[A-Za-z]:\\|^\\\\")


def check_block_catalog(report: Report) -> None:
    path = ROOT / "BR_Insert.lsp"
    rows = parse_list_rows(path, 5)
    report.note(f"Block catalog rows: {len(rows)}")

    by_display_category = Counter((row[0].upper(), row[2].upper()) for _, row in rows)
    for (display, category), count in sorted(by_display_category.items()):
        if count > 1:
            report.warn(f"BR_Insert.lsp: duplicate block display/category '{category} / {display}' ({count}x)")

    exact_rows = Counter(tuple(row) for _, row in rows)
    for row, count in sorted(exact_rows.items()):
        if count > 1:
            report.warn(f"BR_Insert.lsp: exact duplicate block row '{row[2]} / {row[0]}' ({count}x)")

    absolute_sources = [(line, row[0], row[4]) for line, row in rows if ABS_PATH_RE.match(row[4])]
    if absolute_sources:
        report.warn(f"BR_Insert.lsp: {len(absolute_sources)} block rows use absolute source paths")


def check_detail_catalog(report: Report) -> None:
    path = ROOT / "BR_Details.lsp"
    rows = parse_list_rows(path, 6)
    report.note(f"Detail catalog rows: {len(rows)}")

    by_display_category = Counter((row[0].upper(), row[2].upper()) for _, row in rows)
    for (display, category), count in sorted(by_display_category.items()):
        if count > 1:
            report.warn(f"BR_Details.lsp: duplicate detail display/category '{category} / {display}' ({count}x)")

    categories = {row[2] for _, row in rows}
    if "Abbreaviations" in categories:
        report.warn("BR_Details.lsp: category 'Abbreaviations' appears misspelled")


def check_layer_catalog(report: Report) -> None:
    text = (ROOT / "BR_Layers.lsp").read_text(encoding="latin-1")
    row_re = re.compile(r'\(list\s+"([^"]+)"\s+(-?\d+)\s+"([^"]+)"\s+"')
    rows = [(name, int(color), ltype) for name, color, ltype in row_re.findall(text)]
    report.note(f"Layer catalog rows: {len(rows)}")

    layer_names = Counter(name.upper() for name, _, _ in rows)
    for name, count in sorted(layer_names.items()):
        if count > 1:
            report.warn(f"BR_Layers.lsp: duplicate layer name '{name}' ({count}x)")

    for name, color, _ in rows:
        if color < 1 or color > 255:
            report.error(f"BR_Layers.lsp: layer '{name}' has invalid ACI color {color}")


def check_hardcoded_paths(report: Report) -> None:
    path_re = re.compile(r'"([A-Za-z]:\\[^"]+)"')
    counts: Counter[str] = Counter()
    for path in source_files("*.lsp"):
        for match in path_re.findall(path.read_text(encoding="latin-1")):
            counts[match[:2].upper()] += 1
    if counts:
        report.warn(
            "Hardcoded drive paths remain: "
            + ", ".join(f"{drive}={count}" for drive, count in sorted(counts.items()))
        )


def run_checks() -> Report:
    report = Report()
    report.note(f"Repo root: {ROOT}")
    report.note(f"LSP files: {len(source_files('*.lsp'))}")
    report.note(f"DCL files: {len(source_files('*.dcl'))}")

    check_lisp_balance(report)
    check_dcl_keys(report)
    check_block_catalog(report)
    check_detail_catalog(report)
    check_layer_catalog(report)
    check_hardcoded_paths(report)

    return report


def print_report(report: Report, *, quiet: bool = False) -> None:
    if not quiet:
        for item in report.info:
            print(f"INFO: {item}")
    for item in report.warnings:
        print(f"WARN: {item}")
    for item in report.errors:
        print(f"ERROR: {item}")

    print(
        f"SUMMARY: {len(report.errors)} error(s), "
        f"{len(report.warnings)} warning(s), {len(report.info)} info item(s)"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate BR AutoLISP repo source files.")
    parser.add_argument("--quiet", action="store_true", help="hide informational output")
    args = parser.parse_args()

    report = run_checks()
    print_report(report, quiet=args.quiet)
    return 1 if report.errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
