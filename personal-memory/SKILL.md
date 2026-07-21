---
name: personal-memory
description: "Set up a persistent personal memory system so Claude knows the user across sessions instead of starting cold every time — a staged roadmap from the built-in Memory feature, to a CLAUDE.md rules file, to an Obsidian-backed LLM wiki, to a self-consolidating knowledge base. MANDATORY TRIGGERS: 'set up my second brain', 'make Claude remember me', 'persistent memory for Claude', 'Obsidian + Claude', 'LLM wiki', 'how do I get Claude to know my context every session'. Distinct from `agent-builder` (a worker's memory) and `vibe-coder` (a live coding session) — this is general-purpose personal memory, not scoped to coding."
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# personal-memory

Restarting from zero every session is a choice, not a limitation — the gap between "an AI that meets me fresh each time" and "an AI that already knows my context" is a small number of concrete setup steps, staged by how much the user actually needs, not a single all-or-nothing system.

## Attribution

- **AgriciDaniel/claude-obsidian** — [github.com/AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian), 9,545★ (checked 2026-07-18 via GitHub API), MIT license. Primary reference — a self-organizing AI second brain for Obsidian + Claude Code that files anything read into a Markdown knowledge graph automatically, built on Andrej Karpathy's "LLM Wiki" pattern (the same lineage this workspace already cites elsewhere for the "raw folder" memory problem, see `agent-builder`'s `graphify` entry).
- **eugeniughelbur/obsidian-second-brain** — [github.com/eugeniughelbur/obsidian-second-brain](https://github.com/eugeniughelbur/obsidian-second-brain), 3,346★ (checked 2026-07-18 via GitHub API, most recently active of the candidates found), MIT license. Reference for Step 4's consolidation pattern — includes scheduled agents that reorganize/prune the vault ("maintain the vault while you sleep"), the closest real analog to the self-growing-brain stage.
- **breferrari/obsidian-mind** — [github.com/breferrari/obsidian-mind](https://github.com/breferrari/obsidian-mind), 3,361★ (checked 2026-07-18 via GitHub API), MIT license. Alternative — an Obsidian vault template giving persistent memory to Claude Code, Codex, and Gemini CLI specifically (useful if the user already works across more than one CLI agent, not just Claude).
- **MarkusPfundstein/mcp-obsidian** — [github.com/MarkusPfundstein/mcp-obsidian](https://github.com/MarkusPfundstein/mcp-obsidian), 4,094★ (checked 2026-07-18 via GitHub API), MIT license. The connectivity layer the above tools build on — an MCP server exposing Obsidian's REST API plugin. Named for Step 3 as the actual read/write mechanism, not a competing framework.
- **multica-ai/andrej-karpathy-skills** — [github.com/multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills), 193,973★ (checked 2026-07-19 via direct GitHub HTML verification), MIT license (verified via license badge on the repo page). A Claude Code plugin packaging Karpathy-style guidelines/skills. Flag for the user specifically: this repo's name matches the "karpathy-skills v1 guidelines" already referenced in this machine's own `hermes-agents/AGENTS.md` commit history — worth the user confirming directly whether that prior adoption *is* this repo before this entry is treated as a second, independent source for the same lineage already cited above (`AgriciDaniel/claude-obsidian`'s Karpathy "LLM Wiki" attribution).
- **GoogleCloudPlatform/knowledge-catalog** (Open Knowledge Format, OKF v0.1) — [github.com/GoogleCloudPlatform/knowledge-catalog](https://github.com/GoogleCloudPlatform/knowledge-catalog), 7,393★ (checked 2026-07-19 via GitHub API), **Apache 2.0** (verified via GitHub API license endpoint) — first-party Google spec, announced 2026-06-12, same "clean-license first-party format" reasoning this workspace already applies to `google-labs-code/design.md` in `design-report`. **Step 3's Obsidian-free alternative**: a bundle of plain markdown files with minimal YAML frontmatter (only `type` is mandatory; `title`/`description`/`resource`/`tags`/`timestamp` recommended), `index.md`/`log.md` as reserved conventions, cross-linked via ordinary markdown links — no database, no vendor SDK, no Obsidian install required. Prioritizes git-diffability and human readability over vector-embedding semantic search, and is explicitly tool/vendor-neutral (portable across Claude/Codex/Gemini, not Claude-specific). A personal OKF-based automation brain built on this spec demonstrates the pattern — that specific tool was not adopted (not a checkable GitHub project), but the OKF spec it builds on is.
- **This skill's own Step 1-4 structure** (Memory feature → CLAUDE.md → Obsidian+LLM wiki → self-growing consolidation) — a real, checkable progression rather than a single jump to the heaviest setup. This skill does not adopt a "Hermes Agent" tool named in the source material for Step 4 — **not because "Hermes Agent" products are unverified in general** (see `agent-builder`'s Attribution: `NousResearch/hermes-agent` is a real, 216,464★, MIT-licensed project — the name space is legitimate), but because that source did not identify its tool as that repo or any other checkable GitHub project, so it could not be independently verified as of this check. Step 4 instead cites the two verified GitHub candidates above for the same consolidation-agent stage. If a future pass confirms that tool is the same NousResearch project (or another verifiable one), revise this entry accordingly instead of re-dismissing it.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 1: Diagnose the current stage before adding anything

Ask (AskUserQuestion) or infer from what's already in place — don't build a heavier stage than the user needs:

1. **Stage 0 — nothing set up.** Claude starts cold every session.
2. **Stage 1 — the built-in Memory feature is on**, but nothing else. Works for short recall, has no structure and no cross-tool portability.
3. **Stage 2 — a `CLAUDE.md`/`AGENTS.md` rules file exists** (project- or user-level) that's read every session. Durable and portable, but it's a flat file the user has to maintain by hand — it doesn't grow on its own.
4. **Stage 3 — an Obsidian vault + LLM-wiki pattern exists**, queryable and writable by Claude, not just a static rules file.
5. **Stage 4 — the vault self-consolidates** on a schedule (prunes, reorganizes, promotes durable notes) instead of growing as an unstructured pile forever.

Identify the current stage, then move one stage at a time — don't jump straight to Stage 4 for a user who has nothing set up yet; each stage is usable on its own and the jump in setup complexity is real.

## Step 2: Stage 1→2 — turn ad-hoc memory into a durable rules file

If only the built-in Memory feature is active, the next concrete step is a `CLAUDE.md` (or equivalent) file: durable, versionable, portable across machines, and — critically — something the user can read and edit directly, unlike opaque memory-feature state. Keep it short; a rules file that's grown into a long undifferentiated dump gets skipped partway through by the model reading it (the same failure mode `_shared/CORE-LAWS.md` in this workspace was built to avoid) — split out anything long-form into a referenced file instead of inlining it.

## Step 3: Stage 2→3 — move from a flat file to a queryable wiki

A single `CLAUDE.md` degrades once it's tracking more than rules-of-thumb — accumulated facts, project history, and preferences need to be looked up, not re-read in full every session. Two real paths exist here, not one — pick based on what the user actually wants:

- **Obsidian vault + LLM-wiki** (richer, requires installing Obsidian): connect it via `mcp-obsidian` (see Attribution) and follow `AgriciDaniel/claude-obsidian`'s approach for auto-filing new information into the graph as it's read, rather than the user manually organizing notes. Better when the user wants a visual graph view and is already an Obsidian user or willing to become one.
- **Open Knowledge Format (OKF)** (lighter, no extra app): a directory of plain markdown files with YAML frontmatter (see Attribution, `GoogleCloudPlatform/knowledge-catalog`) — just `git init` a folder, write files with a `type` field and optional `title`/`description`/`resource`/`tags`/`timestamp`, and use `index.md` for directory listings and `log.md` for change history. Better when the user wants something readable in any editor, diffable in git, and portable across agent tools (not locked to Claude or to Obsidian's plugin ecosystem) — the tradeoff is no visual graph, cross-references are just markdown links.

## Step 4: Stage 3→4 — self-consolidation (optional, only for a vault under real load)

Only add this once the vault has enough volume that browsing it manually is already slow. Add a scheduled consolidation pass — see `eugeniughelbur/obsidian-second-brain`'s "sleep" agent pattern (Attribution) — that reviews accumulated notes and promotes/prunes/reorganizes rather than letting every note carry equal weight forever. This mirrors the same consolidation principle `agent-builder` Step 1.4 applies to a business worker's memory (OpenClaw's "Dreaming"); the underlying pattern is domain-general, only the target differs (a personal vault here, a worker's memory file there).

---

## What this skill does not do

It does not design an autonomous business worker's memory policy — that's `agent-builder` Step 1 item 4. It does not cover coding-session-specific context discipline (Context7, git worktrees, subagent isolation) — that's `vibe-coder`. It does not install Obsidian or any MCP server; it names real, verified candidates and lets the user choose and install. It does not recommend jumping straight to Stage 4 — most users get most of the value at Stage 2 or 3, and the later stages should be earned by actual note volume, not adopted because they sound more advanced.

## Durable-learning promotion guard

Do not promote an AI-generated summary directly into durable memory. Store the primary-source link, distinguish source facts from the user's interpretation, and require source comparison plus delayed active recall before marking a learning note as understood. Keep failed or uncertain recall visible for the next review instead of letting fluent prose masquerade as mastery. Promote only the corrected note and attach one application or decision showing how the knowledge was used.
