---
name: skill-publisher
description: Scaffold an existing Agent Skill (a SKILL.md folder) for cross-platform distribution across Claude Code, OpenAI Codex, and Google Antigravity — generating the harness-specific plugin manifests and repo layout needed to publish it on GitHub. Use when the user wants to publish, distribute, or package a skill for multiple agents, mentions hosting skills on GitHub for Claude/Codex/Antigravity, or asks how to make a skill "portable" or "cross-agent".
---

# Skill Publisher

All three harnesses already read the same open format — [agentskills.io](https://agentskills.io/specification): a folder with `SKILL.md` (`name` + `description` frontmatter) plus optional `scripts/`, `references/`, `assets/`. That part never changes per-target. What differs is (a) where each harness looks for skills, and (b) the optional manifest wrapper needed to distribute it as an installable **plugin** instead of a manually-copied folder.

## Step 0 — validate the base skill first

- `name`: lowercase, hyphens only, no leading/trailing/consecutive hyphens, matches the folder name, ≤64 chars.
- `description`: non-empty, ≤1024 chars, states what it does *and* when to use it.
- Only the standard subfolders (`scripts/`, `references/`, `assets/`) beyond `SKILL.md`.

Fix this before scaffolding anything else — a skill that's broken against the shared spec breaks identically in all three harnesses. Fix it once here, not three times downstream. If the `skills-ref` CLI is available, `skills-ref validate ./skill-name` checks this for you.

## Repo layout

One shared skill folder at the repo root; every harness-specific manifest below just points at it — never duplicate the skill content per target.

```
repo-root/
├── skills/<name>/SKILL.md            # canonical source of truth
├── .claude-plugin/
│   ├── plugin.json                   # Claude Code plugin manifest
│   └── marketplace.json              # Claude Code marketplace entry
├── .codex-plugin/
│   └── plugin.json                   # Codex plugin manifest
├── .agents/plugins/marketplace.json  # Codex marketplace entry
├── plugins/<name>/
│   ├── plugin.json                   # Antigravity plugin marker
│   ├── mcp_config.json               # Optional: Antigravity MCP server config
│   ├── .mcp.json                     # Optional: Claude / Codex MCP server config
│   └── skills/<name>/                # mirrored copy from skills/
├── scripts/sync-skills.sh            # auto-syncs skills/ into plugins/
└── README.md                         # install table for all four
```

## Claude Code

`.claude-plugin/plugin.json`:
```json
{
  "name": "<name>",
  "version": "1.0.0",
  "description": "<same as SKILL.md description, trimmed>",
  "author": { "name": "<you>" }
}
```
`.claude-plugin/marketplace.json` (the repo acts as its own marketplace):
```json
{
  "name": "<repo-name>",
  "owner": { "name": "<you>" },
  "plugins": [
    { "name": "<name>", "source": "./", "description": "<same>" }
  ]
}
```
Install: `claude plugin marketplace add <you>/<repo>` → `claude plugin install <name>@<repo>`.

## Codex

`.codex-plugin/plugin.json`:
```json
{
  "name": "<name>",
  "version": "1.0.0",
  "description": "<same>",
  "author": { "name": "<you>" },
  "homepage": "https://github.com/<you>/<repo>"
}
```
Optional `skills/<name>/agents/openai.yaml` — only add it if you want a display name/icon in the ChatGPT desktop app, or to turn off implicit invocation (`policy.allow_implicit_invocation: false`).

`.agents/plugins/marketplace.json`:
```json
{
  "name": "<repo-name>",
  "plugins": [
    { "name": "<name>", "source": { "source": "local", "path": "./" } }
  ]
}
```
Install: `codex plugin marketplace add <you>/<repo>` → `codex plugin add <name>@<repo-name>`.

Without a plugin, Codex also auto-discovers bare skill folders from `.agents/skills/` up the directory tree — fine for repo-local use, just not a shareable installable unit.

## Antigravity

Antigravity's plugin format is real but deliberately minimal — a `plugin.json` marker file, and the skill nested *inside* the plugin (not pointed at from outside it):
```
plugins/<name>/
├── plugin.json        # { "name": "<name>" } — the "name" field is optional, defaults to the folder name
└── skills/<name>/     # mirrored copy kept in sync via scripts/sync-skills.sh
```
`skills/<name>` at the repo root is the canonical source of truth. The nested copy inside `plugins/<name>/skills/<name>` is automatically mirrored and kept identical using `scripts/sync-skills.sh` (and the pre-commit hook). This avoids raw symlink text blobs on GitHub's web interface, ensures markdown renders cleanly in browsers, and provides full out-of-the-box compatibility with Windows checkouts and ZIP downloads.

Install has no registry step today: place the `plugins/<name>/` folder into `.agents/plugins/` at the workspace root (project-scoped) or `~/.gemini/config/plugins/` (global), or run `agy plugin install <path-or-url>` if the CLI is available. There's no marketplace.json equivalent — just "copy the folder in."

## Bundling MCP Servers (Optional)

If a skill relies on specialized tools (e.g. Exa search), you can package MCP server configurations inside the plugin:

- **Claude Code & Codex**: Place `.mcp.json` at `plugins/<name>/.mcp.json` and declare `"mcpServers": "./.mcp.json"` in `plugins/<name>/.claude-plugin/plugin.json` and `plugins/<name>/.codex-plugin/plugin.json`.
- **Google Antigravity**: Place `mcp_config.json` at `plugins/<name>/mcp_config.json`.
- **Remote / Hosted Servers**: For hosted endpoints (e.g. `https://mcp.exa.ai/mcp`), use `"type": "http"`, `"url": "..."` in `.mcp.json` and `"serverUrl": "..."` in `mcp_config.json`. Users authenticate via OAuth without requiring an API key.

## README table

| Agent | Install |
|---|---|
| Claude Code | `claude plugin marketplace add you/repo` → `claude plugin install name@repo` |
| Codex | `codex plugin marketplace add you/repo` → `codex plugin add name@repo` |
| Antigravity | `agy plugin install <path-or-url>`, or copy `plugins/name/` into `.agents/plugins/` (workspace) / `~/.gemini/config/plugins/` (global) |
| Any agentskills.io-compatible agent | copy `skills/<name>/` into that agent's skill directory |

## Don't

- Don't manually edit the plugin copy — always edit the canonical source in `skills/<name>/` and run `./scripts/sync-skills.sh` (or let the pre-commit hook sync automatically).
- Don't invent manifest fields beyond what's documented. Claude/Codex plugin.json: `name`, `version`, `description`, `author`, `homepage`. Antigravity plugin.json: `name` only — it's a marker file, not a metadata block, and adding undocumented fields there isn't validated against anything.
- Don't assume Antigravity has a marketplace/registry install path — it currently doesn't; direct users to copy the folder or use `agy plugin install`.
