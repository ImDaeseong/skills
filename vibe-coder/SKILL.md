---
name: vibe-coder
description: "Workflow discipline for a human pair-programming with AI coding agents (Claude Code, Cursor, etc.) on their own project: route each task to the right tool/model by type, gate implementation behind a reviewed plan (Research → Plan → Execute → Review → Ship), keep library docs fresh via Context7, and don't call anything done without a verification + review pass. MANDATORY TRIGGERS: 'vibe coding workflow', 'how should I structure this coding session', 'plan mode', 'set up my coding agent workflow', 'which tool for this task'. This is a human's own interactive coding-session discipline — distinct from `agent-builder`, which designs autonomous business workers, not a live pair-programming loop. Do not trigger for a single small, obviously one-shot code edit that doesn't need a plan gate."
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# vibe-coder

"Just prompt it and see what happens" is how solo projects stall at 80% done with an unreviewable pile of code. This skill is not a coding tool itself — it does not write the application code. It's the discipline layer around whichever coding agent is doing the actual work: which tool handles which task, what has to happen before code gets touched, and what has to happen before anything is called finished.

## Attribution

This skill does not reimplement any of these — it composes their converging methodology (all five independently arrive at the same **Research → Plan → Execute → Review → Ship** shape) and names the one MCP tool worth calling out directly.

