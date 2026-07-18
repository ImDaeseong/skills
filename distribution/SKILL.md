---
name: distribution
description: "Find where attention already exists for an idea/product, build trust before selling, and produce a distribution plan with multiple concrete channel angles — not a single 'post about it' suggestion. MANDATORY TRIGGERS: 'distribution plan', 'how do I market this', 'where should I promote this', 'launch this product', 'growth ideas', 'marketing plan', 'find my audience'. Wraps coreyhaines31/marketingskills (MIT, 40k+★) as a runtime dependency — routes to its `marketing-ideas`, `launch`, `community-marketing`, `co-marketing`, `directory-submissions`, `public-relations`, and `prospecting` skills rather than reimplementing them. Do not trigger on copy/CRO/SEO/ads execution detail — route those directly to the matching marketingskills specialist instead of through this wrapper."
allowed-tools:
  - Bash
  - Read
  - WebFetch
  - WebSearch
  - AskUserQuestion
---

# distribution

"Post about it on social media" is not a distribution plan — it's one channel dressed up as a strategy. This skill's job is narrower and more concrete: find where the target audience's attention is *already* concentrated, describe how to earn trust there before selling, and hand back several specific, executable channel angles for one idea — not a single generic suggestion.

## Attribution

This skill does not reimplement marketing execution — it resolves and routes into a real, actively-maintained skill library rather than rewriting 46 specialist skills' worth of content from scratch.

- **marketingskills** — [github.com/coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills), 40,401★ (checked 2026-07-18 via GitHub API, pushed within the last day), MIT license (verified via GitHub API license endpoint). By Corey Haines. Contains 46 individual `SKILL.md` specialist skills (already in Agent Skills spec format) covering SEO, CRO, copy, paid, growth/retention, sales/GTM, and strategy. This skill treats it as a **runtime dependency**, resolved/cloned on demand exactly like `biz-council` does for `last30days` — never vendored into this repo, never copied verbatim.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: Resolve the engine — do not assume it exists

```bash
MKTG_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*marketingskills*skills*" 2>/dev/null | head -1)
if [ -z "$MKTG_SKILL_MD" ]; then
  echo "marketingskills not found locally."
  MKTG_SKILL_DIR=""
else
  # repo layout is marketingskills/skills/{name}/SKILL.md — three dirnames back to the repo root
  MKTG_SKILL_DIR=$(dirname "$(dirname "$(dirname "$MKTG_SKILL_MD")")")
fi

```

**If not found, ask the user (AskUserQuestion)**: clone `https://github.com/coreyhaines31/marketingskills` into `~/Desktop/skills/marketingskills` now, or proceed with a lighter WebFetch-only pass (fetch individual `SKILL.md` files live from the `main` branch on raw.githubusercontent.com instead of cloning). If the user approves the clone:

```bash
git clone https://github.com/coreyhaines31/marketingskills.git ~/Desktop/skills/marketingskills
```

Note in `.gitignore` (already covers `last30days/`; add `marketingskills/` alongside it the first time this skill is used) — this is a local runtime copy, not tracked content.

## Step 2: Find where the attention already is

Before picking channels, answer this from real signal, not assumption:

1. Where does the target audience already gather (specific subreddits, Discord/Slack servers, newsletters, forums — named, not "social media" generically)?
2. What exact words do they use to describe the problem this idea solves? (their language, not the product's marketing language)
3. What existing communities have "show off your project" days/threads (many subreddits and Discords do — name them if known, WebFetch to confirm if not)?

If this can't be answered from what the user already knows, use WebFetch to check community rules/norms directly rather than guessing self-promotion policies. For scraping many pages from one domain (e.g. a full competitor site or the user's own past content to characterize their brand voice), Firecrawl — [github.com/firecrawl/firecrawl](https://github.com/firecrawl/firecrawl), 152,409★ (checked 2026-07-18 via GitHub API), AGPL-3.0 — is a stronger option than looping WebFetch, when an API key is configured; otherwise fall back to WebFetch/WebSearch and say so.

## Step 3: Route into the marketingskills library

Read `$MKTG_SKILL_DIR`'s own `README.md` skill table and select the specialists that match the request — do not reimplement their content here. The most common routes for a distribution question:

- **`marketing-ideas`** — broad brainstorm across 139 catalogued tactics when the user doesn't know where to start.
- **`launch`** — a specific launch/release/Product Hunt/waitlist moment.
- **`community-marketing`** — building/leveraging an online community for ongoing growth.
- **`co-marketing`** — partnership-based distribution (the "borrow someone else's audience" angle).
- **`directory-submissions`** — startup/SaaS/AI/directory listings as a distribution surface.
- **`public-relations`** — earned media / journalist outreach.
- **`prospecting`** — direct outbound to a qualified list, for B2B.

Read the matched skill(s)' `SKILL.md` directly from `$MKTG_SKILL_DIR/skills/{name}/SKILL.md` and follow it as written — its own instructions (e.g. checking for a `product-marketing.md` context file first) take precedence over anything summarized here.

## Step 4: Trust-before-selling check

Per the framing this skill is built around: distribution succeeds by earning trust in a space before asking for anything. Before finalizing the plan, check each proposed channel against:

- Does this channel's community have norms against selling/self-promo, and does the plan respect them (contribute first, promote second)?
- Is there a concrete piece of value (a free tool, a genuinely useful post, a real answer) planned before the ask — not just an announcement?

If a channel fails this check, flag it rather than dropping it silently — the user may still choose to proceed.

## Step 5: Output — multiple concrete angles, not one

Deliver at minimum 3-5 named, specific channel angles (not "try social media and SEO") each with: the named community/channel, why the audience is already there (Step 2 evidence), the trust-building move before the ask (Step 4), and which marketingskills specialist (Step 3) to invoke next for execution detail.

---

## What this skill does not do

It does not write copy, run ads, build landing pages, or execute SEO — those are the marketingskills specialists' job once routed to (Step 3). It does not vendor or fork marketingskills content into this repo; it resolves the real repo and reads from it live, same discipline as `biz-council` → `last30days`.
