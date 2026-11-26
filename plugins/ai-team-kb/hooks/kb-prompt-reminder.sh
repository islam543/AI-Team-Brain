#!/usr/bin/env bash
# ai-team-kb plugin, UserPromptSubmit hook: one-line reminder to check the team page.
# Silent when the older zip install is also active (its own hook prints the same line).
[ -f "$HOME/.claude/hooks/kb-prompt-reminder.sh" ] && exit 0
echo "AI Team KB: if this request touches a project, finding, dataset or link between projects, read the relevant page entries. If the work produced something that helps someone else (not the user's own next steps), add it to the Inbox yourself without asking and tell the user in one line; no names, no local paths, totals only. Otherwise ignore."
exit 0
