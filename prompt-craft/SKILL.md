---
name: prompt-craft
description: "Write or improve a standalone prompt for ChatGPT/Claude/Gemini (or any LLM) — pick the right technique (zero-shot, few-shot, chain-of-thought, ReAct, structured output) for the task, and check the target model's own current prompting guidance before applying a technique that may be outdated, since what worked for GPT-4-era models is not always what a 2026 frontier model needs. MANDATORY TRIGGERS: 'write me a better prompt', 'how do I prompt X', 'prompt engineering', 'improve this prompt', 'system prompt for X', 'best way to prompt ChatGPT/Claude/Gemini', 'why isn't my prompt working'. Distinct from `agent-builder` (designs a persistent autonomous worker's full five-field spec, not a single ad-hoc prompt) and `vibe-coder` (coding-session workflow discipline, not general prompt craft for any task)."
allowed-tools:
  - Read
  - Write
  - Edit
  - WebFetch
  - WebSearch
  - AskUserQuestion
---

# prompt-craft

A prompt written for a 2023 GPT-4-era model and one written for a 2026 frontier model are not the same artifact — techniques that used to matter (heavy role-play framing, explicit "let's think step by step" scaffolding) are now often baseline behavior, while newer capabilities (huge context windows, native tool-calling, extended thinking budgets, grounding-with-search) open technique options that didn't exist before. This skill picks a technique deliberately for the task at hand, and treats "check the model's own current docs" as a mandatory step, not an optional nicety — a static technique catalog is a starting point, not the last word, on any model released after the catalog was last updated.

## Attribution

- **dair-ai/Prompt-Engineering-Guide** — [github.com/dair-ai/Prompt-Engineering-Guide](https://github.com/dair-ai/Prompt-Engineering-Guide), **76,772★** (checked 2026-07-21 via GitHub API), MIT license (verified via the API's license endpoint), last pushed 2026-03-11. Primary reference by a wide margin over any other candidate found. Model-agnostic technique catalog — zero-shot, few-shot, chain-of-thought, self-consistency, tree-of-thoughts, ReAct, prompt chaining, retrieval-augmented generation, meta-prompting, and adversarial/prompt-injection-defense patterns — this skill routes to its actual technique pages rather than reproducing them verbatim.
- **Jeffallan/claude-skills** (`skills/prompt-engineer/SKILL.md`) — [github.com/Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills), 10,663★ (checked 2026-07-21 via GitHub API), MIT license, last pushed 2026-05-20. Secondary reference, already in Agent Skills format — its 5-step core workflow (draft → test → measure → diagnose failure patterns below an 80%-accuracy checkpoint → iterate, rather than blind re-drafting) and its structured-output guidance (JSON mode, function calling, schema design) are the parts this skill borrows; its model-specific per-vendor detail lives in reference files this skill did not fetch, so treat that specific claim as `[LOW-EVIDENCE]` until read directly.
- **brexhq/prompt-engineering** — [github.com/brexhq/prompt-engineering](https://github.com/brexhq/prompt-engineering), 9,564★ (checked 2026-07-21 via GitHub API), MIT license — evaluated, **not adopted**: last pushed 2023-10-23, roughly three years stale as of this check, predating the current model generation this skill needs to stay current against.
- **Vendor-official prompting docs** (Anthropic, OpenAI, Google) — not GitHub repos, cited as the freshness authority Step 2 requires: none of the GitHub guides above update on the same cadence as a new model release, so a request naming a specific current model must be checked against that vendor's own current docs before trusting a technique's continued relevance, per this workspace's existing LAW 0 discipline (verify directly, don't trust a secondary source's age-unstated claim).

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 1: Classify the request

Ask (AskUserQuestion) if not already clear:

1. **Target model(s)** — a specific one (which family/version), several, or model-agnostic? This determines whether Step 3's vendor-specific pass is needed at all.
2. **New prompt or an existing one that's underperforming?** An existing prompt routes straight to Step 4's diagnosis step instead of starting from Step 2's technique selection.
3. **What does "working" mean here** — a single best-effort answer, a structured/parseable output (JSON, a function call), or a multi-step tool-using task? This picks the technique family in Step 2.

## Step 2: Pick the technique deliberately, not by default

Match the task shape to a technique rather than reaching for chain-of-thought by habit (see Attribution, dair-ai):

- **Simple, well-specified task** → zero-shot first. Adding examples or reasoning scaffolding to a task the model already handles zero-shot wastes tokens without improving the answer.
- **Task needs a specific format/style the model won't infer on its own** → few-shot with 2-3 examples, not more — diminishing returns and higher token cost past that.
- **Multi-step reasoning, math, or anything with an intermediate-logic failure mode** → chain-of-thought; for a genuinely hard reasoning task where a single CoT pass is unreliable, self-consistency (sample multiple CoT paths, take the majority answer) or tree-of-thoughts (explore/backtrack across branches) — heavier and slower, reserve for tasks where a single pass demonstrably fails first.
- **Task needs the model to call tools and react to results mid-task** → ReAct-style interleaved reasoning+action, not a single-shot prompt describing all steps upfront — see `agent-builder` if this is actually a persistent worker rather than a one-off prompt.
- **Output must be machine-parseable** → JSON mode or function/tool-calling with an explicit schema (see Attribution, Jeffallan) rather than asking for JSON in prose and hoping the model's formatting holds.

## Step 3: Check model-specific current guidance before finalizing

**Do not skip this step when a specific current model is named.** A technique that was necessary for an older model generation can be redundant, ineffective, or actively counterproductive for a newer one, and neither GitHub guide above updates fast enough to be trusted blind for a model released after its last commit (dair-ai: 2026-03-11; Jeffallan: 2026-05-20). WebFetch or WebSearch the vendor's own current prompting documentation for the named model family before finalizing:

- **Claude** — check Anthropic's own prompt-engineering docs directly (not a secondary summary) for current guidance on system-prompt structure, XML-tag-based structuring, prefill usage, and extended-thinking/budget controls where relevant.
- **GPT** — check OpenAI's own current guidance for system-message conventions and structured-output/function-calling schema requirements for the specific model version named.
- **Gemini** — check Google's own current guidance, including long-context usage patterns and search-grounding options where the task benefits from real-time information.

If the request doesn't name a specific model, skip this step and note the prompt is model-agnostic rather than guessing which vendor's quirks to apply.

## Step 4: For an underperforming existing prompt, diagnose before rewriting

Per Jeffallan's workflow checkpoint (see Attribution): don't jump straight to a blind rewrite. Ask what the actual failure looks like — wrong format, wrong reasoning, missing constraint, inconsistent across runs — and fix that specific failure mode with the matching technique from Step 2, rather than adding unrelated scaffolding hoping something sticks. For a prompt whose quality needs to be checked systematically across many variants rather than eyeballed once, `agent-builder`'s Step 1.5 rubric-plus-LLM-judge pattern applies here too — reuse it rather than re-deriving a scoring method from scratch.

## Step 5: Deliver

Give the finalized prompt, a short note on which technique(s) were applied and why, and — when Step 3 ran — which vendor doc was checked and its effective date, so the user knows how current the guidance is rather than assuming it's permanent.
