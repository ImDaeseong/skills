---
name: book-author
description: "Ghostwrite a nonfiction technical book (e.g. an AI-development / vibe-coding book) from the author's own accumulated material — captures a voice fingerprint, builds a chapter template blending international AI-engineering-book narrative style with Korean self-publishing-style practical troubleshooting sections, runs a Researcher→Writer→Editor→Reviewer pipeline per chapter, then compiles to DOCX/PDF (via `design-report`) and EPUB (via a wrapped runtime dependency). MANDATORY TRIGGERS: '책으로 만들어줘', '전자책 원고 써줘', '이 내용으로 책 써줘', 'write my book', 'ghostwrite this book', 'turn my notes into a book', 'ebook 원고 작성', '책 스타일'. Distinct from `writing` (prose polish only, no book structure/compile) and `book-distiller` (existing book → Claude skill, the opposite direction)."
allowed-tools:
  - Read
  - Write
  - Bash
  - WebSearch
  - WebFetch
  - AskUserQuestion
---

# book-author

Writing a full nonfiction book is not "draft prose, then polish it" — it's outline discipline, per-chapter fact-checking, a consistent voice across dozens of pages, and a compile step into an actual sellable file. This skill chains those stages instead of leaving them to be rediscovered per chapter, and wraps a real EPUB engine rather than hand-rolling one.

## Attribution

