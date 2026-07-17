---
name: biz-council
description: "Research what real users actually say (Reddit, X, YouTube, TikTok, Instagram Reels, Hacker News, Polymarket, web), run the findings through a 5-advisor council for multi-angle judgment, then produce a precise business/product design document. MANDATORY TRIGGERS: 'biz council this', 'research and council this', 'design a business around X', 'validate this business idea with real data'. Fuses three source projects: last30days (real-user research engine), llm-council (Karpathy's multi-advisor methodology), gstack /spec + /plan-ceo-review (design-doc discipline). Do NOT trigger on trivial questions with one right answer."
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - WebSearch
  - AskUserQuestion
---

# biz-council

Most "AI business idea" output is the model's own guess dressed up as analysis. This skill refuses that shortcut: every claim in the final document must trace back to either (a) a real post/comment pulled by the research engine, or (b) a labeled assumption the user explicitly approved. If evidence is thin, the document says so — it does not fill the gap with plausible-sounding prose.

## Attribution

This skill fuses three source projects and does not reimplement any of them:

- **last30days** — [github.com/mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill), MIT license. Research engine, called as-is in Step 1.
- **llm-council** — [github.com/aiwithremy/claude-skills-llm-council](https://github.com/aiwithremy/claude-skills-llm-council), adapted from Andrej Karpathy's original [github.com/karpathy/llm-council](https://github.com/karpathy/llm-council). Methodology (advisor roles, peer-review, chairman synthesis) referenced in Step 2. **Neither repo has a LICENSE file (verified directly against both repos' root contents, not a secondary source) — both default to all-rights-reserved.** This skill describes the methodology in its own words rather than reproducing either repo's text, and fetches the original live via WebFetch rather than vendoring a local copy (see Step 2). Fine for personal local use; before public redistribution of this workspace, treat the advisor-role concept as the only borrowed idea (not copyrightable expression) and keep this file's own wording as the sole source of the actual instructions.
- **gstack** — [github.com/garrytan/gstack](https://github.com/garrytan/gstack), MIT license. Only the `/spec` and `/plan-ceo-review` *question frameworks* are borrowed in Step 3 — gstack's own runtime (`~/.gstack/`, `gstack-config`, telemetry binaries) is intentionally excluded; those binaries don't exist outside a gstack install and would error or silently no-op if invoked here.

---

## Core Laws

This skill follows `../_shared/CORE-LAWS.md` (LAW 0 no-speculation + tag vocabulary, LAW 1 evidence-ranked library selection, LAW 2 code-architecture-if-implemented). Read that file before running this skill for the first time in a session. Everything below assumes those LAWs are active; only `biz-council`-specific steps are written out here.

---

## Step 1: Research — real users, real platforms

**1.0 Resolve the engine path first — do not assume it.** `biz-council` lives in its own skill folder, separate from `last30days`. last30days' own `SKILL.md` defines `SKILL_DIR` as "the directory of the SKILL.md the model just Read," which only resolves correctly when last30days is loaded directly. Before invoking anything, locate the real installation:

```bash
LAST30DAYS_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*last30days*" 2>/dev/null | head -1)
if [ -z "$LAST30DAYS_SKILL_MD" ]; then
  echo "last30days not found locally."
else
  LAST30DAYS_SKILL_DIR=$(dirname "$LAST30DAYS_SKILL_MD")
  echo "Resolved last30days at: $LAST30DAYS_SKILL_DIR"
fi
```

**If not found, offer to clone it — do not silently skip to Step 2 with no research.** Ask the user (AskUserQuestion): clone `https://github.com/mvanhorn/last30days-skill` into `~/Desktop/skills/last30days` now, or proceed on WebSearch-only evidence (weaker, must be labeled `[LOW-EVIDENCE]` throughout). If the user approves the clone:

```bash
git clone https://github.com/mvanhorn/last30days-skill.git ~/Desktop/skills/last30days
LAST30DAYS_SKILL_DIR=$(find ~/Desktop/skills/last30days -maxdepth 3 -iname "SKILL.md" -path "*last30days*" 2>/dev/null | head -1 | xargs dirname)
echo "Cloned and resolved at: $LAST30DAYS_SKILL_DIR"
```

Never guess a path instead of running this resolution/clone sequence.

**1.1 Run the engine.** Once `LAST30DAYS_SKILL_DIR` is resolved, Read that directory's `SKILL.md` and follow it exactly — first-run setup wizard, `--plan` for named entities, the source list (Reddit, X, YouTube, TikTok, **Instagram Reels**, Hacker News, Polymarket, GitHub, web; optional Bluesky/Threads/Pinterest/LinkedIn/Xiaohongshu with the right keys). Do not reimplement its logic — invoke `"$LAST30DAYS_SKILL_DIR/scripts/last30days.py"` as that file documents. Relay its engine footer and evidence per its own LAWs; do not paraphrase or fabricate around a "nothing solid this window" result.

**1.2 Korean-market supplement (known gap — do not claim otherwise).** The last30days engine has no Naver or Daum connector. For a Korean-market business question, run this as a separate, explicitly-labeled supplement:

1. Use WebSearch with `site:naver.com` / `site:daum.net` plus the topic, and separately search Naver 카페/블로그/지식iN and Daum 카페 by name if WebSearch surfaces them.
2. Label every finding from this supplement `[KR-WEB - via WebSearch, not last30days engine]` so the final doc never implies engine-level coverage that doesn't exist.
3. If WebSearch returns nothing usable, say so explicitly rather than padding with generic claims about "Korean users."

**1.3 Evidence gate — do not proceed on empty research.** Before moving to Step 2, check: did 1.1 and/or 1.2 return at least a handful of real, citable items? If both came back empty or "nothing solid this window," STOP. Do not run the council on zero evidence — that just produces five confident-sounding guesses. Tell the user research came back thin and ask whether to: narrow/rephrase the topic, supply their own context/data manually, or proceed anyway with everything downstream tagged `[LOW-EVIDENCE]`.

## Step 2: Council — 5-advisor multi-angle judgment

Reuse the `llm-council` methodology (see Attribution above for its license status — reference it, don't republish it as your own):

1. Frame the business question using the Step 1 research (1.1 web/social evidence plus any 1.2 KR-web supplement) as grounding context (not the user's raw question alone — enrich it with the strongest 3-5 evidence items, cited).
2. Spawn 5 sub-agents in parallel: **The Contrarian**, **The First Principles Thinker**, **The Expansionist**, **The Outsider**, **The Executor**. `llm-council` is not vendored locally (license unconfirmed — see Attribution), so fetch the original advisor descriptions live via WebFetch on `https://github.com/aiwithremy/claude-skills-llm-council/blob/main/SKILL.md` the first time this step runs in a session, rather than assuming a local copy exists; cache the fetched text in-session for the rest of the run. Do not weaken, merge, or paraphrase-from-memory these roles.
3. Anonymize responses A-E, run a peer-review round (strongest response / biggest blind spot / what everyone missed).
4. Chairman synthesis: where the council agrees, where it clashes, blind spots caught, the recommendation, the one thing to do first.

Do not skip the peer-review round — it's the step that catches the blind spots a single-pass "ask 5 times" would miss.

## Step 3: Design document — turn the verdict into something buildable

Borrow the *question framework* from gstack `/spec` and `/plan-ceo-review` — not their runtime. Do not invoke any `gstack-*` binary; those only exist inside a gstack install and are irrelevant here.

**3a. Lock the "why" (from /spec Phase 1).** Answer all five before drafting anything:
1. Who is affected? (be specific — a demographic/behavior segment found in Step 1 research, not "everyone")
2. What is the current behavior/pain, per the evidence?
3. What should the outcome be instead?
4. Why now? (what in the Step 1 research suggests timing — a trend, a gap competitors haven't filled, a platform shift)
5. How will you know it worked? (a measurable signal, not a vibe)

If any of these can't be answered from Step 1 evidence, ask the user directly (AskUserQuestion) — do not invent an answer.

**3b. Scope-check (from /plan-ceo-review's four modes).** Present the business idea once at each of these angles and let the user pick a direction:
- **Scope Expansion** — what's the 10x version if execution cost weren't a constraint?
- **Selective Expansion** — hold the core scope, cherry-pick one or two expansions with the best evidence-to-effort ratio.
- **Hold Scope** — the smallest version that tests the core hypothesis from Step 1.
- **Scope Reduction** — strip to the single riskiest assumption and design only to test that.

**3c. Write the document.** Structure:

```
# {Business/Product Name}: Design Document

## Evidence Base
{Every source cited in Step 1.1 and 1.2, with links. Note coverage gaps honestly.}

## Council Verdict
{Full output of Step 2 — agreement, clashes, blind spots, recommendation, first move.}

## The Five Questions (Spec Lock)
{3a answers, each citing the evidence or user-confirmed assumption it rests on.}

## Scope Decision
{Which of the 3b four modes was chosen, and why.}

## What Gets Built
{Feature list / user flow. Tag anything not evidence-backed with the canonical `[ASSUMPTION - unverified, confirm with user]` tag from LAW 0.}

## Open Risks
{What the council flagged as blind spots or clashes that remain unresolved.}
```

---

LAW 1 (library selection) and LAW 2 (code architecture, if this design doc is later implemented) apply exactly as written in `../_shared/CORE-LAWS.md` — no `biz-council`-specific override.

Do not write actual source files under this skill unless the user explicitly asks for an implementation pass separate from the design doc.
