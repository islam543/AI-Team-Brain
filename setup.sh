#!/usr/bin/env bash
# Set up the ai-team-kb plugin on this computer. Mac or Linux terminal, or Git Bash on Windows.
#   bash setup.sh                 (uses the team page, AI Team Knowledge: https://qicbizdev.atlassian.net/wiki/x/GwADy)
#   bash setup.sh "<page link>"   (only to point at a different page)
# Safe to run again: it updates what is already there. In order, it:
#   1. finds Claude Code's command-line tool (on PATH, or inside the Claude desktop app on a Mac)
#   2. adds this repo as the "ai-team-brain" plugin marketplace, or refreshes it
#   3. installs the ai-team-kb plugin with your page link, or updates it and saves the link
#   4. turns on auto-update for ai-team-brain in your Claude settings.json (backup first)
#   5. removes the older zip install if it is there (backups first; page link and local copy kept)
#   6. prints a short check
# The page link is saved in your Claude settings; the page itself stays in Confluence, restricted to team members.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TEAM_PAGE="https://qicbizdev.atlassian.net/wiki/x/GwADy"   # AI Team Knowledge (Confluence)
URL="${1:-$TEAM_PAGE}"
case "$URL" in
  https://*.atlassian.net/wiki/*) ;;
  *) echo "Not a Confluence page link: $URL" >&2; exit 2 ;;
esac
CL="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
KB="${AI_TEAM_KB:-$HOME/.claude/ai-team-kb}"

# 1. Claude Code's command-line tool
CLAUDE_BIN="$(command -v claude 2>/dev/null || true)"
if [ -z "$CLAUDE_BIN" ]; then
  for c in "$HOME/Library/Application Support/Claude/claude-code/"*/*/claude.app/Contents/MacOS/claude; do
    [ -x "$c" ] && CLAUDE_BIN="$c"
  done
fi
if [ -z "$CLAUDE_BIN" ]; then
  echo "Claude Code's command-line tool was not found. Do it by hand in a Claude session: /plugin, add marketplace islam543/AI-Team-Brain, install ai-team-kb, paste the page link, then Marketplaces, ai-team-brain, enable auto-update." >&2
  exit 3
fi
echo "1. Claude Code: $CLAUDE_BIN"
. "$HERE/plugins/ai-team-kb/tools/find_python.sh"

# 2. Marketplace
if "$CLAUDE_BIN" plugin marketplace list --json 2>/dev/null | grep -q '"name": *"ai-team-brain"'; then
  "$CLAUDE_BIN" plugin marketplace update ai-team-brain
else
  "$CLAUDE_BIN" plugin marketplace add islam543/AI-Team-Brain
fi

# 3. Plugin and page link
if "$CLAUDE_BIN" plugin list --json 2>/dev/null | grep -q '"id": *"ai-team-kb@ai-team-brain"'; then
  "$CLAUDE_BIN" plugin update ai-team-kb@ai-team-brain
  "$PY" -I -c 'import json,sys; print(json.dumps({"page_url": sys.argv[1]}))' "$URL" \
    | "$CLAUDE_BIN" plugin configure ai-team-kb@ai-team-brain --values-stdin
else
  "$CLAUDE_BIN" plugin install ai-team-kb@ai-team-brain --config "page_url=$URL"
fi
mkdir -p "$KB"
printf '%s\n' "$URL" > "$KB/page_url"

# 4. Auto-update
"$PY" -I - "$CL/settings.json" <<'PYEOF'
import json, pathlib, shutil, sys
p = pathlib.Path(sys.argv[1])
d = json.loads(p.read_text(encoding="utf-8")) if p.exists() else {}
m = d.setdefault("extraKnownMarketplaces", {}).setdefault(
    "ai-team-brain", {"source": {"source": "github", "repo": "islam543/AI-Team-Brain"}})
if m.get("autoUpdate") is True:
    print("4. auto-update already on")
else:
    if p.exists():
        shutil.copy(p, str(p) + ".bak-ai-team-brain")
    m["autoUpdate"] = True
    p.write_text(json.dumps(d, indent=2) + "\n", encoding="utf-8")
    print("4. auto-update turned on (backup: settings.json.bak-ai-team-brain)")
PYEOF

# 5. Older zip install
if [ -f "$CL/hooks/kb-session-start.sh" ] || grep -q "ai-team-kb:start" "$CL/CLAUDE.md" 2>/dev/null; then
  echo "5. older zip install found: removing it"
  bash "$HERE/plugins/ai-team-kb/tools/remove_old_install.sh"
else
  echo "5. no older zip install"
fi

# 6. Check
echo "6. check:"
"$CLAUDE_BIN" plugin list --json | "$PY" -I -c 'import json,sys
for p in json.load(sys.stdin):
    if p.get("id") == "ai-team-kb@ai-team-brain":
        print("   plugin:", p["id"], "version", p.get("version"), "enabled" if p.get("enabled") else "NOT enabled")'
echo "Done. Open a new Claude session (with the Atlassian connector on), then run /ai-team-kb:kb-harvest."
