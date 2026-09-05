---
name: sales-desk
description: "Run sales-execution work on a specific prospect or account — company research, BANT/MEDDIC lead qualification, decision-maker mapping from the company's own public site, outreach-sequence drafting, objection-handling prep, and a pipeline report. MANDATORY TRIGGERS: 'research this prospect', 'qualify this lead', 'find decision makers at this company', 'write a cold outreach sequence for X', 'prep me for this sales call', 'handle this sales objection', 'build a sales pipeline report'. Do not trigger for pricing/RFP/deal-desk/partnership strategy (route to `biz-ops`) or channel/growth-marketing distribution planning (route to `distribution`) — this is prospect-level sales execution, not deal strategy or marketing channel selection."
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# sales-desk

`biz-ops` covers deal *strategy* (pricing, RFP response, partnerships, deal-desk) and `distribution` covers *channel/growth-marketing* work — neither does prospect-level sales execution: researching a specific company, qualifying it against BANT/MEDDIC, finding who the actual buyers are, and drafting outreach. This skill wraps a real, actively-maintained tool that automates that specific gap.

## Attribution

This skill does not reimplement sales-execution tooling — it resolves and routes into a real, actively-maintained tool as a **runtime dependency**, cloned on demand exactly like `video-watcher` does for `claude-video`. Never vendored into this repo, never copied verbatim.

- **zubair-trabzada/ai-sales-team-claude** — [github.com/zubair-trabzada/ai-sales-team-claude](https://github.com/zubair-trabzada/ai-sales-team-claude), 1,094 stars (checked 2026-09-06 via GitHub API), **MIT license** (confirmed by reading the repo's `LICENSE` file directly). 14 skills orchestrated across 5 parallel sub-agents: company/firmographic research, BANT+MEDDIC qualification scoring, decision-maker/buying-committee mapping, competitive intelligence, outreach-sequence generation, meeting prep, objection-handling playbooks, and Markdown/PDF pipeline reports.
- **Source-code safety audit (LAW 1 point 5), 2026-09-06:** `install.sh`, `scripts/contact_finder.py`, `scripts/analyze_prospect.py`, `scripts/lead_scorer.py`, and `scripts/generate_pdf_report.py` were fetched and read directly via `raw.githubusercontent.com` (literal file bytes). `install.sh` only clones the repo, copies its own skill/agent/script/template files into `~/.claude/skills/sales/` and `~/.claude/agents/`, and checks for optional Python packages (`reportlab`, `beautifulsoup4`) — no `curl | sh` to a third party, no destructive commands, no credential handling. The scripts fetch only the **target company's own public website** (`/about`, `/team`, `/leadership`, and similar paths) to extract publicly-listed names/titles — not LinkedIn, not a people-search/data-broker API, and no personal data beyond what the company itself has published. No hidden trigger-and-payload or exfiltration step found.
- **One real security smell to flag, not a blocker:** `contact_finder.py` disables TLS certificate verification on its own outbound fetches (`ssl.CERT_NONE`, `check_hostname = False`). This is a genuine MITM-risk anti-pattern in the upstream code, not malicious — it only affects the tool's own read-only fetch of the target site, not any credential or user data — but avoid running this specific data-collection step over an untrusted network (e.g. open public wifi).
- Requires `git`, Python 3, and optionally `reportlab`/`beautifulsoup4` (`pip install -r requirements.txt`) for PDF export and more robust HTML parsing.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: Resolve the engine — do not assume it exists

```bash
SALES_SKILL_MD=$(find "$HOME/.claude/skills" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*sales*" 2>/dev/null | grep -v sales-desk | head -1)
if [ -z "$SALES_SKILL_MD" ]; then
  echo "ai-sales-team-claude not found locally."
  SALES_DIR=""
else
  SALES_DIR=$(dirname "$SALES_SKILL_MD")
fi
```

**If not found, ask the user (AskUserQuestion)**: clone `https://github.com/zubair-trabzada/ai-sales-team-claude` into `~/Desktop/skills/ai-sales-team-claude` now (MIT, safety-audited above — note the public-website-only data collection and the TLS-verification caveat), or stop. If approved:

```bash
git clone --depth 1 https://github.com/zubair-trabzada/ai-sales-team-claude.git ~/Desktop/skills/ai-sales-team-claude
bash ~/Desktop/skills/ai-sales-team-claude/install.sh
```

`ai-sales-team-claude/` is already in this repo's `.gitignore` — it is a local runtime copy, not tracked content.

## Step 2: Delegate to the upstream skill as written

Read the installed `~/.claude/skills/sales/SKILL.md` and follow **its own commands** exactly — its instructions take precedence over anything summarized here. Match the request to the closest command rather than always running the full pipeline:

- Full account research + qualification + outreach plan → `/sales prospect <url>`
- Just qualification scoring → `/sales qualify <url>`
- Just decision-maker mapping → `/sales contacts <url>`
- Outreach sequence only → `/sales outreach <prospect>`
- Meeting prep, objection handling, competitive intel, or pipeline report → the matching named command

Don't default to the full 5-agent `prospect` pipeline when the user only asked for one piece of it.

## Step 3: Hand back the result

Report the output file(s) the upstream command produced (e.g. `PROSPECT-ANALYSIS.md`, a pipeline report) and the qualification score if one was generated. Remind the user that firmographic/contact data came from the target company's own public site, not a verified people-data provider — treat names/titles as a research starting point to confirm, not a guaranteed-current contact list.

---

## What this skill does not do

It does not vendor or fork `ai-sales-team-claude` into this repo — it resolves the real repo and runs it live. It does not do deal-pricing/RFP/partnership strategy (that's `biz-ops`) or channel/growth-marketing planning (that's `distribution`). It does not scrape LinkedIn, social profiles, or any people-search/data-broker service — only the target company's own published web pages.
