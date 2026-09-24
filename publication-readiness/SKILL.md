---
name: publication-readiness
description: "Assess whether a book, ebook, or manuscript is ready for commercial publication by separating artifact validity from rights, editorial, human-reader, rendering/accessibility, and sales-channel approval. Use for '출판 가능한가', '출판 준비도 확인', '판매해도 되나', 'publish-ready', or final pre-publication review. Read-only by default; use book-author for manuscript creation and distribution for promotion strategy."
allowed-tools:
  - Read
  - Bash
  - WebSearch
  - WebFetch
  - AskUserQuestion
---

# publication-readiness

Assess commercial publication readiness without turning automated build success into release approval. A valid EPUB or PDF is one gate, not the final verdict.

**Created by ImDaeseong / [GitHub](https://github.com/ImDaeseong/skills)**

This open-source skill generalises a release-gate method developed while preparing technical manuscripts and ebooks. It is a read-only assessor unless the user separately authorises fixes.

**Licence:** MIT. See `LICENSE`; use, modify, and redistribute with the copyright notice.

**Feedback & Support:** Report methodology issues through the repository's issue tracker. If the agent skipped this skill's checks, acknowledge and rerun the missing gate instead of treating that as a methodology defect.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## Boundary

- Use `book-author` to create or substantially revise the manuscript.
- Use this skill to decide whether the current artifact and release package are ready.
- Use `distribution` for promotion and channel strategy, not release approval.
- Do not publish, upload, purchase identifiers, accept legal terms, or change live listings without explicit user authorisation.
- Default to read-only inspection. If the user also asks for fixes, finish the assessment first, state the repair scope, and preserve the original evidence.

## Start with the release target

Identify the intended format and channel: EPUB, PDF, print, direct download, marketplace, or several of these. Read the project's existing release checklist, rights ledger, validation reports, and channel records before inventing new requirements.

If a channel requirement could have changed, verify it from that channel's current official documentation. Record the page and observation date. A remembered rule is not release evidence.

## Evaluate six independent gates

Use `PASS`, `HOLD`, or `NOT APPLICABLE` for every gate. `NOT APPLICABLE` needs a reason; a missing check is `HOLD`.

| Gate | PASS requires | Typical HOLD evidence |
|---|---|---|
| Artifact integrity | Current source builds; structure, links, metadata, and format validators pass on the exact release candidate | Validator not run after the last content change; stale report; broken package |
| Rights and privacy | Text, images, fonts, code, data, names, and attachments have recorded permission or a documented exclusion; secrets and private data are absent | Unknown licence, unreviewed attachment, private/company data, unresolved attribution |
| Editorial quality | Author review is complete and the required professional or independent edit for the release context is recorded | Automated proofreading only; unresolved factual/editorial findings |
| Human reader | Representative readers complete the book's key tasks or comprehension goals against stated criteria | AI simulation only; no real readers; repeated confusion without retest |
| Rendering and accessibility | The exact candidate is inspected in relevant dedicated readers/devices; navigation, reflow, zoom, contrast, tables/code, and assistive structure are checked as applicable | Browser preview only; report belongs to an older candidate; no narrow-screen or assistive check |
| Channel package | Current official requirements are met for metadata, cover, identifiers, pricing/tax choices, preview, delivery files, and seller declarations | Placeholder metadata, missing upload/delivery file, unaccepted declaration, unverified current rule |

Do not merge these gates into an average score. A high-risk HOLD in rights, privacy, or seller declarations blocks release even when every technical test passes.

## Evidence discipline

For each gate, record:

1. the exact artifact or file inspected;
2. the command, report, official page, or human observation used;
3. when it was produced;
4. whether it applies to the current candidate;
5. what remains unverified.

Treat these as insufficient by themselves:

- “the build succeeded” as proof of rights or readability;
- AI review as a substitute for representative human readers;
- a browser rendering as a substitute for every dedicated ebook reader;
- an old EPUBCheck/accessibility report after the source changed;
- a checked box with no responsible person or evidence;
- a channel rule recalled from memory.

## Verdict

Return one of these verdicts:

- **READY FOR THE NAMED CHANNEL** — every applicable gate is PASS on the exact candidate and no required human approval is missing.
- **TECHNICALLY VALID, RELEASE HOLD** — artifact checks pass but one or more commercial/human gates remain.
- **NOT READY** — the artifact itself fails or the release package is incomplete.

Report the result in this compact form:

```markdown
Verdict: TECHNICALLY VALID, RELEASE HOLD
Target: EPUB on [channel]

| Gate | Status | Current evidence | Next action |
|---|---|---|---|
| Artifact integrity | PASS | ... | — |
| Rights and privacy | HOLD | ... | ... |

Release blockers:
1. ...

Non-blocking improvements:
- ...
```

Separate blockers from optional improvements. Stop when all agreed gates pass; do not expand into indefinite polishing.

## Pre-delivery verification

Before giving the verdict, re-read this skill and confirm:

- the named target format and channel are explicit;
- every gate has current evidence or an honest HOLD;
- human evidence has not been replaced by AI or automation;
- reports refer to the exact candidate being assessed;
- rights/privacy and channel declarations cannot be averaged away;
- no upload, publication, purchase, or live-listing mutation occurred without explicit approval;
- the verdict wording matches the weakest blocking gate.

If a rule from this skill produced a wrong decision, reproduce the failure with a positive scenario and a counterexample, make the smallest correction, and rerun this checklist. Never describe the method as perfect.
