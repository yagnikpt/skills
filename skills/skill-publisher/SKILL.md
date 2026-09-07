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
├── skills/<name>/SKILL.md            # the one shared skill — source of truth
├── .claude-plugin/
│   ├── plugin.json                   # Claude Code plugin manifest
│   └── marketplace.json              # Claude Code marketplace entry
├── .codex-plugin/
│   └── plugin.json                   # Codex plugin manifest
├── .agents/plugins/marketplace.json  # Codex marketplace entry
├── plugins/<name>/
│   ├── plugin.json                   # Antigravity plugin marker
│   └── skills/<name>/                # symlink to ../../../skills/<name>
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
└── skills/<name>/     # symlink to ../../../skills/<name>
```
`skills/<name>` inside the plugin should be a symlink to the repo-root `skills/<name>`, not a copy — same single-source-of-truth rule, ensuring `SKILL.md` plus any optional `scripts/`, `references/`, or `assets/` subfolders are automatically shared without duplicating files.

Install has no registry step today: place the `plugins/<name>/` folder into `.agents/plugins/` at the workspace root (project-scoped) or `~/.gemini/config/plugins/` (global), or run `agy plugin install <path-or-url>` if the CLI is available. There's no marketplace.json equivalent — just "copy the folder in."

## README table

| Agent | Install |
|---|---|
| Claude Code | `claude plugin marketplace add you/repo` → `claude plugin install name@repo` |
| Codex | `codex plugin marketplace add you/repo` → `codex plugin add name@repo` |
| Antigravity | `agy plugin install <path-or-url>`, or copy `plugins/name/` into `.agents/plugins/` (workspace) / `~/.gemini/config/plugins/` (global) |
| Any agentskills.io-compatible agent | copy `skills/<name>/` into that agent's skill directory |

## Don't

- Don't fork the skill content per target — one real skill folder in `skills/<name>`; every other copy (including the one nested under `plugins/<name>/skills/` for Antigravity) is a symlink to it, never a duplicate.
- Don't invent manifest fields beyond what's documented. Claude/Codex plugin.json: `name`, `version`, `description`, `author`, `homepage`. Antigravity plugin.json: `name` only — it's a marker file, not a metadata block, and adding undocumented fields there isn't validated against anything.
- Don't assume Antigravity has a marketplace/registry install path — it currently doesn't; direct users to copy the folder or use `agy plugin install`.
