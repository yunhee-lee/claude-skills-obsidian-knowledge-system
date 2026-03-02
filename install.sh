#!/bin/bash

set -e

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Claude Skills Installer ==="
echo ""

# 1. Vault path
read -p "Obsidian vault path (e.g. /Users/yourname/Obsidian/MyVault): " VAULT_PATH

if [ -z "$VAULT_PATH" ]; then
  echo "Error: vault path cannot be empty."
  exit 1
fi

# Trim trailing slash
VAULT_PATH="${VAULT_PATH%/}"

if [ ! -d "$VAULT_PATH" ]; then
  echo "Warning: '$VAULT_PATH' does not exist. Make sure the path is correct."
  read -p "Continue anyway? (y/N): " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 1
fi

# 2. Select skills to install
echo ""
echo "Skills available:"
echo "  1) learningmate         — Obsidian atomic notes + Anki cards"
echo "  2) knowledge-summarizer — YouTube / Web / PDF → Report → learningmate"
echo "  3) book-reflection      — 5-stage post-reading reflection"
echo ""
read -p "Which skills to install? (e.g. 1 2 3, or press Enter for all): " SELECTION

if [ -z "$SELECTION" ]; then
  SKILLS=("learningmate" "knowledge-summarizer" "book-reflection")
else
  SKILLS=()
  for num in $SELECTION; do
    case $num in
      1) SKILLS+=("learningmate") ;;
      2) SKILLS+=("knowledge-summarizer") ;;
      3) SKILLS+=("book-reflection") ;;
      *) echo "Unknown option: $num — skipping" ;;
    esac
  done
fi

# 3. Install
mkdir -p "$SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  SRC="$SCRIPT_DIR/skills/$skill/SKILL.md"
  DEST_DIR="$SKILLS_DIR/$skill"
  DEST="$DEST_DIR/SKILL.md"

  if [ ! -f "$SRC" ]; then
    echo "  [skip] $skill — source not found"
    continue
  fi

  mkdir -p "$DEST_DIR"

  # Replace placeholder with actual vault path (macOS & Linux compatible)
  if sed --version 2>/dev/null | grep -q GNU; then
    sed "s|{{VAULT_PATH}}|$VAULT_PATH|g" "$SRC" > "$DEST"
  else
    sed "s|{{VAULT_PATH}}|$VAULT_PATH|g" "$SRC" > "$DEST"
  fi

  echo "  [ok] $skill → $DEST"
done

echo ""
echo "Done! Restart Claude Code to pick up the new skills."
echo ""
echo "Tips:"
echo "  - Run '/learningmate' to start the learning companion"
echo "  - Run '/knowledge-summarizer <URL or PDF path>' to ingest content"
echo "  - Run '/book-reflection init \"Title\" \"Author\"' to start a book reflection"
echo ""
echo "Personalization (edit the installed SKILL.md files):"
echo "  - learningmate: update the User profile, focus domains, and Anki deck names"
echo "  - knowledge-summarizer: uses your vault structure (0️⃣ Inbox, 3️⃣ Knowledge, etc.)"
