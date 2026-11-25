# AI-Team-Brain

Claude Code plugins that connect an AI team's Claude sessions to one shared knowledge page in Confluence: projects, findings and datasets that someone else on the team could reuse.

The page, its link and its content stay in the company's Confluence. Nothing from it is stored in this repo; the link is asked when you install.

## Set this up (for Claude)

If a user gave you this repo and asked you to set it up, follow these steps in order.

1. **Get the page link.** You need the link to the team's Confluence knowledge page (it looks like `https://<site>.atlassian.net/wiki/spaces/.../pages/<id>/...`). If the user did not give it, ask for it. If the Atlassian connector is on, you may search Confluence for the page titled "AI Team Knowledge" and confirm it with the user. Never write the link into this repo or any shared file.
2. **Tell the user what will change, then go ahead:** a plugin marketplace and the `ai-team-kb` plugin in Claude Code, auto-update turned on in their Claude `settings.json` (backed up first), and removal of an older zip install of the same tool if one is there (backed up first).
3. **Get the repo and run the setup script** (Mac or Linux terminal; Git Bash on Windows, not PowerShell). Read `setup.sh` before running it; it is short.

   ```bash
   git clone --depth 1 https://github.com/islam543/AI-Team-Brain.git "${TMPDIR:-/tmp}/ai-team-brain-setup"
   bash "${TMPDIR:-/tmp}/ai-team-brain-setup/setup.sh" "<page link>"
   ```

   It ends with `Done.` and prints the installed plugin version. It is safe to run again; on a laptop that already has the plugin it updates it and saves the link.
4. **If `setup.sh` says the Claude Code command-line tool was not found,** do not try other ways: ask the user to do it in a Claude session with `/plugin`: add the marketplace `islam543/AI-Team-Brain`, install `ai-team-kb`, paste the page link when asked, then in Marketplaces choose `ai-team-brain` and enable auto-update.
5. **Finish:** tell the user to make sure the Atlassian connector is on (Claude settings, Connectors, Atlassian; sign in with their work account), then open a new Claude session. In that session the plugin loads the page rules; the first `/ai-team-kb:kb-harvest` shares their past work.

**To pull the latest changes now** on a laptop that already has it: `claude plugin marketplace update ai-team-brain`, then `claude plugin update ai-team-kb@ai-team-brain`, then a new session. With auto-update on this happens by itself.

**Needs:** Claude Code (terminal or the desktop app's Code tab), git, Python 3.8 or newer (`python3`, `python` or `py`), bash.

## Plugins

| Plugin | What it does |
|---|---|
| [`ai-team-kb`](plugins/ai-team-kb/README.md) | At session start, prints the page rules and an index of your local copy of the page. On each prompt, reminds Claude to check whether the request touches the page. Adds lines only with your yes, as targeted edits. Skills: `/ai-team-kb:kb-harvest` (share your past or today's work) and `/ai-team-kb:kb-sort` (page owner: sort the Inbox). |

## Install by hand

Easiest: give this repo link to a Claude session and say "set this up" (steps above). By hand:

```bash
claude plugin marketplace add islam543/AI-Team-Brain
claude plugin install ai-team-kb@ai-team-brain --config page_url="<your team page link>"
```

Then turn on auto-update once: in a Claude session run `/plugin`, open Marketplaces, choose `ai-team-brain`, enable auto-update. Claude Code checks for changes after your first message of a session and loads them at the next start. No version is pinned, so every commit here is an update.

Open a new Claude session after installing.

## Security

Plugins run code on your computer with your rights, and auto-update replaces their files when this repo changes. The hooks in `plugins/ai-team-kb/hooks/` are two short bash scripts that only read and copy files under `~/.claude/ai-team-kb`. Read them before installing.
