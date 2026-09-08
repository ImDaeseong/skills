---
name: pm-delivery-ops
description: "Run day-to-day product management operations — write Jira-ready tickets/stories with acceptance criteria, prioritize a backlog against a stated metric, run a metrics review, and collaborate with a Figma-based design system without drifting from it. MANDATORY TRIGGERS: 'write this as a Jira ticket', 'prioritize the backlog', 'backlog grooming', 'sprint planning', 'metrics review', 'PRD for this feature', 'design system 준수 확인', 'Figma 디자인 리뷰 체크리스트', 'PM 업무 정리'. Methodology and templates only — does not connect to a live Jira/Figma account or MCP server; for that, use Jira's/Figma's own official MCP integration directly. Distinct from `biz-ops` (financial/commercial/vendor operations for an existing business, not product delivery) and `managing-up` (a single message to a manager, not a recurring workflow)."
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

# pm-delivery-ops

Recurring product-manager operations — the work that happens between "we validated this idea" (`biz-council`'s job) and "we're running the business" (`biz-ops`'s job): turning a problem into a ticket, deciding what's next in the backlog, reading a metrics review, and keeping a feature honest against its design system. This skill packages that recurring work as templates and checklists, not a live integration.

## Attribution

- **alirezarezvani/claude-skills** — [github.com/alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) (same dependency `biz-ops` already uses; re-confirmed 2026-09-06 per `../_shared/DEFERRED.md`'s ERP/SCM re-search entry — 25,577 stars, MIT). **Primary reference for ticket/backlog mechanics.** Its `project-management` category ([github.com/alirezarezvani/claude-skills/tree/main/project-management](https://github.com/alirezarezvani/claude-skills/tree/main/project-management)) ships `jira-expert` (JQL, workflows, automation), `scrum-master`, `senior-pm`, and `confluence-expert` — this skill routes ticket-writing and sprint-mechanics requests there rather than reimplementing Jira/Atlassian conventions from scratch, same discipline as `biz-ops` → Finance/Commercial/Business-Operations.
- **Figma's own design-system guidance** — [figma.com/resource-library/claude-skill-design-system](https://www.figma.com/resource-library/claude-skill-design-system/) (checked 2026-09-09) confirms Figma itself now publishes Claude-skill guidance for design-system consistency, but its worked skills (`figma-use`, `figma-generate-library`, `figma-code-connect`) require the Figma MCP server and a live file connection — out of scope here by design (methodology-only, no MCP). This skill's Figma-collaboration section is original content: a PM-side review checklist for staying inside an existing design system, not a wrapper around Figma's own MCP skills. If a request actually needs Figma file access, say so and point to Figma's official MCP guide rather than improvising a fake connection.
- No dominant, permissively-licensed Jira+Figma combined "PM toolkit" skill was found as a single package (candidates surfaced during research — `deanpeters/Product-Manager-Skills` — carry CC BY-NC-SA 4.0, NonCommercial, and fail CORE-LAWS LAW 1's license gate outright regardless of content quality). Splitting the ticket-mechanics half (alirezarezvani, MIT) from the design-collaboration half (original, Figma-doc-informed) avoids that license trap rather than adopting a single mismatched package.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 1: Classify the request

Ask (AskUserQuestion) if not already clear:

1. **Ticket writing** — turning a problem/feature into a Jira-ready story (title, user story, acceptance criteria, priority)? → Step 2.
2. **Backlog prioritization** — deciding what's next across several candidate items? → Step 3.
3. **Metrics review** — reading a set of numbers to decide what changed and what to do about it? → Step 4.
4. **Design-system collaboration** — checking a feature/ticket stays consistent with an existing Figma design system before it ships? → Step 5.

A request can span more than one (e.g. a PRD usually needs ticket writing + a metric to measure against) — sequence them rather than forcing a single answer.

## Step 2: Write a Jira-ready ticket

Structure every ticket the same way, regardless of who eventually files it in Jira:

- **Title** — verb-first, scoped to one outcome ("Add CSV export to transaction history", not "Export improvements").
- **Problem** — one sentence: who hits this, and what breaks or is missing today. Not the solution yet.
- **User story** — "As a [role], I want [capability], so that [outcome]." If the role or outcome can't be named, the ticket isn't ready to write yet — ask instead of guessing.
- **Acceptance criteria** — a checklist of concrete, testable conditions (Given/When/Then works well), not a restatement of the user story. A ticket with no acceptance criteria is the single most common Jira-hygiene gap `alirezarezvani/claude-skills`' `jira-expert` flags — don't reproduce it here.
- **Priority + sizing signal** — carry whatever scale the team actually uses (P0-P3, T-shirt size, story points); don't invent a new scale mid-ticket.
- For JQL, automation rules, or bulk ticket operations specifically, route to `alirezarezvani/claude-skills`' `jira-expert` rather than hand-deriving JQL syntax from memory.

## Step 3: Prioritize the backlog against a stated metric

Refuse to prioritize against vibes. Before ranking anything:

- Name the metric this backlog is supposed to move (activation, retention, a specific funnel step, a compliance deadline). If none is named, ask — a backlog ranked with no target metric is arbitrary and will be re-litigated later.
- For each candidate item, state its expected direction and rough size of effect on that metric, and its cost (eng-weeks, cross-team dependency, regulatory review time) — even a rough T-shirt-size estimate beats no estimate.
- Rank by effect-to-cost, not by whoever asked most recently or most loudly (recency/loudness bias is the concrete failure mode this step exists to block).
- Surface items that are cheap-and-blocking (a small fix that's gating something bigger) even if their own metric impact looks small — sequencing matters, not just individual item score.

## Step 4: Run a metrics review

- State the metric, the time window, and the comparison baseline (prior period, target, cohort) — a number with no baseline isn't a finding.
- Separate "what changed" (the observation) from "why it changed" (the hypothesis) from "what to do" (the action) — don't collapse these into one sentence; a wrong hypothesis quietly baked into the stated fact is how a metrics review misleads a room.
- Flag a metric that moved but has no attached hypothesis yet as open, not resolved — per CORE-LAWS LAW 0, don't state a causal story with no evidence behind it.

## Step 5: Design-system collaboration checklist (Figma, no MCP)

For a PM reviewing whether a feature stays inside an existing design system, without connecting to Figma directly:

- Ask the designer (or read the design doc) which existing components this feature is supposed to reuse before assuming a new component is needed — a new component request is a real cost (design + eng + a design-system maintenance burden going forward), not a free choice.
- Check the request states which design tokens (spacing, color, type scale) it inherits vs. overrides — an override with no stated reason is a design-system drift signal worth flagging back to the designer, not silently accepting.
- If the request genuinely needs live Figma file access (reading actual component specs, syncing tokens, generating from a live file), say so explicitly and point to Figma's own MCP guide ([figma.com/resource-library/claude-skill-design-system](https://www.figma.com/resource-library/claude-skill-design-system/)) rather than fabricating what a Figma file contains — per CORE-LAWS LAW 0.

## What this skill does not do

It does not connect to a live Jira or Figma account — no API calls, no MCP server, no assumption about what a real ticket or file currently contains. It does not validate whether a product/feature should exist at all (`biz-council`) or run the financial/vendor/commercial side of an existing business (`biz-ops`). It does not draft a single message to a manager about one decision (`managing-up`) — this is the recurring operational workflow, not a one-off communication.
