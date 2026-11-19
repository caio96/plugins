# Caio's AI Plugin Marketplace

Personal Claude Code plugin marketplace (ID `csalvado-plugins`, the name used in install commands). Manifest: `.claude-plugin/marketplace.json`; each plugin lives in `plugins/<name>/` with its own `.claude-plugin/plugin.json`.

## Conventions
- Plugins must be portable: no references to files outside the plugin, no project-specific paths. Use `${CLAUDE_PLUGIN_ROOT}` for intra-plugin paths in hooks/MCP config.
- Plugin agents are namespaced `<plugin>:<agent>` (e.g. `orchestrate:reviewer`); reference them that way in skills.
- Output styles that should keep coding ability need `keep-coding-instructions: true`.
- Change standards (minimal diffs, brief non-historical comments, tests/logging following repo precedent) are duplicated in `orchestrate/agents/implementer.md`, `orchestrate/agents/reviewer.md`, and `orchestrate/skills/orchestrate/SKILL.md` — components can't include shared files, so edit all three together.

## Validate / test
- `scripts/check.sh` before pushing: validates all manifests and fails if a changed plugin didn't bump its `version` (installed copies only update on a version change). Static, no model calls.
- `claude --plugin-dir ./plugins/<name>` to try a plugin without installing.
- Skill/style quality: use `skill-creator` evals (workspaces go in `*-workspace/`, git-ignored).
