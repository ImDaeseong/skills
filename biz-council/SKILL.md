---
name: biz-council
description: "Research what real users actually say (Reddit, X, YouTube, TikTok, Instagram Reels, Hacker News, Polymarket, web), run the findings through a 5-advisor council for multi-angle judgment, then produce a precise business/product design document. If multiple candidate ideas are still open, scores them (growing/low-competition/personal-fit) before proceeding. MANDATORY TRIGGERS: 'biz council this', 'research and council this', 'design a business around X', 'validate this business idea with real data', 'give me a startup idea in X', 'help me pick which idea to build'. Fuses three source projects: last30days (real-user research engine), llm-council (Karpathy's multi-advisor methodology), gstack /spec + /plan-ceo-review (design-doc discipline). Do NOT trigger on trivial questions with one right answer."
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - Task
---

# biz-council

Most "AI business idea" output is the model's own guess dressed up as analysis. This skill refuses that shortcut: every claim in the final document must trace back to either (a) a real post/comment pulled by the research engine, or (b) a labeled assumption the user explicitly approved. If evidence is thin, the document says so — it does not fill the gap with plausible-sounding prose.

## Attribution

This skill fuses three core source projects (methodology it directly runs on) plus three additional references (an evaluated alternative, an optional tool, and a business-strategy framework) — it does not reimplement any of them:

