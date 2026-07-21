# skills

Claude Skills workspace. Each subfolder is a skill (`SKILL.md` + supporting files) written for Claude Code / Cowork. Other Agent Skills-compatible hosts may be able to load these, but `allowed-tools` names Claude-specific tools (e.g. `AskUserQuestion`, `Task`, `Bash`) — a strict host that only permits `name`/`description` in frontmatter, or that maps tool names differently, may need those translated before a skill runs correctly.

All original content tracked in this repository is [MIT licensed](LICENSE). Third-party projects it references are not included or relicensed; review [NOTICE.md](NOTICE.md) and [`ATTRIBUTION.md`](ATTRIBUTION.md) before installing or reusing external material.

---

## 사용법 (한글)

1. **설치.** 이 저장소를 그대로 clone/다운로드한 뒤, 14개 스킬 폴더(`genie/`, `biz-council/`, `design-report/`, `agent-builder/`, `distribution/`, `curator/`, `vibe-coder/`, `video-producer/`, `personal-memory/`, `game-dev/`, `biz-ops/`, `writing/`, `social-carousel/`, `prompt-craft/`)를 쓰는 에이전트 호스트의 스킬 디렉터리에 연결합니다 (Claude Code라면 `~/.claude/skills/` 아래에 심볼릭 링크하거나 복사).
2. **호출.** 요청 내용을 모르면 **"지니야" / genie**를 부르세요 — `_shared/ROUTING.md`를 읽고 알맞은 전문 스킬과 호출 방법을 알려줍니다. 스킬 이름을 알면 바로 호출해도 됩니다 (예: "biz-council로 이 아이디어 검증해줘").
3. **빈 도메인.** 아직 없는 분야(기획/제조/판매/재무운영 등)를 요청하면 genie가 "없다"고 정직하게 답하고 새로 만들지 물어봅니다 — 만들 때도 항상 같은 절차(GitHub에서 별점 높은 실제 후보 조사 → 라이선스 확인 → 방법론만 발췌해 원문 그대로 베끼지 않고 재작성 → `_shared/ROUTING.md`에 한 줄 추가)를 따릅니다. 근거가 부족하면 "만들지 않고 왜 안 만들었는지"를 기록합니다 — 재무운영이 그 사례입니다.
4. **공유 규칙.** `_shared/CORE-LAWS.md`(LAW 0 추측 금지, LAW 1 별점순 라이브러리 채택, LAW 2 코드 구현 시 구조 원칙, LAW 3 검증 루프 형식, LAW 4 스킬 작성법 자체)를 모든 스킬이 공유합니다 — 새 스킬을 추가·수정할 때 이 파일을 먼저 참조하세요.
5. **런타임 의존성.** `last30days`와 `marketingskills`는 라이선스가 명확(MIT)해서 필요 시 자동으로 다시 clone되지만, `llm-council`/`anthropics/skills`처럼 라이선스가 불명확한 참고 자료는 이 저장소에 절대 복사(vendoring)하지 않습니다 — 링크와 방법론 설명만 있습니다.
6. **검증.** 최초 clone 후 `powershell.exe -NoProfile -File scripts/install-git-hooks.ps1`로 훅을 설치하고, 커밋 전에 `powershell.exe -NoProfile -File scripts/validate_workspace.ps1`과 `powershell.exe -NoProfile -File scripts/validate_links.ps1`을 실행하세요. 검사는 14개 스킬의 구조·권한·라우팅·날짜와 수익 주장, MCP, 학습·기억, 에이전트 아키텍처, 반복 루프, 금융 행동 안전 가드를 확인합니다. 커밋 훅과 GitHub Actions에서도 검증합니다.
7. **개별 스킬 사용법.** 각 스킬을 언제/어떻게 호출하는지, 무엇을 입력해야 하고 무엇을 받는지, 알려진 제약(예: `last30days`의 Windows 미지원)까지 스킬별로 정리한 상세 가이드는 [`USAGE.md`](USAGE.md)를 참조하세요.

## Usage (English)

