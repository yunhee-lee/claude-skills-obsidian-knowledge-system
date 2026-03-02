# Book Reflection

독서 중 메모(Reading Log)부터 완독 후 곱씹기(Core Summary → Dialogue → Critical Review → Life Application)까지,
하나의 Obsidian 노트 안에서 5단계로 진행하는 독서 성찰 스킬.

## Pipeline

```
/book-reflection init "책 제목" "저자명"
    │
    ▼
노트 생성 → 사용자가 Reading Log 직접 기록 (독서 중)
    │
    ▼  /book-reflection [파일명] 실행 (완독 후)
Stage 2: Core Summary 생성
    │
    ▼  /book-reflection [파일명] 다시 실행
Stage 3: Understanding the Author's Argument — 문답 진행
    │
    ▼  /book-reflection [파일명] 다시 실행
Stage 4: Critical Review & Knowledge Expansion — 비판적 검토 + 기존 메모 연결
    │
    ▼  /book-reflection [파일명] 다시 실행
Stage 5: Life Application — 삶 적용 1-2개
```

---

# A. 트리거 형식

| 형식 | 동작 |
|---|---|
| `/book-reflection init "책 제목" "저자명"` | 새 노트 생성 |
| `/book-reflection [파일명 or 경로]` | 현재 단계 감지 후 실행 |
| `/book-reflection [파일명] stage=2` (또는 3/4/5) | 특정 단계 강제 실행 |

- 파일명 형식: `<책 제목> 저자.md` (예: `<Slow Productivity> Cal Newport.md`, `<원씽> 게리 켈러.md`)
- 저장 경로: `{{VAULT_PATH}}/0️⃣ Inbox/`
- 파일명에 공백이 있으면 따옴표로 감쌀 것

---

# B. Stage 감지 로직

노트를 Read한 후 아래 순서로 판단:

1. `### Core Summary` 섹션 바로 아래가 placeholder(`##### Sub Topic\n- -`)만 있음 → **Stage 2 실행**
2. `### Understanding the Author's Argument` 섹션이 placeholder(`- -`)만 있음 → **Stage 3 실행**
3. `### Critical Review & Knowledge Expansion` 섹션이 placeholder(`- -`)만 있음 → **Stage 4 실행**
4. `### Life Application` 섹션이 placeholder(`##### Case Title\n- -`)만 있음 → **Stage 5 실행**
5. 모두 채워져 있음 → 완료 안내 출력

"비어있음" 판단 기준: 섹션 heading 바로 아래에 실질적인 내용이 없거나, 템플릿 placeholder(`- -`, `##### Sub Topic`, `##### Case Title`, `- [[]]`)만 있는 경우.

---

# C. Init Mode

## 실행 내용

1. 사용자 입력에서 책 제목, 저자명 파싱
2. 파일 경로 결정:
   ```
   {{VAULT_PATH}}/0️⃣ Inbox/<책 제목> 저자.md
   ```
   예시: `<Atomic Habits> James Clear.md`, `<죽음이란 무엇인가> 셸리 케이건.md`
3. 템플릿(`Structure/Templates/Primary Note - Book.md`)을 기반으로 노트 생성:
   - `{{date}}` → 오늘 날짜 (`YYYY.MM.DD(Day)` 형식, 예: `2026.03.02(Mon)`)
   - `author: ""` → `author: "저자명"`
   - References 섹션의 `{{author}} 《{{title}}》` → `저자명 《책 제목》`
   - Reading Log의 첫 번째 entry 날짜 placeholder(`##### YYYY.MM.DD(Date)`) → 오늘 날짜로 교체
4. 완료 후 출력:

```
## book-reflection — 노트 생성 완료

- 파일: `0️⃣ Inbox/<책 제목> 저자.md`
- 다음 단계: 책을 읽으면서 Reading Log에 날짜별로 기록하세요.
- 완독 후: `/book-reflection "<책 제목> 저자"` 를 실행하면 Stage 2부터 진행합니다.
```