- **luquiluke/claude-book-skill** — [github.com/luquiluke/claude-book-skill](https://github.com/luquiluke/claude-book-skill) (checked 2026-09-22 via GitHub API: 1 star, MIT, pushed 2026-07-07). `[LOW-EVIDENCE]` — conceptual source for Step 3's six-stage pipeline (Researcher→Writer→Editor→Reviewer→Editor→Compiler). **Not cloned as a runtime dependency**: a 1-star repo does not clear this workspace's evidence bar for executing someone else's code unsupervised, unlike `book-to-skill` or `claude-epub-skill` below. The pipeline shape is re-implemented in this skill's own words instead.
- **smerchek/claude-epub-skill** — [github.com/smerchek/claude-epub-skill](https://github.com/smerchek/claude-epub-skill) (checked 2026-09-22 via GitHub API: 162 stars, MIT, pushed 2025-10-18), **MIT license** (verified by reading the repo's actual `LICENSE` file directly). **Runtime dependency** for Step 4's EPUB output — its `markdown-to-epub` sub-skill turns a single Markdown file (H1 = chapter boundary) into an EPUB3 file via `ebooklib`.
  - **Source-code safety audit (LAW 1 point 5), done 2026-09-22 before adopting:** the package was cloned and `scripts/epub_generator.py` and `scripts/markdown_processor.py` read directly. No `subprocess`/`os.system`/`eval`/`exec` calls, no network calls (`requests`/`urllib`/`socket`), pure local Markdown→EPUB transformation via `ebooklib`/`markdown2`/`Pygments` (pinned in `requirements.txt`). No hidden trigger-and-payload found.
- **arturseo-geo/ebook-publishing-skill** — [github.com/arturseo-geo/ebook-publishing-skill](https://github.com/arturseo-geo/ebook-publishing-skill) (checked 2026-09-22 via GitHub API: 48 stars, MIT, pushed 2026-03-24). Reference only, not cloned — its HTML→PDF (Puppeteer) + Pandoc + EPUBCheck toolchain description informs Step 4's PDF fallback note only; `book-author` is scoped to manuscript production, not distribution.
- **Chip Huyen, *AI Engineering* (O'Reilly, 2025)** and **Addy Osmani, *Beyond Vibe Coding* (O'Reilly)** — published books, not repos, so LAW 1's star ranking doesn't apply. Style references (checked via WebSearch/WebFetch 2026-09-22) for Step 1's chapter template: concept-first chapter openings with diagrams, progressive/narrative argument over reference-list structure, and Osmani's "spectrum framing" (position the reader before diving in).
- **국내 크몽 실전 전자책 판매 사례** (checked via WebSearch 2026-09-22, e.g. kmong.com listings for Claude Code/바이브코딩 guides) — source for Step 1's "장 끝 트러블슈팅 체크리스트 + 부록(치트시트/API/배포)" pattern, which the international books above do not use.
- **arXiv:2402.08855, "GhostWriter" (CHI 2024)** — `[LOW-EVIDENCE]`, an 18-participant HCI study. Cited only as evidence that learning a voice fingerprint from writing samples is a studied approach to AI-assisted authorship, not as proof of book-writing-quality outcomes.
- **`writing` skill** (this workspace, internal) — Step 3 routes Korean/English prose-polish to it instead of duplicating its AI-tell pattern catalog here.
- **`design-report` skill + `anthropics/skills`'s `docx`/`pdf` skills** (this workspace, internal + source-available) — Step 4 routes DOCX/PDF generation and cover-design direction there instead of reimplementing document generation here.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 0: Resolve the EPUB engine — do not assume it exists

```bash
EPUB_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*claude-epub-skill*" 2>/dev/null | head -1)
if [ -z "$EPUB_SKILL_MD" ]; then
  echo "claude-epub-skill not found locally."
  EPUB_DIR=""
else
  EPUB_DIR=$(dirname "$EPUB_SKILL_MD")
fi
```

**If not found, ask the user (AskUserQuestion)**: clone `https://github.com/smerchek/claude-epub-skill` into `~/Desktop/skills/claude-epub-skill` now (MIT, safety-audited above), or stop. If approved:

```bash
git clone --depth 1 https://github.com/smerchek/claude-epub-skill.git ~/Desktop/skills/claude-epub-skill
EPUB_DIR=~/Desktop/skills/claude-epub-skill/markdown-to-epub
python3 -m pip install -r "$EPUB_DIR/requirements.txt"
```

`claude-epub-skill/` is already in this repo's `.gitignore` — a local runtime copy, not tracked content.

## Step 1: Capture voice + lock the chapter template (`STYLE.md`)

Ask (AskUserQuestion) if not already clear: writing samples or prior conversation content to fingerprint voice (per `writing`'s "match a real voice instead of a generic register" principle); target reader (입문자 vs 실무자).

Write `STYLE.md` in the book's project directory (create if missing) with this template, synthesized from the sources above — every part below traces to a cited source, don't drop one silently:

1. **장 열기** — Osmani식 포지셔닝("이 장이 어디까지고 다음 장은 어디부터인지") + 저자 경험 1-2문단.
2. **본문** — Huyen식: 개념 정의 → 다이어그램 → 점진적 심화. 레퍼런스 나열 대신 논증하듯 전개.
3. **실습** — 실제로 실행·검증된 코드/프로젝트만 싣는다 (AGENTS.md Evidence Rule과 동일: 실행해보지 않은 코드는 원고에 넣지 않음).
4. **장 마무리** — 크몽식 "막히는 지점" 체크리스트/에러 가이드.
5. **부록**(전권 끝, 각 장이 아니라 책 전체 끝) — 치트시트 + API 설명 + 배포 기초.

## Step 2: Outline from the author's own accumulated material

Point at the raw material (past conversation exports, notes, drafts) rather than inventing chapter topics from scratch — the reason this skill exists is a real backlog of questions that already maps out where readers actually get stuck. Order chapters by that "막히는 지점" progression, not textbook topic order — a concept that readers hit trouble with early gets pulled forward even if a textbook would place it later.

## Step 3: Per-chapter pipeline

For each chapter, run this pipeline (the shape is `luquiluke/claude-book-skill`'s concept, re-implemented here rather than cloned, given that repo's 1-star evidence):

1. **Researcher** — gather facts for this chapter's claims; every claim carries a source or an explicit `[ASSUMPTION - unverified, confirm with user]` flag, per LAW 0.
2. **Writer** — draft against `STYLE.md`'s template and the captured voice fingerprint.
3. **윤문** — hand off to the `writing` skill (Korean text → `im-not-ai`'s 70-pattern pass; English → `humanizer`) instead of re-deriving pattern removal here.
4. **Reviewer** — check the draft against `STYLE.md`'s 5-part structure as a literal checklist (diagram present? code actually executed? troubleshooting section present? appendix material flagged for the back matter instead of inlined?); return `CLEAR` or a list of what's missing.
5. **Revise** — fix flagged gaps; **max 3 cycles** (LAW 3's iteration cap). If still failing after 3, stop at HOLD and ask the user rather than shipping a chapter that doesn't meet its own template.

## Step 4: Compile output

- **DOCX/PDF + cover** — hand off to `design-report` (which itself routes to `anthropics/skills`'s `docx`/`pdf` skills for the file and to Google's `DESIGN.md` spec for a cover/token direction) rather than reimplementing document generation here.
- **EPUB** — concatenate the finished, reviewed chapters into one Markdown file (H1 = chapter boundary, matching the Step 0 engine's own chapter-detection rule), then run the Step 0 engine per its own `SKILL.md`/`REFERENCE.md` at `$EPUB_DIR` — its instructions on markdown structure and metadata take precedence over anything paraphrased here.
- If a print-ready PDF with different typography than `design-report`'s output is wanted, the HTML→PDF (Puppeteer) + Pandoc toolchain referenced in `arturseo-geo/ebook-publishing-skill`'s Attribution entry is a documented approach — not wrapped as a dependency here since `design-report` already covers PDF output for this workspace.

## What this skill does not do

Researcher 단계를 건너뛰고 곧장 Writer로 가지 않는다 — 사실 확인 없는 챕터는 산출물로 인정하지 않는다. 저작권 있는 제3자 콘텐츠를 원고에 그대로 붙여넣지 않는다. `book-distiller`(기존 책 → Claude 스킬 변환)와는 정반대 방향이며, `writing`(프로스 윤문만) 이나 `design-report`(포맷팅만)의 역할을 대체하지 않고 오케스트레이션만 한다. 원고 완성 이후의 출판·유통 단계는 이 스킬의 범위 밖이다.
