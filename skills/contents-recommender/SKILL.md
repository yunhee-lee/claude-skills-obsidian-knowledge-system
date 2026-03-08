---
description: Recommends the most relevant learning content (KB notes, books, web, YouTube) for a given question, problem, or curiosity.
allowed-tools: Read, Write, Edit, Glob, Grep, WebSearch
user-invokable: true
---

# Contents Recommender

## Pipeline

```
/contents-recommender [키워드 또는 문장]
    │
    ▼
문서 생성 — (Research) 키워드.md in {{VAULT_PATH}}/0️⃣ Inbox/
    │
    ▼
문제 구체화 — 질문 유형 판별 → clarifying questions 3개 제시 → 사용자 답변 수집
    │
    ▼
우선순위 탐색
  (1) Knowledge base — Glob/Grep으로 {{VAULT_PATH}} 탐색
  (2) 보유 서적 챕터 — Book Reference List.md → 목차 노트 확인
  (3) 웹 검색 — WebSearch (선호 도메인 우선)
  (4) YouTube — WebSearch (선호 유튜버 우선)
    │
    ▼
후보 목록 정리 → 적절성 비교 → 상위 3개 선정
    │
    ▼
문서에 추천 결과 기록 + 채팅으로 추천 사유 설명
```

---

# A. Trigger

`$ARGUMENTS`에서 키워드 또는 문장을 읽음.
- 비어 있으면 → "추천받고 싶은 주제나 고민을 입력해주세요." 출력 후 종료.

---

# B. Step 1 — 문서 생성

파일명: `(Research) {키워드}.md`
저장 위치: `{{VAULT_PATH}}/0️⃣ Inbox/`

키워드는 `$ARGUMENTS`를 그대로 사용. 문장이면 핵심어 3단어 이내로 축약.

초기 문서 내용:

```markdown
---
tags:
  - note/recommendation
date: YYYY.MM.DD(Day)
query: {사용자 입력 전문}
---
## Recommendation Context
### Problem Summary
- (탐색 후 채움)
### Search Criteria
(탐색 후 채움)
---
## Recommended Content (Top 3)
(탐색 후 채움)
---
## Full Candidate List
(탐색 후 채움)
```

문서 생성 후 사용자에게 경로 알림.

---

# C. Step 2 — 문제 구체화

질문 유형을 먼저 판별:
- **유형 A (지식 탐색)**: 특정 개념/기술/도메인을 이해하거나 학습하려는 경우
- **유형 B (업무·일상 고민)**: 실제 상황에서 방향이나 접근법을 찾으려는 경우

판별 후 해당 유형의 질문 3개를 한 번에 제시. 이미 충분한 컨텍스트가 주어진 항목은 생략.

**유형 A 질문:**
1. **배경 수준**: "이 주제를 처음 접하시나요, 어느 정도 알고 계신가요?"
2. **형식 선호**: "영상/글/책 중 선호하는 형식이 있나요? 없으면 상관없어요."
3. **깊이**: "핵심만 빠르게 파악하고 싶으신가요, 깊이 공부하고 싶으신가요?"

**유형 B 질문:**
1. **상황 구체화**: "어떤 상황에서 이 고민이 생겼나요? 조금 더 구체적으로 말씀해주세요. (예: 조직 규모, 현재 어떤 단계에 있는지, 언제부터 느끼는지 등)"
2. **이미 시도한 것**: "지금까지 생각해봤거나 시도해본 접근이 있나요?"
3. **원하는 도움 유형**: "지금 당장 실행할 수 있는 방법이 필요하신가요, 이 문제를 더 깊이 이해하는 게 먼저인가요?"

사용자 답변을 받은 뒤 탐색 단계로 진행.

---

# D. Step 3 — 소스 탐색

## (1) Knowledge Base

Glob/Grep으로 `{{VAULT_PATH}}/` 탐색. 대상 폴더: `0️⃣ Inbox`, `2️⃣ Notes`, `3️⃣ Knowledge`.

- 키워드 + 연관어로 검색
- 관련 노트 발견 시 → 노트 직접 추천 (`[[문서 제목]]` 형식으로 링크, 내용 한 줄 설명)
- 결과 없으면 → 알림 없이 다음 소스로 이동

## (2) 보유 서적 (챕터 단위)

