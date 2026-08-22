---
name: video-watcher
description: "Watch an existing video (YouTube/TikTok/Vimeo/Twitch/Loom/local file) — frames plus transcript together — to answer questions about it: hooks, structure, on-screen actions, retention beats. MANDATORY TRIGGERS: 'watch this video', 'analyze this video/link', 'what happens in this video', 'summarize this youtube/tiktok video', 'break down this video's hook', '이 영상 좀 봐줘', '이 틱톡 영상 분석해줘'. Do not trigger for rendering new video content from a script (route to `video-producer`) or cutting an existing long video into short clips (route to `shorts-clipper`) — this is read-only video comprehension, not production."
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# video-watcher

Claude cannot natively watch a video someone links or uploads. This skill wraps a real, actively-maintained tool that downloads the video, extracts scene-aware frames, pulls a timestamped transcript, and hands both to Claude to `Read` and reason over — reverse-engineering hooks, retention beats, on-screen actions, or just answering "what's in this video?".

## Attribution

This skill does not reimplement video watching — it resolves and routes into a real, actively-maintained tool as a **runtime dependency**, cloned on demand exactly like `book-distiller` does for `book-to-skill`. Never vendored into this repo, never copied verbatim.

- **bradautomates/claude-video** (`watch` sub-skill) — [github.com/bradautomates/claude-video](https://github.com/bradautomates/claude-video) (checked via GitHub API, star count top-tier — exact number not frozen per this workspace's no-fixed-star-count policy), **MIT license** (confirmed via the GitHub API license endpoint). Downloads with `yt-dlp`, extracts frames with `ffmpeg` (scene-aware or fast-keyframe), and transcribes via native captions or a Whisper API fallback (Groq preferred, OpenAI fallback).
- **Source-code safety audit (LAW 1 point 5):** `skills/watch/SKILL.md` was read directly before adoption. It runs `yt-dlp`/`ffmpeg`/`ffprobe` locally on the given source, sends only the **extracted audio** (never the video) to Groq's or OpenAI's Whisper transcription endpoint — and only when a user-supplied API key is configured and native captions are missing. It does not access any platform account (no login/cookies/posting — `yt-dlp` only requests public data), does not share a provider's key with the other provider's endpoint, and does not log/cache API keys. Its own `SKILL.md` documents this explicitly under a "Security & Permissions" section. No hidden trigger-and-payload found.
- Requires `ffmpeg`, `ffprobe`, and `yt-dlp` locally (the tool's own `setup.py` auto-installs via Homebrew on macOS, or prints install commands on Linux/Windows). A Whisper API key (Groq or OpenAI) is optional — encouraged for videos without native captions, never required to proceed.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: Resolve the engine — do not assume it exists

```bash
WATCH_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" ~/Desktop/skills -maxdepth 5 -iname "SKILL.md" -path "*claude-video*watch*" 2>/dev/null | head -1)
if [ -z "$WATCH_SKILL_MD" ]; then
  echo "claude-video (watch) not found locally."
  WATCH_DIR=""
else
  WATCH_DIR=$(dirname "$WATCH_SKILL_MD")
fi
```

**If not found, ask the user (AskUserQuestion)**: clone `https://github.com/bradautomates/claude-video` into `~/Desktop/skills/claude-video` now (MIT, safety-audited above), or stop. If the user approves:

```bash
git clone --depth 1 https://github.com/bradautomates/claude-video.git ~/Desktop/skills/claude-video
```

`claude-video/` is already in this repo's `.gitignore` — it is a local runtime copy, not tracked content.

## Step 2: Delegate to the upstream `watch` skill as written

Read `$WATCH_DIR/SKILL.md` (i.e. `~/Desktop/skills/claude-video/skills/watch/SKILL.md`) and follow **its own steps** — its instructions take precedence over anything summarized here. In particular, do not skip its own built-in gates:

- **First-run setup preflight** (`scripts/setup.py`) — installs `ffmpeg`/`yt-dlp` if missing, scaffolds `~/.config/watch/.env`, and asks the user's preferred detail level (`transcript`/`efficient`/`balanced`/`token-burner`). Let it run; don't force a detail level without asking.
- **Whisper API key is optional, not required** — if the user declines, proceed with `--no-whisper`; native captions or frames-only still work.
- **Read every returned frame path** in a single parallel batch, then answer citing timestamps from both the frames and the transcript.

## Step 3: Answer, then clean up

Answer the user's actual question (or summarize structure/hooks/key moments if none was asked) citing timestamps. If the user won't ask follow-ups about this same video, delete the working directory the script printed (`rm -rf <dir>`); if they might, leave it in place for the rest of the session.

---

## What this skill does not do

It does not vendor or fork `claude-video` into this repo — it resolves the real repo and runs it live. It does not render or edit video (that's `video-producer` for new content, `shorts-clipper` for cutting an existing long video into shorts). It does not upload the source video itself to any API — only extracted audio, and only when Whisper is needed and enabled.
