# skills

Claude Code/Cowork용 Agent Skills 모음입니다. 19개 전문 스킬과 요청을 적절한 스킬로 연결하는 `genie`로 구성됩니다(총 20개).

> 다른 Agent Skills 호스트에서도 사용할 수 있지만, `allowed-tools`의 `AskUserQuestion`, `Task`, `Bash` 등은 Claude 전용 이름이므로 호스트에 맞게 변환해야 할 수 있습니다.

## 빠른 시작

1. 저장소를 clone하거나 내려받습니다.
2. 각 스킬 폴더를 에이전트의 스킬 디렉터리에 연결합니다. Claude Code는 `~/.claude/skills/` 아래에 복사하거나 심볼릭 링크를 만듭니다.
3. 무엇을 호출할지 모르겠다면 **`genie`**를 사용합니다. `genie`는 [`_shared/ROUTING.md`](_shared/ROUTING.md)를 읽고 알맞은 전문 스킬을 안내합니다.
4. 스킬 이름을 안다면 직접 호출해도 됩니다. 예: “`biz-council`로 이 사업 아이디어를 검증해 줘.”

스킬별 입력, 출력, 호출 예시와 제약은 [`USAGE.md`](USAGE.md)를 참고하세요.

## 검증

최초 clone 후 Git hook을 한 번 설치합니다.

```powershell
powershell.exe -NoProfile -File scripts/install-git-hooks.ps1
```

커밋 전에는 다음 세 검사를 실행합니다.

```powershell
powershell.exe -NoProfile -File scripts/validate_workspace.ps1
powershell.exe -NoProfile -File scripts/validate_links.ps1
powershell.exe -NoProfile -File scripts/test_validators_ignore_scan.ps1
```

- `validate_workspace.ps1`: all 20 skills의 구조, 이름, 도구 권한, 라우팅, 날짜와 안전 가드를 검사합니다.
- `validate_links.ps1`: 로컬 Markdown 링크를 검사합니다.
- `test_validators_ignore_scan.ps1`: 검증기가 gitignored 제3자 디렉터리에 진입하지 않는지 회귀 검사합니다.
- 같은 검사는 [GitHub Actions](.github/workflows/validate.yml)에서도 실행됩니다.

PASS는 규칙과 필수 문구가 올바르게 배치됐다는 뜻입니다. 실제 요청에서 claim attribution, idempotency, financial actions 같은 규칙을 제대로 수행했는지는 별도의 행동 검증과 사람의 검토가 필요합니다.

## 구조

- [`genie/`](genie/SKILL.md): 단일 진입점과 라우터
- [`_shared/CORE-LAWS.md`](_shared/CORE-LAWS.md): 모든 스킬이 따르는 공통 원칙과 검증 루프
- [`_shared/ROUTING.md`](_shared/ROUTING.md): 요청과 전문 스킬의 연결표
- [`_shared/DEFERRED.md`](_shared/DEFERRED.md): 아직 제공하지 않는 영역과 보류 근거
- [`USAGE.md`](USAGE.md): 스킬별 상세 사용법
- [`ATTRIBUTION.md`](ATTRIBUTION.md): 외부 프로젝트의 출처, 라이선스와 채택 근거

## 제공 스킬

| 영역 | 스킬 |
|---|---|
| 라우팅 | [`genie`](genie/SKILL.md) |
| 사업·분석 | [`biz-council`](biz-council/SKILL.md), [`biz-ops`](biz-ops/SKILL.md), [`ai-adoption-scout`](ai-adoption-scout/SKILL.md), [`filing-analyst`](filing-analyst/SKILL.md), [`erp-fundamentals`](erp-fundamentals/SKILL.md) |
| 콘텐츠·문서 | [`writing`](writing/SKILL.md), [`curator`](curator/SKILL.md), [`social-carousel`](social-carousel/SKILL.md), [`video-producer`](video-producer/SKILL.md), [`image-motion-graphics`](image-motion-graphics/SKILL.md), [`design-report`](design-report/SKILL.md), [`book-distiller`](book-distiller/SKILL.md) |
| 개발·에이전트 | [`agent-builder`](agent-builder/SKILL.md), [`vibe-coder`](vibe-coder/SKILL.md), [`game-dev`](game-dev/SKILL.md), [`prompt-craft`](prompt-craft/SKILL.md), [`personal-memory`](personal-memory/SKILL.md) |
| 업무 커뮤니케이션 | [`distribution`](distribution/SKILL.md), [`managing-up`](managing-up/SKILL.md) |

현재 제공하지 않는 영역은 기획, 제조, 영업, 개인·창업자 재무 운영, ERP/SCM/CRM 시스템 연동입니다. `genie`는 지원하지 않는 요청을 임의로 처리하지 않고 한계를 알립니다.

## 제3자 의존성과 라이선스

이 저장소가 직접 작성한 콘텐츠는 [MIT License](LICENSE)로 배포됩니다. 외부 프로젝트는 이 저장소의 라이선스로 재배포되지 않습니다.

- `last30days`, `marketingskills`, `book-to-skill`은 필요할 때 내려받는 gitignored 런타임 의존성입니다.
- 이들의 자체 테스트는 이 저장소의 PASS 기준에 포함되지 않습니다. 특히 `last30days` 테스트는 POSIX 환경을 전제로 하므로 Windows에서 직접 실행하면 무관한 실패가 발생할 수 있습니다.
- 외부 자료를 설치하거나 재사용하기 전에 [`NOTICE.md`](NOTICE.md)와 [`ATTRIBUTION.md`](ATTRIBUTION.md)를 확인하세요.

## English

This repository contains 18 Claude-oriented specialist skills plus `genie`, the routing entry point (19 in total). See [`USAGE.md`](USAGE.md) for per-skill instructions, [`ATTRIBUTION.md`](ATTRIBUTION.md) for third-party evidence and licenses, and the verification commands above before committing.
