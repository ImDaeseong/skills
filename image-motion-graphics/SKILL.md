---
name: image-motion-graphics
description: "Turn one image, song, lyrics, or audio file into layered motion graphics: generate a key visual, reconstruct transparent assets, assemble PSD/AEP when available, and render a verified music video with a motion-locked background. MANDATORY TRIGGERS: '이미지 한 장으로 모션그래픽', '가사와 MP3로 뮤직비디오', '가사와 WAV로 영상 만들어줘', '노래로 뮤직비디오 이미지 만들어줘', '레이어 분리 PSD', 'PSD를 AEP로', 'animate this still image', 'turn this song into a music video'. Do not trigger for static-image-only requests or ordinary timeline editing of existing footage."
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# image-motion-graphics

Create a reproducible one-scene pipeline from concept or still image to layered PSD/AEP and a reviewed render.

Follow the packaged [core production laws](references/CORE-LAWS.md) in full. This
copy is bundled with the skill so standalone installation does not break the
required reference.

## 1. Lock the requested endpoint

Determine which endpoint the user wants: key visual only; transparent layer assets plus a layer manifest; layered PSD; AEP motion project; or rendered video.

Also establish aspect ratio, duration, frame rate, and whether audio synchronization is required. When lyrics plus an MP3 or WAV are attached and the user asks to make the music video, treat the endpoint as the full-song rendered video without asking them to repeat those inputs. Use the audio's measured duration, 16:9, 1920x1080, and 12 fps as explicitly reported defaults unless the user supplies different settings. Do not run the full pipeline when an earlier endpoint is enough.

Accept either entry point:

- **Concept entry:** song, lyrics, or script. Translate the emotional arc into one scene before generating the key visual.
- **Image entry:** user-provided still. Preserve its composition unless the user requests a redesign.
- **Song package entry:** lyrics plus MP3 or WAV. Read embedded metadata when present, measure the real audio duration, map lyric sections to the timeline, create the key visual when none is supplied, and continue through the requested final render. When timing comes from beat or tempo estimation, accept an estimate only above a normalized periodicity-confidence threshold, check the audio duration against the complete scene timeline before copying assets, and keep regression fixtures for noise and duration mismatch next to the clean click-track case.

## 2. Confirm the production tools

Check the current host for its native image-generation capability and for Photoshop and After Effects before promising editable PSD/AEP output. Use the host-native image generator when available. Check Adobe applications or their scripting entry points with a read-only command or visible app inspection.

If a required tool is unavailable, state the exact boundary and offer the nearest honest endpoint: key visual, transparent PNG set, layer manifest, JSX script, or renderer-neutral video. Do not claim that a renamed ZIP or a flat image is a PSD/AEP.

## 3. Design the key visual for separation

When generating the initial still, compose distinct foreground, midground, and background planes. Keep major objects readable with clean silhouettes and limited overlap. Avoid text unless exact text is required.

For a song or script, write a one-sentence visual thesis before generation. Prefer one emotionally legible moment over illustrating every lyric. Preserve recurring story objects that can carry motion, such as a person, umbrella, streetlamp, rain, reflections, trees, or distant architecture.

Lock the visual genre before writing the image prompt. Record the inferred era, location, realism level, and camera language, plus one excluded genre. Base these choices on concrete situations repeated across the lyrics, not on the title, a single metaphor, or the music genre label. Treat K-pop, EDM, rock, and ballad as energy and pacing cues rather than automatic visual genres. Use science fiction, cyberpunk, fantasy, historical, or supernatural imagery only when the user requests it or multiple lyric details clearly establish it. When evidence is ambiguous, default to a contemporary, human-scale, realistic setting.

Translate abstract labels into lived situations. For example, a narrator called a “villain” because society rejects dissent should first suggest a contemporary school, workplace, audition stage, street, or social gathering—not masks, dystopian grids, futuristic cities, or supernatural powers. Before image generation, state the genre lock in this compact form: `era / place / realism / camera language / excluded genre`.

## 4. Produce a layer manifest

List every intended layer from back to front. For each layer record:

- stable file name;
- semantic role;
- full-canvas bounding box and anchor point;
- original position and scale;
- z-order and parent candidate;
- whether hidden portions require reconstruction;
- entrance direction and motion delay;
- whether subtle idle motion is allowed.

Separate at minimum the clean background, principal subject, story props, foreground occluders, lighting/reflection overlays, and near/mid/far atmosphere when present.

## 5. Reconstruct assets instead of crudely cutting them

Generate each foreground object as an independent transparent-alpha asset. Reconstruct areas hidden behind other elements so the object remains complete when animated. Generate a clean background plate with removed objects filled naturally.

Composite all generated assets at their manifest coordinates and compare the reconstruction against the source. Correct silhouette, scale, or occlusion errors before building PSD/AEP. Preserve the original image; write generated resources to a separate project folder.

## 6. Assemble the editable scene

When Photoshop is available, create a full-canvas PSD with named layers in manifest order and retain transparency. Keep layers at the source coordinates rather than trimming and manually guessing their placement.

When After Effects is available, import the PSD as a composition while retaining layer sizes. Use a composition hierarchy that distinguishes background, environment, characters, props, atmosphere, and adjustment layers. Parent dependent parts to their owner so shared translation is not duplicated.

## 7. Apply restrained motion

Animate non-background layers from the nearest suitable frame edge to their manifest position while opacity moves from 0 to 100. Stagger entrances from the bottom PSD layer upward unless narrative timing requires an explicitly documented exception.

