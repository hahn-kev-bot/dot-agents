#!/bin/bash
# Claude Code cloud environment setup: installs this repo's skills, agents, global AGENTS.md
# and shared skill overrides. Also the macOS/Linux setup; Windows uses setup.ps1.
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

# Shared skill overrides (settings/skill-overrides.json) go into ~/.claude/settings.json.
# Overrides the machine already has win, so each machine can hide or change skills
# for itself. Settings, unlike SKILL.md frontmatter, survive `npx skills update`.
overrides="$dest/settings/skill-overrides.json"
settings="$HOME/.claude/settings.json"
if [ -f "$overrides" ]; then
  [ -s "$settings" ] || echo '{}' > "$settings"
  tmp="$(mktemp)"
  if command -v jq >/dev/null; then
    jq --slurpfile shared "$overrides" \
      '.skillOverrides = ($shared[0].skillOverrides + (.skillOverrides // {}))' "$settings" > "$tmp"
  elif command -v python3 >/dev/null; then
    python3 - "$settings" "$overrides" > "$tmp" <<'PY'
import json, sys
settings, shared = (json.load(open(p)) for p in sys.argv[1:])
settings["skillOverrides"] = {**shared["skillOverrides"], **settings.get("skillOverrides", {})}
print(json.dumps(settings, indent=2))
PY
  else
    echo "dot-agents: neither jq nor python3 found, skipped merging skill overrides" >&2
  fi
  if [ -s "$tmp" ] && ! cmp -s "$tmp" "$settings"; then cat "$tmp" > "$settings"; fi
  rm -f "$tmp"
fi

echo "dot-agents: $(ls "$dest/skills" | wc -l) skills, $(ls "$dest/agents" | wc -l) agents linked into $HOME/.claude"
