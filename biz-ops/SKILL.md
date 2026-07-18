---
name: biz-ops
description: "Run the back-office of an existing business with AI agent skills — financial analysis (DCF, budgeting, forecasting, SaaS metrics), commercial deal work (pricing, RFP response, partnerships, deal-desk), and business operations (vendor management, procurement, process mapping). MANDATORY TRIGGERS: 'build a DCF model', 'budget forecast', 'SaaS metrics', 'pricing strategy', 'respond to this RFP', 'vendor management', 'procurement', 'process map this workflow', 'business operations skill'. Distinct from `biz-council` (validates a *new* product/business idea against real user demand, one-time) and `distribution` (marketing/growth channels) — this is ongoing operational and financial work for a business that already exists. Do not trigger for founder personal cash-runway/burn-rate discipline or literal ERP/CRM software system integration — see 'Not yet built' in `../_shared/ROUTING.md` for why those are deferred separately."
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# biz-ops

A business that has moved past validating whether to exist (that's `biz-council`'s job) still needs someone doing the recurring work of running it — pricing a deal, building a forecast, managing a vendor relationship, responding to an RFP. This skill packages that recurring operational and financial work as AI agent skills rather than either reinventing each one from a blank prompt or reaching for enterprise software (SAP, Salesforce, NetSuite) this workspace has no license-clear evidence for.

## Attribution

- **alirezarezvani/claude-skills** — [github.com/alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills), 22,733★ (checked 2026-07-18 via direct GitHub HTML verification), MIT license (verified — LICENSE file present, repository description confirms "MIT License for open s[ource]"). **Primary reference.** Actively maintained (wave-3 domain overhaul dated 2026-06-11, roughly one month before this check). Three of its 30+ skill categories map directly onto this skill's scope:
  - **Finance** (4 skills) — financial analyst work (DCF, budgeting, forecasting), a SaaS metrics coach (script-driven: `metrics_calculator.py --mrr --customers --churned`), and a business investment advisor.
  - **Commercial** (8 skills) — orchestrator + pricing-strategist, deal-desk, partnerships-architect, channel-economics, commercial-policy, rfp-responder, commercial-forecaster.
  - **Business Operations** (7 skills) — orchestrator + process-mapper, vendor-management, capacity-planner, internal-comms, knowledge-ops, procurement-optimizer.
  This skill routes into these three categories rather than reimplementing their methodology; the underlying library is installed separately by the user (`/plugin install finance-skills@claude-code-skills` is the pattern the upstream repo itself documents for its plugin-scoped install).
- **cluster-software/agent-crm** — [github.com/cluster-software/agent-crm](https://github.com/cluster-software/agent-crm), **111★** (checked 2026-07-18 via direct GitHub HTML verification) — far below this workspace's usual evidence bar. `[LICENSE-UNCONFIRMED]` — the GitHub API's license endpoint returns no `spdx_id` for this repo (empty/no LICENSE file detected), so per CORE-LAWS LAW 1 point 4 it defaults to all-rights-reserved: reference/read only, do not install, vendor, or redistribute until a LICENSE file is found and verified directly. Named here only as an early-stage, purpose-built option for literal CRM-system access ("headless CRM for Claude & Codex," backed by a16z Speedrun) if a request specifically needs a live CRM data store rather than deal/pricing strategy advice. Flag both its low star count and its unconfirmed license to the user before recommending it; do not treat it as equivalent evidence to the primary reference above.
- **No dominant OSS match was found for literal ERP or SCM *software integration*** (i.e., an agent skill that connects to and operates SAP, NetSuite, Oracle ERP, or a dedicated supply-chain-management platform) — searched 2026-07-18. What exists instead is operations-advisory skills adjacent to that ground (`business-operations`'s vendor-management and procurement-optimizer, above), which this skill routes to for the *strategy and process* side of SCM without claiming to integrate the *software* side. If a request specifically needs live ERP/SCM system access rather than advisory work, say so per LAW 0 rather than improvising a fake integration.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 1: Classify the request into one of the three domains

Ask (AskUserQuestion) if not already clear:

1. **Finance** — is this "build/read a financial model or metric" (DCF, budget, forecast, SaaS metric like MRR/churn/CAC)? Route to the Finance category.
2. **Commercial** — is this "price, negotiate, or win a specific deal" (pricing a contract, responding to an RFP, structuring a partnership, forecasting a specific deal's outcome)? Route to the Commercial category.
3. **Business Operations** — is this "run an internal process" (mapping a workflow, managing a vendor relationship, planning capacity, optimizing procurement)? Route to the Business Operations category.

A request can span more than one — e.g. an RFP response usually needs both a Commercial (rfp-responder) and a Finance (forecasting) pass. Say so and sequence them rather than forcing a single-category answer.

## Step 2: Confirm the underlying skill library is actually available

This skill routes into `alirezarezvani/claude-skills` rather than reimplementing its content (same discipline as `distribution` → `marketingskills`). Check whether it's installed before assuming — the upstream repo's own install pattern is a Claude Code plugin (`/plugin install finance-skills@claude-code-skills` for the Finance category; the Commercial and Business Operations categories install the same way under their own plugin names). If not installed, tell the user and ask (AskUserQuestion) whether to install it now or proceed with a lighter WebFetch-only pass reading the specific skill's file live from the repo.

## Step 3: For financial outputs specifically, keep the evidence discipline from CORE-LAWS LAW 0

A DCF, forecast, or SaaS-metrics output is a number someone may act on. Before presenting one as final:

- State every input assumption explicitly (discount rate, growth rate, churn assumption) rather than letting them hide inside a formula — a wrong assumption silently propagates.
- If the underlying skill's script (e.g. `metrics_calculator.py`) is available, run it rather than hand-computing the same metric from scratch — a maintained calculator is less error-prone than a fresh derivation, same reasoning `agent-builder`'s Step 1.5 uses for choosing a maintained rubric tool over describing one from scratch.
- Label a projection as a projection, not a fact — "forecast" and "actual" are different claims, and a business-operations output that blurs them is exactly the kind of unlabeled-guess failure LAW 0 exists to prevent.

## What this skill does not do

It does not validate whether a new business/product idea should exist (that's `biz-council`). It does not manage a founder's personal cash-runway/burn discipline — see `../_shared/ROUTING.md`'s "Not yet built" entry for why that specific niche was evaluated and deferred separately (no dominant OSS match for that exact scope, even though this skill covers adjacent ground). It does not connect to or operate a literal ERP or SCM software platform — see Attribution above; it covers the operations-advisory and process side, not systems integration. It does not fabricate a CRM/ERP integration where none exists — if the request needs one, name `cluster-software/agent-crm` with its actual (low) star count rather than presenting it as equivalent-strength evidence to the primary reference.
