# csalvado-plugins

Personal Claude Code plugin marketplace.

| Plugin | What it gives you |
|---|---|
| `terse` | `terse` output style — cuts filler, keeps code/commands/errors verbatim. Adapted from caveman (full level). |
| `orchestrate` | `orchestrate` skill (decompose → dispatch subagents → synthesize, per-unit model choice, worktree parallelism) + `orchestrate:reviewer` agent. |

## Install on a new machine

```
/plugin marketplace add caio96/plugins     # private repo: needs git access (gh auth / SSH)
/plugin install terse@csalvado-plugins
/plugin install orchestrate@csalvado-plugins
```

Enable the output style everywhere in `~/.claude/settings.json`:

```json
{ "outputStyle": "terse" }
```

(Or pick it per session with `/output-style`. Check the exact name it lists — plugin styles may be namespaced.)

## Enable in a project

Commit to the project's `.claude/settings.json` so collaborators/machines get prompted:

```json
{
  "extraKnownMarketplaces": {
    "csalvado-plugins": { "source": { "source": "github", "repo": "caio96/plugins" } }
  },
  "enabledPlugins": { "orchestrate@csalvado-plugins": true }
}
```

## Develop

```
claude --plugin-dir ./plugins/orchestrate     # try a plugin without installing
claude plugin validate .                       # validate marketplace + plugins
```

Bump `version` in the plugin's `.claude-plugin/plugin.json` on every change — installed copies only update when the version changes.
