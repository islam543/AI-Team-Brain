#!/usr/bin/env bash
# Remove the older zip install of AI Team Knowledge (hooks in settings.json, the CLAUDE.md
# section, ~/.claude/hooks/kb-*.sh) so it does not run next to this plugin. Keeps the page
# link and local copy in ~/.claude/ai-team-kb. Backs up settings.json and CLAUDE.md first.
#   bash ~/.claude/ai-team-kb/remove_old_install.sh   (or the copy in the plugin's tools folder)
set -euo pipefail
# Works from any folder that also holds find_python.sh and register_hooks.py
# (the plugin's tools folder, or ~/.claude/ai-team-kb after a session start).
HERE="$(cd "$(dirname "$0")" && pwd)"
CL="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
. "$HERE/find_python.sh"
"$PY" -I "$HERE/register_hooks.py" remove "$CL/settings.json" "$CL/CLAUDE.md"
rm -f "$CL/hooks/kb-session-start.sh" "$CL/hooks/kb-prompt-reminder.sh"
echo "Old install removed. Open a new Claude session."
