# skills

A collection of agent skills for Claude Code, OpenAI Codex, and Google Antigravity, following the [agentskills.io](https://agentskills.io) specification.

## Skills

- **[`exa-fact-search`](./skills/exa-fact-search)** — Route web searches and fact-finding through Exa's MCP tools with auto-detection for quick lookups vs. multi-facet research.
- **[`skill-publisher`](./skills/skill-publisher)** — Scaffold and package agent skills for cross-platform distribution across Claude Code, OpenAI Codex, and Google Antigravity.

## Installation

### Universal

```bash
npx skills add yagnikpt/skills
```

### Claude Code

```bash
claude plugin marketplace add yagnikpt/skills
claude plugin install <skill-name>@skills
```

### OpenAI Codex

```bash
codex plugin marketplace add yagnikpt/skills
codex plugin add <skill-name>@skills
```

### Google Antigravity

```bash
agy plugin install https://github.com/yagnikpt/skills/plugins/<skill-name>
```

Or copy `plugins/<skill-name>/` into `.agents/plugins/` (project-level) or `~/.gemini/config/plugins/` (global).

### Manual

Copy `skills/<skill-name>/` directly into your agent's skill directory.

## Development

Canonical skills live under `skills/`. Plugin copies under `plugins/` are mirrored automatically:

```bash
./scripts/sync-skills.sh          # sync skills/ -> plugins/
./scripts/sync-skills.sh --check  # check for drift
```

## License

MIT
