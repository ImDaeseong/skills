---
name: diagram-forge
description: "Generate a standalone, shareable diagram file (architecture, workflow, sequence, data-flow, or lifecycle/state) as explorable interactive HTML with inline SVG, dark/light themes, and PNG/JPEG/WebP/SVG/WebM export — distinct from a diagram drawn inline inside an Artifact. MANDATORY TRIGGERS: 'diagram this architecture', 'make a workflow diagram I can share', 'export this as an interactive diagram', 'visualize this system as HTML', 'convert this Mermaid diagram to HTML', 'sequence diagram as a standalone file'. Do not trigger when a diagram embedded inside the current Artifact/chat response is enough — that is native Artifact diagramming, not this skill's job."
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# diagram-forge

Claude's native Artifact diagramming draws a diagram inline inside the current chat/Artifact — useful, but not a portable file someone can open, search, export, or share outside that conversation. This skill wraps a real, actively-maintained tool that produces a self-contained HTML file with its own viewer (search, focus, route tracing, dark/light toggle) and deterministic export to PNG/JPEG/WebP/SVG/WebM — a genuinely different output shape, not a restatement of inline Artifact diagrams.

## Attribution

This skill does not reimplement diagram rendering — it resolves and routes into a real, actively-maintained tool as a **runtime dependency**, cloned on demand exactly like `video-watcher` does for `claude-video`. Never vendored into this repo, never copied verbatim.

- **tt-a1i/archify** — [github.com/tt-a1i/archify](https://github.com/tt-a1i/archify), **MIT license** (confirmed by reading the repo's `LICENSE` file directly — copyright covers both tt-a1i and the earlier `Cocoon-AI/architecture-diagram-generator` v1.0 it's based on, also MIT). Five diagram types (architecture, workflow, sequence, data-flow, lifecycle) authored as a small typed JSON spec, validated, then rendered deterministically to a standalone HTML artifact with an interactive viewer.
- **Source-code safety audit (LAW 1 point 5):** the actual `archify/SKILL.md` was read directly via raw GitHub content, not summarized. Its documented commands (`node bin/archify.mjs validate|deliver|preview|doctor|demo`) all operate on local JSON/HTML files with no network calls or external endpoints named. Its "update awareness" step explicitly states an update notice is "information, not permission" and never auto-downloads or auto-executes an update. No hidden trigger-and-payload, destructive command, or exfiltration step found.
- Requires Node.js locally. No other install is documented as needed inside the skill package itself.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

---

## Step 1: Resolve the engine — do not assume it exists

```bash
ARCHIFY_SKILL_MD=$(find "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" ~/Desktop/skills -maxdepth 5 -iname "SKILL.md" -path "*archify*" 2>/dev/null | grep -v diagram-forge | head -1)
if [ -z "$ARCHIFY_SKILL_MD" ]; then
  echo "archify not found locally."
  ARCHIFY_DIR=""
else
  ARCHIFY_DIR=$(dirname "$ARCHIFY_SKILL_MD")
fi
```

**If not found, ask the user (AskUserQuestion)**: install it via the upstream project's own documented installer, or clone it directly — either is fine, both are MIT:

```bash
# Preferred, per upstream's own docs — requires Node.js and network access to npm:
npx skills add tt-a1i/archify -g
# After installation, rerun the resolver above to set ARCHIFY_DIR before Step 2.

# Fallback if npx/the "skills" installer package is unavailable:
git clone --depth 1 https://github.com/tt-a1i/archify.git ~/Desktop/skills/archify-src
# The actual skill package lives in the repo's archify/ subfolder:
ARCHIFY_DIR=~/Desktop/skills/archify-src/archify
```

`archify-src/` is already in this repo's `.gitignore` — it is a local runtime copy, not tracked content.

## Step 2: Delegate to the upstream skill as written

Read `$ARCHIFY_DIR/SKILL.md` and follow **its own fast-authoring path** exactly — its technical steps apply within the host permissions, user authorization, and `../_shared/CORE-LAWS.md`; those boundaries retain precedence. In particular, do not skip its own built-in gates:

- Read only the one matching schema (`schemas/`) and one matching example (`examples/`) for the chosen diagram type — not the full reference set.
- Write the candidate JSON, then run `node bin/archify.mjs validate <type> <candidate.json> --quality showcase --json` after every edit; a passing final validation freezes the candidate.
- `deliver` is the final acceptance command — a non-zero exit is never success, and a failed delivery preserves the previous output rather than overwriting it.
- If the user's input is a pasted Mermaid diagram, read it for topology and meaning, then author fresh Archify JSON — do not mechanically re-render Mermaid styling.

## Step 3: Hand back the result

Report the checked HTML file path, diagram type, and validation summary the upstream `deliver` command produces. Offer the export formats (PNG/JPEG/WebP/SVG/WebM) if the user wants a static image alongside the interactive HTML.

---

## What this skill does not do

It does not vendor or fork `archify` into this repo — it resolves the real package and runs it live. It does not replace inline Artifact diagramming when a portable file isn't actually needed — check with the user first if it's unclear which they want. It does not auto-download or auto-apply an archify update; per the upstream tool's own design, an update notice is surfaced but the installed version stays unchanged until the user acts on it themselves.