1. **Install.** Clone or download this repository as-is, then point your agent host's skills directory at all 14 skill folders (`genie/`, `biz-council/`, `design-report/`, `agent-builder/`, `distribution/`, `curator/`, `vibe-coder/`, `video-producer/`, `personal-memory/`, `game-dev/`, `biz-ops/`, `writing/`, `social-carousel/`, `prompt-craft/`) — for Claude Code, symlink or copy them under `~/.claude/skills/`.
2. **Invoke.** Call **`genie`** for anything — it reads `_shared/ROUTING.md` and tells you which specialist skill to invoke. You don't need to know skill names, but you can also call one directly by name (e.g. "validate this idea with biz-council").
3. **Missing domains.** If you ask for a domain that doesn't exist yet (planning/manufacturing/sales/financial operations/etc.), `genie` says so honestly and offers to build one — always via the same process: find real GitHub candidates ranked by stars → check their license → extract methodology and rewrite it in original wording (never copy verbatim) → add one row to `_shared/ROUTING.md`. When the evidence doesn't clear the bar, the deferral itself gets recorded (financial operations is the example — see the table below).
4. **Shared rules.** `_shared/CORE-LAWS.md` holds LAW 0 (no speculation), LAW 1 (GitHub libraries ranked by real star counts, license-gated), LAW 2 (code-architecture principles if a design doc becomes code), LAW 3 (a formal verification-loop contract), and LAW 4 (how to author a skill itself) — read it before adding or editing any skill.
5. **Runtime dependencies.** `last30days` and `marketingskills` have clear licenses (MIT) so they're auto-cloned on demand when missing; anything with an unclear license (`llm-council`, `anthropics/skills`) is never vendored into this repo — only linked and described in this skill's own words.
6. **Verify.** After the first clone, install the hook with `powershell.exe -NoProfile -File scripts/install-git-hooks.ps1`. Before committing, run `powershell.exe -NoProfile -File scripts/validate_workspace.ps1` and `powershell.exe -NoProfile -File scripts/validate_links.ps1`. They validate all 14 skills, permissions, routing, dates, claim attribution, MCP, learning and memory, architecture, repeated loops, financial actions, and local links. The hook and GitHub Actions run these checks again.
7. **Per-skill usage.** For exactly when/how to invoke each skill, what to give it, what it returns, and known limitations (e.g. `last30days`'s Windows gap), see [`USAGE.md`](USAGE.md).

---

## Entry point

Call **`genie`** for anything — it reads `_shared/ROUTING.md` and routes you to the right specialist skill below. It does not solve requests itself, and it says so honestly when no specialist exists yet for a given domain (see `genie/SKILL.md`).

## Verification guard

`scripts/validate_workspace.ps1` checks structural and safety rules; `scripts/validate_links.ps1` checks local Markdown links. Run both before committing. The pre-commit hook runs workspace validation locally, and `.github/workflows/validate.yml` runs both checks on pushes and pull requests. Install the local hook once per clone with `powershell.exe -NoProfile -File scripts/install-git-hooks.ps1`.

## Shared foundation

- [`_shared/CORE-LAWS.md`](_shared/CORE-LAWS.md) — **LAW 0** (no speculation + canonical evidence tags), **LAW 1** (GitHub library selection ranked by real star counts, license-gated), **LAW 2** (UI/logic separation, class structure, explicit success/failure returns — if a design doc becomes code), **LAW 3** (every validate/retry/fix pass runs a bounded, evidence-based verification loop with a stated exit and HOLD condition), **LAW 4** (how to author a skill itself — description as trigger, progressive disclosure, state the non-obvious; sourced from Anthropic's own engineering guidance). Every skill below references this instead of duplicating it.
- [`_shared/ROUTING.md`](_shared/ROUTING.md) — the table `genie` reads to dispatch requests.

## My skills

| Skill | What it does |
|---|---|
| [`genie/`](genie/SKILL.md) | Router / single entry point. Matches a request to a specialist skill and tells the host/user what to invoke; never fabricates capability it doesn't have. |
| [`biz-council/`](biz-council/SKILL.md) | Researches real user signal (Reddit, X, YouTube, TikTok, Instagram Reels, Hacker News, Polymarket, web + a Korean-web supplement); if multiple candidate ideas are still open, scores them (growing/low-competition/personal-fit) before proceeding; runs the chosen idea through a 5-advisor council for multi-angle judgment, then produces a precise, evidence-cited business/product design document. |
| [`design-report/`](design-report/SKILL.md) | Gives a visual artifact a deliberate design direction — anti-slop process via `taste-skill`/`ui-ux-pro-max-skill`, motion/interaction feel, mascot/illustration consistency, reference-image anchoring — persisted as a portable `DESIGN.md` token file (Google's open spec) so it carries across pages/media/tools instead of drifting, verified by rendering when the artifact actually renders; also formats structured findings (e.g. a `biz-council` document) into a DOCX/PPTX/XLSX/PDF report. |
| [`agent-builder/`](agent-builder/SKILL.md) | Designs a production-disciplined AI worker (goal, context, tools/permissions, memory, verification), separates reasoning patterns/RAG/MCP/frameworks from full architecture, and rejects unnecessary agentic complexity. Repeated loops require external state, idempotency, progress evidence, independent verification, bounded nested budgets, checkpoints, stop/HOLD conditions, and human approval for consequential actions. |
| [`distribution/`](distribution/SKILL.md) | Finds where target-audience attention already exists and produces 3-5 concrete trust-first channel angles; wraps `marketingskills` as a runtime dependency for execution detail (SEO/CRO/ads/launch/PR/etc.), never reimplements it. |
| [`curator/`](curator/SKILL.md) | Watches a niche for what's timely (`last30days`), forms a specific honest-opinion angle, and scripts it via `marketingskills`' `social` skill. Educational content must be checked against the primary source with closed-source active recall, delayed re-test, and concrete application rather than treating an AI summary as understanding. |
| [`vibe-coder/`](vibe-coder/SKILL.md) | Workflow discipline for a human coding alongside AI agents on their own project — build the harness deliberately, task-to-tool routing, a reviewed-plan gate before implementation (Research→Plan→Execute→Review→Ship) that surfaces unknowns first (blind-spot pass, brainstorm/prototype, interview, reference) and tracks oversized scope as issue-tracker tickets, Context7 for doc freshness, terse replies once approved, verification+review before "done." Distinct from `agent-builder` (that designs autonomous business workers; this is the human's own live coding-session discipline). |
| [`video-producer/`](video-producer/SKILL.md) | Turns a script/asset list (e.g. from `curator`) into an actual rendered video — intros, transitions, lower thirds, animated infographics — via `hyperframes` (HTML→deterministic MP4, Apache-2.0), with `ShortGPT` for footage/voiceover sourcing when the request needs a full auto-pipeline. Fills the video-assembly gap `curator` explicitly stops short of. |
| [`personal-memory/`](personal-memory/SKILL.md) | Stages a human's cross-session memory setup from built-in Memory through a self-consolidating Obsidian/LLM wiki. AI summaries are not promoted directly: durable learning notes retain the primary-source link, separate facts from interpretation, require delayed active recall, and attach a real application or decision. |
| [`game-dev/`](game-dev/SKILL.md) | Builds/extends a 2D or 3D game with an AI agent driving the actual engine — Unreal via Epic Games' own first-party MCP plugin, or Godot/Unity/Phaser/Three.js via a routed engine skill — locks a one-page design doc (unit/entity tree, resource/economy structure, enemy/AI behavior patterns) via `vibe-coder`'s plan gate before any gameplay code, then builds the asset/animation pipeline and verifies by playing the build (browser automation or the engine's own test harness) rather than reading the render code. |
| [`biz-ops/`](biz-ops/SKILL.md) | Runs the back-office of an already-existing business — financial analysis (DCF/budgeting/forecasting/SaaS metrics), commercial deal work (pricing/RFP response/partnerships), business operations (vendor management/procurement/process mapping) — by routing into `alirezarezvani/claude-skills`' Finance/Commercial/Business-Operations categories rather than reimplementing them. Distinct from `biz-council` (one-time new-idea validation, not ongoing operations). |
| [`writing/`](writing/SKILL.md) | Writes/edits prose (essays, blog posts, articles, personal writing) to read as a specific human wrote it, via `blader/humanizer`'s 33 catalogued AI-writing patterns (Wikipedia's "Signs of AI writing," em dashes, rule-of-three, inflated significance, etc.) with an explicit false-positive checklist to avoid over-editing legitimately clean prose; matches a provided voice sample rather than defaulting to a generic register. |
| [`social-carousel/`](social-carousel/SKILL.md) | Chains real trend research (`last30days`, reused from `biz-council`/`curator`/`distribution`) into a specific honest angle, then exports it as an Instagram/LinkedIn multi-slide carousel at exact platform dimensions via `open-carrusel` (MIT). Does not auto-post — hands back slide files for the user to review and publish. |
| [`prompt-craft/`](prompt-craft/SKILL.md) | Writes or improves a standalone LLM prompt — picks a technique (zero-shot/few-shot/CoT/ReAct/structured output) via `dair-ai/Prompt-Engineering-Guide`, checks the target model's own current vendor docs before trusting a technique that may be outdated, and diagnoses an underperforming prompt's actual failure mode before rewriting. Distinct from `agent-builder` (persistent worker design) and `vibe-coder` (coding-session discipline). |

**Not yet built:** planning, manufacturing, sales, financial operations (cash-flow/runway discipline). `genie` will say so rather than improvise if one of these is requested — see `_shared/ROUTING.md` "Not yet built" for how a new one gets added. Financial operations and planning were both actively evaluated and deferred, not just unconsidered — see [`ATTRIBUTION.md`](ATTRIBUTION.md).

## Attribution

Every third-party project a skill references, cites, or depends on at runtime — with real star counts, license checks, and the reasoning behind each adoption/deferral — now lives in its own file: [`ATTRIBUTION.md`](ATTRIBUTION.md). Kept separate from this README so the install/usage instructions above stay short; see that file for the per-skill evidence tables and the origin-story/cross-cutting evaluation log.
