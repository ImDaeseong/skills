---
name: curator
description: "Watch a topic/niche for what's actually happening right now (new models, launches, news), judge why it matters for a specific audience, and produce a short-form hot-take script with a hook, an analogy, and a title — grounded in real signal, not a generic recap. MANDATORY TRIGGERS: 'curate this for me', 'what's the hot take on X', 'make a short video about this news', 'give me a 7-day content sprint', 'react to this launch'. Reuses last30days (real-signal research, already integrated for biz-council) for Step 1 and marketingskills' `social` skill (already integrated for distribution) for Step 3 — does not duplicate either. Do not trigger for evergreen/non-timely content strategy — route that to `distribution` → `content-strategy` instead."
allowed-tools:
  - Bash
  - Read
  - Write
  - WebFetch
  - AskUserQuestion
---

# curator

A curator's value is a specific, honest opinion on something timely — not a neutral summary. This skill refuses to produce generic recaps: every hot take must (a) be grounded in something that actually happened, checked via real research, not the model's prior knowledge of "what's usually true," and (b) state a specific "here's why this matters for [named niche]" angle, not a one-size-fits-all reaction.

## Attribution

This skill introduces no new heavy dependency — it composes two engines already present in this workspace rather than duplicating capability that already exists at high quality elsewhere:

- **last30days** — [github.com/mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill), MIT license (already documented in this repo's README). Reused as-is in Step 1 for "what's actually happening" — same resolution/clone pattern as `biz-council` Step 1, not re-described here.
- **marketingskills `social`** — [github.com/coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills), 40,401★ (checked 2026-07-18), MIT license (already documented in this repo's README via `distribution`). Its `social` skill already covers video hooks, TikTok/Reels/Shorts scripting, and social listening at production quality — Step 3 routes into it rather than reimplementing script-writing craft here.
- **hardikpandya/stop-slop** — [github.com/hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop), 14,006★ (checked 2026-07-19 via direct GitHub HTML verification), MIT license. Reference for Step 3's prose quality — a skill specifically for catching and removing predictable "AI tells" (stock phrases, structures, rhythms) from written output, applied to the hot-take script before it's considered final. Reinforces this skill's existing "honest opinion, not a hedge" principle with a concrete pattern-catalog rather than a vague instruction to "sound authentic."
- **Not reimplemented here, routed instead:** footage sourcing, voiceover synthesis, and video rendering are `video-producer`'s job (see `../video-producer/SKILL.md`, which adopts `heygen-com/hyperframes` as primary — 35,961★, Apache-2.0 — with `remotion-dev/remotion` noted as license-gated and `RayVentura/ShortGPT` as a full-pipeline option). This skill stops at the written script and hands off rather than reimplementing rendering.

## Core Laws

This skill follows `../_shared/CORE-LAWS.md` (LAW 0 no-speculation, LAW 1 evidence-ranked selection, LAW 2 code-architecture-if-implemented).

---

## Step 1: What's actually happening — real signal, not recall

Resolve and run `last30days` exactly as `biz-council` Step 1 does (find `LAST30DAYS_SKILL_DIR` under `~/Desktop/skills`, `~/.claude/skills`, etc.; offer to clone if missing; never assume a path). Scope the query to the requested topic/niche and a tight recency window (the last few days, not "recent" vaguely) — a curator reacting to three-week-old news isn't a curator.

If `last30days` returns nothing solid for the window, say so and stop rather than inventing a "trend."

## Step 2: Why this matters — the specific angle

For each real item Step 1 surfaced, answer before drafting anything:

1. **Who specifically** cares about this (the named niche/sub-audience — not "AI enthusiasts" broadly)?
2. **What changed** — the concrete before/after, not a vague "this is big."
3. **The honest opinion** — the algorithm rewards a raw, specific take, not a hedge. State a real position (this is overhyped / underhyped / a genuine shift / a dead end and why), not "there are pros and cons."
4. **The analogy** — one comparison that makes the significance click for someone who hasn't followed the space closely.

If the honest opinion can't be formed from Step 1 evidence alone, ask the user for their actual take (AskUserQuestion) rather than fabricating a confident-sounding stance with no basis.

## Step 3: Script it — route to `social`, don't reimplement

Resolve `marketingskills` the same way `distribution` does (see `../distribution/SKILL.md` Step 1 for the exact resolution/clone sequence — reuse it, don't duplicate it here). Read `$MKTG_SKILL_DIR/skills/social/SKILL.md` and follow it for the actual hook/title/short-form-script craft, feeding it:

- The real item + evidence from Step 1
- The specific niche + honest opinion + analogy from Step 2

`social`'s own instructions (platform-specific format, hook patterns, etc.) take precedence over anything summarized here.

**Before calling the script final, pass it through a stop-slop check** (see Attribution) — the same predictable AI phrasing that makes a design read as generic makes a hot take read as generic too, and a script full of "AI tells" undercuts the whole point of a curator's raw, specific voice.

## Step 4: 7-day sprint (when requested)

If the user asks for a sprint rather than a single piece: repeat Steps 1-3 once per day for 7 days, keeping a running "taste file" — the hooks, analogies, and titles that worked, so later days can reference earlier ones instead of starting cold each time. Store the taste file wherever the user is already keeping working notes for this task; do not invent a new persistent-storage location without asking.

## Output

```
# {Topic}: Hot Take

## What Happened (Step 1 evidence)
{Real item(s), cited, with dates from the last30days window}

## Why It Matters For {Named Niche} (Step 2)
{Specific change + honest opinion + analogy}

## Script (Step 3, via marketingskills/social)
{Hook, title, body — platform-specific per social's own format}
```

---

## What this skill does not do

It does not source footage, synthesize voiceover, or render video itself — that's `video-producer`'s job (route the finished script to it when the user wants an actual rendered file, not just the written script). It does not write evergreen/non-timely content strategy — that routes to `distribution` → `content-strategy`. It does not fabricate a "trend" when Step 1 comes back empty.
