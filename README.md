# Skills

A collection of portable, cross-agent skills and plugins for **Claude Code**, **OpenAI Codex**, and **Google Antigravity**, adhering to the open [agentskills.io](https://agentskills.io/specification) specification.

## Skills Included

| Skill | Description |
|---|---|
| [`exa-fact-search`](./skills/exa-fact-search) | Routes web search and fact-finding through Exa's MCP tools (`web_search_exa`, `web_search_advanced_exa`, `web_fetch_exa`) with auto-detection for quick lookup vs. multi-facet report mode. |
| [`skill-publisher`](./skills/skill-publisher) | Scaffolds an existing Agent Skill (`SKILL.md` folder) for cross-platform distribution across Claude Code, OpenAI Codex, and Google Antigravity — generating harness-specific manifests and repo layout. |

---

## Installation

### 1. `exa-fact-search`

| Agent | Command / Method |
|---|---|
| **Claude Code** | `claude plugin marketplace add yagnikpt/skills`<br>`claude plugin install exa-fact-search@skills` |
| **OpenAI Codex** | `codex plugin marketplace add yagnikpt/skills`<br>`codex plugin add exa-fact-search@skills` |
| **Google Antigravity** | `agy plugin install https://github.com/yagnikpt/skills/plugins/exa-fact-search`<br>_or copy `plugins/exa-fact-search/` into `.agents/plugins/` (workspace) or `~/.gemini/config/plugins/` (global)_ |
| **Any `agentskills.io` Agent** | Copy `skills/exa-fact-search/` into the agent's skill directory |

### 2. `skill-publisher`

| Agent | Command / Method |
|---|---|
| **Claude Code** | `claude plugin marketplace add yagnikpt/skills`<br>`claude plugin install skill-publisher@skills` |
| **OpenAI Codex** | `codex plugin marketplace add yagnikpt/skills`<br>`codex plugin add skill-publisher@skills` |
| **Google Antigravity** | `agy plugin install https://github.com/yagnikpt/skills/plugins/skill-publisher`<br>_or copy `plugins/skill-publisher/` into `.agents/plugins/` (workspace) or `~/.gemini/config/plugins/` (global)_ |
| **Any `agentskills.io` Agent** | Copy `skills/skill-publisher/` into the agent's skill directory |

---

## Repository Structure

All skills maintain a single source of truth under `skills/`. Every harness-specific manifest or plugin wrapper points to the canonical skill folder via symlinks without duplicating content.

```text
skills/
├── skills/
│   ├── exa-fact-search/
│   │   └── SKILL.md                          # Source of truth
│   └── skill-publisher/
│       └── SKILL.md                          # Source of truth
├── plugins/
│   ├── exa-fact-search/
│   │   ├── plugin.json                       # Antigravity marker
│   │   ├── .claude-plugin/plugin.json        # Claude plugin manifest
│   │   ├── .codex-plugin/plugin.json         # Codex plugin manifest
│   │   └── skills/exa-fact-search            # Symlink to ../../../skills/exa-fact-search
│   └── skill-publisher/
│       ├── plugin.json                       # Antigravity marker
│       ├── .claude-plugin/plugin.json        # Claude plugin manifest
│       ├── .codex-plugin/plugin.json         # Codex plugin manifest
│       └── skills/skill-publisher            # Symlink to ../../../skills/skill-publisher
├── .claude-plugin/
│   ├── plugin.json                           # Repo-level Claude manifest
│   └── marketplace.json                      # Claude marketplace catalog
├── .codex-plugin/
│   ├── plugin.json                           # Repo-level Codex manifest
├── .agents/plugins/
│   └── marketplace.json                      # Codex marketplace catalog
└── README.md
```

## License

MIT
