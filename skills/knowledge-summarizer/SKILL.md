---
description: Digests YouTube videos, web articles, and PDF papers into structured Reports, then automatically processes them through learningmate to create atomic knowledge notes.
user-invokable: true
---

# Knowledge Summarizer

수집 레이어 스킬. 다양한 소스(YouTube, 웹 아티클, PDF 논문)를 받아 정제된 Report를 생성한 뒤 사용자 확인 후 learningmate에게 넘김.

## Pipeline

```
Input (YouTube URL / Web URL / PDF path / .md path)
    │
    ▼
[knowledge-summarizer] 소스 추출 + Report 생성
    │
    ▼
0️⃣ Inbox/(YouTube|Article|Paper) 제목 - Input  ← 기록 보존
    │
    ▼
[사용자 확인] Report 검토 → 수정 요청 가능 (반복)
    │
    ▼  (사용자 승인 후)
[learningmate PROCESS] 호출
    │
    ▼
0️⃣ Inbox/ 또는 3️⃣ Knowledge/ 원자 노트들
```

---

# A. Input 감지 로직

`$ARGUMENTS`를 읽어 소스 타입 판별:

| 조건 | 타입 |
|---|---|
| `youtu.be` 또는 `youtube.com` 포함 | YouTube |
| `http://` 또는 `https://`로 시작 (YouTube 제외) | Web Article |
| `.pdf`로 끝나는 파일 경로 | PDF Paper |
| `.md`로 끝나는 파일 경로 | Markdown → learningmate에 직접 위임 |

---

# B. 소스별 추출 방법

## YouTube

1. `yt-dlp`로 자막 다운로드:
   ```bash
   yt-dlp --write-auto-sub --sub-lang ko --skip-download "URL" -o "/tmp/yt_transcript"
   ```
   - 한국어 자막 없으면 `--sub-lang en`으로 재시도:
     ```bash
     yt-dlp --write-auto-sub --sub-lang en --skip-download "URL" -o "/tmp/yt_transcript"
     ```

2. 생성된 `.vtt` 파일 경로 확인:
   ```bash
   ls /tmp/yt_transcript*.vtt 2>/dev/null || ls /tmp/yt_transcript*.srt 2>/dev/null
   ```

3. VTT 정제 (Bash) — 타임스탬프는 `[HH:MM:SS]` 형식으로 추출하여 섹션 분리에 활용:
   ```bash
   # 타임스탬프 포함 구조화된 텍스트 추출
   grep -v '^WEBVTT' file.vtt | \
   grep -v '^NOTE' | \
   sed 's/<[^>]*>//g' | \
   sed '/^[[:space:]]*$/d' | \
   awk '!seen[$0]++' | \
   grep -v '^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]* --> '
   ```

4. 정제된 전체 스크립트 기반으로 Report 초안 작성 (타임스탬프 포함)

5. **프레임 캡처 (ffmpeg)**: Report 작성 중 시각 자료가 유효한 타임스탬프를 선별하여 프레임 추출
   - 선별 기준: 화자가 화면을 가리키는 발화 ("보시면", "이 그래프", "여기 보면"), 중요 개념 도식/슬라이드/스크린셰어가 등장하는 시점
   - **화질 선택 기준**:
     - 스크린셰어 또는 UI 데모가 포함된 영상 (텍스트/코드/앱 화면을 캡처해야 하는 경우) → **고화질 다운로드**:
       ```bash
       yt-dlp -f "bestvideo[height<=1080][ext=mp4]/bestvideo[height<=1080]/best[height<=1080]" "URL" -o "/tmp/yt_video.%(ext)s"
       ```
     - 슬라이드/도식만 있는 일반 강의 영상 → **중화질 다운로드**:
       ```bash
       yt-dlp -f "bestvideo[height<=480][ext=mp4]/bestvideo[height<=480]/worst" "URL" -o "/tmp/yt_video.%(ext)s"
       ```
   - 프레임 추출 (타임스탬프별):
     ```bash
     ffmpeg -ss HH:MM:SS -i /tmp/yt_video.mp4 -frames:v 1 -q:v 2 "{{VAULT_PATH}}/Structure/Attachments/[VIDEO_ID]_[HH-MM-SS].png"
     ```
   - 파일명 규칙: `[VIDEO_ID]_[HH-MM-SS].png` (예: `NVBS0LV1lFI_00-08-21.png`)
   - Report 해당 섹션에 삽입:
     ```
     ![[NVBS0LV1lFI_00-08-21.png]]
     ```
   - 인터뷰/대담 영상처럼 슬라이드나 도식이 없는 경우에는 프레임 캡처를 생략

