---
name: design-report
description: "Give a visual/UI artifact a deliberate design direction, and/or turn structured findings (e.g. a biz-council design document) into a formatted report file (DOCX/PPTX/XLSX/PDF). MANDATORY TRIGGERS: 'design this', 'make it look good', 'turn this into a report', 'make a deck', 'export as PDF/PPTX/DOCX'."
allowed-tools:
  - Read
  - Write
  - WebSearch
  - Bash
---

# design-report

## Core Laws

Follows `../_shared/CORE-LAWS.md` in full — LAW 0 (no speculation, use the canonical tags), LAW 1 (evidence-ranked library selection), LAW 2 (code architecture if implemented).

## Attribution (LAW 1 evidence, checked via GitHub/GitHub page on the date below)

| Candidate | Stars (checked 2026-07-17) | License (verified against the repo directly, not a secondary source) | Role here |
|---|---|---|---|
| `anthropics/skills` — `frontend-design` skill | 162k (checked 2026-07-17) | Mixed repository license status: README says many skills are Apache 2.0; document skills are explicitly source-available, not open source. Treat this referenced skill as read/consult only unless its specific subfolder license is verified before reuse. | **Design direction, primary reference only.** Official Anthropic skill; forces a deliberate visual direction (typography, layout, color, motion) before writing any markup, and bans generic defaults (Inter, Roboto, Arial, Space Grotesk as unexamined choices). Read for approach; do not copy its prompt text verbatim into anything redistributed. |
| `anthropics/skills` — `docx`/`pdf`/`pptx`/`xlsx` skills | 162k (same repo, checked 2026-07-17) | Source-available, not open source per upstream README; keep `[LICENSE-UNCONFIRMED]` for redistribution/adaptation. | Report file generation reference (DOCX/PPTX/XLSX/PDF from structured content). Reference only. |
| `tfriedel/claude-office-skills` | 787 | `[LICENSE-UNCONFIRMED]` — no LICENSE file (verified) | Fallback/secondary reference for DOCX/PPTX/XLSX/PDF generation. |
| `claude-office-skills/skills` (`report-generator`) | 305 (checked 2026-07-17) | MIT at repository level; individual skill folders may differ per upstream README. | Weaker star signal than the two above; keep as a tertiary reference only. |

**Do not vendor these references into this workspace.** The Anthropic document skills are source-available rather than open source; community Office skills may have repo-level MIT terms but still require folder-level checks before copying. Do not copy prompt/instruction text into `design-report`'s own output verbatim — describe the approach in this skill's own words. The actual docx/pptx/xlsx/pdf generation should call each host's own available tooling (e.g. an installed Office-document MCP server, or the referenced skill installed separately by the user) rather than this skill re-implementing or embedding their document-generation code.

## Step 1: Design direction (when the request involves a visual artifact)

Before writing any HTML/CSS/component code for a deck, landing page, or prototype:

1. Commit to a specific typography pairing, color direction, and layout approach — state the choice and the one-line reason, not a menu of options.
2. Do not default to Inter/Roboto/Arial/Space Grotesk without a stated reason; per the `frontend-design` skill's own rule, these read as "unexamined AI defaults."
3. If the input is a `biz-council` design document, pull its "What Gets Built" section as the content skeleton — do not invent features not in that document.

## Step 2: Report generation (when the request is to format findings into a document)

1. Identify target format (DOCX/PPTX/XLSX/PDF) from the request.
2. Check what's actually available in this session/host (an installed Office MCP tool, a Python environment with the relevant library, or the user has one of the Attribution-table skills installed separately) — do not assume a tool exists; verify with a tool call (e.g., check for an MCP resource, or `command -v` for a CLI dependency) before promising output in that format.
3. If nothing is available, say so and ask whether to install one of the Attribution-table options (respecting the license notes above) or produce a plain Markdown report instead.
4. Structure the report content around whatever it's summarizing (e.g. a `biz-council` document's six sections) — do not add sections the source material doesn't support.

## What this skill does not do

Does not run research (that's `biz-council`), does not fabricate a design or report when the underlying content/tooling isn't there — say so per LAW 0 instead of producing a plausible-looking placeholder.
