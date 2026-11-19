# 🧰 Caio's AI Plugin Marketplace

Personal [Claude Code](https://code.claude.com) plugins I use day to day: install once per machine, enable per project.

## 📦 Plugins

### `terse` — output style

Cuts filler and keeps technical substance exact. Fragments are fine, while code, commands, paths, and error strings stay verbatim. It switches to full sentences for warnings and destructive actions, and writes commits, PRs, and code comments in normal prose. Adapted from [caveman](https://github.com/JuliusBrussee/caveman) (full level).

### `orchestrate` — multi-agent workflow

| Component | Type | What it does |
|---|---|---|
| `orchestrate` | skill | Decompose → dispatch subagents → synthesize. Per-unit model choice, parallel worktrees, a brief durable ledger in `.notes/`. |
| `orchestrate:implementer` | agent | Does one scoped code change: minimal diff, follows repo precedent for tests, comments, and logging, commits and reports. |
| `orchestrate:reviewer` | agent | Independent review. Critical / Suggestion / Nit findings scored 0–100, may run tests to confirm. |
| `/orchestrate:review [base] [gate]` | command | Runs the reviewer on the current changes. |

## 🚀 Install

On a new machine (private repo, so this needs GitHub access via SSH or `gh auth`):

```text
/plugin marketplace add caio96/plugins
/plugin install terse@csalvado-plugins
/plugin install orchestrate@csalvado-plugins
```

To make `terse` the default everywhere, add this to `~/.claude/settings.json`:

```json
{ "outputStyle": "terse" }
```

Or pick it per session with `/output-style`.

> [!NOTE]
> Check the exact name `/output-style` lists. Plugin styles may be namespaced.

## 🗂️ Enable in a project

Commit this to the project's `.claude/settings.json` so every machine gets prompted to install:

```json
{
  "extraKnownMarketplaces": {
    "csalvado-plugins": { "source": { "source": "github", "repo": "caio96/plugins" } }
  },
  "enabledPlugins": { "orchestrate@csalvado-plugins": true }
}
```

## 🛠️ Develop

```bash
claude --plugin-dir ./plugins/orchestrate   # try a plugin without installing
scripts/check.sh [base]                     # validate manifests + version-bump check (base: origin/main)
```

> [!IMPORTANT]
> Bump `version` in `plugins/<name>/.claude-plugin/plugin.json` on every change. Installed copies only update when the version changes.

## 📄 License

[MIT](LICENSE)
