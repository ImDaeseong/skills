---
name: shorts-clipper
description: "Turn an existing longform video into short vertical clips (YouTube Shorts/TikTok/Instagram Reels) — transcribe, score candidate segments for hook/coherence/payoff, get user approval, snap cut points to word/sentence boundaries, render animated captions, export per-platform. MANDATORY TRIGGERS: 'make shorts from this video', 'clip this into tiktoks', 'extract shorts/reels from this', 'cut this long video into clips', '이 영상으로 쇼츠 만들어줘', '롱폼을 숏폼으로'. Do not trigger for rendering brand-new video content from a script or asset list (route to `video-producer`) or for just watching/summarizing a video without cutting it (route to `video-watcher`) — this is existing-footage → short-clip extraction, not from-scratch production."
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# shorts-clipper

Cutting a longform video into short-form clips by hand — finding the hook-worthy moments, snapping cuts to clean word boundaries, adding animated captions, exporting per-platform specs — is slow, repetitive work. This skill wraps a real, actively-maintained tool that automates the mechanical steps (transcription, boundary snapping, rendering, encoding) while keeping Claude as the segment-scoring judgment layer and the user in the approval loop.

## Attribution

This skill does not reimplement clip extraction — it resolves and routes into a real, actively-maintained tool as a **runtime dependency**, cloned on demand exactly like `book-distiller` does for `book-to-skill`. Never vendored into this repo, never copied verbatim.

- **AgriciDaniel/claude-shorts** — [github.com/AgriciDaniel/claude-shorts](https://github.com/AgriciDaniel/claude-shorts) (checked via GitHub API, star count mid-tier — exact number not frozen per this workspace's no-fixed-star-count policy), **MIT license** (confirmed via the GitHub API license endpoint) for the skill wrapper itself. A 10-step interactive pipeline: local transcription (`faster-whisper`), content-type detection (talking-head/screen/podcast), Claude-driven segment scoring against a documented rubric, user approval, audio-aware boundary snapping, Remotion rendering of animated captions, and platform-specific FFmpeg export.
- **Remotion license carve-out — read before using:** the wrapper's `remotion/package.json` depends directly on the `remotion` npm package, which `video-producer`'s own Attribution already documents as **source-available, not open source** (re-verified directly against its `LICENSE.md` 2026-08-21: free for individuals, non-profits, and for-profit organizations with ≤3 employees; a paid Company License is required above that headcount). Tag `[LICENSE-UNCONFIRMED]` for that dependency specifically and confirm the user's eligibility (AskUserQuestion) before running Step 9's render — this is a license-eligibility gate, not a code-safety concern. The upstream `LICENSE.md` itself notes the terms "will slightly change" in a future Remotion 5.0 — not yet in effect as of the check date, but re-verify if this skill is revisited after that release ships.
- **Source-code safety audit (LAW 1 point 5):** `SKILL.md`, `install.sh`, and `setup.sh` were read directly before adoption. `install.sh` only copies files into `~/.claude/skills/shorts`. `setup.sh` creates a local Python venv and installs `faster-whisper`/`mediapipe`/`opencv-python`/`torch` (CPU or CUDA build depending on detected GPU) via `pip`, and installs the Remotion project's npm dependencies — no `curl | sh` from an untrusted source, no destructive commands. The pipeline itself runs entirely locally (`ffmpeg`, local Whisper, local Remotion render) — no network calls to any third-party API, so there is no data-exfiltration surface beyond what the user already has installed. No hidden trigger-and-payload found.
- Requires `ffmpeg`, Python 3 (venv auto-created), and Node.js/npm (for Remotion) locally. GPU (NVIDIA) is auto-detected and used for faster transcription/encoding if present; falls back to CPU otherwise.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: Resolve the engine — do not assume it exists

```bash
SHORTS_SKILL_MD=$(find "$HOME/.claude/skills" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*claude-shorts*" 2>/dev/null | head -1)
if [ -z "$SHORTS_SKILL_MD" ]; then
  echo "claude-shorts not found locally."
  SHORTS_DIR=""
else
  SHORTS_DIR=$(dirname "$SHORTS_SKILL_MD")
fi
```

**If not found, ask the user (AskUserQuestion)**: clone `https://github.com/AgriciDaniel/claude-shorts` into `~/Desktop/skills/claude-shorts` now (MIT wrapper, Remotion dependency license-gated per Attribution above), or stop. If approved:

```bash
git clone --depth 1 https://github.com/AgriciDaniel/claude-shorts.git ~/Desktop/skills/claude-shorts
```

`claude-shorts/` is already in this repo's `.gitignore` — it is a local runtime copy, not tracked content.

## Step 2: Confirm the Remotion license gate before doing anything else

Before running setup or the pipeline, ask the user (AskUserQuestion) to confirm they qualify for Remotion's free tier — individual, non-profit, or a for-profit org with 3 or fewer employees. If they don't qualify and don't have a paid Remotion Company License, stop here and say why (the render step in Step 9 of the upstream pipeline depends on the `remotion` npm package).

## Step 3: Run setup once, then delegate to the upstream pipeline as written

```bash
bash "$SHORTS_DIR/setup.sh"
```

**Before delegating, export the variable the upstream pipeline actually expects:**

```bash
export SHORTS_ROOT="$SHORTS_DIR"
```

Upstream's own Pre-Flight block only auto-detects `~/.claude/skills/shorts`, `~/.claude/skills/claude-shorts`, `~/claude-shorts`, or the current directory — none of which match the `~/Desktop/skills/claude-shorts` clone path used here. Every one of its 10 steps invokes scripts as `"$SHORTS_ROOT/scripts/..."`, so without this export the pipeline fails at Step 1 with an empty path.

Then read `$SHORTS_DIR/SKILL.md` and follow **its own 10-step pipeline** exactly — its instructions take precedence over anything summarized here. In particular, do not skip its own built-in gates:

- **Step 1 (preflight)** — run its safety checks and GPU detection before touching the input file; stop on preflight errors.
- **Step 5 (present)** — always present scored candidate segments for the user's approval; never auto-render without it.
- **Step 10 (export + validate)** — run its post-export validation (`validate.sh`) and report any failed files rather than declaring the export done.

## Step 4: Hand back the exported files

Report the final per-platform file table the pipeline produces (file, platform, duration, size) and whether validation passed. Offer to delete the pipeline's temp directory (`$SHORTS_TMP`, default `/tmp/claude-shorts`) once the user confirms they're done.

---

## What this skill does not do

It does not vendor or fork `claude-shorts` into this repo — it resolves the real repo and runs it live. It does not render brand-new video content from a script (that's `video-producer`) or just watch/summarize a video without cutting it (that's `video-watcher`). It does not bypass the Remotion license-eligibility check in Step 2, and it does not auto-render without the user approving segments in the upstream pipeline's own Step 5.
