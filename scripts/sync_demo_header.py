#!/usr/bin/env python
"""Sync partials/demo-header.html into demo pages between marker comments."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PARTIAL = ROOT / "partials" / "demo-header.html"
MARKER_START = "<!-- demo-header:start -->"
MARKER_END = "<!-- demo-header:end -->"
TARGET_PAGES = [
    "index.html",
    "text-box.html",
    "login.html",
    "automation-practice-form.html",
    "sandbox.html",
]
HEADER_RE = re.compile(r"<header class=\"header\"[\s\S]*?</header>", re.MULTILINE)
BLOCK_RE = re.compile(
    re.escape(MARKER_START) + r"[\s\S]*?" + re.escape(MARKER_END),
    re.MULTILINE,
)


def build_block(partial: str) -> str:
    body = partial.strip()
    return f"{MARKER_START}\n{body}\n{MARKER_END}"


def sync_page(path: Path, block: str) -> bool:
    text = path.read_text(encoding="utf-8")
    if MARKER_START in text:
        updated, count = BLOCK_RE.subn(block, text, count=1)
        if count != 1:
            raise RuntimeError(f"{path.name}: expected one marker block, found {count}")
    else:
        updated, count = HEADER_RE.subn(block, text, count=1)
        if count != 1:
            raise RuntimeError(f"{path.name}: header block not found")
    if updated == text:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def main() -> int:
    if not PARTIAL.is_file():
        print(f"Missing partial: {PARTIAL}", file=sys.stderr)
        return 1

    partial = PARTIAL.read_text(encoding="utf-8")
    block = build_block(partial)
    changed = 0

    for name in TARGET_PAGES:
        path = ROOT / name
        if not path.is_file():
            print(f"Skip missing page: {name}", file=sys.stderr)
            continue
        if sync_page(path, block):
            print(f"Updated {name}")
            changed += 1
        else:
            print(f"Unchanged {name}")

    print(f"Done ({changed} updated).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
