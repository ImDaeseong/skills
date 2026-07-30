---
name: ai-adoption-scout
description: "Maps how people and companies actually use AI right now (real signal via `last30days`, plus named usage reports like Anthropic's Economic Index or vendor/analyst stats via WebSearch — never recalled from memory) onto the user's own stated task, team, or business, then ranks concrete adoption ideas by feasibility. Hands findings to `design-report` only if the user wants a stakeholder-ready case document. MANDATORY TRIGGERS: '다른 사람들은 AI를 어떻게 쓰나', 'AI 활용 아이디어', 'AI 도입 사례', 'where else could we use AI', 'AI use case ideas for my team', 'how are other companies using AI'. Do not trigger for validating a brand-new product idea (route to `biz-council`) or for designing a persistent AI worker/agent (route to `agent-builder`) — this skill is about finding and ranking adoption opportunities, not building or validating one."
allowed-tools:
  - Read
  - Write
  - Bash
  - WebSearch
  - WebFetch
  - AskUserQuestion
---

# ai-adoption-scout

Most "how could we use AI more" conversations either recite the same three generic examples (chatbot, summarizer, image generator) from the model's training data, or jump straight to building something without checking what's actually working elsewhere first. This skill grounds the ideation step in real, dated usage signal before mapping it onto the user's specific context.

## Attribution

No new heavy dependency — composes engines already present in this workspace:

- **last30days** — [github.com/mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill), MIT license (already documented in `ATTRIBUTION.md`'s Shared runtime dependencies table). Reused as-is in Step 1, same resolution/clone pattern as `biz-council`/`curator` Step 1 — not re-described here. Same Windows source-coverage gap applies (see `USAGE.md#biz-council`).
- **design-report** — this workspace's own skill, not an external dependency. Step 3 hands off structured findings to it rather than reimplementing document formatting.
- Named usage reports (Anthropic Economic Index, Comscore AI Intelligence Report, etc.) are not a fixed dependency — they're fetched live via WebSearch each run since usage-share data changes monthly; cite the specific report and check date every time, per LAW 0, rather than treating a number from an earlier session as still current.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: What's actually happening — real signal, not recall

Two parallel sources, both required:

1. **`last30days`** — resolve and run it exactly as `biz-council` Step 1 does (find `LAST30DAYS_SKILL_DIR` under `~/Desktop/skills`, `~/.claude/skills`, etc.; offer to clone if missing). Scope the query to AI-usage discussion in the user's stated domain/industry, not a generic "AI news" sweep.
2. **WebSearch** — search for named, dated usage reports (Anthropic Economic Index, OpenAI/Comscore/industry-analyst usage stats) relevant to the user's domain. Every stat carries the source name and the check date; a number with neither is a LAW 0 violation, not a fact.

If both sources come back thin for the stated domain, say so and widen to the adjacent, better-covered category rather than inventing specificity that isn't there — tag as `[LOW-EVIDENCE]` if the user explicitly wants to proceed anyway.

## Step 2: Map to the user's actual context

Do not proceed to ranking until the user has stated (ask via AskUserQuestion if not already given):

1. **The concrete task/team/business** this is for — not "my company" broadly, the actual workflow or role.
2. **What's already in place** — existing tools, data, and any AI usage already happening, so ideas don't duplicate it.
3. **What's off the table** — cost ceiling, data-sensitivity constraints, tooling the user has already ruled out.

For each real pattern Step 1 surfaced, state:
- The specific adoption idea, named plainly (not "leverage AI for synergy")
- Why it fits *this* context (ties back to item 1/2/3 above, not generic reasoning)
- A feasibility rank: **ready now** (existing tools/data cover it) / **needs setup** (a tool or data source must be added first) / **needs more evidence** (Step 1 signal was thin for this specific angle)

Present 3-5 ranked ideas, not an unranked list — per this workspace's LAW 1 discipline of ranking candidates with reasons rather than a single unexplained pick.

## Step 3: Stakeholder document (only if requested)

If the user wants to pitch this to a team or decision-maker, hand the ranked findings from Step 2 (with Step 1's cited evidence) to `design-report` for DOCX/PPTX formatting — see `../design-report/SKILL.md`. Do not build a document pipeline here; that skill already owns formatting.

## Output

```
# AI Adoption Scout: {Domain/Team}

## What's Actually Happening (Step 1 evidence)
{Real items from last30days + named usage reports, cited with dates}

## Ranked Ideas For {Context} (Step 2)
1. {Idea} — {why it fits} — {ready now / needs setup / needs more evidence}
2. ...

## Next Step
{Stakeholder document via design-report, or direct next action}
```

---

## What this skill does not do

It does not validate whether a brand-new product/business idea is viable — that's `biz-council`'s job. It does not design or build a persistent AI worker/agent — that's `agent-builder`'s job (once an idea from this skill is picked and needs to become an actual running system, route there). It does not fabricate adoption examples when Step 1 comes back empty for the stated domain.
