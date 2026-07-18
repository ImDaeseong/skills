---
name: agent-builder
description: "Design a small, production-disciplined AI worker: explicit goal, context sources, tools/permissions, memory policy, and self-verification — then make an evidence-checked cloud-vs-local model routing call (Claude/frontier vs Ollama-backed local model). MANDATORY TRIGGERS: 'build me an agent for X', 'design an AI worker', 'should this run locally or in the cloud', 'daily briefing agent', 'local model for this task'. Fuses humanlayer/12-factor-agents (control-flow/context discipline) with a source-checked Ollama routing decision. Do not trigger on a single one-off prompt that doesn't need to run repeatedly or hold state/tools/permissions."
allowed-tools:
  - Read
  - Write
  - Bash
  - WebFetch
  - AskUserQuestion
---

# agent-builder

"Just write a prompt that loops" is not an agent design — it's a prototype that breaks the first time it hits an edge case. This skill refuses that shortcut: every worker it designs must have an explicit goal, a bounded context, a bounded tool/permission set, a stated memory policy, and a way to check its own output before finishing. Model choice (cloud vs local) is a checked decision, not a default.

## Attribution

This skill does not reimplement any of its references — it borrows methodology and rewrites it in its own words, or names a runtime tool directly without vendoring it.

- **12-factor-agents** — [github.com/humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents), 24,372★ (checked 2026-07-18 via GitHub API). License: GitHub's detector reports `NOASSERTION`, but the repo's actual `LICENSE` file (fetched and read directly, not from a secondary source) is **Apache License 2.0** — permissive, safe to reference and adapt with attribution. Control-flow and context-discipline principles referenced in Step 3, described in this skill's own words, not reproduced verbatim.
- **ollama** — [github.com/ollama/ollama](https://github.com/ollama/ollama), 176,339★ (checked 2026-07-18 via GitHub API), MIT license. Named directly as the local-model runtime option in Step 2 — this skill tells the user which command to run, it does not install Ollama or vendor its code.
- **crewAI** — [github.com/crewAIInc/crewAI](https://github.com/crewAIInc/crewAI), 55,700★ (checked 2026-07-18 via GitHub API), MIT license. Referenced only as the fallback pattern when a design needs more than one coordinated worker role — not required for single-worker designs, and not vendored.
- **Paperclip** — [github.com/paperclipai/paperclip](https://github.com/paperclipai/paperclip), 74,047★ (checked 2026-07-18 via GitHub API), MIT license (verified via GitHub API license endpoint and repo's own license badge). Primary reference for Step 5 (ongoing multi-agent operations) — org charts, budgets, goal alignment, and heartbeat-based scheduling for a team of agents. Works alongside OpenClaw/Claude Code/Codex/Cursor rather than replacing them.
- **Harbour** — [github.com/geekforbrains/harbour](https://github.com/geekforbrains/harbour), 188★ (checked 2026-07-18 via GitHub API), MIT license. Smaller, narrower alternative surfaced from a podcast case study (Andrew Wilkinson / Gavin Vickery, 2026-05-05) — a polling-based control plane where agents pull recurring jobs on their own schedule. Named here because it's what the source case study actually used, even though Paperclip has far more stars; note the gap honestly rather than pretending the smaller tool is the top-ranked pick.
- **AgentField** — [github.com/Agent-Field/agentfield](https://github.com/Agent-Field/agentfield), 2,362★ (checked 2026-07-18 via GitHub API), Apache-2.0 license. Secondary alternative when the priority is pure control-plane observability/auditability (agents as callable microservices) rather than Paperclip's org-chart/budget framing.
- **promptfoo** — [github.com/promptfoo/promptfoo](https://github.com/promptfoo/promptfoo), 23,368★ (checked 2026-07-18 via GitHub API), MIT license. Primary reference for the rubric + LLM-judge verification technique in Step 1.5 — its `llm-rubric` model-graded assertion is the maintained implementation this skill points to rather than describing from scratch. Evaluated alongside **deepeval** ([github.com/confident-ai/deepeval](https://github.com/confident-ai/deepeval), 16,919★, Apache-2.0) and **ragas** ([github.com/explodinggradients/ragas](https://github.com/explodinggradients/ragas), 14,885★, Apache-2.0) per LAW 1 — promptfoo ranked first by star count and directly matches the rubric terminology this technique uses.
- **OpenClaw/OpenClaw** — [github.com/OpenClaw/OpenClaw](https://github.com/OpenClaw/OpenClaw), **383,292★** (checked 2026-07-18 via direct GitHub HTML verification), MIT license — the largest repo cited anywhere in this workspace. Reference for Step 1.4's memory-consolidation ("Dreaming") technique: a periodic background pass that scores accumulated memory candidates and promotes only qualified ones to the durable file.
- **NousResearch/hermes-agent** — [github.com/NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent), 216,464★ (checked 2026-07-18 via direct GitHub HTML verification), MIT license. Named here as a factual correction, not a new methodology adoption: an earlier turn in this session assumed a video's "Hermes agent" was necessarily an unrelated proprietary product, by analogy to a different, separately-unverified "Hermes Desktop" product referenced even earlier. This repo shows that name space does include at least one real, massively-evidenced, MIT-licensed open-source agent platform (comparable in scope to OpenClaw) — a caution against assuming "sounds like a commercial product" without checking, in either direction.
- **safishamsi/graphify** — [github.com/safishamsi/graphify](https://github.com/safishamsi/graphify), 90,274★ (checked 2026-07-18 via direct GitHub HTML verification), MIT license. Reference for Step 1.4's knowledge-graph memory option — a Claude Code skill that turns any folder (code, notes, papers, screenshots) into a persistent, queryable graph rather than a flat log; its own README cites the exact "Karpathy's `/raw` folder" problem this option addresses, and claims 71.5x fewer tokens per query versus re-reading raw files (its own benchmark, not independently re-verified here).

---

## Core Laws

This skill follows `../_shared/CORE-LAWS.md` (LAW 0 no-speculation + tag vocabulary, LAW 1 evidence-ranked library selection, LAW 2 code-architecture-if-implemented). Read that file before running this skill for the first time in a session.

---

## Step 1: Define the worker — five fields, all mandatory

Do not proceed to Step 2 until all five are answered. If the user can't answer one, AskUserQuestion — do not invent a plausible-sounding default. Prefer multiple-choice questions over open-ended ones here: a concrete set of options is faster for the user to react to than a blank prompt, and narrows the field to something checkable in Step 2-3 rather than another vague answer. If the user has a lot of unstructured context rather than a clean answer to a specific question (their role, interests, existing tools, past attempts), let them dump it all in one go rather than forcing it through a Q&A sequence — then extract and structure the five fields from that dump yourself, and confirm the extraction rather than asking them to have organized it themselves first.

1. **Goal** — one sentence, one measurable outcome. Not "help with research," but "produce a 5-bullet daily briefing from three named sources by 8am."
2. **Context** — the exact sources the worker may read (named files, named APIs, named feeds). Never "everything it can find."
3. **Tools** — the exact actions the worker may take (e.g. "read this API, write to this file," not "full shell access"). Per 12-factor-agents: the tool list is a permission boundary, not a convenience list. When the action is "connect to an external app," pick the integration layer deliberately rather than defaulting to whichever is most familiar (framing surfaced from a Helena Liu Zapier SDK video, 2026-06-26): **no-code automation** (trigger→action platforms) for a simple, infrequent, human-supervised connection where the logic is one hop; **MCP** when the worker itself needs to discover and call the external tool's capabilities as part of its own reasoning loop; **a direct SDK/API integration** when the connection is high-volume, needs custom logic between the call and the result, or the no-code platform's trigger/action shape doesn't fit the actual need.
4. **Memory** — what persists across runs (a file, a DB row) versus what is scratch/session-only. State this explicitly; "the model will remember" is not a memory policy. For a persistent-memory file specifically, give the worker an explicit update trigger — e.g. "when the user corrects you, or you learn something that would change a future run, update the memory file" — rather than leaving updates to the model's judgment about when memory is worth writing; an unprompted memory policy tends to either never update or update on everything. For a worker running long enough to accumulate a high volume of memory entries, a raw append-only log degrades — add a periodic **consolidation pass** (see Attribution, OpenClaw's "Dreaming"): score accumulated short-term entries and promote only the qualified ones into the durable memory file, rather than keeping every entry at equal weight forever. If the memory source is a large, unstructured corpus (notes, papers, screenshots, past conversations — not a small flat log), a linear file stops working as a lookup structure; **build a queryable knowledge graph instead** (see Attribution, `graphify`) — persistent, structured, and re-queryable weeks later without re-reading the raw material.
5. **Verification** — how the worker checks its own output is correct before it finishes (a schema check, a re-read-and-compare, a second-pass critique) — not "trust the model's first answer." For output with a clear pass/fail (tests pass, code compiles), the exit condition is the check itself — nothing further to design here. For open-ended output with no objective completion criterion (a written brief, a design doc, a UI that has to "look right"), prefer a **rubric + separate LLM-judge pass** over a vague "look it over again": write explicit, weighted, checkable criteria, then have a distinct model call score against them — see Attribution (promptfoo) for a maintained implementation rather than hand-rolling the judge prompt from scratch each time. Where feasible, make the judge a genuinely different model/provider than the one that produced the output, not just a second pass of the same model — same-model self-review tends to share the same blind spots it's supposed to catch. Whatever the judge returns, it must be **specific enough for the builder to act on** ("the CTA button lacks contrast against the hero background" — not "needs polish") — a pass/fail verdict with no actionable reason stalls the loop instead of converging it. **A single judge call is noisy** — if the verification decision is high-stakes enough to be worth the extra cost, run the judge multiple times (varying temperature/top-p) and aggregate rather than trusting one sample; also don't assume a finer-grained scoring scale (0-100) is automatically more reliable than a coarser one (1-5) — scale choice affects judge consistency in practice, so if this matters, check which scale actually produces stable repeated scores for the task at hand rather than picking one by default.

## Step 2: Model routing — cloud vs local, checked not assumed

Decide per-task, not once for the whole workspace:

- **Route to a cloud/frontier model (Claude, etc.)** when the task needs long-context reasoning, multi-step tool use, or handles a task type the worker hasn't proven reliable on yet.
- **Route to a local model via Ollama** when the task is high-volume, low-latency, narrow (single well-defined transform), privacy-sensitive, or must run offline.

**Before recommending a specific local model, verify it actually exists** — do not name a model from memory. Run `ollama list` if Ollama is already installed locally, or WebFetch `https://ollama.com/library` to confirm the target model is currently published, and cite what was found. If neither check is possible, tag the recommendation `[ASSUMPTION - unverified, confirm with user]` per LAW 0 instead of stating a model name as fact.

If the worker needs more than one coordinated role (e.g., a researcher role feeding a writer role), note that as the point where a framework like crewAI (see Attribution) becomes relevant — do not build ad hoc multi-agent orchestration from scratch when a maintained one exists at that stars/license tier.

## Step 3: Control-flow discipline (from 12-factor-agents, rewritten)

Apply these to every worker design, regardless of cloud/local routing:

- **The application owns the loop, not the model.** Explicit stop conditions, a retry budget, and approval gates live in code/config around the model call — never left to the model to decide when to stop on its own.
- **Treat each run as stateless where possible.** Input state + a single event produces an output state; avoid relying on an ever-growing prompt history as the only place state lives — persist what actually needs to persist (Step 1.4) instead.
- **Curate context, don't dump it.** Full logs, full tool output, and full retrieved documents degrade reliability. Summarize, link back to the source, and only inline what the next step actually needs.
- **Human decisions are structured input, not a side channel.** If a human approval or correction changes the run, model it as an observable input the worker resumes from — not an out-of-band Slack message the worker never sees.

## Step 4: Write the worker design doc

```
# {Worker Name}: Agent Design

## Goal
{Step 1.1 — one sentence, measurable}

## Context Sources
{Step 1.2 — named list, not "everything"}

## Tools & Permissions
{Step 1.3 — named list, each with why it's needed}

## Memory Policy
{Step 1.4 — what persists, where, what's scratch-only}

## Verification Method
{Step 1.5 — how the worker checks its own output}

## Model Routing Decision
{Step 2 — cloud or local, which local model if any, and the check run to confirm it exists (or the [ASSUMPTION] tag if unchecked)}

## Control-Flow Notes
{Step 3 — stop conditions, retry budget, approval gates specific to this worker}

## Open Risks
{Anything Step 1-3 couldn't fully resolve}
```

## Step 5 (only when the worker isn't alone): Ongoing multi-agent operations

Steps 1-4 design and document one worker. If the user's actual need is several workers running continuously — recurring jobs, shared context, budgets, an audit trail, coordinated across roles (dev/marketing/support) — that is a different problem: an operations control plane, not a single worker's five fields. Don't force-fit it into Step 1.

1. Confirm this is really the need: is there more than one recurring role, and does work need to keep happening without a human re-triggering each run? If it's one worker on a schedule, a plain cron trigger plus Steps 1-4 is enough — don't add a control plane for a single job. Pick the trigger type deliberately, not by default: **cron** (fixed schedule, e.g. "every morning at 8am") for time-bound work; **heartbeat** (the worker polls in on its own interval, per Paperclip's own model) when the exact timing matters less than "eventually, regularly"; **hooks** (see `vibe-coder` Step 1) when the trigger is an event, not a clock — a file changed, a PR opened; **goal loop** (runs until a stated condition is met, not a fixed number of iterations or a clock) when completion is defined by an outcome, not a schedule — this is the hardest of the four to specify correctly, since a vague goal condition produces a loop that never terminates or terminates too early; the goal condition needs the same rigor as Step 1.5's verification criteria.
2. If a control plane is warranted, default to **Paperclip** (see Attribution) — highest-evidence pick (74,047★, MIT, actively maintained). It handles heartbeat-based scheduling, org-chart-style role assignment, budgets, and an audit trail, and works with whatever agent runtime (OpenClaw, Claude Code, Codex, Cursor) each role already uses.
3. If the priority is narrower (just polling-based recurring jobs, no budget/org-chart layer), **Harbour** is the lighter option — smaller and less battle-tested, say so if recommending it.
4. If the priority is agents-as-callable-microservices with strict observability/audit needs, **AgentField** is the alternative.
5. Whatever is chosen, each individual role still gets its own Step 1-4 design (goal, context, tools, memory, verification, model routing) — the control plane coordinates workers, it doesn't replace designing them.

---

## What this skill does not do

It does not install Ollama, pull models, or write the worker's actual source code unless the user explicitly asks for an implementation pass separate from the design doc (LAW 2 applies then — UI/logic separation, typed module boundaries, explicit success/failure returns). It does not fabricate a local-model name it hasn't checked exists.
