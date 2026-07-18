---
name: personal-memory
description: "Set up a persistent personal memory system so Claude knows the user across sessions instead of starting cold every time — a staged roadmap from the built-in Memory feature, to a CLAUDE.md rules file, to an Obsidian-backed LLM wiki, to a self-consolidating knowledge base. MANDATORY TRIGGERS: 'set up my second brain', 'make Claude remember me', 'persistent memory for Claude', 'Obsidian + Claude', 'LLM wiki', 'how do I get Claude to know my context every session'. Distinct from `agent-builder` (designs an autonomous business worker's memory) and `vibe-coder` (a human's live coding-session discipline) — this is a human's own general-purpose, cross-session personal memory setup, not scoped to coding or to a built worker."
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
- **Jay Choi, "클로드를 완벽한 세컨드브레인으로 만드는 4단계"** — (YouTube, 2026-07-14) — not a GitHub repo, cited as a staging framework. Source of this skill's own Step 1-4 structure (Memory feature → CLAUDE.md → Obsidian+LLM wiki → self-growing consolidation) — a real, checkable progression rather than a single jump to the heaviest setup. This skill does not adopt the video's own named "Hermes Agent" tool (an unrelated, unverified personal project, not a GitHub repo evaluated here) — Step 4 instead cites the two verified GitHub candidates above for the same consolidation-agent stage.

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

A single `CLAUDE.md` degrades once it's tracking more than rules-of-thumb — accumulated facts, project history, and preferences need to be looked up, not re-read in full every session. This is where an Obsidian vault + LLM-wiki pattern earns its complexity: connect it via `mcp-obsidian` (see Attribution) and follow `AgriciDaniel/claude-obsidian`'s approach for auto-filing new information into the graph as it's read, rather than the user manually organizing notes.

## Step 4: Stage 3→4 — self-consolidation (optional, only for a vault under real load)

Only add this once the vault has enough volume that browsing it manually is already slow. Add a scheduled consolidation pass — see `eugeniughelbur/obsidian-second-brain`'s "sleep" agent pattern (Attribution) — that reviews accumulated notes and promotes/prunes/reorganizes rather than letting every note carry equal weight forever. This mirrors the same consolidation principle `agent-builder` Step 1.4 applies to a business worker's memory (OpenClaw's "Dreaming"); the underlying pattern is domain-general, only the target differs (a personal vault here, a worker's memory file there).

---

## What this skill does not do

It does not design an autonomous business worker's memory policy — that's `agent-builder` Step 1 item 4. It does not cover coding-session-specific context discipline (Context7, git worktrees, subagent isolation) — that's `vibe-coder`. It does not install Obsidian or any MCP server; it names real, verified candidates and lets the user choose and install. It does not recommend jumping straight to Stage 4 — most users get most of the value at Stage 2 or 3, and the later stages should be earned by actual note volume, not adopted because they sound more advanced.
