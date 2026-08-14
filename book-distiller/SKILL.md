---
name: book-distiller
description: "Turn a book/document (PDF, EPUB, DOCX, HTML, Markdown, text, RTF, MOBI/AZW) into a structured, on-demand agent skill — core mental models + per-chapter files loaded only when queried + glossary + patterns + decision tables — instead of dumping the whole book into context. MANDATORY TRIGGERS: 'turn this book into a skill', 'this PDF into a skill', 'make a skill from this document', 'distill this book for Claude', 'book to skill', '이 책을 스킬로 만들어줘', 'PDF를 스킬로'. Do not trigger for writing a standalone prompt (route to prompt-craft) or designing an agent worker (route to agent-builder) — this is specifically source-document → reusable knowledge skill."
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# book-distiller

Dumping a whole book into context is expensive and the model still can't find the one framework it needs. This skill wraps a real, actively-maintained tool that converts a source document into a structured skill once, then loads only the chapters a later query actually touches — precise extraction over completeness.

## Attribution

This skill does not reimplement extraction — it resolves and routes into a real, actively-maintained tool as a **runtime dependency**, cloned on demand exactly like `distribution` does for `marketingskills` and `curator` does for `last30days`. Never vendored into this repo, never copied verbatim.

- **book-to-skill** — [github.com/virgiliojr94/book-to-skill](https://github.com/virgiliojr94/book-to-skill) (checked 2026-08-14 via GitHub API), **MIT license** (verified by reading the repo's actual `LICENSE.md` directly — GitHub's detector reports `NOASSERTION` because a Tencent-style preamble is absent, but the file body is the standard MIT text). By Virgílio Jr. A Python tool + Agent Skill that extracts PDF/EPUB/DOCX/HTML/MD/text/RTF/MOBI/AZW into `SKILL.md` + per-chapter files + glossary + patterns + cheatsheet.
- **Source-code safety audit (LAW 1 point 5), done 2026-08-14 before adopting:** the upstream package (`book_to_skill/`, `scripts/extract.py`, `tools/`) was cloned and read directly. All `subprocess` calls use list-form args (no `shell=True`), scoped to `pip install` (gated by the `BOOK_SKILL_INSTALL_MISSING` env var, default `ask`) and local format converters (`pdftotext`, Calibre `ebook-convert`) on the input file. No network calls (`requests`/`urllib`), no `os.system`/`eval`/`exec`, no env-var or credential exfiltration, no destructive commands. `git`/`gh repo create` appear only in the tool's own user-gated publishing step (`--private` default). No hidden trigger-and-payload found.
- The upstream's "24×–51× fewer tokens than dumping the book into context" figure is the **vendor's own self-reported number** (`[LOW-EVIDENCE]` — not independently benchmarked here); cite it as the tool's claim, not a measured fact.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: Resolve the engine — do not assume it exists

```bash
BTS_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*book-to-skill*" 2>/dev/null | head -1)
if [ -z "$BTS_SKILL_MD" ]; then
  echo "book-to-skill not found locally."
  BTS_DIR=""
else
  BTS_DIR=$(dirname "$BTS_SKILL_MD")
fi
```

**If not found, ask the user (AskUserQuestion)**: clone `https://github.com/virgiliojr94/book-to-skill` into `~/Desktop/skills/book-to-skill` now (MIT, safety-audited above), or stop. If the user approves:

```bash
git clone --depth 1 https://github.com/virgiliojr94/book-to-skill.git ~/Desktop/skills/book-to-skill
```

`book-to-skill/` is already in this repo's `.gitignore` — it is a local runtime copy, not tracked content.

## Step 2: Delegate to the upstream skill as written

Read `$BTS_DIR/SKILL.md` and follow **its own steps** for the actual conversion — its instructions take precedence over anything summarized here. In particular, do not bypass its own built-in gates:

- **Cost pre-flight** — it estimates tokens and shows a pricing disclaimer before generating; surface that to the user and get confirmation rather than running silently.
- **Copyright gate** — a third-party copyrighted book publishes to a **private** repo only; public visibility needs openly-licensed/original material or explicit user authorization.
- **Security scan** — it runs `tools/scan_generated_skill.py` on the generated skill before load/publish; a non-zero exit halts. Do not skip it.

The extractor entrypoint it drives is `python3 scripts/extract.py` (run from `$BTS_DIR`). If format-specific extractors are missing it will offer to install them (`--install-missing ask`) — pass that choice to the user, do not force `yes`.

## Step 3: Hand back the generated skill

Report where the generated skill was written (its folder, the chapter files, glossary, cheatsheet) and its estimated token footprint. Do **not** auto-register it into this workspace's `_shared/ROUTING.md` or `marketplace.json` — a generated skill is the user's own artifact, not a workspace skill, unless they explicitly ask to add it here (which then follows this workspace's own skill-authoring process under LAW 4).

---

## What this skill does not do

It does not vendor or fork `book-to-skill` into this repo — it resolves the real repo and runs it live. It does not write a prompt (that's `prompt-craft`) or design an agent worker (that's `agent-builder`). It does not publish a skill built from a copyrighted book to a public repo, and it does not skip the upstream cost/copyright/scan gates.
