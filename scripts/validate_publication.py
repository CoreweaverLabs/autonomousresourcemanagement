#!/usr/bin/env python3
"""Validate the public publication set before release."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "publication-manifest.json"


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def main() -> int:
    errors: list[str] = []
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"FAIL: cannot parse publication-manifest.json: {exc}")
        return 1

    base_url = manifest["baseUrl"].rstrip("/")
    listed_paths = {item["path"] for item in manifest["publications"]}

    for item in manifest["publications"]:
        path = item["path"]
        relative = path.strip("/")
        html = ROOT / relative / "index.html" if relative else ROOT / "index.html"
        if not html.exists():
            fail(f"{path}: missing {html.relative_to(ROOT)}", errors)
            continue
        text = html.read_text(encoding="utf-8")
        if not re.search(r"<title>[^<]+</title>", text, re.I):
            fail(f"{path}: missing title", errors)
        if not re.search(r'<meta[^>]+name=[\"\']description[\"\'][^>]+content=', text, re.I):
            fail(f"{path}: missing meta description", errors)
        expected_canonical = item.get("canonical", base_url + (path if path != "/" else "/"))
        canonical_match = re.search(r'<link[^>]+rel=[\"\']canonical[\"\'][^>]+href=[\"\']([^\"\']+)', text, re.I)
        if not canonical_match:
            fail(f"{path}: missing canonical URL", errors)
        elif canonical_match.group(1).rstrip("/") != expected_canonical.rstrip("/"):
            fail(f"{path}: canonical URL is {canonical_match.group(1)!r}, expected {expected_canonical!r}", errors)
        if not ("application/ld+json" in text or "schema.json" in text):
            fail(f"{path}: missing JSON-LD or schema reference", errors)

    for item in manifest["excluded"]:
        relative = item["path"].strip("/")
        html = ROOT / relative / "index.html"
        if html.exists():
            text = html.read_text(encoding="utf-8")
            if not re.search(r'<meta[^>]+name=[\"\']robots[\"\'][^>]+content=[\"\'][^\"\']*noindex', text, re.I):
                fail(f"{item['path']}: excluded page must remain noindex", errors)
        if item["path"] in listed_paths:
            fail(f"{item['path']}: cannot be both public and excluded", errors)

    sitemap = (ROOT / "sitemap.xml").read_text(encoding="utf-8")
    llms = (ROOT / "llms.txt").read_text(encoding="utf-8")
    for item in manifest["excluded"]:
        if item["path"].strip("/") in sitemap or item["path"].strip("/") in llms:
            fail(f"{item['path']}: excluded archive appears in discovery files", errors)

    if errors:
        print("PUBLICATION GATE: FAIL")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"PUBLICATION GATE: PASS ({len(manifest['publications'])} public pages, {len(manifest['excluded'])} excluded archives)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
