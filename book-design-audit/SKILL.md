---
name: book-design-audit
description: "Audit the visual design of a book PDF or EPUB: typography, page geometry, hierarchy, spacing, tables, code, figures, captions, and reflow. Use for book-layout review, Korean-book readability review, or pre-publisher visual QA. Read-only by default; it does not replace publication-readiness or manuscript editing."
allowed-tools:
  - Read
  - Write
  - Bash
  - WebSearch
  - WebFetch
  - AskUserQuestion
---

# book-design-audit

Inspect the rendered reading experience, distinguish measurable defects from design judgment, and produce a repair-oriented report.

**Created by ImDaeseong / [GitHub](https://github.com/ImDaeseong/skills)**

This open-source skill generalises a visual QA workflow for print-oriented PDFs and reflowable EPUBs.

**Licence:** MIT. See `LICENSE`; use, modify, and redistribute with the copyright notice.

**Feedback & Support:** Report methodology issues through the repository issue tracker. If the agent skipped a check, acknowledge and rerun it rather than treating that as a methodology defect.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Boundary

- Use this skill to inspect visual design and reading flow, not to decide rights, pricing, channel metadata, or final commercial approval.
- Route final release readiness to `publication-readiness`; route substantial manuscript rewriting to `book-author` or the user's writing workflow.
- Default to read-only inspection. Edit source or rebuild artifacts only when the user separately authorises fixes.
- Never treat a successful text extraction, build, or validator as proof of visual quality.

## Inputs and evidence

Identify the exact candidate file, intended medium, trim/page size, reading device or print channel, audience, and source files if available. If one is unknown, record it as an assumption or HOLD instead of inventing it.

For PDF, inspect document metadata and font embedding, then render every page to images. For EPUB, inspect package/navigation/accessibility metadata and render representative states in an actual EPUB reader when available: default, enlarged text, and narrow viewport. Browser HTML alone is not proof of reader behavior.

Read [references/audit-checklist.md](references/audit-checklist.md) for the applicable format. Read [references/evidence-basis.md](references/evidence-basis.md) only when assigning a standards- or research-based rationale.

## Audit method

1. Establish a machine inventory: page count, dimensions, fonts, images, navigation, headings, links, and current validator results.
2. Render the full artifact. Use contact sheets only for scanning; reopen every suspected page at readable resolution before reporting a defect.
3. Review representative page classes: cover, copyright/front matter, contents, part opener, chapter opener, ordinary prose, dense list, table, code block, figure, references, and final page.
4. Sweep all pages for clipping, overlap, blank or near-blank pages, inconsistent margins, isolated headings, widows/orphans, broken glyphs, low-resolution images, detached captions, and abrupt density changes.
5. For EPUB, repeat the high-risk page classes with font enlargement and narrow reflow. Fixed PDF measurements do not become EPUB requirements.
6. Classify every finding and keep the raw observation separate from the judgment.

## Finding classes

- **DEFECT:** observable failure such as clipped text, overlap, missing glyphs, unreadable contrast, broken navigation, detached caption, or unusable reflow.
- **READABILITY RISK:** evidence-supported concern requiring contextual judgment, such as very long lines, cramped leading, weak hierarchy, or excessive density.
- **DESIGN RECOMMENDATION:** aesthetic improvement with no claim that the current version is incorrect.
- **PUBLISHER DECISION:** trim, house style, cover direction, production specification, or other choice requiring the publisher or human owner.
- **NOT VERIFIED:** relevant check could not be performed in the available reader, device, print proof, or assistive environment.

Do not convert a research average into a universal threshold. Screen studies, Latin-script studies, accessibility customization criteria, and print typography are different evidence scopes. Korean/CJK work requires rendered inspection and, where consequential, a human reader or publisher review.

## Report contract

Write `BOOK_DESIGN_AUDIT.md` beside the project unless the user names another location. Include:

- candidate identity and hash;
- tools/readers and observation date;
- page-class coverage and untested environments;
- a compact finding table with severity, class, page/location, evidence, proposed repair, and verification method;
- strengths worth preserving;
- publisher decisions separated from author-fixable items;
- final verdict: `VISUAL QA PASS`, `FIXES REQUIRED`, or `VISUAL QA HOLD`.

When fixes are authorised, preserve the original, modify the canonical source rather than patching the generated PDF where practical, rebuild, rerender affected pages plus adjacent pages, and rerun artifact validators. Stop when agreed defects pass; do not polish indefinitely.

When the visual-audit report is bound to the artifact hash, use an explicit
two-pass rebuild after source edits: build a candidate, treat the expected stale
hash as an evidence checkpoint rather than a layout defect, render and inspect
the candidate, update the report identity, verify the evidence gate directly,
then rerun the deterministic full build and confirm the artifact is identical.

## Pre-delivery verification

Before reporting completion, re-read this skill and confirm:

- the exact candidate and its hash are recorded;
- every page was included in the sweep, not only a sample;
- suspected pages were inspected individually at readable resolution;
- PDF, EPUB, and print claims were not conflated;
- findings use the five classes above and cite observable locations;
- evidence-based claims match the scope and limitations in `evidence-basis.md`;
- publisher decisions and unavailable human/device checks remain HOLD rather than simulated PASS;
- after any fix, the latest rebuilt artifact was rerendered and revalidated.

If the method produces a wrong decision, retain the failing example and a counterexample, make the smallest correction, and rerun this checklist. Never describe the method as perfect.
