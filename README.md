# skills

GitHub의 공개 스킬과 자료를 선별해 그대로 사용하거나 개선·보완하는 개인 저장소입니다. Claude Code/Cowork용 전문 스킬 27개와 라우터 `genie`, 총 28개를 관리합니다.

## 사용

- 스킬을 모르면 “지니야, 하고 싶은 일은 …”, 알고 있다면 “`biz-council`로 사업 아이디어를 검증해 줘”처럼 요청합니다.
- 로컬에서는 필요한 스킬을 연결하고 `../_shared/` 참조 경로를 유지합니다.
- 자세한 입력·출력은 [사용법](USAGE.md), 웹 Project 설정은 [시작하기](시작하기.md)를 참고하세요. 로컬 도구가 필요한 작업은 별도로 실행해야 합니다.

## 스킬 목록

| 분야 | 스킬 |
|---|---|
| 사업·분석 | `biz-council`, `biz-ops`, `ai-adoption-scout`, `filing-analyst`, `erp-fundamentals`, `sales-desk`, `founder-finance` |
| 글·문서·도식 | `writing`, `curator`, `social-carousel`, `design-report`, `book-distiller`, `diagram-forge` |
| 영상 | `video-producer`, `image-motion-graphics`, `video-watcher`, `shorts-clipper`, `footage-editor` |
| 개발·에이전트 | `agent-builder`, `vibe-coder`, `game-dev`, `prompt-craft`, `personal-memory` |
| 마케팅·업무 소통 | `distribution`, `managing-up` |
| 업무 운영·커리어 | `pm-delivery-ops`, `job-posting-tracker` |

## 변경 후 검증

저장소 루트에서 실행합니다. 같은 검사 3종이 GitHub Actions에서도 실행됩니다.

```powershell
# 최초 1회: 커밋 전 검사 훅 설치
powershell.exe -NoProfile -File scripts/install-git-hooks.ps1
# 변경 후: 구조·링크·회귀 검사
powershell.exe -NoProfile -File scripts/validate_workspace.ps1
powershell.exe -NoProfile -File scripts/validate_links.ps1
powershell.exe -NoProfile -File scripts/test_validators_ignore_scan.ps1
```

PASS는 저장소 검사 통과를 뜻합니다. 실제 작업 결과와 외부 도구의 동작은 별도로 확인합니다.

## 출처·라이선스

원본 출처와 활용 방식은 [ATTRIBUTION.md](ATTRIBUTION.md)에 기록합니다. 원본에는 각 저작자의 라이선스가, 자체 추가 작성 부분에는 [MIT](LICENSE)가 적용됩니다. 재사용 시 [NOTICE.md](NOTICE.md)를 확인하세요.

일부 스킬은 외부 프로젝트를 필요할 때 내려받아 사용합니다. 이들은 Git 추적과 이 저장소의 테스트 범위에서 제외됩니다.