- **obra/superpowers** — [github.com/obra/superpowers](https://github.com/obra/superpowers), **256,647★** (checked [ASSUMPTION - unverified, confirm with user] via direct GitHub HTML verification), MIT license. Primary reference. Its convergent shape: brainstorm the real spec out loud → chunk the design for human review → write an implementation plan (TDD red/green, YAGNI, DRY) → subagent-driven execution with inspection at each step → verification before completion → code review → finish the branch.
- **affaan-m/everything-claude-code** — [github.com/affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code), 230,675★ (checked [ASSUMPTION - unverified, confirm with user]), MIT license. Secondary reference (plan → PRD → implement → code review → build-fix → e2e testing → PR) — largest by agent/command/skill count (67/139/278), useful when a task needs one of its more specialized commands rather than superpowers' leaner set.
- **mattpocock/skills** — [github.com/mattpocock/skills](https://github.com/mattpocock/skills), 175,644★ (checked [ASSUMPTION - unverified, confirm with user]), MIT license. Tertiary reference — spec → tickets → TDD → prototype → bug diagnosis → implement → code review → architecture improvement; useful for its explicit `diagnosing-bugs` and `improve-codebase-architecture` steps that the other two don't name separately.
- **github/spec-kit** — [github.com/github/spec-kit](https://github.com/github/spec-kit), 121,999★ (checked [ASSUMPTION - unverified, confirm with user]), MIT license. GitHub's own official spec-driven-development toolkit (`/speckit.specify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.implement`) — reference when a project wants a more formal, checkpointed spec artifact than superpowers' conversational chunking produces.
- **upstash/context7** — [github.com/upstash/context7](https://github.com/upstash/context7), 59,283★ (checked [ASSUMPTION - unverified, confirm with user]), MIT license. The MCP server this skill names for Step 4 (keeping library docs current) — named directly in the podcast source (Chris Raroque, 2025-12-02) as "Context 7." Not installed by this skill; the user configures it as an MCP server if they want it.
- **shanraisshan/claude-code-best-practice** — [github.com/shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice), 62,989★ (checked [ASSUMPTION - unverified, confirm with user]), MIT license. Primary reference for Step 1's four harness components (its own CONCEPTS table names Commands/Rules/Skills/Hooks/MCP as the distinct building blocks) — beyond just the discovery-path role credited elsewhere in this file.
- **DietrichGebert/ponytail** — [github.com/DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail), 85,215★ (checked [ASSUMPTION - unverified, confirm with user]), MIT license. Reference for Step 3's YAGNI emphasis — a dedicated, measured skill for minimal-code discipline ("the best code is the code you never wrote"; ~54% less code on average, up to 94%, per its own benchmark against a fair agentic baseline — cited as its claim, not independently re-verified here).
- **JuliusBrussee/caveman** — [github.com/JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman), 90,347★ (checked [ASSUMPTION - unverified, confirm with user]), MIT license. Reference for Step 4's output-token economy — cuts reply verbosity (~65% fewer output tokens per its own benchmark) while keeping code/commands/errors byte-exact; distinct from Context7 (which is about input-context freshness, not output length).

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full. If the active project has an `AGENTS.md` or equivalent with stricter verification rules, follow those too; otherwise LAW 3 supplies the complete verification-loop, evidence, regression-guard, and HOLD contract. The steps below add task-to-tool routing, plan-gate mechanics, and the specific tools (Context7, git worktrees) that implement the discipline.

## Step 1: Build the harness deliberately (once per project, not once per task)

"Harness" is the environment scaffolding around the model — per `claude-code-best-practice` (see Attribution), it decomposes into four distinct building blocks. Set these up deliberately rather than letting them accumulate ad hoc:

- **Commands** — reusable prompt templates for a repeated request shape (`.claude/commands/<name>.md` or equivalent). If the same multi-paragraph prompt gets typed more than twice, it should be a command.
- **Rules** — the persistent context/constraints file (`CLAUDE.md`/`AGENTS.md`) loaded every session — see Step 3.1 below, this is where "read existing project context first" comes from.
- **Skills** — packaged, triggerable procedures for a recurring workflow shape (this very file is one) — reach for a skill over a command when the procedure has multiple steps/branches, not just a filled-in template.
- **Hooks** — enforcement that doesn't depend on the model remembering to do something (e.g. a pre-commit check, a guard against editing a protected path) — use a hook, not a rule-file reminder, for anything that must never be skipped; a rule can be forgotten, a hook can't be.

**Start small and scale in steps** — don't try to build all four at once for a new project. Add a command when you notice repetition, a hook when you notice a rule getting silently ignored, a skill when a command's single template stops covering the branching the task actually needs. A harness built incrementally against real friction beats one designed upfront against imagined friction.

## Step 2: Route the task to the right tool/model before starting

Don't default to one tool for everything. Classify the task first:

- **Broad architecture, new scaffolding, or anything where getting the shape right matters more than speed** — route to the most capable model available, in plan mode, before any code is written.
- **A gnarly multi-step bug, or a change that touches many files in ways that are hard to hold in your head** — route to whichever available agent has the strongest plan-mode/diff-review loop for that kind of change; don't brute-force it with a single large prompt.
- **UI/animation/visual micro-iteration** — route to whichever tool gives the fastest look-tweak-look loop (live preview, screenshot-in-the-loop); this is a different bottleneck (visual judgment, not logic) than the other two.

If unsure which category a task falls in, ask (AskUserQuestion) rather than guessing — the classification determines the next three steps.

## Step 3: Plan gate — nothing gets implemented without a reviewed plan first

Per the converged shape across all four primary references (see Attribution):

1. **Read existing project context first** (`CLAUDE.md`/`AGENTS.md`, any prior plan artifact from a previous Step 3 run) — a plan written without checking what's already established repeats decisions or contradicts them. Get the real spec out loud next — what is this actually trying to do, not just the literal request text.
2. Chunk the design into review-sized pieces the user can actually read and sign off on — not one giant unreadable plan dump.
3. Write the implementation plan explicitly emphasizing **TDD (red/green)**, **YAGNI**, and **DRY** — these three constraints are what keep an autonomous multi-hour execution run from drifting.
4. Do not start execution until the user has signed off on the plan. A plan nobody reviewed is not a gate, it's a formality.

## Step 4: Execution discipline

- **Keep docs current via Context7** (see Attribution) if configured — an agent working from stale training-data knowledge of a library's API is a common, avoidable failure mode. Check whether it's actually set up as an MCP server before assuming it's available; if not, say so rather than silently proceeding on possibly-outdated API assumptions.
- **Run long-lived processes (dev servers, watchers) as background tasks** so the agent can read logs directly during debugging instead of the user copy-pasting terminal output back and forth.
- **Use git worktrees to isolate parallel work streams** when more than one task is running concurrently — prevents one in-flight change from corrupting another's working tree.
- **Subagent-driven execution with inspection at each step**, not one uninspected end-to-end run — per superpowers' model, review happens as each engineering task completes, not only at the very end.
- **Keep replies terse once the plan is approved** (see `caveman`, Attribution) — full prose explanations of every edit cost output tokens for no benefit once the human has already signed off on the plan; code, commands, and error text stay byte-exact, only the surrounding narration shrinks.

## Step 5: Verification + review gate before calling anything done

Run LAW 3's verification loop and any stricter active-project rules. Also run an actual code-review pass (self-review against the plan from Step 3, or an available AI review tool) before the branch is considered finished, not just "tests pass." A green test suite and a reviewed diff are different checks; both are required.

## Output

When this skill runs at the start of a coding session, it should produce a short plan artifact (following Step 3) — a markdown checklist naming the task classification (Step 2), the chunked design, and the TDD/YAGNI/DRY-constrained implementation steps — for the user to sign off on before any code is touched.

---

## What this skill does not do

It does not write the application code itself — that's the coding agent's job once the plan is approved. It does not install Context7, superpowers, or any of the referenced plugins; it names them and lets the user install what they want. It follows LAW 3 by default and layers any stricter active-project verification rules on top.
