#!/usr/bin/env python
"""Verify landing page assets match reference/index.* contracts."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "reference"
CSS_FILE = ROOT / "allure-shell.css"
HTML_FILE = ROOT / "index.html"
TOKEN_FILE = REFERENCE / "index.css-tokens.json"
STRUCTURE_FILE = REFERENCE / "index.structure.json"


def load_json(path: Path) -> dict | list:
    return json.loads(path.read_text(encoding="utf-8"))


def parse_root_tokens(css: str) -> dict[str, str]:
    match = re.search(r":root\s*\{([^}]+)\}", css, re.S)
    if not match:
        raise RuntimeError(":root block not found in allure-shell.css")
    return {
        name: value.strip()
        for name, value in re.findall(r"(--[\w-]+)\s*:\s*([^;]+);", match.group(1))
    }


def check_css_tokens() -> list[str]:
    errors: list[str] = []
    expected = load_json(TOKEN_FILE)
    actual = parse_root_tokens(CSS_FILE.read_text(encoding="utf-8"))

    for name, value in expected.items():
        if name not in actual:
            errors.append(f"Missing CSS token in allure-shell.css: {name}")
        elif actual[name] != value:
            errors.append(
                f"CSS token drift {name}: expected {value!r}, got {actual[name]!r}"
            )

    return errors


def check_structure() -> list[str]:
    errors: list[str] = []
    structure = load_json(STRUCTURE_FILE)
    html = HTML_FILE.read_text(encoding="utf-8")

    for test_id in structure["requiredTestIds"]:
        needle = f'data-testid="{test_id}"'
        if needle not in html:
            errors.append(f"Missing data-testid in index.html: {test_id}")

    for selector in structure["requiredSelectors"]:
        if selector.startswith("#"):
            if f'id="{selector[1:]}"' not in html:
                errors.append(f"Missing selector in index.html: {selector}")
        elif selector.startswith("."):
            class_name = selector[1:]
            if not re.search(rf'\bclass="[^"]*\b{re.escape(class_name)}\b', html):
                errors.append(f"Missing selector in index.html: {selector}")
        else:
            errors.append(f"Unsupported selector in reference: {selector}")

    if "<!-- demo-header:start -->" not in html or "<!-- demo-header:end -->" not in html:
        errors.append("index.html is missing demo-header marker comments")

    return errors


def main() -> int:
    missing = [path for path in (TOKEN_FILE, STRUCTURE_FILE, CSS_FILE, HTML_FILE) if not path.is_file()]
    if missing:
        for path in missing:
            print(f"Missing required file: {path}", file=sys.stderr)
        return 1

    errors = check_css_tokens() + check_structure()
    if errors:
        print("Landing reference check failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print("Landing reference check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
