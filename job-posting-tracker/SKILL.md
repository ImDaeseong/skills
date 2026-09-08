---
name: job-posting-tracker
description: "Turn real, pasted job postings into a running record of what skills/tech stacks AI/IT roles actually demand — parses required vs. preferred requirements per posting, classifies each into a role cluster (LLM/Agent Engineer, MLOps/Infra, Embodied AI/Robotics, Applied/Research Scientist, Product/PM, Frontend, AI Transformation Consulting, etc.), appends to a cumulative tally file so patterns emerge across many postings, and — only when explicitly asked — runs an optional gap-analysis pass against the user's own stated current skills to produce a prioritized learning roadmap. MANDATORY TRIGGERS: '채용공고 스킬 분석', '이 공고 확인해줘', '요즘 AI 직무에 필요한 스킬', 'job posting skill analysis', 'what skills does this role need', '직무별 기술스택 정리', '내 스택 대비 부족한 스킬', '학습 로드맵 만들어줘'. Requirement extraction and tallying only by default — not a resume-matcher, interview simulator, or job-application tool; every skill/requirement in the output must trace to an actual pasted posting, never inferred or assumed, and any learning-resource recommendation must be verified (WebSearch), never named from memory. Distinct from `pm-delivery-ops` (running day-to-day PM/eng operations) and `ai-adoption-scout` (mapping AI adoption ideas onto the user's own work, not job-market requirements)."
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
  - WebSearch
---

# job-posting-tracker

Job descriptions are one of the few places "what skills matter right now" shows up as a real, dated, falsifiable signal instead of a trend article's opinion. This skill turns a pasted posting (or a batch of them) into structured, source-traceable data, and keeps a running tally across sessions so the pattern — which tools/frameworks keep recurring across otherwise-different roles — gets clearer the more postings go through it, rather than resetting to zero each time.

## Attribution