---

# D. Stage 2: Core Summary

## 목적

Reading Log에 담긴 사용자의 날 것의 반응을 바탕으로, 이 책의 핵심을 구조화된 형태로 정리.

## 실행 내용

1. 노트의 `### Reading Log` 전체를 읽음
2. 아래 구조로 Core Summary 작성 (H5 소제목 사용):

```markdown
##### Thesis (저자의 핵심 주장)
- [1-2 문장으로 명확하게]

##### Key Concepts (핵심 개념)
- [개념 1]: [한 줄 설명]
- [개념 2]: [한 줄 설명]

##### From Your Reading Log
- [Reading Log에서 유독 반복되거나 강하게 반응한 주제/구절 패턴 요약]
```

3. `### Core Summary` 섹션의 placeholder(`##### Sub Topic\n- -`)를 위 내용으로 교체 (Edit tool)
4. 사용자에게 확인 요청:

```
Core Summary를 작성했어요. 검토 후 수정이 필요하면 말씀해주세요.
준비되면 `/book-reflection "<파일명>"` 을 다시 실행해서 Stage 3으로 넘어가세요.
```

---

# E. Stage 3: Understanding the Author's Argument

## 목적

저자의 논증을 표면적으로 이해하는 수준을 넘어, 더 깊이 파고들기 위한 대화 진행.
AI가 소크라테스식 문답(Socratic questioning)으로 사용자의 이해를 심화시키고 빈틈을 발견하게 함.

## 실행 내용

1. Reading Log + Core Summary를 읽음
2. 아래 기준으로 **3개의 질문** 생성:
   - 질문 1: 사용자가 Reading Log에서 헷갈리거나 납득이 안 된다고 언급한 부분을 파고드는 질문
   - 질문 2: Core Summary에 담긴 저자의 핵심 주장을 더 명확히 이해하게 하는 질문
   - 질문 3: 사용자가 미처 생각하지 못했을 수 있는 저자의 전제(assumption)나 맥락을 드러내는 질문

3. 질문을 차례로 제시하며 대화 진행:
   - 질문을 한 번에 하나씩 제시
   - 사용자의 답변을 받으면 AI가 응답 (동의/반박/확장/후속 질문)
   - 각 질문당 2-3회 교환 후 다음 질문으로 이동

4. 대화 완료 후 Q&A 요약을 노트에 기록:

```markdown
- **Q1: [질문 내용]**
	- 내 답변: [사용자 답변 요약]
	- 심화: [AI의 응답 / 핵심 인사이트 요약]
- **Q2: [질문 내용]**
	- 내 답변: [사용자 답변 요약]
	- 심화: [AI의 응답 / 핵심 인사이트 요약]
- **Q3: [질문 내용]**
	- 내 답변: [사용자 답변 요약]
	- 심화: [AI의 응답 / 핵심 인사이트 요약]
```

5. `### Understanding the Author's Argument` 섹션의 placeholder(`- -`)를 위 내용으로 교체 (Edit tool)

---

# F. Stage 4: Critical Review & Knowledge Expansion

## 목적

저자의 주장을 비판적으로 검토하고, 기존 메모와 연결하며 지식을 확장.

## 실행 내용

### 4-1. 기존 노트 연결 (Related Notes)

1. Core Summary에서 핵심 키워드 추출 (개념어 3-5개)
2. Grep으로 아래 경로 검색:
   ```
   {{VAULT_PATH}}/3️⃣ Knowledge/
   {{VAULT_PATH}}/0️⃣ Inbox/
   ```
3. 관련된 노트 발견 시 사용자에게 제시:
   ```
   관련된 기존 메모를 찾았어요:
   - [[노트 제목]] — [어떤 개념이 연결되는지 한 줄 설명]
   ```
4. `##### Related Notes` 섹션의 `- [[]]` placeholder를 실제 링크로 교체 (Edit tool)

