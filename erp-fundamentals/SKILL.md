---
name: erp-fundamentals
description: "Before scoping or speccing an ERP-shaped project, establish the industry-agnostic baseline (universal module taxonomy, core master data, standard cross-industry processes) plus which verified industry standard applies once the vertical is known. MANDATORY TRIGGERS: 'build an ERP', 'ERP spec', 'ERP requirements', 'design an ERP system', 'what modules does an ERP need', 'ERP for my business'. Distinct from `biz-ops` (ongoing back-office execution for a business that already has its processes defined) and from literal ERP/SCM software system integration (connecting to and operating SAP/NetSuite/Oracle — see `../_shared/DEFERRED.md`, still uncovered by any evidence-cleared OSS skill). This skill produces the knowledge baseline a spec is built from, not the spec itself and not a system connection."
allowed-tools:
  - Read
  - AskUserQuestion
---

# erp-fundamentals

A request to "build an ERP" arrives with no spec, no confirmed industry, and no baseline knowledge of what an ERP actually has to cover — every prior attempt to fill this gap in the workspace searched for an installable OSS *agent-skill package* and found none that cleared `../_shared/CORE-LAWS.md`'s LAW 1 star/license bar (see `../_shared/DEFERRED.md`'s ERP/SCM entries). That search answers a different question than this skill does: an OSS package to *adopt* was never found, but the underlying domain knowledge — the module taxonomy every real ERP shares, and the standards each industry vertical maps to — is well-documented and can be stated directly, without needing a GitHub candidate at all.

## Attribution

- **Universal ERP module taxonomy** — sourced from NetSuite's own vendor documentation ([netsuite.com/portal/resource/articles/erp/erp-modules.shtml](https://www.netsuite.com/portal/resource/articles/erp/erp-modules.shtml)) and TechTarget's ERP finance-module definition ([techtarget.com/searcherp/definition/ERP-finance-module](https://www.techtarget.com/searcherp/definition/ERP-finance-module)), cross-checked 2026-07-30. Oracle ERP Cloud's own six-pillar grouping (Financials, Procurement, Project Portfolio Management, Supply Chain & Manufacturing, Enterprise Performance Management, Risk Management) is cited as one real vendor's concrete instance of the same taxonomy, not as the only correct grouping.
- **Industry-standard layer** — each of these was independently verified (with primary-source checks) during this workspace's 2026-07-29 domain-coverage research, recorded in `../_shared/DEFERRED.md`:
  - Manufacturing: **ANSI/ISA-95** (IEC/ISO 62264) — the ERP-to-MES information-exchange standard, "universally adopted" per isa.org/Siemens/Tulip/Symestic.
  - Accounting: **US GAAP** (FASB) and **IFRS** (IASB, required or permitted in 110+ countries per Deloitte's GAAP-vs-IFRS comparison).
  - Trade/customs: **Incoterms 2020** (ICC) and the **Harmonized System (HS Code)** (WCO, 200+ countries).
  - Retail/apparel/distribution: **GS1** barcode/EDI/traceability (1M+ companies, 6B+ transactions/day per gs1.org, incl. GS1 US's Apparel & General Merchandise guidelines).
- **Vendor-specific reference (if the request names a specific platform)** — Oracle's own **SuiteCloud Agent Skills v1.0** for NetSuite (`oracle/netsuite-suitecloud-sdk`, 315★, UPL-1.0, Oracle's own org, confirmed via `docs.oracle.com` 2026-07-29) and two SAP-specific community collections, `secondsky/sap-skills` (392★, GPL-3.0) and `marianfoo/sap-ai-mcp-servers` (396★, MIT) — all still far below this workspace's usual 22,733★ bar, named here only as a starting point if a request specifically needs SAP/NetSuite conventions rather than generic ERP structure.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full. Especially LAW 0 — do not present the module list or a standard's scope from memory beyond what's cited above; if a request needs a specific figure (a GAAP rule number, an exact ISA-95 layer definition) not already verified here, say so and verify it before stating it as fact.

## Step 1: Universal baseline — always applies regardless of industry

Every real ERP, independent of vertical, is built from the same core modules and master data, per the Attribution sources above:

- **General Ledger (GL)** — the central record of all financial transactions (accounts, assets, liabilities); every other module posts into it.
- **Accounts Payable (AP) / Accounts Receivable (AR)** — vendor invoices/payments and customer invoices/collections.
- **Procurement (Procure-to-Pay)** — requisition → purchase order → receipt → invoice match.
- **Inventory / Item Master** — stock levels, locations, valuation.
- **Order Management (Order-to-Cash)** — quote/order → fulfillment → invoice → collection.
- **HR/Payroll** — employee records, compensation, time tracking (present in most ERPs even when a dedicated HRIS also exists).
- **Master data, cross-cutting** — Chart of Accounts, Vendor master, Customer master, Item master. These are shared reference data every module above reads from; get this wrong and every downstream module inherits the error.

State this list back to the user as the acceptance-criteria seed before scoping further — a request that only wants "invoicing" or "inventory" may not need the full set, and that should be confirmed rather than assumed.

## Step 2: Identify the industry layer

Ask (AskUserQuestion) which industry/vertical the ERP is for, if not already stated — the baseline in Step 1 does not change, but which additional standard applies does:

| Vertical | Standard to apply | Source |
|---|---|---|
| Manufacturing | ISA-95 (MES integration layer, BOM/routing concepts) | Attribution above |
| General accounting-heavy / any company's financial layer | GAAP or IFRS depending on jurisdiction | Attribution above |
| Import/export/trade | Incoterms 2020 + HS Code classification | Attribution above |
| Retail/apparel/distribution | GS1 barcode/EDI | Attribution above |
| Specifically SAP or NetSuite | See vendor-specific reference above | Attribution above |
| Anything else (healthcare, semiconductor, etc.) | Check `../_shared/DEFERRED.md` first — several verticals were searched and found to have **no** evidence-cleared skill or even a clear OSS integration target; say so rather than improvising | `../_shared/DEFERRED.md` |

Healthcare in particular is flagged in `../_shared/DEFERRED.md` as a heightened-risk category (PHI/HIPAA exposure) — do not proceed past the baseline into implementation specifics for a healthcare ERP without a dedicated safety design, not a reuse of this skill's guard.

## Step 3: Hand off to execution — this skill does not build or connect anything

- **Turning the baseline + industry layer into an actual spec** — use this skill's Step 1/2 output as the acceptance-criteria seed for a proper spec process (e.g. a `/spec`-style requirements pass in whatever host tool is running); this skill stops at the knowledge baseline.
- **Ongoing back-office work once the ERP's processes are already defined** (financial analysis, RFP response, vendor management) — route to `biz-ops`.
- **Literal software connection to a real ERP platform** (SAP, NetSuite, Oracle) — not covered here or anywhere in this workspace yet; check `../_shared/DEFERRED.md`'s ERP/SCM entry and say so honestly (LAW 0) rather than fabricating an integration.

## What this skill does not do

It does not connect to, configure, or operate any real ERP software. It does not replace `biz-ops`'s ongoing operational/financial work once an ERP's processes already exist. It does not cover a vertical `../_shared/DEFERRED.md` marks as having no evidence-cleared candidate (healthcare, semiconductor, apparel-specific agent tooling) without flagging that gap explicitly. It does not fabricate GAAP/IFRS/ISA-95/Incoterms specifics beyond what's cited above — a request needing exact regulatory detail needs a fresh, verified check, not a recollection from this file.
