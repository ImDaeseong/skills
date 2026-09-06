# skills

**GitHub에 공개된 스킬과 관련 자료를 선별해 활용하는 개인 스킬 저장소입니다.** 원본을 그대로 사용하거나, 사용 목적에 맞게 개선·보완·재구성합니다. 원본 출처와 활용 방식은 [ATTRIBUTION.md](ATTRIBUTION.md)에 기록합니다.

Claude Code/Cowork용 전문 스킬 25개와 요청을 분류하는 `genie`, 총 26개로 구성됩니다.

## 시작하기

- **로컬 에이전트:** 저장소를 내려받고 필요한 스킬을 연결합니다. 각 `SKILL.md`가 참조하는 `../_shared/` 경로도 유지하세요. 다른 호스트에서는 도구 이름과 권한을 맞춰야 합니다.
- **웹 Project:** [시작하기](시작하기.md)에 따라 [프로젝트 지침](지침.md)과 공통 문서를 등록합니다. 로컬 도구 실행이 필요한 단계는 별도로 수행합니다.
- **호출:** 스킬을 모르겠다면 “지니야, 하고 싶은 일을 설명할게.” 알고 있다면 “`biz-council`로 이 사업 아이디어를 검증해 줘.”처럼 직접 요청합니다.

`genie`는 [라우팅 표](_shared/ROUTING.md)를 읽고 알맞은 스킬을 안내합니다. 입력·출력·제약은 [사용법](USAGE.md), 미지원 영역과 검토 근거는 [보류 목록](_shared/DEFERRED.md)을 확인하세요.

## 제공 스킬

| 영역 | 스킬 |
|---|---|
| 라우팅 | [genie](genie/SKILL.md) |
| 사업·분석 | [biz-council](biz-council/SKILL.md), [biz-ops](biz-ops/SKILL.md), [ai-adoption-scout](ai-adoption-scout/SKILL.md), [filing-analyst](filing-analyst/SKILL.md), [erp-fundamentals](erp-fundamentals/SKILL.md), [sales-desk](sales-desk/SKILL.md), [founder-finance](founder-finance/SKILL.md) |
| 글·문서·도식 | [writing](writing/SKILL.md), [curator](curator/SKILL.md), [social-carousel](social-carousel/SKILL.md), [design-report](design-report/SKILL.md), [book-distiller](book-distiller/SKILL.md), [diagram-forge](diagram-forge/SKILL.md) |
| 영상 | [video-producer](video-producer/SKILL.md), [image-motion-graphics](image-motion-graphics/SKILL.md), [video-watcher](video-watcher/SKILL.md), [shorts-clipper](shorts-clipper/SKILL.md), [footage-editor](footage-editor/SKILL.md) |
| 개발·에이전트 | [agent-builder](agent-builder/SKILL.md), [vibe-coder](vibe-coder/SKILL.md), [game-dev](game-dev/SKILL.md), [prompt-craft](prompt-craft/SKILL.md), [personal-memory](personal-memory/SKILL.md) |
| 마케팅·업무 소통 | [distribution](distribution/SKILL.md), [managing-up](managing-up/SKILL.md) |

## 검증

저장소 루트에서 실행합니다. 최초 1회 훅을 설치하고, 변경 후에는 검사 3종을 실행하세요.

```powershell
# 최초 1회: 커밋 전 구조·링크 검사 훅 설치
powershell.exe -NoProfile -File scripts/install-git-hooks.ps1

# 변경 후: 구조·권한·라우팅·날짜, 링크, 회귀 검사
powershell.exe -NoProfile -File scripts/validate_workspace.ps1
powershell.exe -NoProfile -File scripts/validate_links.ps1
powershell.exe -NoProfile -File scripts/test_validators_ignore_scan.ps1
```

같은 3종 검사를 [GitHub Actions](.github/workflows/validate.yml)에서도 실행합니다. PASS는 저장소 검사 통과를 뜻하며, 실제 요청의 실행 품질은 별도로 확인해야 합니다.

## 의존성과 라이선스

원본 스킬·자료의 저작권과 라이선스는 각 원저작자의 고지를 따릅니다. 이 저장소의 [MIT License](LICENSE)는 자체 추가 작성 부분에 적용되며, 외부 원본의 라이선스를 대체하지 않습니다. 설치·재사용 전 [고지](NOTICE.md)와 [출처·채택 근거](ATTRIBUTION.md)를 확인하세요.

`last30days`, `marketingskills`, `book-to-skill`, `claude-video`, `claude-shorts`, `video-use`, `archify-src`, `ai-sales-team-claude`, `charlie-cfo-skill`는 필요할 때 내려받는 런타임 의존성입니다. Git 추적과 이 저장소의 테스트 범위에서 제외되며, 자체 테스트는 해당 프로젝트의 지원 환경에서 실행합니다.

공통 원칙은 [CORE-LAWS](_shared/CORE-LAWS.md), 전체 파일 안내는 [파일설명](파일설명.md), 선택적 계정 메모리 요약은 [메모리](메모리.md)를 참고하세요.

**English:** Checks cover all 26 skills. Runtime behavior—including claim attribution, idempotency, and financial actions—requires separate validation.
