# skills

Claude Skills workspace. Each subfolder is a skill (`SKILL.md` + supporting files) usable by Claude Code / Cowork / other agent hosts.

This repository's own content (`genie/`, `biz-council/`, `design-report/`, `_shared/`, this README) is [MIT licensed](LICENSE). Third-party projects it references are NOT covered by that license — check the "Referenced sites" table below before reusing anything derived from them.

---

## 사용법 (한글)

1. 이 저장소를 그대로 clone 또는 다운로드해서 원하는 위치에 둡니다.
2. `genie/`, `biz-council/`, `design-report/` 폴더를 각자 쓰는 에이전트 호스트의 스킬 디렉터리에 연결합니다 (예: Claude Code라면 `~/.claude/skills/` 아래에 심볼릭 링크하거나 복사).
3. 아무 요청이든 **"지니야" / genie**를 부르면, `_shared/ROUTING.md`를 읽고 알맞은 전문 스킬과 호출 방법을 알려줍니다. 스킬 이름을 몰라도 됩니다.
4. 특정 스킬을 바로 쓰고 싶으면 이름으로 직접 호출해도 됩니다 (예: "biz-council로 이 아이디어 검증해줘").
5. 아직 없는 분야(기획/마케팅/제조/판매 등)를 요청하면 genie가 "없다"고 정직하게 답하고, 새로 만들지 물어봅니다 — 만들 때도 항상 같은 절차(GitHub에서 별점 높은 실제 후보 조사 → 라이선스 확인 → 방법론만 발췌해 원문 그대로 베끼지 않고 재작성 → `_shared/ROUTING.md`에 한 줄 추가)를 따릅니다.
6. `_shared/CORE-LAWS.md`는 모든 스킬이 공유하는 규칙(추측 금지, GitHub 라이브러리는 별점순 채택, 코드로 구현될 경우의 구조 원칙)입니다 — 새 스킬을 추가하거나 수정할 때 이 파일을 참조하세요.
7. last30days는 라이선스가 명확(MIT)해서 필요 시 자동으로 다시 clone되지만, llm-council/anthropics-skills처럼 라이선스가 불명확한 참고 자료는 이 저장소에 절대 복사(vendoring)하지 않습니다 — 링크와 방법론 설명만 있습니다.

## Usage (English)

1. Clone or download this repository as-is.
2. Point your agent host's skills directory at `genie/`, `biz-council/`, and `design-report/` (e.g. for Claude Code, symlink or copy them under `~/.claude/skills/`).
3. Call **`genie`** for anything — it reads `_shared/ROUTING.md` and tells you which specialist skill to invoke. You don't need to know skill names.
4. You can also invoke a specific skill directly by name (e.g. "validate this idea with biz-council").
5. If you ask for a domain that doesn't exist yet (planning/marketing/manufacturing/sales/etc.), `genie` says so honestly and offers to build one — always via the same process: find real GitHub candidates ranked by stars → check their license → extract methodology and rewrite it in original wording (never copy verbatim) → add one row to `_shared/ROUTING.md`.
6. `_shared/CORE-LAWS.md` holds the rules every skill shares (no speculation, GitHub libraries ranked by real star counts, code-architecture principles if a design doc is ever implemented) — read it before adding or editing any skill.
7. `last30days` has a clear license (MIT) so it's auto-cloned on demand when missing; anything with an unclear license (`llm-council`, `anthropics/skills`) is never vendored into this repo — only linked and described in this skill's own words.

---

## Entry point

Call **`genie`** for anything — it reads `_shared/ROUTING.md` and routes you to the right specialist skill below. It does not solve requests itself, and it says so honestly when no specialist exists yet for a given domain (see `genie/SKILL.md`).

## Shared foundation

- [`_shared/CORE-LAWS.md`](_shared/CORE-LAWS.md) — LAW 0 (no speculation + canonical evidence tags), LAW 1 (GitHub library selection ranked by real star counts), LAW 2 (UI/logic separation, class structure, explicit success/failure returns — if a design doc becomes code). Every skill below references this instead of duplicating it.
- [`_shared/ROUTING.md`](_shared/ROUTING.md) — the table `genie` reads to dispatch requests.