- **he-yufeng/FindJobs-Agent** — [github.com/he-yufeng/FindJobs-Agent](https://github.com/he-yufeng/FindJobs-Agent) (checked 2026-09-09 via GitHub API: 252 stars, MIT license confirmed, pushed 2026-09-07 — active). **Considered, not adopted.** It does LLM-based skill-taxonomy extraction from postings, the same core idea as this skill's Step 2 — but it's a full standalone application (résumé PDF/Word parsing, resume-to-job match scoring, a multi-turn mock-interview generator, its own `jobs.db` database) built to run outside an agent session, not a lightweight Claude-skill wrapper. Adopting it would pull in résumé-scoring and interview-simulation scope no request here asked for, and its persistence model (a SQLite database, not a plain file) doesn't fit this skill's plain-Markdown running-tally design. No purpose-built, lightweight "extract structured skill data from a job posting, nothing else" Claude Skill package was found at this check — this skill's extraction/classification logic is original content instead.
- **No cross-check candidate found** for the specific combination this skill does (multi-session cumulative tallying of requirement frequency across many separately-pasted postings, output as a single running file). Revisit if a purpose-built lightweight package for exactly this surfaces.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

LAW 0 matters most here: every skill/tool named in the output must come from an actual pasted posting's text, never filled in from what a role "usually" needs.

## Step 1: Establish the output file

Ask (AskUserQuestion) if not already clear: is there an existing tally file to append to (ask for its path), or start a new one? Default new-file name: `job-posting-tracker.md` in the user's current working directory, unless they name a different location. Read the existing file first if one is named — never overwrite; every run appends.

## Step 2: Extract per posting, from the posting's own text only

For each pasted posting, pull out exactly what it states — do not fill gaps with assumption:

- **Role title and org** (if stated).
- **Required skills/tools** — list each named technology, framework, or method literally as written (e.g. "vLLM," "LangGraph," "Kubernetes," "Jira," "ISA-95") — not a paraphrase or a broader category substituted for the literal term.
- **Preferred/우대 skills/tools** — same rule, kept in a separate list from required. A posting that doesn't clearly separate the two gets a note saying so, not a guessed split.
- **Domain signal** — any named industry/regulatory context stated in the posting (금융/증권, 방산/보안, 국방, 게임, 에듀테크, etc.) — only if the posting actually says so.
- If a posting is too vague to extract anything concrete (no named tools/frameworks at all), say that explicitly rather than inventing plausible-sounding skills for it.

## Step 3: Classify into a role cluster

Assign each posting to one cluster based on its actual stated duties — do not force every posting into a pre-existing cluster if none fits; add a new cluster name when a posting's duties genuinely don't match any existing one. Starting clusters (extend as real postings warrant, don't pre-populate ones no posting has hit yet):

- LLM/Agent Engineering (agent workflows, RAG, tool-calling, multi-agent)
- MLOps/AI Infra (GPU clusters, K8s/OpenShift, model serving, CI/CD for ML)
- Embodied AI/Robotics/Physical AI (VLA, sim-to-real, ROS, Isaac Sim)
- Applied/Research Scientist (paper-adjacent, benchmarks, ablation studies, domain-specific modeling — e.g. batteries, physics-informed AI)
- Product/PM for AI services (backlog, metrics, cross-functional lead — routes ticket/backlog *work itself* to `pm-delivery-ops`, this skill only tallies what skills that role posting asked for)
- Frontend/Full-stack for AI products
- AI Transformation Consulting (전략/로드맵/거버넌스, not hands-on model building)
- Data Engineering/Pipeline for AI

## Step 4: Update the running tally

Append a dated entry per posting (role, cluster, required list, preferred list, domain signal, one-line source description — e.g. company name if given, or "미상 공고 2026-09-09") to the file's log section, then recompute a frequency table at the top: each named skill/tool, how many postings (of the total processed so far) mentioned it as required vs. preferred, and which clusters it shows up in. A skill mentioned by 1 of 20 postings and one mentioned by 15 of 20 are very different signals — keep the raw count visible, not just a sorted list, so the reader can judge strength themselves rather than trust an implied ranking.

## Step 5: Gap analysis and learning roadmap (only when explicitly asked)

Do not run this step unless the user explicitly asks for a gap analysis or roadmap — the default output (Steps 1-4) is market signal only, not a personal verdict.

1. **Get the user's current skillset from the user, not from assumption.** Ask (AskUserQuestion or a direct question) what they already know/have used. Do not infer their skill level from their job title, resume file name, or anything not explicitly stated — an unstated skill is treated as a gap, not silently assumed present.
2. **Compute gaps from the tally file's real numbers**, not from a fresh guess: for each skill/tool in the frequency table, mark 보유 (user stated they have it) or 부족 (not stated). Prioritize gaps by (required-count + preferred-count × 0.5) descending — a skill required by 11 of 38 postings and marked 부족 outranks one preferred by 2 of 38, regardless of how "important-sounding" either name is.
3. **State the sample-size caveat again here**, explicitly, before presenting the roadmap — the tally is `[LOW-EVIDENCE]` (one batch of pasted postings, not a market survey), so a roadmap built on it is a reasonable starting point, not a certified career plan.
4. **For each top-priority gap, recommend how to close it without fabricating a specific course/resource from memory.** If a concrete resource (a course, certification, official doc) is worth naming, verify it exists via WebSearch first — name, real link, and what it actually covers — rather than naming a plausible-sounding course title from memory. When no verification pass is run, recommend the resource *type* only (e.g. "공식 문서 + 사이드 프로젝트로 직접 구현해보는 방식이 일반적" ) rather than a specific named product, per CORE-LAWS LAW 0.
5. Output as a prioritized list (top gap first) appended to the same tally file under a dated "## 갭분석" section — never silently overwrite a prior gap-analysis run; each run is dated and additive, same discipline as Step 4's log.

## What this skill does not do

It does not score a résumé against a posting, generate interview questions, or apply/tailor a cover letter to a specific job — that's `he-yufeng/FindJobs-Agent`'s actual scope, not adopted here. Steps 1-4 do not compare the tally against the user's own current skills — that only happens in Step 5, and only when explicitly asked. It does not fabricate a skill, requirement, or learning resource a posting or a verification pass didn't actually produce, per CORE-LAWS LAW 0.
