#!/bin/bash
# Claude Code cloud environment setup: installs this repo's skills, agents and global AGENTS.md.
#
# Paste this one line into the environment's setup script (claude.ai/code > environment settings):
#   curl -fsSL https://raw.githubusercontent.com/hahn-kev-bot/dot-agents/main/cloud/setup.sh | bash
#
# Cloud sessions don't load ~/.claude from your machine or install plugins, so this recreates
# the parts that matter. It is idempotent: re-running pulls the latest and relinks.
set -euo pipefail

repo="${DOT_AGENTS_REPO:-https://github.com/hahn-kev-bot/dot-agents.git}"
dest="$HOME/.agents"

if [ -d "$dest/.git" ]; then
  git -C "$dest" pull --ff-only --quiet
else
  rm -rf "$dest"
  git clone --depth 1 --quiet "$repo" "$dest"
fi

mkdir -p "$HOME/.claude"
for dir in skills agents; do
  target="$HOME/.claude/$dir"
  # Keep anything the image already put there instead of deleting it.
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.pre-dot-agents"
  fi
  ln -sfn "$dest/$dir" "$target"
done

import_line='@~/.agents/AGENTS.md'
grep -qxF "$import_line" "$HOME/.claude/CLAUDE.md" 2>/dev/null || echo "$import_line" >> "$HOME/.claude/CLAUDE.md"

echo "dot-agents: $(ls "$dest/skills" | wc -l) skills, $(ls "$dest/agents" | wc -l) agents linked into $HOME/.claude"
