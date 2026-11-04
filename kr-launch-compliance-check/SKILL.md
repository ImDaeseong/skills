---
name: kr-launch-compliance-check
description: "Korean-market pre-launch regulatory checklist for small consumer-goods or service businesses, one industry per reference file: apparel/caps/t-shirts, cosmetics, massage. Every legal item carries its statute, check date, and verified/unverified status. MANDATORY TRIGGERS: '의류 사업 규제', '티셔츠 판매 신고', '모자 KC 인증', '화장품 판매 허가', '마사지 사업 법규', '쇼핑몰 통신판매업 신고', 'what permits do I need to sell X in Korea'. Do not trigger on picking a business idea (use biz-council), channel plans (distribution), or pricing (founder-finance)."
allowed-tools:
  - Read
  - WebSearch
  - AskUserQuestion
---

# kr-launch-compliance-check

비전문가가 판매 전에 놓치기 쉬운 한국 규제를 업종별로 짚어 준다. 사업 판단은 하지 않는다. 아이템 선정은 `biz-council`, 채널은 `distribution`, 손익은 `founder-finance`로 넘긴다.

## Core Laws

Follow `../_shared/CORE-LAWS.md` in full.

## 업종 파일

| 업종 | 파일 | 상태 |
|---|---|---|
| 의류·모자·티셔츠 | `references/apparel.md` | 작성됨 (확인됨/미확인 구분) |
| 화장품 | `references/cosmetics.md` | 작성됨 (확인됨/미확인 구분) |
| 마사지 | `references/massage.md` | 작성됨 (마사지가 안마사 업무로 정의됨을 확인, 자격 없는 사람의 허용 범위는 미확인 — 담당 기관 문의 필수) |

파일이 없는 업종을 물으면 "아직 검증된 자료가 없다"고 말하고 기억으로 답하지 않는다. 그 업종의 법령은 법제처(law.go.kr)에서 직접 확인하도록 안내한다.

## 절차

1. 물건인지 서비스인지, 어느 업종인지 묻는다 (`AskUserQuestion`). 걸리는 업종의 파일만 읽는다. 업종이 둘 이상 걸리면(예: 마사지 가게에서 화장품도 판매) 각각 읽고 표를 업종별로 나눈다.
2. 파일 끝의 "사용자에게 먼저 물을 것"을 순서대로 묻고, 답에 해당하는 항목만 보여 준다. 해당 없는 항목까지 늘어놓지 않는다.
3. 출력은 `항목 / 근거 조문 / 확인일 / 상태(확인됨·미확인)` 표로 고정한다. 파일의 상태 표시를 바꾸지 않는다.
4. 확인일이 재검증 기한을 지났으면 그 사실을 먼저 말한다. 호스트에 브라우저 도구(예: Playwright)가 있으면 법제처에서 현행본을 열어 다시 확인하고, 없으면 재검증하지 못했다고 밝힌 뒤 사용자에게 law.go.kr에서 직접 확인하도록 안내한다.

## 지켜야 할 한계

- 사용자 문구가 적법한지 판정하지 않는다. 효능·광고 표현은 허용/금지 사례를 보여 주고 최종 판단은 담당 기관에 맡긴다.
- 체크리스트를 다 채웠다고 합법이라고 말하지 않는다. 판단이 갈리는 항목마다 문의처를 붙인다.
- 법령 확인에는 법제처 원문을 쓴다. 블로그 요약은 `[LOW-EVIDENCE]`로만 쓴다. 법제처 페이지는 스크립트로 그려지므로 일반 가져오기(WebFetch)로는 본문이 비어 온다. 브라우저 도구로만 읽을 수 있다.
- 법률자문이 아니다.
