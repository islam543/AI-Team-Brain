# AI-Team-Brain

Claude Code plugin marketplace (`ai-team-brain`) holding the `ai-team-kb` plugin, which connects Claude to the team's shared Confluence page, AI Team Knowledge: https://qicbizdev.atlassian.net/wiki/x/GwADy (restricted to team members).

## If the user asks you to set this up

Follow "Set this up (for Claude)" in `README.md`: say what will change, then run `bash setup.sh` from this folder (it uses the team page above) and report its output.

## If you are changing the plugin

- Public repo: the page's short link above is the only company reference allowed (in README, CLAUDE.md, setup.sh, plugin.json, rules.md, the hook and the skills). Never add page content, company data, names of people or local paths.
- Do not pin `version` in `plugin.json` or `marketplace.json`; every commit is an update for users with auto-update on.
- Start-up hook output over about 10,000 characters is cut to a preview: keep `rules.md` plus the page index well under that (index capped at 5,000 characters).
- Check before pushing: `claude plugin validate .` and `claude plugin validate plugins/ai-team-kb`, `bash -n` on every `.sh`, and run `hooks/kb-session-start.sh` with a throwaway `HOME` to see its output and size.
- No em dashes in text the plugin prints or the page shows.
