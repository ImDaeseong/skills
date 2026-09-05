---
name: founder-finance
description: "Apply bootstrapped-founder cash discipline to a specific decision — runway/burn-rate calculation, unit-economics sanity check (LTV:CAC, CAC payback), a hiring or spending decision's payback period, working-capital/cash-conversion-cycle optimization, or a driver-based revenue/cash forecast. MANDATORY TRIGGERS: 'how much runway do we have', 'should we make this hire', 'what's our burn multiple', 'check our unit economics', 'build a 13-week cash flow forecast', 'founder financial discipline', '런웨이 계산', '번레이트'. Do not trigger for DCF/valuation/investor-facing financial modeling of an established business (route to `biz-ops`) or validating a brand-new business idea (route to `biz-council`) — this is day-to-day cash-runway discipline for a self-funded or bootstrapped operator, not investment-analyst modeling."
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# founder-finance

`biz-ops` builds DCF/budgeting/SaaS-metrics models for an already-established business, and `biz-council` validates a brand-new idea — neither one is the specific, narrower question a bootstrapped or self-funded founder actually asks day to day: how much runway is left, whether a hire pays for itself, and whether the unit economics still work. This skill wraps a real reference methodology for exactly that gap.

## Attribution

This skill does not reimplement founder-finance methodology — it resolves and routes into a real, actively-maintained skill as a **runtime dependency**, cloned on demand exactly like `video-watcher` does for `claude-video`. Never vendored into this repo, never copied verbatim.

- **EveryInc/charlie-cfo-skill** — [github.com/EveryInc/charlie-cfo-skill](https://github.com/EveryInc/charlie-cfo-skill), 309 stars (checked 2026-09-06 via GitHub API), **MIT license** (confirmed by reading the repo's `LICENSE` file directly — "Copyright (c) 2026 Every," the media/software company behind Cora and Sparkle). A pure-methodology Claude skill (no scripts, no external calls) covering cash-management rules (runway targets, reserve structure, burn multiple), unit economics (LTV:CAC, CAC payback, revenue-per-employee benchmarks), capital-allocation/hiring-ROI framing, working-capital optimization (cash conversion cycle, AR/AP discipline), financial review rhythms, and driver-based 13-week/rolling forecasting — with reference files citing real-company benchmarks (Mailchimp, Zapier, Basecamp, ConvertKit, Zoho).
- **Source-code safety audit (LAW 1 point 5), 2026-09-06:** the actual `SKILL.md` was fetched and read directly via `raw.githubusercontent.com` (literal file bytes, full 161 lines). It is static reference content only — no scripts, no `allowed-tools` requiring Bash/network access, no external calls of any kind. No hidden trigger-and-payload possible in a file with no executable surface.
- No install required beyond cloning the repository — this is a knowledge reference, not a tool.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: Resolve the reference — do not assume it exists

```bash
CHARLIE_SKILL_MD=$(find "$HOME/.claude/skills" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*charlie-cfo-skill*" 2>/dev/null | head -1)
if [ -z "$CHARLIE_SKILL_MD" ]; then
  echo "charlie-cfo-skill not found locally."
  CHARLIE_DIR=""
else
  CHARLIE_DIR=$(dirname "$CHARLIE_SKILL_MD")
fi
```

**If not found, ask the user (AskUserQuestion)**: clone `https://github.com/EveryInc/charlie-cfo-skill` into `~/Desktop/skills/charlie-cfo-skill` now (MIT, safety-audited above), or stop. If approved:

```bash
git clone --depth 1 https://github.com/EveryInc/charlie-cfo-skill.git ~/Desktop/skills/charlie-cfo-skill
```

`charlie-cfo-skill/` is already in this repo's `.gitignore` — it is a local runtime copy, not tracked content.

## Step 2: Apply the framework to the user's actual numbers

Read `$CHARLIE_DIR/SKILL.md` and its `references/metrics-benchmarks.md` and `references/case-studies.md`. Match the user's question to the relevant section rather than reciting the whole framework:

- **Runway/burn question** → Cash Management Rules (reserve structure, burn multiple, danger-zone thresholds).
- **Hiring or spending decision** → Capital Allocation Framework's payback-period and "what else could this salary fund" questions.
- **Unit-economics health check** → LTV:CAC / CAC-payback / Rule-of-40 thresholds in the Key Metrics Dashboard.
- **Cash-flow forecast** → the driver-based MRR buildup model and 13-week rolling forecast, with base/moderate-downside/severe-downside scenarios.
- **Working-capital question** → Cash Conversion Cycle and AR/AP discipline section.

Every number the user provides (actual burn, headcount, ARR) drives the calculation — do not substitute the reference's example benchmarks for the user's own figures; use the benchmarks only as a comparison point, labeled as such.

## Step 3: State the answer, then the comparison

Give the direct answer to the question asked (e.g. "18 months runway at current burn, below the 24-36 month target") before listing the general framework — lead with the specific number, not a restated lecture on the methodology.

---

## What this skill does not do

It does not vendor or fork `charlie-cfo-skill` into this repo — it resolves the real repo and reads it live. It does not build DCF/valuation models or investor-facing financial statements for an established business (that's `biz-ops`), and it does not validate whether a new business idea is worth pursuing (that's `biz-council`). It treats the reference file's benchmarks as comparison points, never as a substitute for the user's own real figures.
