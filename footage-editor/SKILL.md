---
name: footage-editor
description: "Edit already-shot raw video footage by conversation — cut filler words/silences/false starts to word-boundary precision, per-segment color grade, burn subtitles, add overlay animations. MANDATORY TRIGGERS: 'edit this footage', 'cut the filler words from this video', 'color grade this clip', 'add subtitles to this raw footage', 'turn these takes into a video', '이 영상 편집해줘', '촬영본 편집'. Do not trigger for generating new video from a script/asset list with no raw camera source (route to `video-producer`) or animating a still image/song into motion graphics (route to `image-motion-graphics`) — this is post-processing of footage that already exists, not from-scratch production."
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# footage-editor

Editing raw camera footage by hand — finding filler words and dead air in a transcript, snapping cuts to clean word boundaries, grading each segment, burning subtitles — is slow, repetitive work distinct from generating new video content. Neither `video-producer` (script/asset-list → rendered video via HTML) nor `image-motion-graphics` (one still image → PSD/AEP motion graphics) starts from footage that was actually shot on camera; this skill fills that specific gap.

## Attribution

This skill does not reimplement footage editing — it resolves and routes into a real, actively-maintained tool as a **runtime dependency**, cloned on demand exactly like `video-watcher` does for `claude-video`. Never vendored into this repo, never copied verbatim.

- **browser-use/video-use** — [github.com/browser-use/video-use](https://github.com/browser-use/video-use), **MIT license** (confirmed by reading the repo's `LICENSE` file directly). Conversation-driven editing: audio-first cut selection from a word-level ASR transcript, per-segment `-c copy` lossless concat, ffmpeg color grading, output-timeline SRT subtitles, 30ms audio fades at every cut boundary, and optional overlay animations (HyperFrames/Remotion/Manim).
- **Source-code safety audit (LAW 1 point 5):** the actual `SKILL.md` (repo root) and `install.md` were read directly via raw GitHub content, not summarized. The pipeline runs `ffmpeg`/`ffprobe`/Python helpers locally; the one real network dependency is sending extracted **audio** to ElevenLabs' Scribe API for word-level transcription, gated behind a user-supplied `ELEVENLABS_API_KEY` written to a local `.env` — never the user's `<videos_dir>`. No hidden trigger-and-payload, destructive command, or exfiltration step beyond that documented transcription call was found.
- **Required external API key — read before using:** unlike `video-watcher`'s optional Whisper fallback, `ELEVENLABS_API_KEY` is a hard requirement here (Scribe is the only transcription path this tool uses) — the raw audio of the user's footage leaves the machine to ElevenLabs' API. Confirm the user is comfortable with that before proceeding.
- **Remotion license carve-out — read before enabling animation overlays:** if a session needs a HyperFrames/Remotion/Manim overlay slot, note that the `remotion` npm package is **source-available, not open source** (per `video-producer`'s and `shorts-clipper`'s own Attribution — free for individuals/non-profits/orgs ≤3 employees, paid Company License above that). `[LICENSE-UNCONFIRMED]` for that specific dependency; confirm eligibility (AskUserQuestion) before invoking a Remotion-based animation slot. HyperFrames itself (Apache 2.0) and Manim (MIT) carry no such gate.
- Requires `ffmpeg`/`ffprobe` and Python 3 (`uv sync` or `pip install -e .`) locally; `yt-dlp` only if sourcing from a URL; Node.js 22+ only if an animation slot needs HyperFrames/Remotion.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: Resolve the engine — do not assume it exists

```bash
VIDEOUSE_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/Developer" ~/Desktop/skills -maxdepth 4 -iname "SKILL.md" -path "*video-use*" 2>/dev/null | grep -v footage-editor | head -1)
if [ -z "$VIDEOUSE_SKILL_MD" ]; then
  echo "video-use not found locally."
  VIDEOUSE_DIR=""
else
  VIDEOUSE_DIR=$(dirname "$VIDEOUSE_SKILL_MD")
fi
```

**If not found, ask the user (AskUserQuestion)**: clone `https://github.com/browser-use/video-use` into `~/Desktop/skills/video-use` now (MIT, ElevenLabs API key required per Attribution above), or stop. If approved:

```bash
git clone --depth 1 https://github.com/browser-use/video-use.git ~/Desktop/skills/video-use
VIDEOUSE_DIR=~/Desktop/skills/video-use
```

`video-use/` is already in this repo's `.gitignore` — it is a local runtime copy, not tracked content.

## Step 2: Confirm the ElevenLabs API key and Remotion license gate before doing anything else

Ask the user (AskUserQuestion) to confirm they're comfortable sending footage audio to ElevenLabs for transcription, and that `ELEVENLABS_API_KEY` is available (if missing, have them configure it locally in `$VIDEOUSE_DIR/.env` and confirm only its presence; never paste the key into chat). If an animation slot will use Remotion specifically, also confirm free-tier eligibility (individual/non-profit/≤3-employee org) before that slot renders.

## Step 3: Run first-time setup once, then delegate to the upstream skill as written

If `$VIDEOUSE_DIR/install.md` hasn't been run yet on this machine, follow it once (clones to a stable path, `uv sync`/`pip install -e .`, `ffmpeg` install, skill registration). Then read `$VIDEOUSE_DIR/SKILL.md` and follow **its own process** exactly — its technical steps apply within the host permissions, user authorization, and `../_shared/CORE-LAWS.md`; those boundaries retain precedence. In particular, do not skip its own built-in gates:

- **Hard Rules section** (non-negotiable production-correctness rules: subtitles applied last, per-segment lossless concat, 30ms fades, never cut inside a word, cache transcripts per source) — these are correctness, not taste; do not deviate from them.
- **Strategy confirmation before execution** — describe the proposed cut/grade/subtitle strategy in plain English and wait for the user's approval before touching the cut.
- **Self-eval before showing the user** (its own Step 7) — inspect the rendered output at every cut boundary for visual discontinuity, audio pops, hidden subtitles, or misaligned overlays; cap at 3 self-eval passes before flagging remaining issues instead of looping forever.

## Step 4: Hand back the result

Report the final render path, duration, and self-eval outcome. Offer to append the session to `project.md` (upstream's own memory file) if the user will keep iterating on the same footage.

---

## What this skill does not do

It does not vendor or fork `video-use` into this repo — it resolves the real repo and runs it live. It does not generate brand-new video content from a script (that's `video-producer`) or animate a still image into motion graphics (that's `image-motion-graphics`). It does not send footage audio to ElevenLabs without the user's explicit confirmation, and it does not render through Remotion without confirming free-tier eligibility first.