For a stop-motion feel, quantize foreground and atmosphere animation timing to the selected low frame rate. After arrival, allow only extremely small rotational drift around approximately one degree. Keep the background motion-locked: its position, scale, rotation, and anchor point must remain identical for the entire composition. Do not apply whole-frame pan, zoom, integer-pixel crop animation, handheld simulation, wiggle, or low-frame-rate transforms to the background. If camera motion is explicitly requested, render it with smooth subpixel interpolation at the delivery frame rate while keeping stop-motion quantization confined to independent foreground layers. Exclude layers whose inherited parent motion already supplies sufficient movement.

Treat rain, reflections, and light as atmosphere rather than rigid objects: vary their timing gently without obscuring the subject. For a music video, align major entrances or lighting changes to structural song moments only when audio or timestamps are available. Derive timing markers from audio analysis or use user-provided timestamps rather than relying on unauditable by-ear guesses, and keep aligned events in song order. This is a production rule informed by research that aligns visual events or motion keyframes to musical beats and, in MV-Crafter, constrains the synchronization to remain monotonic ([MV-Crafter, arXiv:2504.17267](https://arxiv.org/abs/2504.17267); [MVAA, arXiv:2506.18881](https://arxiv.org/abs/2506.18881); authors' abstracts read 2026-10-08).

## 8. Render and verify

Run the bounded verification loop required by CORE-LAWS. Produce fresh evidence for each applicable check:

- alpha assets open with real transparency and no baked background;
- the reconstructed still matches the source composition;
- PSD layers are named, ordered, editable, and positioned correctly;
- AEP opens without missing footage and uses the expected composition settings;
- the background has no idle wiggle;
- sampled background landmarks remain at identical pixel coordinates from beginning to end unless the user explicitly requested smooth camera motion;
- child layers do not receive duplicated motion;
- entrance order, opacity, duration, and frame rate match the manifest;
- sampled beginning, middle, and ending frames, plus at least one frame inside each layer entrance, contain no exposed reconstruction holes or overlapping/clipped layers;
- the rendered clip is watched or inspected as frames, not accepted from an exit code alone.

Stop at HOLD when editable-format creation or visual review cannot be performed in the current environment. Return the completed earlier-stage assets and the precise remaining manual step.

## 9. Optional: animated lyric text layer (external tool, JIZURA)

When the user wants moving lyric typography over the finished background, use JIZURA ([852wa/JIZURA](https://github.com/852wa/JIZURA), MIT, © hakoniwa; Korean UI at `/ko/`) as an external browser tool. Do not copy or fork its code. It does not align lyrics to audio: timing comes from an imported LRC/SRT/VTT file, tap-sync (Space per line), or beat detection, so the user must supply or tap the timestamps. Browser operation is manual for the user unless a browser-automation tool is already installed.

1. Prepare an LRC (`[mm:ss.xx]lyric` per line) from the user's timestamps; JIZURA can also export the timing it ends up with (`LRC`).
2. In JIZURA, import the LRC and audio, then export **투명 PNG (ZIP·배경 없음)**. The PNG frames are RGBA, 1920x1080, 30 fps (JIZURA's own MP4 export defaults to 24 fps).
3. Composite the frame sequence over the finished background, matching the delivery frame rate rather than the 12 fps stop-motion rate (the text layer is not part of the motion-locked background rules): `ffmpeg -i background.mp4 -framerate 30 -i jizura_%05d.png -filter_complex "[0]fps=30[bg];[bg][1]overlay=format=auto:shortest=1" out.mp4`. The overlay output inherits the first input's frame rate, so without the `fps=30` step a 12 fps background silently drops the text layer to 12 fps.
4. Check three things before delivery: the lyric lines land on the audio, the text color reads against the actual background (some styles emit dark glyphs), and the decorative HUD text some styles add is wanted.

Verified 2026-11-15 against JIZURA 0.13.0 (commit 4c8278c) with four Korean lyric lines and a synthetic 120 BPM click track: LRC import and export, correct Hangul rendering, an alpha channel that survives compositing, and a 278-frame transparent sequence composited with the command above over a real 12 fps video file to a 1920x1080, 30 fps, 9.27 s result (without `fps=30` the same overlay output 12 fps). JIZURA's own MP4 export (default 24 fps, H.264 + AAC, 1920x1080) took the full 12 s length of the audio file, not the lyric length, and its scene changes matched the LRC times (blank before 0.5 s, line 1 at 1.0 s, line 2 at 3.6 s, line 4 at 8.8 s). The overlay command does not carry audio: when the background video has none, add the song as a third input and `-map "[v]" -map 2:a -c:a aac -shortest` after naming the overlay output `[v]` (verified; `-shortest` cuts the result to the shorter of the text layer and the song, so a song longer than the lyric sequence is truncated — drop `-shortest` and extend the text layer if the full song is needed). Not verified: a real song (beat detection, tap-sync feel) and a background produced by this skill's own render. If either matters for the task, run it first and report the result.

## Evaluation scenarios

Before a major revision, check the skill against these requests:

1. A melancholic song and lyrics with no image: produce one separable 16:9 key visual, then stop when the requested endpoint is the image.
2. A supplied poster: reconstruct hidden portions into transparent assets and a coordinate-preserving PSD without merely cropping the poster.
3. A layered PSD plus audio: build a low-frame-rate AEP with bottom-up entrances, restrained rotation, correct parenting, and an inspected render.
4. Lyrics plus an MP3 or WAV and “뮤직비디오로 만들어줘”: measure the audio, create the key visual when absent, render the full song, and prove that background landmarks do not jitter while rain and foreground layers move.
5. A contemporary K-pop/EDM song uses “villain” as a social label but contains no futuristic setting: choose a realistic present-day social scene and explicitly exclude science fiction or cyberpunk imagery.
