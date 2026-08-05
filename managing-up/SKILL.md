---
name: managing-up
description: "Draft a message to your manager/lead when you need to push back on a deadline, surface a technical risk, or negotiate scope — built on Gabarro & Kotter's 'Managing Your Boss' (HBR) and Frei's critique of solutions-only reporting, not a copy-pasted template. Produces trade-off options with numbers, translated into business-impact terms, instead of a flat refusal. MANDATORY TRIGGERS: '팀장한테 어떻게 말해야', '매니징 업', 'managing up', '일정 조정 요청', '상사 설득', 'convince my manager', 'push back on this deadline', 'how do I tell my boss', 'trade-off options for my manager', '기술부채 설득'. Do not trigger for general workplace conflict unrelated to a specific request/decision needing your manager's sign-off, or for peer-to-peer (non-hierarchical) negotiation — see `writing` for general tone/voice editing instead."
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

# managing-up

Help drafting a message to a manager/lead about a specific decision — an unrealistic deadline, a scope change, a technical risk that needs sign-off. The goal is a message the manager can act on (a decision to make), not a complaint or a template filled with placeholders.

## Attribution

- **Gabarro, J. J. & Kotter, J. P., "Managing Your Boss," Harvard Business Review** (originally 1980, republished as an HBR Classic 2005) — [hbr.org/2005/01/managing-your-boss](https://hbr.org/2005/01/managing-your-boss). Primary source for the core premise: the manager-report relationship is mutual dependence, not one-way authority — your manager needs your reliability and honest information as much as you need their resources and priority-setting.
- **"Figure Out Your Manager's Communication Style," Harvard Business Review, 2015** — [hbr.org/2015/07/figure-out-your-managers-communication-style](https://hbr.org/2015/07/figure-out-your-managers-communication-style). Basis for Step 1 (read the manager's actual decision style before drafting, not a generic register).
- **Frances Frei (Harvard Business School), cited in "The Problem with Saying 'Don't Bring Me Problems, Bring Me Solutions,'" Harvard Business Review, 2017** — [hbr.org/2017/09/the-problem-with-saying-dont-bring-me-problems-bring-me-solutions](https://hbr.org/2017/09/the-problem-with-saying-dont-bring-me-problems-bring-me-solutions). Important correction this skill applies: demanding "solutions only" from yourself before you're allowed to raise a problem can suppress early warning signs. The message this skill drafts surfaces the problem *and* options — it does not wait until a fully-baked single solution exists before saying anything.
- Technical-debt-to-business-impact framing (mapping engineering risk to velocity/reliability/security/cost terms a non-engineering manager can act on) is a widely used industry practice, not a single peer-reviewed finding — see Jellyfish, "Effective Strategies for Communicating the Business Impact of Engineering" ([jellyfish.co/blog/communicating-the-business-impact-of-engineering](https://jellyfish.co/blog/communicating-the-business-impact-of-engineering)) and arXiv:2505.13009 "Reframing Technical Debt" for the general framing `[LOW-EVIDENCE]` on any specific numeric claim from these — treat the *framing* as well-attested, not any specific number quoted in them.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full. Especially LAW 0: do not present a made-up statistic about "managing up" as fact (a "88% of professionals" style claim from an unverified survey is exactly the kind of unlabeled number LAW 0 exists to block — cite a real, checkable source or tag `[LOW-EVIDENCE]`).

## Step 1: Get the actual situation, not a hypothetical

Ask (AskUserQuestion) for these four things if not already given — do not draft from a placeholder:

1. **Current situation** — what triggered this (a sudden request, a discovered risk, a deadline that's now unrealistic).
2. **Real technical/operational risk** — specific and checkable, not vague ("결제 모듈 검증 부족" is fine; "품질이 떨어질 것 같다" alone is not — ask what the actual failure mode is).
3. **Desired outcome** — what decision you want your manager to make.
4. **Your manager's actual current pressure** — per Gabarro & Kotter, you need a real understanding of what your manager is accountable for this cycle, not a guess. If the user doesn't know, say so plainly and draft around the acknowledged gap (do not invent a plausible-sounding KPI on their behalf — that would be exactly the fabrication LAW 0 blocks).

## Step 2: Draft trade-off options, not a refusal

Per Frei's critique above, do not draft a flat "this isn't possible" message. Draft 2-3 concrete options, each with the actual cost/risk stated in numbers where the user has them (days, error-budget, headcount) — not vague terms like "significant risk." A message with one option is a request for permission; a message with real trade-offs is a request for a decision, which is the difference this skill is actually for.

Structure:
- Open by naming the shared goal in the manager's own terms (Step 1's item 4) — this is not flattery, it's establishing that the message is solving the manager's problem too, per the mutual-dependence premise in Gabarro & Kotter.
- State the risk plainly, with the specific failure mode from Step 1 item 2.
- Present the options with real trade-offs attached to each.
- End with a specific ask the manager can answer in one line (not "let me know what you think").

## Step 3: Check before sending

This skill drafts a message; it does not send one. Before treating a draft as final:

- Every number in the draft must trace back to something the user actually stated in Step 1 — if a number got invented to make the draft sound more concrete, remove it or ask.
- Read the draft once for tone: per Frei, this should read as "here's a decision I need from you," not as a complaint or an implicit threat to quit/underperform.

## What this skill does not do

It does not fabricate your manager's KPIs, your team's velocity numbers, or a "percentage of professionals who agree" statistic to make a draft sound more persuasive — every claim in the output must come from the user or a cited source above. It does not handle general workplace conflict unrelated to a specific decision (interpersonal friction, performance reviews) — that is outside a communication-drafting skill's scope. It does not send the message on the user's behalf.
