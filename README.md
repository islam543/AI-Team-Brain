# AI-Team-Brain

Claude Code plugins that connect an AI team's Claude sessions to one shared knowledge page in Confluence: projects, findings and datasets that someone else on the team could reuse.

The page, its link and its content stay in the company's Confluence. Nothing from it is stored in this repo; the link is asked when you install.

## Plugins

| Plugin | What it does |
|---|---|
| [`ai-team-kb`](plugins/ai-team-kb/README.md) | At session start, prints the page rules and an index of your local copy of the page. On each prompt, reminds Claude to check whether the request touches the page. Adds lines only with your yes, as targeted edits. Skills: `/ai-team-kb:kb-harvest` (share your past or today's work) and `/ai-team-kb:kb-sort` (page owner: sort the Inbox). |

## Install

```bash
claude plugin marketplace add islam543/AI-Team-Brain
claude plugin install ai-team-kb@ai-team-brain --config page_url="<your team page link>"
```

Then turn on auto-update once: in a Claude session run `/plugin`, open Marketplaces, choose `ai-team-brain`, enable auto-update. Claude Code checks for changes after your first message of a session and loads them at the next start. No version is pinned, so every commit here is an update.

Open a new Claude session after installing.

## Security

Plugins run code on your computer with your rights, and auto-update replaces their files when this repo changes. The hooks in `plugins/ai-team-kb/hooks/` are two short bash scripts that only read and copy files under `~/.claude/ai-team-kb`. Read them before installing.
