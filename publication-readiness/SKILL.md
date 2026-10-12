---
name: publication-readiness
description: "Assess whether a book, ebook, or manuscript is ready for commercial publication by separating artifact validity from rights, editorial, content truth, technical currency, human-reader, rendering/accessibility, and sales-channel approval. Use for '출판 가능한가', '출판 준비도 확인', '판매해도 되나', '사실·논문 확인', '낡은 기술인가', '최신성 점검', 'publish-ready', or final pre-publication review. Read-only by default; use book-author for manuscript creation and distribution for promotion strategy."
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

## Evaluate eight independent gates

Use `PASS`, `HOLD`, or `NOT APPLICABLE` for every gate. `NOT APPLICABLE` needs a reason; a missing check is `HOLD`.

| Gate | PASS requires | Typical HOLD evidence |
|---|---|---|
| Artifact integrity | Current source builds; structure, links, metadata, and format validators pass on the exact release candidate | Validator not run after the last content change; stale report; broken package |
| Rights and privacy | Text, images, fonts, code, data, names, and attachments have recorded permission or a documented exclusion; secrets and private data are absent | Unknown licence, unreviewed attachment, private/company data, unresolved attribution |
| Editorial quality | Author review is complete and the required professional or independent edit for the release context is recorded | Automated proofreading only; unresolved factual/editorial findings |
| Content truth | Every checkable claim (number, paper, standard, quotation, product behavior) is traced to a primary source read in this session; cited papers match title and authors; links resolve or are classified; the book separates sourced fact from the author's own experience | A number from memory or a search snippet; a paper cited but never opened; a dead link; a vendor survey presented without its interest |
| Technical currency | Each time-sensitive statement (runtime versions, end-of-life dates, model and API names, deprecation dates, standards, tool install steps) was checked against an official page dated now, is tagged keep / historical / update / delete with a re-check condition, and the book's examples run on currently supported runtimes | An end-of-life runtime as the baseline; a retired API recommended for new work; a ledger older than the release window; "newer version exists" confused with "old choice retired" |
| Human reader | Representative readers complete the book's key tasks or comprehension goals against stated criteria | AI simulation only; no real readers; repeated confusion without retest |
| Rendering and accessibility | The exact candidate is inspected in relevant dedicated readers/devices; navigation, reflow, zoom, contrast, tables/code, and assistive structure are checked as applicable | Browser preview only; report belongs to an older candidate; no narrow-screen or assistive check |
| Channel package | Current official requirements are met for metadata, cover, identifiers, pricing/tax choices, preview, delivery files, and seller declarations | Placeholder metadata, missing upload/delivery file, unaccepted declaration, unverified current rule |

Do not merge these gates into an average score. A high-risk HOLD in rights, privacy, or seller declarations blocks release even when every technical test passes.

### Match the recurring question to a gate

| Question | Gate | Minimum evidence |
|---|---|---|
| Can it be published? | All eight, then the verdict | The gate table above |
| Is it easy enough to read? | Editorial quality, human reader | Measured sentence length, jargon, figure density (AI can measure these) plus real readers on stated tasks (AI cannot judge comprehension) |
| Is it fact-based? | Content truth | The quoted sentence from the primary source for each number and citation |
| Is the technology outdated? | Technical currency | Official pages dated now, plus a ledger with a re-check condition per item |
| Is it verified? | Artifact integrity | Validator output on the exact candidate, bound to its hash |

### Source ladder for truth and currency checks

- A primary source is the paper or its abstract page, the standards body's page, or the vendor's official documentation. Search summaries, news write-ups, and blogs are leads, not evidence; two of them can disagree on the same number.
- Quote the sentence that contains each number. Confirm which version it comes from (a preprint's v1 and v2 can differ) and whether the work is peer reviewed.
- A fetch that returns part of a page, or a neighbouring page of the same site, does not support "not documented". Read on or fetch the reference page before holding an item as unverified.
- Classify every link: ok (200/202), expected exception (local address, intentionally private repository, a bot-blocked 403 whose page you opened another way), or broken. Retry a failed HEAD with GET before calling a link dead.
- "A newer version exists" is not "the old choice is retired". Tag each item keep, historical, update, or delete, and record the check date and what would trigger the next check.
- When newer research changes how an old number reads, show both side by side with the date and the evidence level instead of silently replacing the old one.

### Companion code and evidence binding

- If the book links to a code repository, check the promised paths, that the release tag points at a commit containing what the book describes (count lag only for commits that change linked files), and that the examples run in a clean copy on a currently supported runtime.
- Store each validator result with the hash of the artifact it checked, in one record file that prose points to, and make the build reproducible so unchanged sources give identical bytes. Otherwise a rebuild silently invalidates every stored PASS.
- Call a paid API only with explicit approval, stating model, number of calls, and cost. A mock proves the surrounding code, not that the real model satisfies the validator.

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
- every number, citation, and time-sensitive statement traces to a primary source read in this session, or is held as unverified;
- human evidence has not been replaced by AI or automation;
- reports refer to the exact candidate being assessed;
- rights/privacy and channel declarations cannot be averaged away;
- no upload, publication, purchase, or live-listing mutation occurred without explicit approval;
- the verdict wording matches the weakest blocking gate.

## Evaluation scenarios

Re-run these when editing the skill; each should reach the stated result.

1. A book tells beginners to use "Python 3.9 or later" and the runtime's maintainers list 3.9 as end of life → Technical currency is HOLD with an update action, not PASS because the examples still run.
2. A book states a research percentage that appears only in a news write-up or search snippet → Content truth is HOLD until the paper's own sentence is quoted; a newer replication of the same study is shown next to the old figure.
3. A companion repository gains a commit that edits only its README after the release tag → the tag-lag finding stays quiet, while a commit that edits a linked example raises it.

If a rule from this skill produced a wrong decision, reproduce the failure with a positive scenario and a counterexample, make the smallest correction, and rerun this checklist. Never describe the method as perfect.
