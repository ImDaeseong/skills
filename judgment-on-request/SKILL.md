---
name: judgment-on-request
description: "Evaluate a user's opinion, proposal, or decision by running a full step-by-step judgment internally (hypothesis, counter-argument, evidence check, confidence), but answer with only the verdict and its single strongest reason — then unpack the full reasoning chain, one layer deeper each time, only when the user actually asks why. MANDATORY TRIGGERS: '이거 어떻게 생각해', '내 의견 어때', '판단해줘', '왜 그렇게 생각해', '근거는', '확신도는', 'what do you think of this', 'judge this idea', 'why do you think that', 'what's your reasoning'. Do not trigger when the user already asked for full step-by-step reasoning up front (route to `prompt-craft`'s CoT guidance instead) or when the task needs several independent expert viewpoints in parallel (route to `committee`)."
allowed-tools:
  - Read
---

# judgment-on-request

## Attribution

No existing GitHub repo or Claude skill implementing this exact answer-first / disclose-on-request pattern was found (WebSearch checked 2026-09-19: "on-demand reasoning disclosure", "lazy chain of thought" — no matching repo or skill). The pattern itself is not new — it is a specific packaging of two separately-documented ideas, cited here instead of claimed as invented:

- **Answer-first, on-demand rationale disclosure** — a presentation format studied directly in "Seeing the Reasoning: How LLM Rationales Influence User Trust and Decision-Making in Factual Verification Tasks" (CHI 2026 Extended Abstracts) — [dl.acm.org/doi/10.1145/3772363.3798613](https://dl.acm.org/doi/10.1145/3772363.3798613). That study found users prefer a summary-first answer with reasoning expandable on demand, and use it mainly to audit outputs and calibrate trust — not that disclosure format itself changes trust outcomes.
- **Progressive disclosure** — the general UX/agent-design principle of surfacing only what's needed now and revealing detail on request — [uxtigers.com/post/progressive-disclosure](https://www.uxtigers.com/post/progressive-disclosure), and its application to agent skill loading — [mindstudio.ai/blog/progressive-disclosure-ai-agent-skill-design](https://www.mindstudio.ai/blog/progressive-disclosure-ai-agent-skill-design).

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## What this skill is for

The user states an opinion, a proposed decision, or a plan and wants Claude's judgment on it — not a request to think out loud from scratch. This differs from `prompt-craft`'s Chain-of-Thought guidance (always-visible steps) and from `committee` (multiple parallel expert personas): here there is one evaluator, its reasoning is real but hidden by default, and the user controls how much of it gets unpacked.

## Step 1: Form the full judgment, silently

Before answering, actually run the evaluation — do not skip straight to a verdict:
1. State the claim/proposal in one line.
2. Form a verdict (agree / disagree / conditional) and identify the single strongest reason for it.
3. Raise at least one counter-argument against your own verdict.
4. Check whether the verdict depends on any unverified factual claim — if so, verify it with a tool call or tag it per LAW 0 before using it as a reason.
5. Assign a rough confidence (high / medium / low) and note what evidence would change it.

## Step 2: Answer with the verdict only

Reply in 1-3 sentences: the verdict plus its single strongest reason. Do not list the counter-argument, the full chain, or the confidence level unless asked — a dump-everything answer defeats the purpose of this skill and is just standard CoT.

## Step 3: Unpack one layer at a time, only when asked

- Asked "why" / "근거는" / "explain" → reveal the reasoning chain from Step 1 (hypothesis → evidence → conclusion), still without the counter-argument or confidence unless asked further.
- Asked "확신도는" / "how sure" / "what would change your mind" → reveal the counter-argument and confidence level, and what evidence would flip the verdict.
- Never fabricate a deeper layer that wasn't actually formed in Step 1 — if the silent judgment didn't consider something the user asks about, say so and evaluate it now rather than backfilling a rationale.

## What this skill does not do

It does not replace `committee` when the user genuinely wants several independent expert perspectives compared side by side. It does not apply when the user already asked for visible step-by-step reasoning up front — respect that request plainly instead of hiding it. It does not skip Step 1's actual evaluation to save time — the verdict in Step 2 must come from a real judgment already formed, not be invented after the fact to match whatever gets unpacked later.

## Evaluation scenarios

1. User: "이 프로젝트에 마이크로서비스로 쪼개는 거 어때?" → reply is a short verdict + top reason (e.g. "지금 팀 규모론 시기상조예요 — 배포 복잡도가 먼저 늘어납니다"), not a 5-step breakdown.
2. Same session, user: "왜 그렇게 생각해?" → reply unpacks the reasoning chain (team size → ops overhead → evidence), still no confidence/counter-argument yet.
3. Same session, user: "확신도는? 반대 의견도 있어?" → reply gives confidence level, the counter-argument from Step 1, and what would change the verdict (e.g. "만약 배포 자동화가 이미 갖춰져 있다면 결론이 달라집니다").
