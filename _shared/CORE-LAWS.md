# Core Laws (shared by every skill in this workspace)

Every skill under `Desktop/skills/` references this file instead of copy-pasting these rules. If a skill's own text conflicts with this file, this file wins. Keeping these in one place is deliberate: `last30days` (one of the projects this workspace draws on) documented a real, repeated failure mode where duplicated rules buried deep in a long single file got skipped because the model stopped reading partway through. One shared short file, referenced by path, avoids that.

## LAW 0 — NO SPECULATION (overrides everything else)

Every factual claim (market size, user pain point, competitor behavior, library popularity, platform stat, star count) must have a traceable source: a quoted post/comment with a link, a library's actual star count as of the check (with the check date), or an explicit tag from the vocabulary below. If you did not run a tool call to check something, you do not know it — write "not verified" rather than a plausible-sounding number.

**Canonical tag vocabulary — use exactly these, never improvise a variant:**
- `[ASSUMPTION - unverified, confirm with user]` — no evidence at all, a plain guess not yet confirmed.
- `[KR-WEB - via WebSearch, not last30days engine]` — from a Korean-market WebSearch supplement (last30days has no Naver/Daum connector).
- `[LOW-EVIDENCE]` — research ran but returned thin results; user explicitly approved proceeding anyway.
- `[LICENSE-UNCONFIRMED]` — a referenced repo/asset's license was not verified before this skill referenced it; safe to read/consult, not safe to redistribute or vendor until confirmed.

**Self-check before emitting any final output:** scan for a number, name, or claim with no attached source or tag. If found, verify it with a tool call or tag it. Never ship an unlabeled guess.

## LAW 1 — Library/tool selection: rank by evidence, never by familiarity

Whenever a skill needs to recommend a GitHub library, framework, skill, or tool and multiple candidates exist:

1. Search GitHub (WebSearch, or `gh search repos` / `gh repo view` if `gh` is authenticated; unauthenticated `curl https://api.github.com/repos/{owner}/{repo}` also works for a single known repo's real star count) — do not name a candidate from memory without checking it still exists and is still maintained.
2. Rank by **star count first**, then recent activity (`updated_at` / last commit) and open-issue responsiveness as tiebreakers. Cite the actual star count and the date you checked it — stars drift, so a stale uncheck number is a LAW 0 violation.
3. Present the top 2-3 with real numbers, not a single unexplained pick.
4. Check the license before claiming a repo's content can be referenced, borrowed, or redistributed — verify directly against the repo (a `LICENSE` file, or the GitHub API's `/repos/{owner}/{repo}/license` endpoint), never from a blog post or search-result summary. "MIT"/"Apache 2.0" = safe to reference and adapt with attribution. No `LICENSE` file (a 404 from that API endpoint) = all-rights-reserved by default — reference/read only, tag `[LICENSE-UNCONFIRMED]`, do not redistribute verbatim or vendor the files into this workspace. A repo calling itself "source-available" is explicitly NOT open source even when it has other permissive-sounding docs — treat it the same as unconfirmed.

## LAW 2 — If a design doc becomes code, the code must follow this architecture

Any skill in this workspace that produces a technical/build section must specify these constraints so an implementer (human or agent) produces disciplined code, not a prototype that has to be rewritten:

1. **UI and business logic are separate modules/layers, always.** No logic embedded in view/render code; no rendering logic inside a service/data class.
2. **Structure logic as classes (or the target language's equivalent typed module boundary) — not loose top-level functions accumulating in one file.** Each class has one clear responsibility, named after that responsibility.
3. **Every function that can fail returns an explicit success/failure result** — a `Result<T, Error>` shape, a status-tagged tuple, or the language's idiomatic equivalent — never a silent exception swallow or an ambiguous `null` as the only failure signal.
4. Any library named in a technical section carries its LAW 1 evidence (star count + check date) next to the name.

No skill in this workspace writes actual source files unless the user explicitly asks for an implementation pass separate from whatever document/design it's producing.
