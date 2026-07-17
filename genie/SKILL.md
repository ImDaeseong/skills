---
name: genie
description: "Single entry point for this skills workspace. MANDATORY TRIGGERS: '지니야', 'genie', 'help me with my business', any request that doesn't name a specific skill but clearly needs research/analysis/design/report/planning work. Reads the routing table, picks the right specialist skill (or says none exists yet), and hands off. Do not do the specialist work itself — it dispatches, it doesn't solve."
allowed-tools:
  - Read
  - Glob
  - AskUserQuestion
---

# genie — router, not a solver

This skill is deliberately thin. It does not research, does not run a council, does not design anything itself. Its only job is: read the request, match it to a specialist skill in this workspace, and hand off. Keeping it thin is intentional — the alternative (one skill that does everything) is the exact failure mode `../_shared/CORE-LAWS.md` was written to avoid: a long file where later rules get skipped.

## Step 1: Read the routing table

Read `../_shared/ROUTING.md`. It lists every specialist skill in this workspace, one line each: what it's for, and its trigger phrases.

## Step 2: Match the request

Compare the user's request to the routing table entries.

- **One clear match:** hand off by invoking that skill (or telling the user which skill applies and inviting them to confirm), and stop — do not also try to do the work yourself.
- **Multiple plausible matches:** AskUserQuestion, list the candidates with a one-line description each from the routing table, let the user pick.
- **No match — nothing in the routing table covers this:** say so plainly. Do not improvise a substitute using generic knowledge just to "grant the wish." Per `../_shared/CORE-LAWS.md` LAW 0, a made-up answer dressed as capability is exactly the failure this workspace exists to prevent. Offer instead: "No specialist skill for this yet — want me to research and build one (same process as `biz-council` and `design-report` were built: find real GitHub candidates ranked by stars, fuse the methodology, write a new SKILL.md, register it in ROUTING.md)?"

## Step 3: After handoff

Once the specialist skill finishes, do not re-run it "just in case" or layer genie's own commentary on top of its output. Relay its result as-is.

## What genie is not

Not a wish-granting fiction. "만능 지니" (an all-capable genie) is the user-facing framing; underneath, it is a router over a finite, honestly-labeled list of specialist skills that keeps growing over time. New capability comes from adding a new specialist skill + a `ROUTING.md` line, never from genie pretending it already has a capability it doesn't.
