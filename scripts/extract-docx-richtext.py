#!/usr/bin/env python3
"""Extract reusable rich-text structure from a DOCX source file.

The script is intentionally conservative: it reads WordprocessingML directly,
keeps paragraph/table order, preserves run-level formatting that matters for
classroom PPT production, and emits JSON that later builders can transform into
slides.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
from pathlib import Path
from typing import Any, Iterable
from xml.etree import ElementTree as ET

NS = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
W = "{%s}" % NS["w"]


def qn(name: str) -> str:
    return W + name


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def normalize_text(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def attr_value(element: ET.Element | None, name: str = "val") -> str | None:
    if element is None:
        return None
    return element.get(qn(name))


def truthy_toggle(element: ET.Element | None) -> bool:
    if element is None:
        return False
    value = attr_value(element)
    return value not in {"0", "false", "False", "off"}


def run_text(run: ET.Element) -> str:
    parts: list[str] = []
    for node in run:
        name = local_name(node.tag)
        if name == "t":
            parts.append(node.text or "")
        elif name == "tab":
            parts.append("\t")
        elif name in {"br", "cr"}:
            parts.append("\n")
    return "".join(parts)


def is_red_hex(color: str | None) -> bool:
    if not color:
        return False
    value = color.strip().lstrip("#").upper()
    if len(value) != 6 or not re.fullmatch(r"[0-9A-F]{6}", value):
        return False
    red = int(value[0:2], 16)
    green = int(value[2:4], 16)
    blue = int(value[4:6], 16)
    return red >= 200 and green <= 80 and blue <= 80


def run_payload(run: ET.Element) -> dict[str, Any] | None:
    text = run_text(run)
    if text == "":
        return None

    props = run.find("w:rPr", NS)
    color = attr_value(props.find("w:color", NS) if props is not None else None)
    highlight = attr_value(props.find("w:highlight", NS) if props is not None else None)
    underline = attr_value(props.find("w:u", NS) if props is not None else None)

    payload: dict[str, Any] = {
        "text": text,
        "bold": truthy_toggle(props.find("w:b", NS) if props is not None else None),
        "italic": truthy_toggle(props.find("w:i", NS) if props is not None else None),
        "underline": underline not in {None, "none", "0", "false"},
        "color": color,
        "highlight": highlight,
        "is_red": is_red_hex(color),
    }
    return payload


def paragraph_payload(paragraph: ET.Element, index: int, origin: str) -> dict[str, Any] | None:
    runs = [payload for run in paragraph.findall("w:r", NS) if (payload := run_payload(run))]
    text = "".join(run["text"] for run in runs)
    normalized = normalize_text(text)
    if not normalized:
        return None
    return {
        "index": index,
        "origin": origin,
        "text": text,
        "normalized": normalized,
        "has_red": any(run["is_red"] for run in runs),
        "runs": runs,
    }


def table_payload(table: ET.Element, table_index: int, next_index: int) -> tuple[dict[str, Any], list[dict[str, Any]], int]:
    table_rows: list[list[list[dict[str, Any]]]] = []
    flattened: list[dict[str, Any]] = []
    unit_index = next_index

    for row in table.findall("w:tr", NS):
        row_payload: list[list[dict[str, Any]]] = []
        for cell in row.findall("w:tc", NS):
            cell_payload: list[dict[str, Any]] = []
            for paragraph in cell.findall("w:p", NS):
                payload = paragraph_payload(paragraph, unit_index, f"table:{table_index}")
                if payload is None:
                    continue
                unit_index += 1
                cell_payload.append(payload)
                flattened.append(payload)
            row_payload.append(cell_payload)
        table_rows.append(row_payload)

    return {"index": table_index, "rows": table_rows}, flattened, unit_index


def load_document(docx_path: Path) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    with zipfile.ZipFile(docx_path) as archive:
        xml = archive.read("word/document.xml")

    root = ET.fromstring(xml)
    body = root.find("w:body", NS)
    if body is None:
        raise ValueError("word/document.xml has no body")

    units: list[dict[str, Any]] = []
    tables: list[dict[str, Any]] = []
    unit_index = 0
    table_index = 0

    for child in body:
        name = local_name(child.tag)
        if name == "p":
            payload = paragraph_payload(child, unit_index, "body")
            if payload is not None:
                units.append(payload)
                unit_index += 1
        elif name == "tbl":
            table, flattened, unit_index = table_payload(child, table_index, unit_index)
            tables.append(table)
            units.extend(flattened)
            table_index += 1

    return units, tables


def find_marker(units: list[dict[str, Any]], marker: str | None, start_at: int = 0) -> int | None:
    if not marker:
        return None
    needle = normalize_text(marker)
    for index in range(start_at, len(units)):
        if needle in units[index]["normalized"]:
            return index
    return None


def slice_units(
    units: list[dict[str, Any]],
    start: str | None,
    end: str | None,
    include_start: bool,
    include_end: bool,
) -> tuple[list[dict[str, Any]], dict[str, int | None]]:
    start_index = find_marker(units, start, 0)
    window_start = 0 if start_index is None else start_index + (0 if include_start else 1)

    end_index = find_marker(units, end, window_start)
    window_end = len(units) if end_index is None else end_index + (1 if include_end else 0)

    return units[window_start:window_end], {"start_index": start_index, "end_index": end_index}


def summarize(units: Iterable[dict[str, Any]]) -> dict[str, Any]:
    selected = list(units)
    return {
        "unit_count": len(selected),
        "red_unit_count": sum(1 for unit in selected if unit["has_red"]),
        "source_text_lines": [unit["normalized"] for unit in selected],
        "source_red_lines": [unit["normalized"] for unit in selected if unit["has_red"]],
    }


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract DOCX rich text, table text, source lines, and red-answer lines for English courseware PPT builders."
    )
    parser.add_argument("--docx", required=True, type=Path, help="Input DOCX file.")
    parser.add_argument("--out", type=Path, help="Output JSON path. Defaults to stdout.")
    parser.add_argument("--title", help="Optional logical title to store in the JSON.")
    parser.add_argument("--start", help="Start marker. Matching paragraph is excluded unless --include-start is set.")
    parser.add_argument("--end", help="End marker. Matching paragraph is excluded unless --include-end is set.")
    parser.add_argument("--include-start", action="store_true", help="Include the paragraph containing --start.")
    parser.add_argument("--include-end", action="store_true", help="Include the paragraph containing --end.")
    parser.add_argument("--pretty", action="store_true", help="Pretty-print JSON.")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    units, tables = load_document(args.docx)
    selected, markers = slice_units(units, args.start, args.end, args.include_start, args.include_end)
    summary = summarize(selected)

    payload = {
        "source_docx": str(args.docx.resolve()),
        "title": args.title,
        "markers": markers,
        "units": selected,
        "tables": tables,
        **summary,
    }

    text = json.dumps(payload, ensure_ascii=False, indent=2 if args.pretty else None)
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(text + "\n", encoding="utf-8")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
