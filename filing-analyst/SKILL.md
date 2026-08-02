---
name: filing-analyst
description: "Reads a public company's own regulatory filings (US 10-K/10-Q via SEC EDGAR, Korean 사업보고서 via DART) and produces three fact-cited outputs: a one-page plain-language decoder of what the business actually earns money from, a multi-year comparison of what changed in the company's own words (risk factors, guidance vs. actual), and a reverse-DCF read of what growth rate the current price already assumes. MANDATORY TRIGGERS: '10-K 분석', '사업보고서 분석', '이 회사 뭐하는 회사야', '역DCF', 'reverse DCF', 'implied growth rate', 'analyze this stock's filing', 'what does this company actually do'. Distinct from `biz-ops` (builds a DCF/forecast FOR the user's own business) and `biz-council` (validates whether a NEW business idea should exist) — this skill reads an already-public company's own disclosures for investment research, not the user's business. Not investment advice; every output is decision-support with cited sources, not a buy/sell recommendation."
allowed-tools:
  - Read
  - Write
  - WebFetch
  - WebSearch
  - AskUserQuestion
---

# filing-analyst

Most retail stock content restates a headline number or a chart pattern. What a company's own regulatory filing says, in its own words, is a different and higher-signal source — but a 10-K routinely runs 100-300 pages, which is why most individual investors never open one. This skill reads the actual filing and produces three short outputs, each with a citation back to the specific filing/section/page it came from, so nothing in the output is a number recalled from training data.

## Attribution

- **SEC EDGAR** (`data.sec.gov`) — the US SEC's own official filing database. The `companyfacts`/`companyconcept` JSON APIs and the full-text search system are free and require no API key, but the SEC's own access policy requires a `User-Agent` header identifying the requester (e.g. `"app-name contact@email"`) on every request; requests without one, or that exceed 10 requests/second, receive a 403 and a roughly 10-minute IP block. (`sec.gov/search-filings/edgar-application-programming-interfaces`, verified 2026-08-03.)
- **DART / OpenDART** (`opendart.fss.or.kr`) — Korea's Financial Supervisory Service official disclosure system for 사업보고서 (annual report) and other regulatory filings. Free for anyone, but requires registering for a personal API key (40-character key issued after email signup) before calling the API. (`opendart.fss.or.kr/guide/main.do`, verified 2026-08-03.)
- **Reverse DCF / "Expectations Investing"** — the methodology of taking the current market price as given and solving backward for the one growth-rate (or margin) assumption that makes a standard DCF equal that price, rather than forecasting forward and computing a target price. Originated by Alfred Rappaport and Michael J. Mauboussin (Columbia Business School), *Expectations Investing* (2001, updated 2021). (Cross-verified via Investing.com's "Reverse DCF" explainer and multiple independent finance-education sources, 2026-08-03.)

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full. LAW 0 applies with extra weight here: every figure in this skill's output (revenue, margin, growth rate, a quoted sentence) must trace to an actual fetched filing page/section — never state a company's numbers from training-data memory, since filings restate and revise prior-year figures and a remembered number can already be stale or wrong.

## Investment disclaimer guard (required in every output)

Every output this skill produces ends with an explicit disclaimer, matched to the actual scope of what was done: this is decision-support built from cited public filings, not investment advice; it does not recommend buying, selling, or holding anything; the user is solely responsible for their own investment decisions; figures reflect the filing dates cited and may be stale by the time they're read. Do not omit this even when the user seems to already know it — a downstream reader (e.g. someone the user shares the output with) may not.

## Step 1: Identify the company and locate the source filing

Ask (AskUserQuestion) for the ticker/company name and market (US vs. Korea) if not already given.

- **US ticker:** resolve the CIK (SEC's internal company ID) via SEC's company-tickers lookup, then fetch the filing index via `data.sec.gov/submissions/CIK##########.json` to find the most recent 10-K (or 10-Q for interim data) accession number.
- **Korean company:** resolve the 종목코드/고유번호 via DART's company-search endpoint, then fetch the 사업보고서 filing list.
- If SEC EDGAR/DART access isn't actually available in the current session (no working WebFetch, or DART requires an API key the user hasn't provided), say so explicitly per LAW 0 rather than reconstructing filing content from memory or a secondhand summary site.

## Step 2: 기업 해독기 (Filing Decoder) — what does this company actually earn money from

Read the filing's business/segment-reporting sections (US: Item 1 Business + segment footnotes in the financial statements; Korea: 사업의 내용). Produce a one-page Korean-language summary answering: what segments exist, what share of revenue and of operating profit each contributes (these two shares often diverge — that divergence is usually the most informative single fact), and what that implies about what kind of company this actually is versus its public perception. Every number in the summary carries its filing section/page citation, following the same discipline the source concept behind this skill used ("모든 숫자에 페이지 출처 표기").

## Step 3: 스토리 리더 (Change Reader) — what changed since last time

Fetch 2-3 consecutive years of the same filing section (risk factors, MD&A, or the equivalent Korean sections) plus available earnings-call transcripts if the user has or can provide them (this skill does not have a transcript data source of its own — ask where they should come from, per LAW 0, rather than fabricating quotes). Compare language, not just numbers: what risk/hedge language was present last year and is now gone (or newly added), and how actual results compared to any guidance the company gave. A dropped cautionary sentence or a quietly abandoned guidance metric is often more informative than any single quarter's headline number.

## Step 4: 가격 판독기 (Price Reader) — reverse DCF

Using the current share price (ask the user for it or fetch it if a live-quote tool is available in-session — do not assume a price from memory, since it changes daily) and the company's own reported financials (revenue, margins, share count from the filing already fetched in Step 2), solve backward for the growth rate a standard DCF requires to justify that price, holding a stated discount rate and terminal-growth assumption explicit rather than hidden inside the formula (same discipline `biz-ops` already applies to its own DCF outputs). Present the implied growth rate next to a reasonable historical baseline (e.g. the company's own trailing revenue CAGR) so the user can judge the gap themselves — this skill states the gap, it does not tell the user whether that gap is justified.

## What this skill does not do

It does not give a buy/sell/hold recommendation — see the disclaimer guard above. It does not build a financial model or forecast for the user's own business (that's `biz-ops`) or validate whether a new business idea should exist (that's `biz-council`). It does not fabricate filing content, quoted sentences, historical prices, or earnings-call transcripts when the actual source isn't reachable in-session — it says so and asks for the missing input instead (LAW 0). It does not maintain a live market-data feed; any price used is only as fresh as what the user supplied or what an in-session tool actually returned at run time.
