---
name: video-producer
description: "Turn a script or asset list (e.g. from `curator`) into an actual rendered video — intros, transitions, B-roll, lower thirds, animated infographics, talking-head segments — using HTML/motion-based rendering rather than a closed-source editor. MANDATORY TRIGGERS: 'render this as a video', 'make this into a short video', 'build a video intro', 'animate this infographic', 'add lower thirds/transitions to this'. Fills the video-assembly gap `curator` explicitly stops short of (`curator` produces the script; this skill produces the file). Do not trigger for a single static image — that's `design-report`'s job."
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# video-producer

A script is not a video. This skill closes the gap `curator` deliberately leaves open (it "does not source footage, synthesize voiceover, or render video") — it takes a script/asset list and produces an actual rendered file, using code-based rendering an agent can drive deterministically rather than a GUI editor a human has to operate by hand.

## Attribution

- **heygen-com/hyperframes** — [github.com/heygen-com/hyperframes](https://github.com/heygen-com/hyperframes), 35,961★ (checked 2026-07-18 via direct GitHub HTML verification), **Apache 2.0** (verified via GitHub API license endpoint) — cleanly open. Primary reference: "write HTML, render video, built for agents" — an open-source framework turning HTML/CSS/media/seekable animations into deterministic MP4s, with an existing AI-coding-agent skill integration. This skill follows its approach directly since the license is unambiguous.
- **remotion-dev/remotion** — [github.com/remotion-dev/remotion](https://github.com/remotion-dev/remotion), 53,523★ (checked 2026-07-18 via direct GitHub HTML verification), **source-available, not open source** (verified directly against `LICENSE.md`: free only for individuals, non-profits, and for-profit orgs with ≤3 employees; a paid Company License is required above that) — tag `[LICENSE-UNCONFIRMED]` per LAW 1's explicit rule that "source-available" is not open source regardless of star count. Higher-starred than hyperframes, but not adopted as the primary reference because of the license gate, not the star count. Reference/read only if the user is already eligible for its free tier and chooses it themselves — this skill does not default to it.
- **RayVentura/ShortGPT** — [github.com/RayVentura/ShortGPT](https://github.com/RayVentura/ShortGPT), 7,708★ (checked 2026-07-18 via GitHub API), MIT license. Tertiary option specifically for the parts hyperframes doesn't cover — footage sourcing and voiceover synthesis — when the request needs a full auto-generated pipeline rather than HTML-driven rendering of already-written content.
- **Matt Wolfe, AI VFX techniques video** — (YouTube, 2026-07-09) — not a GitHub repo, cited as craft technique rather than an OSS methodology. Source of Step 1's output-shape categories (intro/transition/background-composite/B-roll/logo-reveal/motion-graphic/talking-head) and the "mostly human-made, AI as a small enhancement layer" restraint principle — the same video that motivated building this skill in the first place (via the earlier-cited hyperframes/remotion discovery).

## Core Laws

Follows `../_shared/CORE-LAWS.md` in full (LAW 0 no-speculation, LAW 1 evidence-ranked selection — see the license gate above for LAW 1 applied to a high-star-but-restricted-license candidate, LAW 2, LAW 3 verification loops).

## Step 1: Confirm what's actually needed before rendering anything

Ask (AskUserQuestion) if not already clear from the request:
1. What's the source content — a `curator` script, user-provided text/images, or something that needs voiceover/footage sourced from scratch?
2. What's the output shape — pick the closest match rather than treating every request as a full custom build (categories from a Matt Wolfe AI-VFX video, 2026-07-09): **intro/outro**, **scene transition**, **background composite** (subject onto a generated/replaced background), **B-roll + text-highlight overlay**, **logo reveal / lower third**, **motion-graphic infographic**, or **animated talking-head segment**.
3. Does it need voiceover or stock footage sourced automatically, or is the visual/text content already complete?

Don't default to the heaviest tool (a full auto-pipeline) when the actual need is a simple rendered clip from content that already exists. **Default to restraint**: per the same source, the strongest results come from mostly human-made content (footage, voice, edit) with AI VFX added as a small enhancement layer — not from generating the whole piece with AI. If the request is "make the whole video with AI," say that's a different, weaker-quality mode than "add an AI effect to my existing edit," and confirm which one is actually wanted.

## Step 2: Route to the right renderer

- **HTML/CSS-drivable content with animation** (lower thirds, animated infographics, transitions, data-driven charts-to-video, talking points overlays) — use **hyperframes** (see Attribution). Write the HTML/CSS describing the frame(s), let it render the deterministic MP4.
- **Content needing sourced voiceover and/or stock footage**, not just rendering already-written material — use **ShortGPT** (see Attribution) for that specific gap, or say explicitly that this skill doesn't source those and ask the user to supply them.
- **If the user is already eligible for Remotion's free tier and specifically wants it** (e.g. an existing Remotion/React codebase) — note the license terms from Attribution so they knowingly opt in; don't silently default to it.

## Step 3: Render, then verify by watching it, not by reading the code

Per this workspace's established render-verification discipline (see `design-report` Step 1.8) — a video that looks correct in the HTML/config and a video that actually renders correctly are different claims. Check the actual rendered output (frame samples, duration, whether text/data bound correctly) before calling it done, not just that the render command exited without error.

---

## What this skill does not do

It does not write the original script (that's `curator` or the user) or design the static visual direction (that's `design-report`'s `DESIGN.md`/taste-skill work — reuse it for a consistent look rather than re-deciding style here). It does not install hyperframes/ShortGPT; it names them and lets the user install what they choose. It does not default to Remotion without the user explicitly confirming their license eligibility.
