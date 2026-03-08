# claude-skills-obsidian-knowledge-system

Claude skills for boosting Obsidian experience as a knowledge hub.

## Skills

### `learningmate`
An intellectual learning companion. Give it a note, a question, or ask for a topic recommendation.

- Converts inbox notes into atomic knowledge notes (`3️⃣ Knowledge/`)
- Generates Anki flashcards (Obsidian-to-Anki format)
- Expands questions into broader learning themes
- Interactive quiz mode

**Usage:**
```
/learningmate                        # list recent inbox notes
/learningmate path/to/note.md        # process a note
/learningmate recommend              # get a topic recommendation
/learningmate quiz path/to/note.md   # generate Anki cards only
```

---

### `knowledge-summarizer`
Ingest YouTube videos, web articles, and PDF papers into structured Reports, then pass them to `learningmate`.

- YouTube: extracts subtitles via `yt-dlp`, captures key frames via `ffmpeg`
- Web: fetches and summarizes via WebFetch
- PDF: reads and structures via the Read tool

**Requires:** `yt-dlp` and `ffmpeg` installed (`brew install yt-dlp ffmpeg`)

**Usage:**
```
/knowledge-summarizer https://youtu.be/VIDEO_ID
/knowledge-summarizer https://example.com/article
/knowledge-summarizer /path/to/paper.pdf
```

---

### `book-reflection`
A 5-stage post-reading reflection workflow, all within a single Obsidian note.

- Stage 1: Reading Log (you write during reading)
- Stage 2: Core Summary (AI-generated from your log)
- Stage 3: Socratic Dialogue (AI questions to deepen understanding)
- Stage 4: Critical Review & Knowledge Expansion
- Stage 5: Life Application (1–2 concrete experiments)

**Usage:**
```
/book-reflection init "Book Title" "Author Name"
/book-reflection "Book Title Author Name"   # run next stage
```

---

### `contents-recommender`
Recommends the most relevant learning content for a given question, problem, or curiosity — searching your KB, books, the web, and YouTube in priority order.

- Searches your Obsidian vault (inbox, notes, knowledge) first
- Checks owned book chapters via `Book Reference List.md`
- Falls back to web and YouTube search, respecting saved preferences
- Saves results to `0️⃣ Inbox/(Recommendation) 키워드.md`

**Usage:**
```
/contents-recommender 카프카 스트리밍
/contents-recommender 팀 성과 측정 어떻게 해야 할지 모르겠어
```

---

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- [Obsidian](https://obsidian.md/) with a vault set up
- [Obsidian-to-Anki](https://github.com/Pseudonium/Obsidian_to_Anki) plugin (for Anki card sync)
- For `knowledge-summarizer`: `yt-dlp` and `ffmpeg`

---

## Installation

```bash
git clone https://github.com/yunhee-lee/claude-skills-obsidian-knowledge-system.git
cd claude-skills-obsidian-knowledge-system
chmod +x install.sh
./install.sh
```

The installer will ask for your Obsidian vault path and copy the skill files to `~/.claude/skills/`, replacing the `{{VAULT_PATH}}` placeholder with your actual vault path.

### Installing a single skill

**Option A — interactive installer (select by number):**
```bash
git clone https://github.com/yunhee-lee/claude-skills-obsidian-knowledge-system.git
cd claude-skills-obsidian-knowledge-system
chmod +x install.sh
./install.sh
# When prompted, enter only the number(s) you want, e.g. "4" for contents-recommender
```

**Option B — download one file directly:**
```bash
SKILL=contents-recommender   # change to the skill you want
VAULT=/path/to/your/vault    # change to your actual vault path

mkdir -p ~/.claude/skills/$SKILL
curl -sSL \
  https://raw.githubusercontent.com/yunhee-lee/claude-skills-obsidian-knowledge-system/main/skills/$SKILL/SKILL.md \
  | sed "s|{{VAULT_PATH}}|$VAULT|g" \
  > ~/.claude/skills/$SKILL/SKILL.md
```

Available skill names: `learningmate`, `knowledge-summarizer`, `book-reflection`, `contents-recommender`

### Allowed tools (optional but recommended)

Add the following to `~/.claude/settings.json` so the skills can run without repeated permission prompts:

```json
{
  "allowedTools": [
    "Bash(yt-dlp*)",
    "Bash(ffmpeg*)",
    "Bash(ls /tmp/*)",
    "Bash(grep*)",
    "Bash(sed*)",
    "Bash(awk*)",
    "Read",
    "Write(/tmp/*)",
    "Write(/path/to/your/vault/*)",
    "WebFetch"
  ]
}
```

Replace `/path/to/your/vault/` with your actual Obsidian vault path.

---

## Personalization

After installation, edit `~/.claude/skills/learningmate/SKILL.md` to customize:

- **User profile** (Section A): your role and experience level
- **Focus domains**: the subject areas you study
- **Anki deck names** (Section D): your Anki deck structure

The vault directory structure expected by default:
```
YourVault/
├── 0️⃣ Inbox/
├── 1️⃣ Projects/
├── 2️⃣ Notes/
├── 3️⃣ Knowledge/
└── 4️⃣ Archive/
```

If your folder names differ, update the references in each SKILL.md after installation.