## Web Article

1. WebFetch로 URL 내용 가져오기
2. 본문 텍스트 추출 → Report 작성

## PDF Paper

1. Read tool로 PDF 읽기
   - 페이지 수가 많을 경우 사용자에게 페이지 범위 확인 후 진행
2. 논문 구조 파악 (Abstract → Introduction → Methods → Results → Discussion) → Report 작성

## Markdown (.md)

learningmate 스킬에 직접 위임:
```
/learningmate [파일 경로]
```

---

# C. Report 작성 원칙

1. **타임스탬프 (YouTube 전용)**: 최상위 bullet에 해당 시점으로 바로 이동하는 클릭 가능한 링크로 삽입
   - 형식: `[HH:MM:SS](YouTube_URL&t=총초수)` — YouTube URL에 `&t=N` (N=총 초 단위) 파라미터 추가
   - `youtu.be` 형식 URL은 `?t=N`, 기존 파라미터가 있는 URL은 `&t=N` 으로 연결
   - 예시: 12분 34초 → 총 754초 → `[12:34](https://youtu.be/VIDEO_ID?t=754)`
   ```
   - 핵심 포인트 제목 [03:21](https://youtu.be/VIDEO_ID?t=201)
   	- 세부 내용
   	- 세부 내용
   ```

2. **원본 소스 기록**: frontmatter `source` 필드와 `## 소스 정보` 섹션에 원본 URL/DOI/파일명 명시

3. **가독성**: bullet + indent 구조를 적극적으로 사용하며, 핵심 단어만 나열하기보다는 논리 구조 또는 인과관계를 구체적으로 서술함. **섹션(Heading) 사이, bullet 항목 사이에 빈 줄을 넣지 않음** — 문서 전체에서 불필요한 줄바꿈을 최소화하여 컴팩트하게 유지. 항목 나열 시 중간점(·) 대신 쉼표(,) 또는 슬래시(/)를 사용. `---` divider는 Notes & Quotes 내부 H5 섹션 사이에는 넣지 않으며, Key Takeaways / Notes & Quotes / Next Learning Topics / Linked Notes 등 최상위 섹션 사이에만 사용.

4. **어려운 용어 설명**: 도메인 특화 전문 용어(논문 약어, 기술 용어, 학술 개념)는 처음 등장 시 괄호로 풀이
   - e.g. `RLHF (사람의 피드백으로 모델이 더 좋은 답을 내도록 훈련하는 방법)`
   - e.g. `RAG (모델이 답변할 때 외부 문서를 검색해서 참조하는 구조)`

5. **상세한 내용 서술**: 단순 요약에 그치지 않고, 발화자의 맥락·근거·배경·인과관계까지 충분히 담아야 함. "왜 그런 주장을 하는가", "어떤 근거로", "그 결과 어떤 의미인가"를 명시적으로 서술할 것. 핵심 발언은 인용 또는 구체적 수치/사례로 뒷받침.

---

# D. 언어 규칙

| 소스 언어 | Report 언어 |
|---|---|
| 한국어 | 한국어 유지 |
| 영어 | 영어 유지 |
| 기타 (일본어, 중국어 등) | 한국어로 번역 |

---

# E. Report 형식

파일명: `(Input, YouTube|Article|Paper) 제목.md` → `{{VAULT_PATH}}/0️⃣ Inbox/`에 저장
e.g. (Input, YouTube) Methodology for Enhancing Retrieval Performance in AI Search