## My skills (rewritten/fused — kept here)

| Skill | What it does |
|---|---|
| [`genie/`](genie/SKILL.md) | Router / single entry point. Matches a request to a specialist skill and tells the host/user what to invoke; never fabricates capability it doesn't have. |
| [`biz-council/`](biz-council/SKILL.md) | Researches real user signal (Reddit, X, YouTube, TikTok, Instagram Reels, Hacker News, Polymarket, web + a Korean-web supplement), runs it through a 5-advisor council for multi-angle judgment, then produces a precise, evidence-cited business/product design document. |
| [`design-report/`](design-report/SKILL.md) | Gives a visual artifact a deliberate design direction, and/or formats structured findings (e.g. a `biz-council` document) into a DOCX/PPTX/XLSX/PDF report. |

**Not yet built:** planning, marketing, manufacturing, sales specialists. `genie` will say so rather than improvise if one of these is requested — see `_shared/ROUTING.md` "Not yet built" for how a new one gets added (same process every time: find real GitHub candidates ranked by stars, fuse the methodology, write a new `SKILL.md`, add a routing row).

## Referenced sites (not vendored — methodology only, or a runtime dependency cloned on demand)

| Project | Link | Stars (checked) | License | Role |
|---|---|---|---|---|
| **last30days** | [github.com/mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) | 52.5k (checked 2026-07-17 via GitHub page) | MIT | **Runtime dependency of `biz-council`.** Not tracked in this repo — cloned into `~/Desktop/skills/last30days` on first use if missing, and ignored by `.gitignore`. |
| **llm-council** | [aiwithremy/claude-skills-llm-council](https://github.com/aiwithremy/claude-skills-llm-council) (fork of [karpathy/llm-council](https://github.com/karpathy/llm-council)) | not verified in this pass | Unconfirmed — **neither repo has a LICENSE file** (verified directly, not from a secondary source); both default to all-rights-reserved | Methodology reference only for `biz-council`'s council step. Not vendored, not redistributed verbatim — `biz-council` describes the approach in its own words and fetches the original live via WebFetch rather than storing a copy. |
| **gstack** | [github.com/garrytan/gstack](https://github.com/garrytan/gstack) | not verified in this pass | MIT | Methodology reference only for `biz-council`'s design-doc step (`/spec`, `/plan-ceo-review` question frameworks). Its own runtime is intentionally excluded. |
| **anthropics/skills** | [github.com/anthropics/skills](https://github.com/anthropics/skills) | 162k (checked 2026-07-17 via GitHub page) | Mixed: README says many skills are Apache 2.0, while `docx`/`pdf`/`pptx`/`xlsx` are source-available, not open source. Treat referenced document skills as `[LICENSE-UNCONFIRMED]` for redistribution. | `design-report`'s primary design + report-format reference, description-only. |
| **tfriedel/claude-office-skills** | [github.com/tfriedel/claude-office-skills](https://github.com/tfriedel/claude-office-skills) | 787 (checked 2026-07-17 via GitHub API) | Unconfirmed — no LICENSE file (verified) | `design-report`'s fallback reference for DOCX/PPTX/XLSX/PDF generation. |
| **Helena Liu / Product Camps** | [youtube.com/@HELENA-LIU](https://www.youtube.com/@HELENA-LIU) | n/a (YouTube channel) | n/a | Original source that surfaced `last30days`, `llm-council`, and `gstack` as "free AI employees" in a video; motivated this whole workspace. |

## Why the originals aren't kept locally

`llm-council` and `gstack` were cloned only to read their SKILL.md methodology, which is now folded into `biz-council/SKILL.md` by reference and summary — keeping the full repos added no further value. `last30days` is a real runtime dependency (not just methodology), so it is not tracked here; `biz-council` re-clones it on demand and `.gitignore` keeps that local runtime copy out of this repo. `anthropics/skills` is mixed-license/source-available depending on subfolder — `design-report` references its docx/pdf/pptx/xlsx and frontend-design skills without vendoring, by design, not by oversight.
