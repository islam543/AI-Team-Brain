# AI-Team-Brain

Claude Code plugin marketplace (`ai-team-brain`) holding the `ai-team-kb` plugin, which connects Claude to a team's shared Confluence knowledge page.

## If the user asks you to set this up

Follow "Set this up (for Claude)" in `README.md`: get the page link from the user, say what will change, then run `bash setup.sh "<page link>"` from this folder and report its output.

## If you are changing the plugin

- Public repo: never add the page link, page content, company data, names of people or local paths. The link reaches users through the plugin's `userConfig` option `page_url`.
- Do not pin `version` in `plugin.json` or `marketplace.json`; every commit is an update for users with auto-update on.
- Start-up hook output over about 10,000 characters is cut to a preview: keep `rules.md` plus the page index well under that (index capped at 5,000 characters).
- Check before pushing: `claude plugin validate .` and `claude plugin validate plugins/ai-team-kb`, `bash -n` on every `.sh`, and run `hooks/kb-session-start.sh` with a throwaway `HOME` to see its output and size.
- No em dashes in text the plugin prints or the page shows.
