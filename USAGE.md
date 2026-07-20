# Usage guide

One section per skill: how to invoke it, what to give it, what you get back, and any known dependency or platform limitation. For the one-line "what it does" summary of each skill, see [README.md](README.md#my-skills); for the raw trigger-phrase table `genie` reads, see [`_shared/ROUTING.md`](_shared/ROUTING.md).

## How invocation works

1. **Install first.** Point your agent host's skills directory at this repo's 13 skill folders (for Claude Code: symlink or copy each folder under `~/.claude/skills/`). A `SKILL.md` file sitting in this repo alone is not "installed" — the host has to be pointed at it before it can trigger.
2. **Two ways to invoke:**
   - **Don't know which skill you need?** Call `genie` (or say "지니야") with your request in plain language. `genie` reads `_shared/ROUTING.md` and tells you which specialist skill to invoke — it does not do the work itself.
   - **Know the skill name?** Trigger it directly by using one of its trigger phrases (see each section below) or by naming it explicitly ("biz-council로 이 아이디어 검증해줘").
3. **Some skills clone an external tool at runtime** (marked "Runtime dependency" below) — the first invocation may ask permission to `git clone` a separate GitHub repo into `~/Desktop/skills/`. This is normal; see [`README.md`](README.md#why-the-originals-arent-kept-locally) for why those aren't vendored into this repo.

---

## genie

**Trigger:** "지니야", "genie", or any request that doesn't name a specific skill.
**Give it:** Your request in plain language, however unstructured.
**Get back:** Which specialist skill to invoke, or an honest "not built yet" if no skill covers the domain (see `_shared/ROUTING.md` "Not yet built").
**Dependency:** None — reads `_shared/ROUTING.md` only.

## biz-council

**Trigger:** "council this", "validate this business idea", "design a business around X", "give me a startup idea in X", "help me pick which idea to build".
**Give it:** A domain/niche (or say you want to explore broadly), and optionally an idea you've already picked.
**Get back:** Real Reddit/X/HN/YouTube evidence on the topic, scored candidate ideas (growing / low-competition / personal-fit / defensible-against-the-model-layer) if you haven't committed to one, then a 5-advisor council pass and an evidence-cited business/product design document.
**Runtime dependency: `last30days`** (cloned to `~/Desktop/skills/last30days` on first use, MIT license). **Known limitation — Windows:** the upstream maintainer's own README states *"Windows support is deferred until per-platform manifest entry points are sorted out."* Confirmed in this workspace's own use (2026-07-19): on Windows, X/Twitter requires live browser cookies the engine cannot extract in a non-interactive session, YouTube needs `yt-dlp` (the tool's own error message suggests `brew install`, which doesn't exist on Windows), and Digg/arXiv/Techmeme need `npx`/Node.js, which frequently isn't present either — GitHub issue [#823](https://github.com/mvanhorn/last30days-skill/issues/823) tracks a specific Windows Node-shim process/RAM problem. In practice this means a Windows run is usually limited to **Reddit (post titles/some comments), Hacker News, GitHub, and web search** — real evidence, but roughly half the tool's designed source coverage. Direct `WebFetch` to `reddit.com` is also blocked in Claude Code's sandbox, so Reddit comment bodies beyond what the engine itself captures aren't independently re-readable. None of this is a flaw in this workspace's process — it's the upstream tool's documented platform gap; budget for thinner evidence and more `[LOW-EVIDENCE]`-tagged findings on Windows than macOS/Linux.

## design-report

**Trigger:** "design this", "make it look good", "turn this into a report", "make a deck", "export as PDF/PPTX/DOCX", "design system", "DESIGN.md", "wireframe this".
**Give it:** A visual artifact to design (deck/landing page/prototype) and/or structured findings to format into a document.
**Get back:** Clarifying questions → a low-fidelity pass → a persisted `DESIGN.md` token file (colors/typography/motion/mascot) that carries across later artifacts in the project, and/or a DOCX/PPTX/XLSX/PDF report.
**Dependency:** References several GitHub design skills (see its own Attribution) but does not auto-clone any of them — for DOCX/PPTX/XLSX/PDF output it checks whether an Office-generation tool is actually available in the session first and says so if not.

## agent-builder

**Trigger:** "build me an agent for X", "design an AI worker", "should this run locally or in the cloud", "daily briefing agent", "manage a team of agents".
**Give it:** What you want a worker to do (or let it extract that from an unstructured context dump).
**Get back:** A worker design doc (goal/context/tools/memory/verification, five mandatory fields) after first observing 10-20 real cases of how a human currently does the task, plus a checked cloud-vs-local model routing decision; if you actually need several workers running continuously, an operations control-plane recommendation (Paperclip/Harbour/AgentField).
**Dependency:** Does not install or clone anything — names real tools (Ollama, Paperclip, promptfoo, etc.) and lets you install what you choose.

## distribution

**Trigger:** "distribution plan", "how do I market this", "where should I promote this", "launch this product", "growth ideas".
**Give it:** The product/idea and its target audience.
**Get back:** 3-5 concrete, named channel angles (not "try social media"), each with why the audience is already there, the trust-building move before any ask, and which `marketingskills` specialist to use for execution detail.
**Runtime dependency: `marketingskills`** (cloned to `~/Desktop/skills/marketingskills` on first use, MIT license, 47 specialist skills). `[ASSUMPTION - unverified, confirm with user]` on Windows compatibility — it appears to be a pure-Python/text skill library rather than a browser-cookie/media-CLI tool like `last30days`, but no upstream issue search has actually confirmed the absence of a Windows-specific gap the way `last30days`'s was (see that entry above).

## curator

**Trigger:** "curate this for me", "hot take on X", "make a short video about this news", "7-day content sprint", "react to this launch".
**Give it:** A niche/topic to watch.
**Get back:** What's timely in that niche right now, a specific honest-opinion angle (not a bland summary), scripted via `marketingskills`' `social` skill.
**Runtime dependency: `last30days`** — same Windows limitation as `biz-council` above applies here too (same underlying engine call).

## vibe-coder

**Trigger:** "vibe coding workflow", "how should I structure this coding session", "plan mode", "set up my coding agent workflow", "which tool for this task".
**Give it:** Nothing upfront — it runs at the start of a coding session on your own project.
**Get back:** A harness check (Commands/Rules/Skills/Hooks), task-to-tool routing, then a mandatory plan gate before any code is touched — the plan itself surfaces unknowns first (blind-spot pass, brainstorm/prototype, interview, reference) rather than assuming the request is fully specified, and tracks oversized scope as issue-tracker tickets instead of one giant plan.
**Dependency:** Names Context7 (MCP server for doc freshness) as optional — not installed by this skill.

## video-producer

**Trigger:** "render this as a video", "make this into a short video", "build a video intro", "animate this infographic".
**Give it:** A script/asset list (often from `curator`'s output).
**Get back:** An actual rendered video file (intros, transitions, lower thirds, animated infographics) via `hyperframes`, with `ShortGPT` for footage/voiceover sourcing on a full auto-pipeline request.
**Dependency:** Does not vendor `hyperframes`/`ShortGPT` — names them, checks availability before promising output.

## personal-memory

**Trigger:** "set up my second brain", "make Claude remember me", "persistent memory for Claude", "Obsidian + Claude", "LLM wiki".
**Give it:** Nothing upfront — it first diagnoses which of 5 memory stages you're already at.
**Get back:** The next concrete setup step only (never jumps straight to the heaviest stage) — built-in Memory → `CLAUDE.md` rules file → a queryable wiki (either an Obsidian vault + MCP, or Google's Obsidian-free **Open Knowledge Format**) → self-consolidation.
**Dependency:** Does not install Obsidian or any MCP server — names real candidates (`AgriciDaniel/claude-obsidian`, `GoogleCloudPlatform/knowledge-catalog`, etc.) and lets you choose.

## game-dev

**Trigger:** "build me a game", "make a 2D game", "make a 3D game", "unreal engine mcp", "game dev with claude code", "playtest my game".
**Give it:** The engine (or "greenfield" to get help choosing one) and what you want built.
**Get back:** A locked one-page design doc (unit/entity tree, resource/economy structure, enemy/AI behavior patterns) via `vibe-coder`'s plan gate, then routing to the right engine-specific skill (Unreal MCP, or Godot/Unity/Phaser/etc.), an asset pipeline, and verification by actually playing the build.
**Dependency:** Does not install any engine — routes to MCP/skill layers on top of an engine you already have.

## biz-ops

**Trigger:** "build a DCF model", "budget forecast", "SaaS metrics", "pricing strategy", "respond to this RFP", "vendor management", "procurement".
**Give it:** The finance/commercial/operations question for an already-existing business.
**Get back:** Routing into the matching category (Finance / Commercial / Business Operations) of `alirezarezvani/claude-skills`.
**Dependency:** Does **not** auto-clone — the underlying library must be installed separately by you (`/plugin install finance-skills@claude-code-skills`, the pattern the upstream repo documents itself). This skill checks whether it's actually available before proceeding rather than assuming.

## writing

**Trigger:** "humanize this text", "edit this to sound less like AI", "write this in my voice", "write a blog post about X", "polish this essay".
**Give it:** A draft, or a request to write from scratch, plus a voice sample if you want it matched.
**Get back:** Prose edited against 33 catalogued AI-writing patterns (`blader/humanizer`) with an explicit false-positive checklist so it doesn't over-edit already-clean writing.
**Dependency:** References `humanizer`/`avoid-ai-writing`/etc. in its own words — does not clone or vendor them.

## social-carousel

**Trigger:** "make a carousel", "instagram carousel", "linkedin carousel", "slide post", "turn this trend into a post", "carousel about X".
**Give it:** A niche/topic to find a real trend angle for (or a trend you've already identified), plus target platform (Instagram vs. LinkedIn) if known.
**Get back:** A multi-slide carousel exported as individual PNGs at exact platform dimensions, built on trend research rather than a guessed topic — output files for you to review and post yourself (never auto-posted).
**Runtime dependency: `last30days`** — same Windows limitation as `biz-council` above applies here too (same underlying engine call). **Runtime dependency: `open-carrusel`** (Instagram, default) or `carousel-generator` (LinkedIn) — requires Node.js locally; the first invocation may ask to clone and run `npm run setup`.

---

## Not yet built

Planning, manufacturing, sales, and financial operations (cash-flow/runway discipline) have no skill yet. `genie` says so honestly rather than improvising — see [`_shared/ROUTING.md`](_shared/ROUTING.md) "Not yet built" for what was actually evaluated and why each was deferred (thin GitHub evidence, not just unconsidered).
