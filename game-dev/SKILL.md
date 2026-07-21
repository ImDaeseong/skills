---
name: game-dev
description: "Build or extend a 2D/3D game with an AI coding agent driving the actual engine — Unreal Engine via MCP, Unity, Godot, or a web engine (Phaser/Three.js) — from asset generation through playtesting, not just writing gameplay code blind. MANDATORY TRIGGERS: 'build me a game', 'make a 2D game', 'make a 3D game', 'unreal engine mcp', 'game dev with claude code', 'playtest my game', 'generate game assets', 'set up a game engine skill'. Distinct from `vibe-coder` (general coding-session discipline, not engine-specific) and `video-producer` (renders a non-interactive video file, not a playable build). Do not trigger for a one-off game-adjacent script (a scoring formula, a save-file parser) that doesn't touch the engine itself."
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# game-dev

"Write the gameplay code and hope it looks right" doesn't work for games the way it sometimes works for a web form — a game is judged by feel (does the jump arc read right, does the hit register on time), and feel only shows up when the thing actually runs. This skill is the discipline layer for building a game with an AI coding agent: which engine-specific channel drives the actual editor/runtime, how to get real assets and animation into it, and how to verify by playing the result rather than by reading the diff.

## Attribution

- **EpicGames/unreal-engine-skills-for-claude-code-plugin** — [github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin](https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin), 140★ (checked 2026-07-18 via direct GitHub HTML verification), MIT license. **Primary reference for Unreal Engine work** — official first-party plugin from Epic Games itself (not a community reverse-engineering effort), giving Claude Code MCP access to actors, Blueprints, materials, Niagara VFX, Control Rig, Sequencer, State Trees, UMG widgets, Gameplay Ability System, and automation testing across 30+ toolsets. Star count is modest, but first-party authorship from the engine vendor outweighs star count here, same reasoning this workspace already applies to `anthropics/skills` in `design-report`'s Attribution.
- **gamedev-skills/awesome-gamedev-agent-skills** — [github.com/gamedev-skills/awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills), 300★ (checked 2026-07-18 via direct GitHub HTML verification), **Apache 2.0** (verified via LICENSE file). Secondary reference for engines outside Unreal — 66 version-pinned skills plus a master router covering Godot, Unity, Phaser, PixiJS, Three.js, Bevy, pygame, LÖVE, and Roblox, each written from the engine's own primary docs rather than secondhand tutorials. Used for Step 2's engine-routing table and as the fallback source when the request isn't Unreal-specific.
- **stablyai/orca** — [github.com/stablyai/orca](https://github.com/stablyai/orca), 21,569★ (rechecked 2026-07-18 via GitHub API — the figure originally recorded here, 90,606★, was wrong, likely a copy-paste mix-up with a different repo checked in the same batch; corrected after a user-reported discrepancy), MIT license (re-verified). Reference for Step 4's parallel-iteration technique — an Agent Development Environment that runs multiple coding agents (Claude Code, Codex, OpenCode, Pi) side by side, each in its own isolated git worktree, so several gameplay-feel variants (e.g. three different jump-arc tunings) can be generated and compared in parallel rather than iterated on serially. Not installed by this skill; named as an option when a task genuinely needs parallel exploration rather than one linear attempt.
- **Solo-developer comparative benchmark** — `[LOW-EVIDENCE]`, a single practitioner's self-reported measurement (Claude Code + Opus 4.7 driving Unity, Unreal, and Godot through matched 2D/3D demo builds), not independently reproduced. Source of Step 1's engine-choice caveat: the developer, who had already shipped a Unity title, found Unity (the most asset/license-popular engine) took the longest under Claude-Code-driven ("vibe coding") development (2 hours on a 2D demo, plus a Unity URP-specific pitfall on 3D) and measured an ~8x 3D-render FPS gap between engines in the same test; their own stated conclusion was to move their next project to Godot specifically for AI-agent-driven work. Treat this as a signal to weigh alongside Step 1's existing platform-fit criteria, not as a replacement for them — a single developer's benchmark is not the same evidence tier as `gamedev-skills/awesome-gamedev-agent-skills`' engine-routing table.
- **Step 3's specific pairing**: a PhaserJS skill for the build loop and a **Playwright-driven game-testing skill** for verification — the agent opens a real browser, presses keys, and plays the game to confirm functionality, rather than reading the render code and assuming it works. Source of the technique "verify by playing," which generalizes past Phaser to any engine with a live, drivable build.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Step 1: Pick the engine channel before writing anything

Ask (AskUserQuestion) if not already clear from the request:

1. **Which engine, or is this greenfield?** If the user already has a project, the engine is fixed — read its existing structure before proposing anything. If greenfield, the choice depends on target platform (2D web/mobile → Phaser/PixiJS; cross-platform indie 2D/3D → Godot; AAA-adjacent 3D or an existing UE project → Unreal; broad commercial 3D with a large asset-store ecosystem → Unity). If the deciding factor is specifically how well the engine works *under Claude-Code-driven development itself* rather than the shipped game's platform needs, see the solo-developer benchmark in Attribution — one developer's own measurement favored Godot over Unity for that reason specifically, though it's a single self-reported data point, not a maintained comparison.
2. **Is there already an MCP/engine-driving connection available in this session**, or does one need to be set up first? Check before assuming — same discipline as every other skill in this workspace's tool-availability checks (see `design-report` Step 1.8, `video-producer` Step 2).

## Step 2: Route to the engine-specific skill

- **Unreal Engine** — install/use `EpicGames/unreal-engine-skills-for-claude-code-plugin` (see Attribution). This gives Claude MCP access to the live editor. **Read its Security section before enabling `--dangerously-skip-permissions` with this plugin loaded** — `ProgrammaticToolset.execute_tool_script` runs arbitrary Python inside the editor process with full asset-database and project-disk access, and the plugin's own docs warn localhost is not a trust boundary (any local process can connect to the MCP server, not just Claude). Save/commit before any MCP-driven session so the working copy is recoverable.
- **Godot, Unity, Phaser, PixiJS, Three.js, Bevy, pygame, LÖVE, Roblox** — route to the matching skill inside `gamedev-skills/awesome-gamedev-agent-skills` (see Attribution) via its master router rather than reimplementing engine-specific knowledge here.
- **If no matching engine skill exists for a niche/newer engine** — say so per LAW 0 rather than improvising API calls from general training-data familiarity; a wrong Blueprint node name or a hallucinated Godot API silently breaks a build in a way that's expensive to debug later.

## Step 2.5: Lock the game-design content before wiring gameplay

Run `vibe-coder`'s Step 3 plan gate (see that skill) with game-specific content as the subject matter — a one-page design doc covering the unit/entity tree (stats, roles), resource/economy structure, and enemy/AI behavior patterns, reviewed and signed off before any gameplay code is written. No dedicated GitHub game-design-document methodology cleared this workspace's evidence bar (searched 2026-07-19: the highest-starred candidates were a 601★ curated link list and single-digit/low-tens-star personal templates, and the AI-assisted `game-design-doc-generator` at 1★ doesn't even cover unit/economy/behavior content) — reuse the already-evidenced `vibe-coder` plan-gate methodology (`obra/superpowers`, 256,647★, see `vibe-coder` Attribution) instead of citing a source this weak.

## Step 3: Build the asset pipeline before wiring gameplay

1. Confirm what's needed: placeholder/programmer art is fine for a prototype validating mechanics; production-ready sprites/models are a separate, heavier request — don't default to the expensive path when the actual need is "does this feel right."
2. For 2D sprite/animation pipelines specifically, the sequence that avoids inconsistent character art across frames (see Attribution): lock a single anchor pose first, derive additional angles/poses from that same anchor rather than prompting each frame independently, then use image-to-video conversion for walk-cycle-style animation and extract a clean frame loop from it — generating each frame independently from a text prompt is the failure mode this sequence exists to avoid.
3. **Verify by playing, not by reading the render/animation code** (see Attribution, Step 3's Playwright-testing pairing) — check what's actually available (a browser-automation tool for a web engine, the target engine's own automated-test harness for Unreal/Unity/Godot) before assuming it exists, same discipline as `design-report` Step 1.8. If nothing is available to drive the build, say so explicitly and ask the user to confirm functionality themselves rather than describing untested gameplay as verified.

## Step 4: Iterate — serially by default, in parallel when a genuine variant question exists

Default to one linear attempt per change, reviewed before the next. Reach for `stablyai/orca` (see Attribution) only when the actual question is "which of several distinct approaches feels better" (e.g. three different jump-arc tunings, two different enemy-AI behaviors) — running several isolated worktrees to compare outcomes side by side, not as a default way to build every feature.

## What this skill does not do

It does not install Unreal, Unity, Godot, or any engine binary — the user brings their own engine install; this skill only routes to the AI-agent-facing MCP/skill layer on top of it. It does not write a full production game end-to-end without checkpoints — Steps 1-4 are gates, not a single uninterrupted generation pass. It does not render a non-interactive video from game footage (that's `video-producer`) or decide the game's static visual/UI direction as a design system (that's `design-report`'s `DESIGN.md` work, reusable here for menu/HUD consistency).