### 4-2. 비판적 검토

아래 순서로 대화 진행:

**Step A — 저자의 논증 약점 찾기**
```
이 책에서 저자의 주장 중 가장 취약하거나 충분히 뒷받침되지 않은 부분이 어디라고 생각하나요?
저자가 지나치게 단순화하거나 반례를 충분히 다루지 않은 것 같은 부분이 있나요?
```

**Step B — 반대 관점 제시**
AI가 강력한 반론을 직접 제시: "이 주장에 반대하는 가장 강한 논거는 [X]입니다. 어떻게 생각하세요?"

**Step C — 연결된 사상가/책 제안**
AI가 이 주제에서 다른 관점을 가진 사상가나 책을 2-3개 제안

### 4-3. 섹션 기록

대화 결과를 `### Critical Review & Knowledge Expansion` 섹션의 placeholder(`- -`) 교체:

```markdown
- **논증의 약점**
	- [사용자와 AI가 식별한 약점 요약]
- **반론**
	- [AI가 제시한 반론 + 사용자 반응 요약]
- **확장 탐색**
	- [ ] [연결된 책/사상가 1]
	- [ ] [연결된 책/사상가 2]
```

---

# G. Stage 5: Life Application

## 목적

책에서 얻은 것을 추상적 지식으로 남기지 않고, 내 삶의 구체적인 상황에 연결.
많은 포인트보다 **1-2개**에 집중하는 것이 핵심.

## 실행 내용

1. 전체 노트(Reading Log + Core Summary + Dialogue + Critical Review)를 읽음
2. 사용자에게 질문:
   ```
   이 책에서 실제로 내 삶에 가져가고 싶은 개념이나 통찰이 있다면 무엇인가요?
   직업, 관계, 습관, 사고방식 중 어떤 영역과 가장 연결되나요?
   ```
3. 사용자의 답변을 받으면 AI가 구체적인 적용 실험 설계를 도움:
   ```
   "[사용자가 선택한 개념]"을 적용해볼 수 있는 구체적이고 작은 실험:
   - 이번 주에 시도해볼 수 있는 것: [구체적인 행동 1가지]
   - 어떻게 되었는지 확인하는 방법: [관찰 기준]
   ```
4. 1-2개의 적용 포인트를 확정하고 `### Life Application` 섹션의 placeholder 교체:

```markdown
##### [적용 개념 또는 상황 제목]
- 내 상황: [어떤 맥락에서 적용할지]
- 이번 주 실험: [구체적인 행동 1가지]
- 확인 방법: [어떻게 결과를 볼지]
```

   적용 포인트가 2개면 `#####` 섹션을 하나 더 추가. 1개면 하나만.

5. 완료 후 출력:

```
## book-reflection 완료

모든 단계가 완료되었어요.

- 노트: `0️⃣ Inbox/<책 제목> 저자.md`
- Reading Log → Core Summary → Dialogue → Critical Review → Life Application

적용 포인트를 실제로 시도해보고, 결과를 Reading Log나 Daily Journal에 기록해보세요.
```

---

# H. 언어 규칙

- 대화(채팅)는 사용자가 쓰는 언어로 응답 (한국어 기본)
- 노트에 기록하는 내용: 사용자의 답변은 사용자가 쓴 언어 그대로, AI 생성 내용은 한국어

---

# I. 에러 처리

- **파일을 찾을 수 없음**: 파일 경로 확인 요청. `0️⃣ Inbox/`에서 `<`로 시작하는 파일 목록 제시
- **Reading Log가 비어있음**: Stage 2 실행 전 "Reading Log에 기록이 없어요. 독서 중 메모를 먼저 작성해주세요." 안내
- **단계 강제 실행 요청 (stage=N)**: 이전 단계가 비어있으면 경고 후 확인 요청 ("Stage 3을 실행하려면 Core Summary가 먼저 필요해요. 그래도 진행할까요?")
