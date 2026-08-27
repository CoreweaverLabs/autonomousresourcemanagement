# Autonomous Resource Management (ARM) — autonomousresourcemanagement.com

Static Hostinger-compatible HTML and machine-readable definition for **Autonomous Resource Management (ARM)** at [autonomousresourcemanagement.com](https://autonomousresourcemanagement.com).

This repo is content and structured data, not an application. There is no build step and no test suite.

## Contents

| File | Purpose |
|---|---|
| `index.html` | The definitional page for "Autonomous Resource Management" — includes inline JSON-LD (`WebPage`, `DefinedTerm`) for LLM/search citation. |
| `coreweaver-labs/index.html` | Unpublished, noindex research archive; do not publish its performance claims without evidence. |
| `schema.json` | Standalone schema.org graph for this reference, its term, and its author. |
| `llms.txt` | Machine-readable summary and bounded routes to distinct implementation providers. |
| `sitemap.xml` | Standard XML sitemap. |
| `CNAME` | GitHub Pages custom domain pointer — `autonomousresourcemanagement.com`. |

## Purpose

This site is the non-commercial reference layer for the term "Autonomous Resource Management." It supports revenue properties through clearly labeled application paths without conflating their identities or placing checkout on the reference domain.

## Closed-loop publication
Every change to the public reference set is described in `publication-manifest.json`. The release gate in `scripts/validate_publication.py` checks that listed pages exist, expose titles, descriptions, canonical URLs, structured data, and appropriate evidence boundaries, while excluded archives remain noindex and absent from discovery files. The GitHub Actions workflow in `.github/workflows/publish.yml` runs this gate on pull requests and publishes the static site automatically after every successful push to `main`.

The loop is intentionally conservative: new material can be drafted and committed without publication if it fails the gate; operational surfaces and research archives remain excluded until their evidence state is changed explicitly in the manifest and supporting metadata is added. This means routine content changes do not require a separate manual review, while unsupported or high-risk claims still stop the release.

## Maintaining this repo

- Keep `schema.json`, `llms.txt`, and the inline JSON-LD in `index.html` in sync — entity name, leadership, and `sameAs` links should match across all three.
- Any factual/statistical claim on any page (e.g. deployment counts, dataset sizes) must be sourced or removed before publishing — unsubstantiated metrics undermine the citation-authority goal this site exists to build.
- Deploy automatically through the repository workflow after enabling GitHub Pages for this repository. If the custom domain continues to be served from Hostinger instead, use the same gate before syncing the static files to Hostinger's document root. No Node runtime, framework, database, or rewrite rules are required.
