#!/usr/bin/env bash
# ai-team-kb plugin, SessionStart hook. Keeps the page tools at a stable path, then prints
# the rules and the local copy of the team's Confluence page. Whatever this prints is added
# to Claude's context. No network, no token, never fails the session.
# Portable: Mac, Linux and Git Bash on Windows (no stat, no date maths).
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
KB="${AI_TEAM_KB:-$HOME/.claude/ai-team-kb}"
mkdir -p "$KB" 2>/dev/null || exit 0
for f in html_to_copy.py check_page.py find_python.sh refresh.sh register_hooks.py remove_old_install.sh; do
  cp -f "$ROOT/tools/$f" "$KB/$f" 2>/dev/null
done

# The older zip install prints the same page from its own hook: do not print it twice.
if [ -f "$HOME/.claude/hooks/kb-session-start.sh" ]; then
  echo "AI Team Knowledge: the ai-team-kb plugin and the older zip install are both active. Tell the user, and with their yes run: bash ~/.claude/ai-team-kb/remove_old_install.sh (removes the old hooks and CLAUDE.md section, keeps the page link and local copy). Then open a new session."
  exit 0
fi

URL="$(printf '%s' "${CLAUDE_PLUGIN_OPTION_PAGE_URL:-}" | tr -d '\r')"
if [ -n "$URL" ]; then
  printf '%s\n' "$URL" > "$KB/page_url"
elif [ -f "$KB/page_url" ]; then
  URL="$(head -n 1 "$KB/page_url" | tr -d '\r')"
fi

cat "$ROOT/rules.md"
# Auto-update is off by default for this marketplace: say so, so Claude can offer to turn it on.
SET="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
. "$KB/find_python.sh" >/dev/null 2>&1 && AU="$("$PY" -I -c 'import json,sys
try:
    m=json.load(open(sys.argv[1],encoding="utf-8")).get("extraKnownMarketplaces",{}).get("ai-team-brain")
    print("on" if m and m.get("autoUpdate") else ("off" if m else "unknown"))
except Exception:
    print("unknown")' "$SET" 2>/dev/null)"
if [ "$AU" = "off" ]; then
  echo "- **Auto-update is off** for ai-team-brain on this computer, so changes in the repo do not arrive by themselves. Tell the user once and, with their yes, set \"autoUpdate\": true on the ai-team-brain entry under extraKnownMarketplaces in $SET (or: /plugin, Marketplaces, ai-team-brain, enable auto-update)."
fi
echo
if [ -z "$URL" ]; then
  echo "AI Team Knowledge: the page link is not set. At the first relevant prompt, ask the user for it (from the team's Confluence), then run: claude plugin configure ai-team-kb@ai-team-brain (or save it with: printf '%s\n' '<link>' > ~/.claude/ai-team-kb/page_url)."
  exit 0
fi
if [ ! -f "$KB/page.md" ]; then
  echo "AI Team Knowledge page: $URL. No local copy yet: at the first relevant prompt, fetch the page as HTML with the Atlassian connector, save it to a temp file and run: bash ~/.claude/ai-team-kb/refresh.sh <file>"
  exit 0
fi
note=""
if [ -n "$(find "$KB/page.md" -mtime +0 2>/dev/null)" ]; then
  note=" The copy is over 1 day old: refresh it before relying on it."
fi
# Hook output over about 10,000 characters is cut to a preview, so print a short index
# (section, title, start of each entry) and let Claude read the full copy when relevant.
echo "AI Team Knowledge page: $URL. Index of the local copy below; full text in ~/.claude/ai-team-kb/page.md (read it when a request is relevant).$note Entries are leads: check before relying on one."
INDEX="$(awk '
/^## How to use/ || /^## Change log/ || /^## Claude setup/ {skip=1; next}
/^#+ / {skip=0; print; next}
skip {next}
/^- \*\*/ {
  line=$0; sub(/^- \*\*/, "", line)
  t=line; sub(/\*\*.*/, "", t)
  r=line; if (!sub(/^[^:]*\): /, "", r)) r=""
  if (length(r) > 100) r=substr(r, 1, 100) "..."
  print "- " t (r == "" ? "" : ": " r)
}' "$KB/page.md" 2>/dev/null)"
if [ "${#INDEX}" -gt 5000 ]; then
  printf '%s\n' "${INDEX:0:5000}"
  echo "(index cut at 5,000 characters: read ~/.claude/ai-team-kb/page.md for the rest)"
else
  printf '%s\n' "$INDEX"
fi
exit 0
