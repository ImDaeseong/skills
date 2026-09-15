---
name: explain-for-audience
description: "Explain a topic, piece of code, error, or document calibrated to a specific audience — a child, a manager, an engineer, a grandparent, or any named role — by adjusting vocabulary, analogy, tone, and depth to that audience, not by shortening the same explanation for everyone. MANDATORY TRIGGERS: 'explain like I am', 'ELI5', 'explain this to my [manager/kid/mom/team]', 'break this down for', 'dumb it down', 'simplify this for', '/eli5'. Do not trigger for general prose editing with no named audience (route to `writing`) or for a standalone shareable diagram file (route to `diagram-forge`) — this skill is about calibrating one explanation to one specific audience, not editing style or producing a diagram file."
allowed-tools:
  - Read
  - AskUserQuestion
---

# explain-for-audience

Two real Claude Code skills solve overlapping halves of this problem differently enough that neither alone is the full answer, and this workspace video-triaged both (실용주의 개발, "클로드 쓴다면 이 스킬 한번 써보세요", 2026-09-11) before adopting the audience-calibration approach as primary.

## Attribution

- **DreambigOu/ELI5** — [github.com/DreambigOu/ELI5](https://github.com/DreambigOu/ELI5) (checked 2026-09-15 via GitHub API: 1229 stars, pushed 2026-03-18), MIT license (verified via the API's own `license.spdx_id: MIT`). **Primary reference** — audience-adaptive, text-based: detects who the explanation is for (age, role, relationship) and calibrates vocabulary, analogy, tone, and depth accordingly, rather than defaulting to one fixed "explain simply" register. Its own 3-step framework: identify the audience → understand the source material → craft the explanation (what / analogy / details / so-what, calibrated to that audience). Read the source file for its full audience-calibration examples rather than reproducing them here.
- **anthropics/claude-plugins-community** (`eli5` plugin) — [github.com/anthropics/claude-plugins-community](https://github.com/anthropics/claude-plugins-community/tree/main/eli5) (checked 2026-09-15 via GitHub API: 4058 stars, pushed 2026-08-25), Apache-2.0 license. **Secondary reference** for one specific case this workspace's DreambigOu-based default doesn't cover well: a true "explain like I'm 5" request where the audience is a young child or a complete beginner who benefits more from a picture than more text. Assumes zero background knowledge, delivers via an HTML artifact with large visuals and minimal text.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 1: Identify the audience

If the request already names one ("explain this to my manager", "ELI5 for a 5 year old"), use it. If not, ask (AskUserQuestion) — age range, role, or relationship is enough; do not guess and proceed, since the wrong audience produces the wrong vocabulary and analogy for the whole explanation.

## Step 2: Understand the source material

Read what's being explained (code, a concept, an error, a document) fully enough to extract its actual key elements before simplifying — an explanation calibrated to the right audience but built on a shallow read of the source is still wrong.

## Step 3: Pick the mode

- **Prose mode (default):** for any named audience above early-childhood level — a manager, an engineer, a parent, a grad student, a teammate. Follow DreambigOu's framework: lead with a concrete analogy from that audience's everyday experience (business outcomes for a manager, architecture terms for an engineer, playground/toy analogies for a young child), then what/details/so-what, calibrated in length and jargon to that audience. Never condescending, never overly casual for a technical audience.
- **Visual mode:** only when the audience is a young child, a complete beginner, or the user explicitly asks for a picture/visual explainer ("그림으로 설명해줘", "picture explainer"). Assume zero background knowledge; build the explanation as an Artifact — read `artifact-design` first for how to construct it well — favoring large visuals and minimal text over prose, per the anthropics reference's approach.

## What this skill does not do

It does not edit or polish prose that already has no specific named audience — that is `writing`'s job. It does not produce a standalone, exportable diagram file (architecture/sequence/workflow) — that is `diagram-forge`'s job; use visual mode here only for an audience-calibrated explanation artifact, not a technical diagram. It does not fabricate a fact to fill a gap the source material left open — say what isn't known rather than dressing a guess up as fact, per this workspace's LAW 0.
