# `outline.json` 인계 스키마

ChatGPT 구조 레이어가 만들고 사용자가 승인한 뒤 Claude 글쓰기 레이어에 전달한다.

```json
{
  "schema_version": 1,
  "title": "책 제목",
  "reader": "대상 독자와 현재 상태",
  "problem": "책이 해결할 중심 문제",
  "promise": "완독 후 독자가 할 수 있는 일",
  "tone": "문체와 태도",
  "total_target_words": 12000,
  "glossary": [
    {
      "term": "표준 표기",
      "definition": "한 줄 정의",
      "forbidden_variants": ["금지 변형"]
    }
  ],
  "chapters": [
    {
      "id": 1,
      "slug": "problem-and-promise",
      "title": "챕터 제목",
      "goal": "이 장을 읽은 뒤 얻는 것",
      "key_claims": ["이 장에서 확립할 주장"],
      "depends_on": [],
      "examples": ["검증 가능하거나 사용자가 제공한 사례"],
      "evidence_needed": [],
      "target_words": 1500,
      "resolves_promise": true
    }
  ]
}
```

## 계약

- `schema_version`은 현재 `1`이다.
- 챕터 `id`는 1부터 연속이며 파일명은 `NN_slug.md`다.
- `slug`는 소문자 영문·숫자·하이픈만 사용한다.
- `depends_on`은 존재하는 앞 챕터만 참조한다.
- `resolves_promise`는 마지막 챕터에만 두며 값은 `true`다. 이는 구조상 회수 의도를 표시할 뿐이며, 실제 의미 충족은 사람이 검토한다.
- 확인되지 않은 근거는 `evidence_needed`에 남긴다.
- 구조 승인 후 핵심 주장 변경은 `outline.json`의 새 승인 버전으로 처리한다.