```markdown
---
tags:
  - note/primary-input-note
date: YYYY.MM.DD(Day)
source type: video 또는 article / paper
source: "원본 URL"
---
## Reference
| **Title**     | |
| ------------- | ------------------------------------------------ |
| **Author**    | |
| **Publisher** | |
| **URL**       | |
### Key Takeaways
- (3-5개의 핵심 인사이트 — 명사형 어미)
---
### Notes & Quotes
##### (대주제 그룹 — 연관된 소주제들을 묶는 H5)
###### (소주제 제목 — H6)
- 첫 번째 주요 포인트 [03:21]  ← YouTube: 타임스탬프 포함
	- 세부 내용: 맥락, 근거, 인과관계를 충분히 서술
	- 어려운 용어 등장 시 괄호 풀이
- 두 번째 주요 포인트 [11:45]
	- 세부 내용
###### (소주제 제목 — H6)
- 포인트 [15:00]
	- 세부 내용
##### (다음 대주제 그룹)
###### (소주제 제목)
- 포인트
	- 세부 내용
---
### Next Learning Topics
- [ ] 관련된 내용 중 추가적으로 학습할 만한 내용 추천
- [ ] 단순 지식을 쌓기 위한 주제보다는 실무적으로 많이 사용되는 토픽 중심
---
### Linked Notes
- [[노트 제목]] — 연결 이유 한 줄 설명
- 위와 같이 중첩 대괄호 안에 `{{VAULT_PATH}}/` 경로 내에 존재하는 관련 노트 제목을 참조
- 탐색 범위: `0️⃣ Inbox/`, `2️⃣ Notes/`, `3️⃣ Knowledge/` 세 폴더 모두 검색하여 관련 노트 찾기
- 각 노트 뒤에 ` — ` (em dash)로 구분하여 이 노트를 연결한 이유를 한 줄로 명시 (예: 동일 개념의 심화 내용, 선행 지식, 반대 관점 등)
```
---

# F. 실행 절차

## Step 1: 소스 타입 감지 및 추출

`$ARGUMENTS`를 분석하여 타입 판별 후 해당 추출 방법 실행.

## Step 2: Report 생성 및 저장

- 파일명: `(Input, YouTube|Article|Paper) 제목.md`
- 저장 위치: `{{VAULT_PATH}}/0️⃣ Inbox/`
- 날짜 형식: `YYYY.MM.DD(Day)` (예: `2026.03.01(Sun)`)
- Indentation: 탭 사용 (스페이스 금지)
- **Linked Notes 탐색**: `0️⃣ Inbox/`, `2️⃣ Notes/`, `3️⃣ Knowledge/` 세 폴더를 모두 검색하여 관련 노트를 찾아 `### Linked Notes` 섹션에 삽입

## Step 3: 사용자 확인

Report 저장 완료 후 즉시 learningmate를 실행하지 않고 먼저 확인 요청:

```
## knowledge-summarizer — Report 생성 완료

### 소스
- 타입: [YouTube / Article / Paper]
- 제목: ...
- URL/경로: ...

### 생성된 Report
- 파일: `0️⃣ Inbox/[파일명].md`

### Key Takeaways
[Report의 ### Key Takeaways 섹션 그대로 출력]

---
다음 중 선택하세요:
1. **진행** — learningmate PROCESS 실행하여 atomic notes 생성
2. **수정 요청** — Report에 보완할 내용 지시 (반복 가능)
3. **중단** — Report만 보존하고 종료
```

## Step 4: 사용자 응답 처리

- **진행 선택**: learningmate 스킬의 PROCESS 모드 실행
  - Report 파일 경로를 `$ARGUMENTS`로 전달
  - 완료 보고 출력
- **수정 요청**: 사용자 지시에 따라 Report 수정 → Step 3으로 돌아가 재확인
- **중단**: Report 파일 경로만 출력하고 종료

---

# G. Output Report 형식

learningmate 처리 완료 후 최종 보고:

```
## knowledge-summarizer 완료 보고

### 소스
- 타입: [YouTube / Article / Paper]
- 제목: ...
- URL/경로: ...

### 생성된 Report
- [[Report 파일명]] → 0️⃣ Inbox/ 저장

### learningmate 처리 결과
[learningmate 완료 보고 그대로 출력]
```

---

# H. 에러 처리

- **yt-dlp 미설치**: `brew install yt-dlp` 안내 후 중단
- **자막 없음**: 영상에 자막이 없음을 안내, 영어/한국어 모두 시도 후 실패 시 URL만 기록하고 수동 입력 요청
- **WebFetch 실패**: URL 접근 불가 안내, 사용자에게 직접 내용 붙여넣기 요청
- **PDF 읽기 실패**: 파일 경로 확인 요청, 페이지 범위 지정 여부 확인
- **파일 경로 공백/특수문자**: 따옴표로 감싸서 처리
