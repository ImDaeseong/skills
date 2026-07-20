---
name: social-carousel
description: "Turn a real, evidence-backed trend/angle into a multi-slide Instagram/LinkedIn carousel post — trend research first, then exact-dimension slide export. MANDATORY TRIGGERS: 'make a carousel', 'instagram carousel', 'linkedin carousel', 'slide post', 'turn this trend into a post', 'carousel about X'. `curator` covers single-piece video/script content; `design-report` covers one-off static images. This skill is specifically the trend-research → multi-slide-carousel pipeline neither of those covers. Do not trigger for a single static image (`design-report`) or a full rendered video (`video-producer`)."
allowed-tools:
  - Read
  - Write
  - Bash
  - WebFetch
  - WebSearch
  - AskUserQuestion
---

# social-carousel

A carousel post is two problems, not one: knowing what's actually worth posting (real trend signal, not a guessed topic) and producing pixel-exact slides for the platform. This skill chains a trend-research engine into a carousel-builder engine rather than reimplementing either.

## Attribution

- **mvanhorn/last30days-skill** — [github.com/mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill), 52,669★ (checked 2026-07-19 via GitHub API), MIT license (verified via GitHub API license endpoint). Same engine `biz-council`/`curator`/`distribution` already use for real Reddit/X/YouTube/TikTok/Instagram-Reels/HN/Polymarket/web signal — reused here rather than a second trend tool, resolved the same way (Step 1).
- **Hainrixz/open-carrusel** — [github.com/Hainrixz/open-carrusel](https://github.com/Hainrixz/open-carrusel), 371★ (checked 2026-07-19 via GitHub API, pushed 2026-04-15), MIT license (verified via GitHub API license endpoint). Primary carousel-builder reference: a Claude-Code-driven chat interface that exports individual PNG slides at exact Instagram dimensions (1080×1080 / 1080×1350 / 1080×1920) via a local Puppeteer render — runs on the user's own machine, nothing uploaded to a third party. Adopted as primary over the alternative below purely on evidence (higher stars, actively pushed, purpose-built for chat-driven agent use).
- **FranciscoMoretti/carousel-generator** — [github.com/FranciscoMoretti/carousel-generator](https://github.com/FranciscoMoretti/carousel-generator), 193★ (checked 2026-07-19 via GitHub API), MIT license, but no commits since 2024-09-29 (stale). LinkedIn-format secondary option — note if the target platform is specifically LinkedIn rather than Instagram, since open-carrusel's dimension presets are Instagram-shaped.
- **alsk1992/instagram-ai-agent** — [github.com/alsk1992/instagram-ai-agent](https://github.com/alsk1992/instagram-ai-agent), 18★ (checked 2026-07-19 via GitHub API) — evaluated and **explicitly excluded**. Both far below this workspace's evidence bar for the niche and built around autonomous auto-posting with an "anti-detection layer" against the platform's own bot detection, which this workspace does not route to (evading a platform's abuse detection is out of scope regardless of star count). This skill produces slide files for the user to review and post themselves; it does not automate posting.
- **Karolis, "Claude skills that will change content creation forever"** — (YouTube, 2026-06-17) — not a GitHub repo, cited as the workflow trigger only. The video's own tool (Virlo, `dev.virlo.ai`) is a closed-source paid SaaS with no public repo, so it carries no LAW 1 evidence and is **not** referenced or adopted here `[ASSUMPTION - unverified, closed-source, cannot check]` — the trend-research + carousel-export *workflow shape* it demonstrated is what's reused, built instead on the open, evidence-checked engines above.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 1: Resolve the trend-research engine — do not assume it exists

Resolve and run `last30days` exactly as `biz-council` Step 1.0/1.1 does (find `LAST30DAYS_SKILL_DIR` under `~/Desktop/skills`, `~/.claude/skills`, etc.; offer to clone `https://github.com/mvanhorn/last30days-skill` if missing; never assume a path) — same convention `curator` Step 1 follows, not re-described here. Include the Korean-web supplement (`[KR-WEB - via WebSearch, not last30days engine]`) if the target audience is Korean, or proceed on WebSearch-only evidence if the user declines to clone (weaker, must be labeled `[LOW-EVIDENCE]`). **Evidence gate**: if research comes back empty, stop and say so rather than inventing a topic — a carousel built on a guessed trend is the exact failure this step exists to prevent.

## Step 2: Resolve the carousel-builder engine — do not assume it exists

```bash
CARROUSEL_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" ~/Desktop/skills -maxdepth 4 -iname "*.md" -ipath "*open-carrusel*" 2>/dev/null | head -1)
if [ -z "$CARROUSEL_SKILL_MD" ]; then
  echo "open-carrusel not found locally."
fi
```

If not found, ask the user (AskUserQuestion): clone `https://github.com/Hainrixz/open-carrusel` into `~/Desktop/skills/open-carrusel` now (requires Node.js locally — `npm run setup` then either `/start` inside Claude Code or `npm run dev` for the no-AI manual editor), or use `FranciscoMoretti/carousel-generator` instead if the target is LinkedIn specifically. Never guess a path or assume either tool is installed.

## Step 3: Turn the trend into a specific angle before touching slide layout

Do not go straight from "here's a trending topic" to slides. Per the same honest-opinion discipline `curator` uses: state what's actually true/useful/surprising about the trend for this specific audience, in one sentence, before drafting slide copy. A carousel that just restates a headline across N slides is not more valuable than the headline.

1. Confirm with the user (AskUserQuestion if not already clear): target platform (Instagram vs. LinkedIn — determines which builder from Step 2 and which aspect ratio), brand/voice constraints (an existing `DESIGN.md` from `design-report`, if one exists — read and reuse its color/typography tokens rather than re-deciding them), and slide count (carousels typically run 5-10 slides; more than ~10 loses swipe-through completion).
2. Draft the slide-by-slide content outline (hook slide → 3-8 content slides → CTA/summary slide) as plain text first, and get it confirmed before generating any visual output — cheap to fix text, expensive to re-render slides.

## Step 4: Generate and verify by looking at the actual output

Invoke the resolved carousel builder per its own docs (Step 2). Per this workspace's established render-verification discipline (see `design-report` Step 1.8 / `video-producer` Step 3): a slide deck that looks correct in the prompt/config and one that actually rendered correctly are different claims. Read the actual output PNG files (dimensions, whether text/brand tokens bound correctly) before calling it done — do not report success from the generation command's exit code alone.

---

## What this skill does not do

It does not fabricate a trend when Step 1's research comes back empty — say so per LAW 0 instead. It does not auto-post to any platform (see the excluded `instagram-ai-agent` entry in Attribution) — output is slide files for the user to review and publish themselves. It does not decide brand visual direction from scratch when a `DESIGN.md` already exists (that's `design-report`'s job, reused here). It does not write single-piece video/script content (`curator`) or a one-off static image (`design-report`).
