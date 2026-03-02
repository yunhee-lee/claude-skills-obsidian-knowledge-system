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

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- [Obsidian](https://obsidian.md/) with a vault set up
- [Obsidian-to-Anki](https://github.com/Pseudonium/Obsidian_to_Anki) plugin (for Anki card sync)
- For `knowledge-summarizer`: `yt-dlp` and `ffmpeg`

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/claude-skills-obsidian-knowledge-system.git
cd claude-skills
chmod +x install.sh
./install.sh
```

The installer will ask for your Obsidian vault path and copy the skill files to `~/.claude/skills/`, replacing the `{{VAULT_PATH}}` placeholder with your actual vault path.

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