- **last30days** — [github.com/mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill), MIT license. Research engine, called as-is in Step 1.
- **llm-council** — [github.com/aiwithremy/claude-skills-llm-council](https://github.com/aiwithremy/claude-skills-llm-council), adapted from Andrej Karpathy's original [github.com/karpathy/llm-council](https://github.com/karpathy/llm-council). Methodology (advisor roles, peer-review, chairman synthesis) referenced in Step 2. **Neither repo has a LICENSE file (verified directly against both repos' root contents, not a secondary source) — both default to all-rights-reserved.** This skill describes the methodology in its own words rather than reproducing either repo's text, and fetches the original live via WebFetch rather than vendoring a local copy (see Step 2). Fine for personal local use; before public redistribution of this workspace, treat the advisor-role concept as the only borrowed idea (not copyrightable expression) and keep this file's own wording as the sole source of the actual instructions.
- **gstack** — [github.com/garrytan/gstack](https://github.com/garrytan/gstack), **122,463★** (checked 2026-07-18 via direct GitHub HTML verification — GitHub API was rate-limited at check time, so the star counter was read directly from the repo page's `aria-label`, not estimated), MIT license (verified same way). Corrects an earlier "not verified in this pass" placeholder in this table — LAW 0 requires a real number, not a deferred check that never got done. Only the `/spec` and `/plan-ceo-review` *question frameworks* are borrowed in Step 3 — gstack's own runtime (`~/.gstack/`, `gstack-config`, telemetry binaries) is intentionally excluded; those binaries don't exist outside a gstack install and would error or silently no-op if invoked here.
- **compound-engineering-plugin** — [github.com/EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin), 23,194★ (checked 2026-07-18 via direct GitHub HTML verification), MIT license. Evaluated per LAW 1 as an alternative research-to-roadmap reference (its `ce-plan` skill turns research into a structured plan) — surfaced from a podcast demo (Matt Van Horn/Greg Isenberg, 2026-02-05, the same Matt Van Horn who built `last30days`). Ranks well below gstack by star count, so gstack remains the primary Step 3 reference; noted here as the documented second candidate rather than a single unexplained pick, per LAW 1.
- **Firecrawl** — [github.com/firecrawl/firecrawl](https://github.com/firecrawl/firecrawl), 152,409★ (checked 2026-07-18 via GitHub API), AGPL-3.0 license (verified via GitHub API license endpoint). Optional bulk-scraping tool named in Step 1.3 — used as an external API/tool call when a key is configured, not vendored or self-hosted by this skill.
- **Richard Yu, “1,000 Hours of studying the Best Digital Product Businesses in 24 Minutes”** — [YouTube](https://www.youtube.com/watch?v=cv0y7oCllek), 2026-06-12. Negative test case for Step 1.4a: useful hypotheses were mixed with self-reported revenue/research hours and universal percentages without disclosed samples. The tactics were not adopted as facts; the case was cross-checked against [Instagram's official recommendation guidance](https://www.facebook.com/help/instagram/653964212890722), [Klaviyo's abandoned-cart benchmarks](https://www.klaviyo.com/blog/abandoned-cart-benchmarks), and published research on [money-back guarantees and purchase intention](https://www.sciencedirect.com/science/article/pii/S0148296313003603).
- **Helena Liu, NotebookLM data-analysis video** — (YouTube, 2026-06-20) — not a GitHub repo, cited as technique source. NotebookLM itself is proprietary and not adopted. Source of Step 1.1a — internal/uploaded business data (support tickets, spreadsheets, competitor research already collected) treated as a first-class evidence source alongside last30days, not a fallback reached for only when public research is thin.
- **Helena Liu, "Don't sell AI automation, do this instead"** — (YouTube, 2025-10-02) — not a GitHub repo, cited as a business-model framing rather than an OSS methodology. Zapier and Lovable (the tools demoed) are proprietary, not adopted. Source of Step 1.5a — the question of whether a service-shaped idea should be repackaged as a productized micro-SaaS (frontend UI + AI agent + automation, connected end to end) instead of sold as bespoke service work each time.
- **"30-day Claude Code solo business" (그랜트)** — (YouTube, 2026-07-08) — not a GitHub repo, cited as a validation-sequencing framing. Source of Step 1.5b — validate with a cheap real-world probe (landing page + a few days of paid ad spend, or one manually-delivered sale) before committing to a full build, not after. The video's own 30-day sequence (idea → minimal site → ad-test → first customer → then content/polish) is the evidence for the ordering, not a specific tool adopted here.
- **a16z, "Avoiding Death on the Yellow Brick Road"** — [a16z.com/avoiding-death-on-the-yellow-brick-road](https://a16z.com/avoiding-death-on-the-yellow-brick-road) — not a GitHub repo, cited as a business-strategy framework rather than an OSS methodology (no LAW 1 star/license ranking applies). Source of Step 1.5's fourth idea-selection criterion: whether an idea's value is a defensible expert-domain advantage (data flywheel, model optionality, cost optimization, governance) or a thin wrapper on a raw model capability that a frontier lab's next release absorbs natively.

---

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full. Read it before running this skill for the first time in a session; only `biz-council`-specific steps appear below.

---

## Step 1: Research — real users, real platforms

**1.0 Resolve the engine path first — do not assume it.** `biz-council` lives in its own skill folder, separate from `last30days`. last30days' own `SKILL.md` defines `SKILL_DIR` as "the directory of the SKILL.md the model just Read," which only resolves correctly when last30days is loaded directly. Before invoking anything, locate the real installation:

```bash
LAST30DAYS_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*last30days*" 2>/dev/null | head -1)
if [ -z "$LAST30DAYS_SKILL_MD" ]; then
  echo "last30days not found locally."
else
  LAST30DAYS_SKILL_DIR=$(dirname "$LAST30DAYS_SKILL_MD")
  echo "Resolved last30days at: $LAST30DAYS_SKILL_DIR"
fi
```

**If not found, offer to clone it — do not silently skip to Step 2 with no research.** Ask the user (AskUserQuestion): clone `https://github.com/mvanhorn/last30days-skill` into `~/Desktop/skills/last30days` now, or proceed on WebSearch-only evidence (weaker, must be labeled `[LOW-EVIDENCE]` throughout). If the user approves the clone:

```bash
git clone https://github.com/mvanhorn/last30days-skill.git ~/Desktop/skills/last30days
LAST30DAYS_SKILL_DIR=$(find ~/Desktop/skills/last30days -maxdepth 3 -iname "SKILL.md" -path "*last30days*" 2>/dev/null | head -1 | xargs dirname)
echo "Cloned and resolved at: $LAST30DAYS_SKILL_DIR"
```

Never guess a path instead of running this resolution/clone sequence.

**1.1 Run the engine.** Once `LAST30DAYS_SKILL_DIR` is resolved, Read that directory's `SKILL.md` and follow it exactly — first-run setup wizard, `--plan` for named entities, the source list (Reddit, X, YouTube, TikTok, **Instagram Reels**, Hacker News, Polymarket, GitHub, web; optional Bluesky/Threads/Pinterest/LinkedIn/Xiaohongshu with the right keys). Do not reimplement its logic — invoke `"$LAST30DAYS_SKILL_DIR/scripts/last30days.py"` as that file documents. Relay its engine footer and evidence per its own LAWs; do not paraphrase or fabricate around a "nothing solid this window" result.

**1.1a Internal data is a first-class source, not a fallback.** last30days covers *external* public signal — it has nothing on the user's own support tickets, sales calls, uploaded spreadsheets, or competitor research they've already collected. If the user has this, ask for it (AskUserQuestion) and read it alongside the 1.1 findings rather than treating it as a weaker consolation prize only reached for when public research comes up thin (framing surfaced from a Helena Liu NotebookLM data-analysis video, 2026-06-20). Internal data — churn timing/reasons, support-ticket themes, ROAS by campaign — is often higher-signal than public sentiment for a business that already has customers, precisely because it reflects this business's reality rather than the general public's.

**1.2 Korean-market supplement (known gap — do not claim otherwise).** The last30days engine has no Naver or Daum connector. For a Korean-market business question, run this as a separate, explicitly-labeled supplement:

1. Use WebSearch with `site:naver.com` / `site:daum.net` plus the topic, and separately search Naver 카페/블로그/지식iN and Daum 카페 by name if WebSearch surfaces them.
2. Label every finding from this supplement `[KR-WEB - via WebSearch, not last30days engine]` so the final doc never implies engine-level coverage that doesn't exist.
3. If WebSearch returns nothing usable, say so explicitly rather than padding with generic claims about "Korean users."

**1.3 Bulk-scraping upgrade (optional — Firecrawl).** WebFetch handles single pages; if the research needs many pages from one domain (a competitor's full site, a target's own content archive to characterize), and a Firecrawl API key is available in the environment, prefer it over looping WebFetch calls. See Attribution for license/verification. If no key is configured, say so and fall back to WebFetch/WebSearch — do not assume Firecrawl is available.

**1.4 Evidence gate — do not proceed on empty research.** Before moving to Step 2, check: did 1.1 and/or 1.2 return at least a handful of real, citable items? If both came back empty or "nothing solid this window," STOP. Do not run the council on zero evidence — that just produces five confident-sounding guesses. Tell the user research came back thin and ask whether to: narrow/rephrase the topic, supply their own context/data manually, or proceed anyway with everything downstream tagged `[LOW-EVIDENCE]`.

**1.4a Claim-quality gate — separate evidence from sales copy.** Before using a creator, course seller, vendor, or case study as evidence:

1. Label revenue, student results, screenshots, research hours, and “I studied X businesses” statements as **self-reported** unless independently audited; a disclaimer does not verify them.
2. Reject universal numbers or words such as “80%,” “95%,” “always,” and “the only platform” unless the source discloses a relevant sample, method, denominator, and comparison baseline. Without those, use `[ASSUMPTION - unverified, confirm with user]` rather than repeating the number.
3. Search for counterevidence from an independent primary source or maintained benchmark. A plausible mechanism is not proof; for example, a guarantee may help or hurt depending on risk and credibility, so do not turn one seller's experience into a universal rule.
4. Convert surviving platform, funnel, pricing, guarantee, and follow-up claims into segment-specific, time-bounded hypotheses. Keep directional evidence (“follow-up can recover sales”) separate from an unsupported magnitude (“80% closes in DMs”).

**1.5 Idea selection (only when the user hasn't committed to one candidate yet).** If Step 1.1 research surfaced several viable directions rather than one named idea to validate, don't silently pick one or run the council on all of them at once. Score each candidate against four criteria and show the scoring, don't just assert a winner: **growing** (the trend data from 1.1 actually shows growth, not just presence), **low competition** (the research didn't surface a crowded field of existing solutions), **personal fit** (the user actually understands or cares about this space — a technically strong idea nobody wants to operate tends to stall), and **defensible against the model layer** (see Attribution, a16z) — "low competition today" isn't the same as "durable": ask whether the idea's core value is a workflow/data/governance advantage in a specific expert domain, or just a thin wrapper on a capability (writing, coding, image generation) that disappears the moment a frontier lab's next model does it natively. An idea that scores well on the first three but fails this check is a rental, not a business — flag it explicitly rather than letting a good growth/competition score paper over it. Ask the user to confirm the pick (AskUserQuestion) before proceeding to Step 2 — this is a judgment call, not something to decide for them.

**1.5a Delivery shape: productized micro-SaaS vs. bespoke service.** If the idea is service-shaped (consulting, done-for-you automation, freelance delivery), ask whether it should instead be packaged as a repeatable product — a thin frontend UI wrapped around the same AI-agent-plus-automation logic — rather than sold as one-off bespoke work each time (framing surfaced from a Helena Liu automation-agency video, 2025-10-02). This is a delivery-shape question, separate from the four selection criteria above: a service can pass all four and still not scale, because each new customer requires redoing the work by hand. Not every idea should be productized (some genuinely need bespoke delivery), so raise it as a question, not a default.

**1.5b Validate with real signal before committing to a full build.** Once an idea and delivery shape are picked, don't let research-stage confidence substitute for a real-world test — a small, cheap probe (a landing page plus a few days of paid ad spend, or a manually-delivered version sold to one real customer) surfaces actual demand faster and cheaper than building the full product first (framing surfaced from a "30-day Claude Code solo business" video, 2026-07-08, whose own timeline sequences exactly this: idea → build a minimal site → market-test with paid ads → land one real customer → only then invest in polish/content). For a tactical claim from Step 1.4a, define an A/B test or sequential test with the target segment, baseline, changed variable, primary metric, minimum observation window/sample, and stop condition before recommending it. Route the actual build to `design-report`/`vibe-coder` and the ad-test/channel work to `distribution` — this step's job is just to flag that the test should happen before the full build, not after.

## Step 2: Council — 5-advisor multi-angle judgment

Reuse the `llm-council` methodology (see Attribution above for its license status — reference it, don't republish it as your own):

1. Frame the business question using the Step 1 research (1.1 web/social evidence plus any 1.2 KR-web supplement) as grounding context (not the user's raw question alone — enrich it with the strongest 3-5 evidence items, cited).
2. Spawn 5 sub-agents in parallel: **The Contrarian**, **The First Principles Thinker**, **The Expansionist**, **The Outsider**, **The Executor**. `llm-council` is not vendored locally (license unconfirmed — see Attribution), so fetch the original advisor descriptions live via WebFetch on `https://github.com/aiwithremy/claude-skills-llm-council/blob/main/SKILL.md` the first time this step runs in a session, rather than assuming a local copy exists; cache the fetched text in-session for the rest of the run. Do not weaken, merge, or paraphrase-from-memory these roles.
3. Anonymize responses A-E, run a peer-review round (strongest response / biggest blind spot / what everyone missed).
4. Chairman synthesis: where the council agrees, where it clashes, blind spots caught, the recommendation, the one thing to do first.

Do not skip the peer-review round — it's the step that catches the blind spots a single-pass "ask 5 times" would miss.

## Step 3: Design document — turn the verdict into something buildable

Borrow the *question framework* from gstack `/spec` and `/plan-ceo-review` — not their runtime. Do not invoke any `gstack-*` binary; those only exist inside a gstack install and are irrelevant here.

**3a. Lock the "why" (from /spec Phase 1).** Answer all five before drafting anything:
1. Who is affected? (be specific — a demographic/behavior segment found in Step 1 research, not "everyone")
2. What is the current behavior/pain, per the evidence?
3. What should the outcome be instead?
4. Why now? (what in the Step 1 research suggests timing — a trend, a gap competitors haven't filled, a platform shift)
5. How will you know it worked? (a measurable signal, not a vibe) — anchor this to the specific funnel stage the idea actually operates in (Attract → Engage → Convert → Monetize → Retain, surfaced from a Helena Liu dashboard-building video, 2026-06-26), not a generic metric. A lead-gen idea's signal is an Attract/Engage number; a pricing change's signal is Convert/Monetize; a churn fix's signal is Retain. Naming the stage forces a specific metric instead of a vague "more revenue."

If any of these can't be answered from Step 1 evidence, ask the user directly (AskUserQuestion) — do not invent an answer.

**3b. Scope-check (from /plan-ceo-review's four modes).** Present the business idea once at each of these angles and let the user pick a direction:
- **Scope Expansion** — what's the 10x version if execution cost weren't a constraint?
- **Selective Expansion** — hold the core scope, cherry-pick one or two expansions with the best evidence-to-effort ratio.
- **Hold Scope** — the smallest version that tests the core hypothesis from Step 1.
- **Scope Reduction** — strip to the single riskiest assumption and design only to test that.

**3c. Write the document.** Structure:

```
# {Business/Product Name}: Design Document

## Evidence Base
{Every source cited in Step 1.1 and 1.2, with links. Note coverage gaps honestly.}

## Council Verdict
{Full output of Step 2 — agreement, clashes, blind spots, recommendation, first move.}

## The Five Questions (Spec Lock)
{3a answers, each citing the evidence or user-confirmed assumption it rests on.}

## Scope Decision
{Which of the 3b four modes was chosen, and why.}

## What Gets Built
{Feature list / user flow. Tag anything not evidence-backed with the canonical `[ASSUMPTION - unverified, confirm with user]` tag from LAW 0.}

## Open Risks
{What the council flagged as blind spots or clashes that remain unresolved.}
```

---

LAW 1 (library selection) and LAW 2 (code architecture, if this design doc is later implemented) apply exactly as written in `../_shared/CORE-LAWS.md` — no `biz-council`-specific override.

Do not write actual source files under this skill unless the user explicitly asks for an implementation pass separate from the design doc.

## AI earnings attribution guard

When an AI-tool case study is used as evidence, separate the tool's contribution from pre-existing assets: audience, brand trust, distribution, domain or design experience, and prior products. Record gross revenue separately from net revenue or profit, refunds, fees, customer-acquisition cost, retention or renewal, and build or operating cost. If those values are unavailable, label them unverified. Faster production does not by itself prove that the tool created demand. Convert the claim into an A/B test or sequential test with a comparison baseline, observation window or sample, and stop condition before recommending the tactic.
