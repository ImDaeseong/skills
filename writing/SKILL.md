---
name: writing
description: "Write or edit prose — essays, blog posts, articles, personal writing — so it reads as a specific human wrote it, not a generic AI pattern-matched into paragraph shape. MANDATORY TRIGGERS: 'humanize this text', 'edit this to sound less like AI', 'write this in my voice', 'write a blog post about X', 'polish this essay', 'match my writing style', 'remove AI writing patterns'. Distinct from `curator` (timely hot-take scripts tied to a launch/news moment, not general prose) and `design-report` (formats already-written content into a visual document, does not write or edit the prose itself). Do not trigger for a one-line caption or a code comment — this is for prose with actual paragraphs."
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# writing

AI-drafted prose has specific, catalogued tells — not "sounds a bit off," but a documented list of patterns (em dashes, rule-of-three, inflated significance, inline-header bullet lists) that a human editor can name and fix one by one. This skill is that editing pass: identify the actual patterns, rewrite to remove them while keeping every point the original made, and match a real voice when one is given instead of defaulting to a generic "helpful assistant" register.

## Attribution

- **blader/humanizer** — [github.com/blader/humanizer](https://github.com/blader/humanizer), **29,755★** (checked 2026-07-18 via direct GitHub HTML verification), MIT license (verified in the file's own frontmatter: `license: MIT`). **Primary reference**, and by a wide margin — next-closest candidate is roughly 12x fewer stars. Built on Wikipedia's own "Signs of AI writing" guide (maintained by WikiProject AI Cleanup, itself derived from "observations of thousands of instances of AI-generated text on Wikipedia" per the skill's own Reference section), so the pattern list traces to a citable primary source rather than one author's taste. Documents 33 named patterns across five categories (content, language/grammar, style, communication, filler/hedging) with before/after pairs for each, plus an explicit "what NOT to flag" section to avoid false-positive edits on legitimately clean human prose. This skill routes to its actual patterns rather than reproducing all 33 verbatim here — read the source file for the full before/after set.
- **conorbronsdon/avoid-ai-writing** — [github.com/conorbronsdon/avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing), 2,441★ (checked 2026-07-18 via GitHub API), MIT license. Secondary/overlapping reference on the same problem (audits and rewrites AI-pattern text), useful as a second pass or cross-check when a `humanizer` rewrite still reads flat — not adopted as primary since its evidence base is an order of magnitude thinner.
- **AgriciDaniel/claude-blog** — [github.com/AgriciDaniel/claude-blog](https://github.com/AgriciDaniel/claude-blog), 1,411★ (checked 2026-07-18 via GitHub API), MIT license. Reference for **structure**, not prose polish — a 5-gate blog-delivery workflow (research → draft → SEO/AI-citation optimization → quality-bar check → delivery) for when the request is "write a blog post from scratch" rather than "edit this existing draft." Use for Step 1's structural pass before `humanizer`'s Step 2 polish pass, not as a substitute for it.
- **haowjy/creative-writing-skills** — [github.com/haowjy/creative-writing-skills](https://github.com/haowjy/creative-writing-skills), 332★ (checked 2026-07-18 via GitHub API), Apache 2.0 license. Reference for fiction/creative writing specifically (scene drafting, voice-in-character, revision) when the request is a story or creative piece rather than an essay/article/blog post — a genuinely different craft from nonfiction prose editing, named separately rather than folded into the `humanizer` pass.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 1: Classify the request before writing anything

Ask (AskUserQuestion) if not already clear:

1. **Editing existing text, or drafting from a blank page?** Editing routes straight to Step 2 (`humanizer`'s pass). Drafting from scratch for a blog/article routes through `AgriciDaniel/claude-blog`'s structural stages first (see Attribution), then the same Step 2 polish pass before delivery.
2. **Nonfiction (essay, blog, article, personal writing) or creative (fiction, story, character voice)?** Creative work routes to `haowjy/creative-writing-skills` instead of the `humanizer` pattern list — fiction has its own craft concerns (pacing, character consistency, show-don't-tell) that a nonfiction AI-tell checklist doesn't cover well.
3. **Is a writing sample available for voice matching?** If the user has their own prior writing to reference, read it before drafting/editing (see Step 3) — matching a real voice beats defaulting to a generic register.

## Step 2: Apply the pattern-removal pass (nonfiction/editing path)

Follow `blader/humanizer`'s own process (see Attribution) rather than reinventing it:

1. **Identify** — scan the text against the 33 catalogued patterns (em dashes, inflated-significance language, rule-of-three, inline-header bullet lists, sycophantic tone, knowledge-cutoff disclaimers, filler phrases, and the rest — read the source for the complete list with before/after examples).
2. **Draft rewrite** — replace AI-isms with natural alternatives while covering everything the original covered; a five-paragraph original stays five paragraphs. Preserve meaning; match the intended register (formal/casual/technical) — don't inject personality into encyclopedic, technical, legal, or reference text where neutral *is* the correct human voice.
3. **Self-check** — ask "what makes this still obviously AI-generated?" and note any remaining tells briefly.
4. **Final rewrite** — address those tells. Zero em dashes or en dashes in the final output; this is a hard constraint per the source, not a "use sparingly" guideline.
5. **Check against the false-positive list before over-editing** — perfect grammar, mixed casual/formal registers, formal vocabulary used correctly, and unsourced-but-plausible claims are not AI tells on their own. Over-editing legitimately clean human prose destroys what made it sound human; flag *clusters* of tells, not isolated ones.

Deliver the draft, the brief "still-AI" notes, and the final rewrite — matching the source skill's own Process and Output contract, not a shortened version of it.

## Step 3: Voice matching (when a writing sample is provided)

Read the sample before rewriting. Note sentence-length pattern, word-choice level, paragraph-opening habits, punctuation tics, recurring phrases, and transition style. Match those specifics in the rewrite rather than only removing AI patterns generically — if the sample uses short sentences and plain words, the rewrite should too, not an "upgraded" vocabulary. Without a sample, fall back to a natural, varied, opinionated default register rather than a flat one.

## What this skill does not do

It does not fabricate factual claims to fill a gap the original left open — per this workspace's LAW 0 and the source skill's own §21 guidance, say what isn't known or cut the sentence rather than dressing a guess up as fact. It does not format the finished prose into a visual document (deck, PDF, styled report) — that's `design-report`'s job once the writing itself is done. It does not write timely reactive content tied to a specific news moment or launch — that's `curator`'s job; this skill handles prose craft, not news judgment.
