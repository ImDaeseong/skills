# Usage guide

These are documented workflows, not a claim that every external integration has been executed here.

One section per skill: how to invoke it, what to give it, what you get back, and any known dependency or platform limitation. For the one-line "what it does" summary of each skill, see [README.md](README.md); for the raw trigger-phrase table `genie` reads, see [`_shared/ROUTING.md`](_shared/ROUTING.md).

## How invocation works

1. **Install first.** Point your agent host's skills directory at this repo's 26 skill folders (for Claude Code: symlink or copy each folder under `~/.claude/skills/`). Keep `_shared/` beside the installed skill folders: their `../_shared/` references require that layout. A `SKILL.md` file sitting in this repo alone is not "installed" — the host has to be pointed at it before it can trigger.
2. **Two ways to invoke:**
   - **Don't know which skill you need?** Call `genie` (or say "지니야") with your request in plain language. `genie` reads `_shared/ROUTING.md` and tells you which specialist skill to invoke — it does not do the work itself.
   - **Know the skill name?** Trigger it directly by using one of its trigger phrases (see each section below) or by naming it explicitly ("biz-council로 이 아이디어 검증해줘").
3. **Some skills clone an external tool at runtime** (marked "Runtime dependency" below) — the first invocation may ask permission to `git clone` a separate GitHub repo into `~/Desktop/skills/`. This is normal; see [`ATTRIBUTION.md`](ATTRIBUTION.md#why-the-originals-arent-kept-locally) for why those aren't vendored into this repo.

---

## genie

**Trigger:** "지니야", "genie", or any request that doesn't name a specific skill.
**Give it:** Your request in plain language, however unstructured.
**Get back:** Which specialist skill to invoke, or an honest "not built yet" if no skill covers the domain (see [`_shared/DEFERRED.md`](_shared/DEFERRED.md)).
**Dependency:** `_shared/CORE-LAWS.md` and `_shared/ROUTING.md`.

## biz-council

**Trigger:** "council this", "validate this business idea", "design a business around X", "give me a startup idea in X", "help me pick which idea to build".
**Give it:** A domain/niche (or say you want to explore broadly), and optionally an idea you've already picked.
**Get back:** Real Reddit/X/HN/YouTube evidence on the topic, scored candidate ideas (growing / low-competition / personal-fit / defensible-against-the-model-layer) if you haven't committed to one, then a 5-advisor council pass and an evidence-cited business/product design document.
**Runtime dependency: `last30days`** (cloned to `~/Desktop/skills/last30days` on first use, MIT). Run the upstream preflight to discover available sources and missing dependencies. Coverage depends on credentials and installed tools such as `yt-dlp` and Node.js; X has cookie and API-key options. The README's deferred Windows support statement concerns the Claude Desktop `.mcpb` bundle, not every CLI workflow. Windows execution was not tested in this document audit; label unavailable sources explicitly. See the [upstream README](https://github.com/mvanhorn/last30days-skill/blob/main/README.md).

## design-report

**Trigger:** "design this", "make it look good", "turn this into a report", "make a deck", "export as PDF/PPTX/DOCX", "design system", "DESIGN.md", "wireframe this".
**Give it:** A visual artifact to design (deck/landing page/prototype) and/or structured findings to format into a document.
**Get back:** Clarifying questions → a low-fidelity pass → a persisted `DESIGN.md` token file (colors/typography/motion/mascot) that carries across later artifacts in the project, and/or a DOCX/PPTX/XLSX/PDF report. If a generated PPTX still looks AI-made, a named second-pass fix (export as PPTX, import into a slide-design tool, unify font/palette, add design elements and animation) instead of just re-prompting.
**Dependency:** References several GitHub design skills (see its own Attribution) but does not auto-clone any of them — for DOCX/PPTX/XLSX/PDF output it checks whether an Office-generation tool is actually available in the session first and says so if not.

## agent-builder

**Trigger:** "build me an agent for X", "design an AI worker", "should this run locally or in the cloud", "daily briefing agent", "manage a team of agents".
**Give it:** What you want a worker to do (or let it extract that from an unstructured context dump).
**Get back:** A worker design doc (goal/context/tools/memory/verification, five mandatory fields) after first observing 10-20 real cases of how a human currently does the task, plus a checked cloud-vs-local model routing decision. A small fixed sequence of roles run once per job (e.g. research → write → image → assemble) is routed to Claude Code's own sub-agents + a `CLAUDE.md` runbook, not a framework; only when you actually need several workers running continuously does it recommend an operations control-plane (Paperclip/Harbour/AgentField).
**Dependency:** Does not install or clone anything — names real tools (Ollama, Paperclip, promptfoo, etc.) and lets you install what you choose.

## distribution

**Trigger:** "distribution plan", "how do I market this", "where should I promote this", "launch this product", "growth ideas".
**Give it:** The product/idea and its target audience.
**Get back:** 3-5 concrete, named channel angles (not "try social media"), each with why the audience is already there, the trust-building move before any ask, and which `marketingskills` specialist to use for execution detail.
**Runtime dependency: `marketingskills`** (cloned to `~/Desktop/skills/marketingskills` on first use, MIT). Read the selected specialist and its dependencies before execution; compatibility depends on the host and any tools that specialist uses. No platform execution test was performed in this document audit.

## curator

**Trigger:** "curate this for me", "hot take on X", "make a short video about this news", "7-day content sprint", "react to this launch".
**Give it:** A niche/topic to watch.
**Get back:** What's timely in that niche right now, a specific honest-opinion angle (not a bland summary), scripted via `marketingskills`' social-content specialist. This also requires the `marketingskills` runtime dependency described under `distribution`.
**Runtime dependency: `last30days`** — the preflight and source-availability caveats in `biz-council` apply here too.

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

## image-motion-graphics

**Trigger:** "이미지 한 장으로 모션그래픽", "가사와 MP3로 뮤직비디오", "가사와 WAV로 영상 만들어줘", "노래로 뮤직비디오 이미지 만들어줘", "레이어 분리 PSD", "PSD를 AEP로", "animate this still image", "turn this song into a music video".
**Give it:** One source image; or lyrics plus an MP3/WAV song file. When the lyrics and audio are attached together, “이 노래를 뮤직비디오로 만들어줘” is enough to request the measured full-song render. Add an aspect ratio, resolution, or editable PSD/AEP endpoint only when you want to override the defaults.
**Get back:** The requested stage of a one-scene pipeline: separable key visual, reconstructed transparent PNG layers and manifest, position-matched PSD, After Effects composition, or an inspected rendered clip.
**Dependency:** Requires a host-native image generator for reconstructed assets and installed Photoshop/After Effects for editable PSD/AEP output. It checks host image-generation and Adobe tool availability first, then stops at the nearest honest endpoint instead of fabricating proprietary files. The background stays motion-locked; low-frame-rate motion applies only to independent foreground, rain, and lighting layers.

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
**Get back:** Prose edited against the current AI-writing patterns in `blader/humanizer` (or `epoko77-ai/im-not-ai` for Korean) with an explicit false-positive checklist so it doesn't over-edit already-clean writing.
**Dependency:** References `humanizer`/`avoid-ai-writing`/etc. in its own words — does not clone or vendor them.

## social-carousel

**Trigger:** "make a carousel", "instagram carousel", "linkedin carousel", "slide post", "turn this trend into a post", "carousel about X".
**Give it:** A niche/topic to find a real trend angle for (or a trend you've already identified), plus target platform (Instagram vs. LinkedIn) if known.
**Get back:** A multi-slide carousel exported as individual PNGs at exact platform dimensions, built on trend research rather than a guessed topic — output files for you to review and post yourself (never auto-posted).
**Runtime dependency: `last30days`** — the preflight and source-availability caveats in `biz-council` apply here too. **Runtime dependency: `open-carrusel`** (Instagram, default) or `carousel-generator` (LinkedIn) — requires Node.js locally. `open-carrusel` requires Node.js 20+ and uses `npm run setup`; `carousel-generator` uses `npm install` and `npm run dev`, with an OpenAI API key for AI generation. Configure keys locally, never paste them into chat.

## prompt-craft

**Trigger:** "write me a better prompt", "how do I prompt X", "prompt engineering", "improve this prompt", "system prompt for X", "best way to prompt ChatGPT/Claude/Gemini".
**Give it:** The task the prompt needs to accomplish, the target model (if known), and an existing prompt if one is already underperforming.
**Get back:** A technique picked deliberately for the task shape (zero-shot/few-shot/CoT/ReAct/structured output), checked against the target model's own current vendor docs when a specific model is named (since static guides lag behind new releases), plus a short note on what was applied and why.
**Dependency:** Does not install or clone anything — references `dair-ai/Prompt-Engineering-Guide` and `Jeffallan/claude-skills`' `prompt-engineer` skill as methodology, and reads vendor docs live via WebFetch/WebSearch when freshness matters.

## erp-fundamentals

**Trigger:** "build an ERP", "ERP spec", "ERP requirements", "what modules does an ERP need", "design an ERP system", "SCM spec", "CRM spec".
**Give it:** The industry/vertical the ERP is for, if known (manufacturing, general accounting, trade/import-export, retail/apparel, or a specific platform like SAP/NetSuite) — it asks if not stated.
**Get back:** A starting module checklist (General Ledger, AP/AR, Procurement, Inventory, Order Management, HR/Payroll, CRM, master data — SCM can also cover planning, manufacturing, logistics, and product lifecycle; confirm SCM and CRM scope against the selected platform and industry) plus the verified standard that applies to the stated vertical (ISA-95, GAAP/IFRS, Incoterms/HS, GS1), to use as the acceptance-criteria seed for a proper spec pass. It does not produce the spec itself, connect to any real ERP/CRM software, or replace `biz-ops`'s ongoing back-office work once an ERP already exists.
**Dependency:** None — original content sourced from cited vendor/standards documentation (see its own Attribution), not an external package.

## ai-adoption-scout

**Trigger:** "다른 사람들은 AI를 어떻게 쓰나", "AI 활용 아이디어", "AI 도입 사례", "where else could we use AI", "AI use case ideas for my team", "how are other companies using AI".
**Give it:** Your actual task/team/business context, what's already in place, and any hard constraints (cost, data sensitivity, ruled-out tools).
**Get back:** Real, dated AI-usage signal for your domain (`last30days` + named usage reports over WebSearch), then 3-5 ranked adoption ideas (ready now / needs setup / needs more evidence) — never a generic three-example list. Hands off to `design-report` only if you want a stakeholder-ready document.
**Runtime dependency: `last30days`** — the preflight and source-availability caveats in `biz-council` apply here too.

## filing-analyst

**Trigger:** "10-K 분석", "사업보고서 분석", "이 회사 뭐하는 회사야", "역DCF", "reverse DCF", "implied growth rate".
**Give it:** A ticker/company name and market (US or Korea); a current share price if no live-quote tool is available in-session; earnings-call transcripts if you want the change-comparison step to include tone, since this skill has no transcript source of its own.
**Get back:** A one-page cited business/segment decoder, a multi-year comparison of what changed in the filing's own language, and a reverse-DCF implied-growth-rate read — every figure cites its filing page/section, and every output ends with an explicit not-investment-advice disclaimer.
**Dependency:** SEC EDGAR (`data.sec.gov`) needs no API key but requires a `User-Agent` header identifying the requester, capped at 10 requests/second. DART (Korean filings) requires a free personal API key from `opendart.fss.or.kr` — configure it locally and confirm only that it is available, never paste the key into chat. Missing access must be reported rather than filled with fabricated filings.

## sales-desk

**Trigger:** "research this prospect", "qualify this lead", "find decision makers at this company", "write a cold outreach sequence for X", "prep me for this sales call", "handle this sales objection".
**Give it:** A company URL or name, and which piece you need (full prospect research, just qualification, just contacts, outreach only, etc.) — it doesn't default to the heaviest 5-agent pipeline if you only need one piece.
**Get back:** BANT/MEDDIC qualification scoring, a decision-maker/buying-committee map sourced from the target company's own public site, a competitive-intel snapshot, an outreach sequence, meeting-prep notes, or a pipeline report — as a saved file (e.g. `PROSPECT-ANALYSIS.md`). Distinct from `biz-ops` (deal/pricing/RFP strategy) and `distribution` (channel/growth-marketing planning) — this is prospect-level sales execution.
**Runtime dependency: `ai-sales-team-claude`** ([github.com/zubair-trabzada/ai-sales-team-claude](https://github.com/zubair-trabzada/ai-sales-team-claude), cloned to `~/Desktop/skills/ai-sales-team-claude` on first use, MIT license, source-audited 2026-09-06 — see [`ATTRIBUTION.md`](ATTRIBUTION.md)). Needs `git` and Python 3; `reportlab`/`beautifulsoup4` are optional for PDF export/better parsing. Only fetches the target company's own public web pages (about/team/leadership) — never LinkedIn or a people-search service. **Caveat:** the upstream contact-finder script disables TLS certificate verification on its own fetches — avoid running it over an untrusted network.

## founder-finance

**Trigger:** "how much runway do we have", "should we make this hire", "what's our burn multiple", "check our unit economics", "build a 13-week cash flow forecast", "런웨이 계산".
**Give it:** Your actual numbers — current burn, cash on hand, headcount, ARR, or the specific hire/spend decision in question.
**Get back:** A direct answer against real thresholds (runway targets, burn multiple, LTV:CAC, CAC payback, Rule of 40) using your own figures, not the reference's example benchmarks. Distinct from `biz-ops` (DCF/valuation modeling for an established business) and `biz-council` (validating a brand-new idea) — this is day-to-day cash discipline for a bootstrapped or self-funded operator.
**Runtime dependency: `charlie-cfo-skill`** ([github.com/EveryInc/charlie-cfo-skill](https://github.com/EveryInc/charlie-cfo-skill), cloned to `~/Desktop/skills/charlie-cfo-skill` on first use, MIT license, source-audited 2026-09-06 — see [`ATTRIBUTION.md`](ATTRIBUTION.md)). Pure reference content — no scripts, no network calls, nothing to install beyond the clone itself.

---

## managing-up

**Trigger:** "팀장한테 어떻게 말해야", "매니징 업", "managing up", "일정 조정 요청", "상사 설득", "convince my manager", "push back on this deadline", "trade-off options for my manager".
**Give it:** The actual situation (what triggered this), the real technical/operational risk in specific terms, what decision you want your manager to make, and — if you know it — what your manager is actually accountable for this cycle. If you don't know the last one, say so; the skill drafts around the acknowledged gap instead of inventing a plausible-sounding KPI.
**Get back:** A draft message with 2-3 trade-off options (each with a real cost/risk attached, not vague terms), opening on the shared goal in your manager's own terms and ending with a specific one-line ask — not a flat refusal, and not a template with unfilled placeholders. Every number in the draft traces back to what you stated.
**Dependency:** None — self-contained, no external library or API. Distinct from `writing` (general tone/voice editing, not manager-specific negotiation).

## book-distiller

**Trigger:** "turn this book into a skill", "이 책을 스킬로 만들어줘", "make a skill from this PDF/document", "distill this book for Claude", "book to skill", "PDF를 스킬로".
**Give it:** A source document (PDF, EPUB, DOCX, HTML, Markdown, plain text, RTF, MOBI/AZW) and, if you have a preference, the target depth.
**Get back:** A structured skill written from the document — core mental models, per-chapter files loaded only when a later query touches them, a glossary, design patterns, and decision tables — plus where it was written and its estimated token footprint. The upstream cost preflight runs before generation; its copyright/publication gate applies before publishing, and its generated-skill security scan runs after generation, before delivery, loading, or publication. Private storage does not by itself establish permission to copy a book; the generated skill is handed back to you, not auto-registered into this workspace.
**Runtime dependency: `book-to-skill`** ([github.com/virgiliojr94/book-to-skill](https://github.com/virgiliojr94/book-to-skill), cloned to `~/Desktop/skills/book-to-skill` on first use, MIT license, source-audited 2026-08-14 — see [`ATTRIBUTION.md`](ATTRIBUTION.md)). Python 3.9+; some formats need optional extractors (`pdftotext`, Calibre for MOBI/AZW) which it offers to install (`--install-missing ask`, not forced). The "24×–51× fewer tokens" figure is the vendor's own self-reported claim (`[LOW-EVIDENCE]`), not independently benchmarked here. Distinct from `prompt-craft` (standalone prompts) and `agent-builder` (worker design).

## video-watcher

**Trigger:** "watch this video", "analyze this video/link", "what happens in this video", "summarize this youtube/tiktok video", "break down this video's hook", "이 영상 좀 봐줘", "이 틱톡 영상 분석해줘".
**Give it:** A video URL (YouTube, TikTok, Vimeo, Twitch clip, Loom, ~1,000 other yt-dlp-supported sites) or a local file path, and optionally a specific question.
**Get back:** An answer grounded in the frames and/or timestamped transcript actually obtained, with missing visual or audio evidence stated — a summary, a hook/retention breakdown, or a direct answer citing timestamps. Read-only: it does not edit or render anything.
**Runtime dependency: `claude-video`'s `watch` sub-skill** ([github.com/bradautomates/claude-video](https://github.com/bradautomates/claude-video), cloned to `~/Desktop/skills/claude-video` on first use, MIT license, source-audited 2026-08-21 — see [`ATTRIBUTION.md`](ATTRIBUTION.md)). Needs `ffmpeg`/`ffprobe`/`yt-dlp` locally (auto-installed on macOS via its own setup script); a Groq or OpenAI Whisper API key is optional, only used as a transcript fallback when native captions are missing. Distinct from `video-producer` (renders new content) and `shorts-clipper` (cuts an existing video into short clips).

## shorts-clipper

**Trigger:** "make shorts from this video", "clip this into tiktoks", "extract shorts/reels from this", "cut this long video into clips", "이 영상으로 쇼츠 만들어줘", "롱폼을 숏폼으로".
**Give it:** A longform local video file.
**Get back:** An interactive 10-step pipeline — transcribe, Claude scores 8-12 candidate segments against a hook/coherence/emotion/value/payoff rubric, you approve/adjust which segments and caption style, boundaries snap to clean word/sentence cuts, Remotion renders animated captions, FFmpeg exports platform-optimized files (YouTube Shorts/TikTok/Instagram Reels) with post-export validation. Never auto-renders without your approval.
**Runtime dependency: `claude-shorts`** ([github.com/AgriciDaniel/claude-shorts](https://github.com/AgriciDaniel/claude-shorts), cloned to `~/Desktop/skills/claude-shorts` on first use, MIT license for the wrapper, source-audited 2026-08-21 — see [`ATTRIBUTION.md`](ATTRIBUTION.md)). Needs `ffmpeg`, Python 3.10+ (venv for `faster-whisper`), Node.js 18+/npm, `jq`, and Bash. The upstream Windows setup requires WSL2; GPU auto-detected and used if present. **License gate:** the Remotion npm package it renders through is source-available (free for individuals/non-profits/orgs ≤3 employees, paid above that) — the skill confirms your eligibility before rendering. Distinct from `video-producer` (renders brand-new content) and `video-watcher` (watches without cutting).

## footage-editor

**Trigger:** "edit this footage", "cut the filler words from this video", "color grade this clip", "add subtitles to this raw footage", "turn these takes into a video", "이 영상 편집해줘", "촬영본 편집".
**Give it:** A folder of already-shot raw footage (talking head, montage, tutorial, interview, etc.).
**Get back:** A conversation-driven edit — proposed cut/grade/subtitle strategy in plain English first, then (on your approval) a rendered clip with filler words and dead air removed at word-boundary precision, per-segment color grading, burned subtitles, and optional overlay animations — self-checked at every cut boundary before being shown to you.
**Runtime dependency: `video-use`** ([github.com/browser-use/video-use](https://github.com/browser-use/video-use), cloned to `~/Desktop/skills/video-use` on first use, MIT license, source-audited 2026-09-06 — see [`ATTRIBUTION.md`](ATTRIBUTION.md)). Needs `ffmpeg`/`ffprobe` and Python 3.10+ locally; Node.js 22+ only if an animation slot needs HyperFrames/Remotion. **Required API key:** transcription runs through ElevenLabs' Scribe API — an `ELEVENLABS_API_KEY` is a hard requirement, and footage audio (not video) is sent to that API; the skill confirms you're comfortable with this before proceeding. **License gate:** if an animation slot uses Remotion specifically, the same source-available employee-count gate as `shorts-clipper` applies. Distinct from `video-producer`/`image-motion-graphics` (generate new content) — this edits footage that was already shot.

## diagram-forge

**Trigger:** "diagram this architecture", "make a workflow diagram I can share", "export this as an interactive diagram", "visualize this system as HTML", "convert this Mermaid diagram to HTML".
**Give it:** A plain-language description of the system/process/sequence/pipeline/state machine to diagram, or a pasted Mermaid `flowchart`/`sequenceDiagram`/`stateDiagram`.
**Get back:** A standalone, validated interactive HTML file (architecture/workflow/sequence/data-flow/lifecycle) with its own viewer — search, focus, route tracing, dark/light toggle — plus export to PNG/JPEG/WebP/SVG/WebM. Distinct from a diagram drawn inline inside the current Artifact/chat, which stays there rather than becoming a portable file.
**Runtime dependency: `archify`** ([github.com/tt-a1i/archify](https://github.com/tt-a1i/archify), installed via its own `npx skills add tt-a1i/archify -g` or cloned to `~/Desktop/skills/archify-src` on first use, MIT license, source-audited 2026-09-06 — see [`ATTRIBUTION.md`](ATTRIBUTION.md)). Needs Node.js locally; no other install required inside the skill package itself.

---

## Not yet built

Planning, manufacturing, and literal ERP/SCM/CRM software-system integration have no skill yet. Prospect-level sales execution is covered by `sales-desk`; founder cash-flow/runway discipline is covered by `founder-finance`. `genie` says so honestly rather than improvising — see [`_shared/DEFERRED.md`](_shared/DEFERRED.md) for what was actually evaluated and why each was deferred (thin GitHub evidence, not just unconsidered).
