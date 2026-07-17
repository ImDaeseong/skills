# Routing table

One row per specialist skill. `genie` reads this file to decide where to send a request. Keep descriptions short and trigger-focused — this file is meant to stay small enough that `genie` can scan it in one pass.

| Skill | Path | Covers | Trigger phrases |
|---|---|---|---|
| `biz-council` | `../biz-council/SKILL.md` | Research real users (Reddit/X/YouTube/TikTok/Reels/HN/Polymarket/web + KR-web supplement) → 5-advisor council judgment → evidence-cited business/product design document | "council this", "validate this business idea", "design a business around X", "research and council this" |
| `design-report` | `../design-report/SKILL.md` | Visual/UI design direction for an artifact (deck, landing page, prototype) + turning structured data/findings into a formatted report (DOCX/PPTX/XLSX/PDF) | "design this", "make it look good", "turn this into a report", "make a deck/presentation" |

## Not yet built

Planning, marketing, manufacturing, and sales specialist skills do not exist yet. When a request needs one of these, `genie` says so honestly (per its own SKILL.md) instead of improvising. To add one: research real GitHub candidates for that domain (ranked by stars, per `../_shared/CORE-LAWS.md` LAW 1), fuse the methodology into a new `SKILL.md` under a new folder, then add a row here.