`{{VAULT_PATH}}/4️⃣ Reference/Book Reference List.md` 읽기.
- 파일 없거나 읽기 실패 → 해당 소스 건너뜀
- 키워드와 관련 있는 책 특정 → 해당 책의 목차 노트 읽기
- 관련 챕터를 **챕터 단위**로 추천: "X책의 N장: 제목" 형식

## (3) 웹 검색

`{{VAULT_PATH}}/4️⃣ Reference/Contents Preferences.md` 확인.
- 선호 도메인 있으면 → 해당 도메인 우선 탐색 (WebSearch에 도메인 필터)
- 없으면 → 일반 WebSearch

## (4) YouTube 검색

`{{VAULT_PATH}}/4️⃣ Reference/Contents Preferences.md` 확인.
- 선호 유튜버 있으면 → 해당 채널 우선 탐색
- 없으면 → 일반 YouTube WebSearch

---

# E. Step 4 — 후보 비교 및 상위 3개 선정

수집한 후보 목록에서 다음 기준으로 상위 3개 선정:
1. 사용자 수준·형식·깊이 선호와의 일치도
2. 키워드와의 직접적 연관성
3. 소스 신뢰도 (Knowledge Base > 검증된 도서 > 저명 사이트/채널)

---

# F. Step 5 — 문서 업데이트

생성한 `(Recommendation) 키워드.md`를 다음 형식으로 업데이트:

```markdown
---
tags:
  - note/recommendation
date: YYYY.MM.DD(Day)
query: {사용자 입력 전문}
---
## Recommendation Context
### Problem Summary
- {사용자가 설명한 문제/고민/호기심 요약}
### Search Criteria
**유형 A (지식 탐색)**
- 수준: [초급 / 중급 / 고급]
- 형식: [영상 / 글 / 책 / 무관]
- 깊이: [핵심 파악 / 깊이 학습]

**유형 B (업무·일상 고민)**
- 상황: {구체적 상황 요약}
- 이미 시도한 것: {있으면 기재, 없으면 생략}
- 원하는 도움: [원인 이해 / 실행 방법 / 둘 다]
---
## Recommended Content (Top 3)
### 1. {컨텐츠 제목}
- Source: [Knowledge Base / Book / Web / YouTube]
- Path: ...
- Reason: ...
### 2. {컨텐츠 제목}
- Source: ...
- Path: ...
- Reason: ...
### 3. {컨텐츠 제목}
- Source: ...
- Path: ...
- Reason: ...
---
## Full Candidate List
- {추천 3개 외 검토했던 후보들}
```

유형 A/B 중 해당하는 섹션만 기재. 둘 다 해당하면 둘 다 작성.

---

# G. Step 6 — 채팅 추천 사유 설명

문서 업데이트 후 채팅에서 추천 사유를 간결하게 설명:
- 상위 3개 각각에 대해 왜 이 컨텐츠가 사용자 문제에 적합한지 1-2문장으로 설명
- 문서 경로 안내

---

# H. 선호 소스 관리

저장 위치: `{{VAULT_PATH}}/4️⃣ Reference/Contents Preferences.md`

**업데이트 조건**: 사용자가 명시적으로 요청한 경우에만.
- "이 사이트 저장해줘", "이 유튜버 추가해줘" 등의 명시적 요청
- 파일 없으면 최초 요청 시 생성

파일 형식:
```markdown
## 선호 웹 도메인
- [도메인] — [이유 한 줄]

## 선호 유튜버
- [채널명] — [이유 한 줄]
```

---

# I. 에러 처리

- KB 결과 없음 → 다음 소스로 이동 (별도 알림 없음)
- Book Reference List 없거나 목차 정보 없음 → 해당 소스 건너뛰고 웹 탐색
- 추천 가능한 컨텐츠가 3개 미만 → 찾은 수만큼 추천하고 "추가 탐색이 필요한 경우 키워드를 더 구체적으로 제시해주세요." 안내
- 모든 소스에서 결과 없음 → "키워드를 다르게 표현하거나 더 구체적으로 입력해주시면 다시 탐색할게요." 요청

---

# J. 언어 규칙

- 채팅 출력: 한국어
- 문서 내용: 한국어
- 문장체: 합니다/입니다 생략, 명사형 또는 -임/-함/-됨 종결
- 들여쓰기: 탭만 사용, 스페이스 금지
