# csalvado-plugins

Personal Claude Code plugin marketplace. Manifest: `.claude-plugin/marketplace.json`; each plugin lives in `plugins/<name>/` with its own `.claude-plugin/plugin.json`.

## Conventions
- Bump `version` in a plugin's `plugin.json` whenever you change it; installs only update on version change.
- Plugins must be portable: no references to files outside the plugin, no project-specific paths. Use `${CLAUDE_PLUGIN_ROOT}` for intra-plugin paths in hooks/MCP config.
- Plugin agents are namespaced `<plugin>:<agent>` (e.g. `orchestrate:reviewer`); reference them that way in skills.
- Output styles that should keep coding ability need `keep-coding-instructions: true`.

## Validate / test
- `claude plugin validate .` before committing; or the `plugin-dev:plugin-validator` agent.
- `claude --plugin-dir ./plugins/<name>` to try a plugin without installing.
- Skill/style quality: use `skill-creator` evals (workspaces go in `*-workspace/`, git-ignored).
