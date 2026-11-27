# OpenCode journal workflow

OpenCode loads the shared identity from `agents/SOUL.md` and this file through the
`instructions` array in `~/.config/opencode/opencode.json`. The installed
`obsidian-journal` skill remains the authority for ordering, templates, review and
publication.

## Stable commands

Prefer the `journal-maintenance` dispatcher from any directory. It resolves the
installed skill and the selected journal through the current user's home, not the
caller's directory.

| Skill command                                        | Stable command                                             |
| ---------------------------------------------------- | ---------------------------------------------------------- |
| `lua scripts/sync.lua`                               | `journal-maintenance sync`                                 |
| `lua scripts/weekly.lua`                             | `journal-maintenance weekly`                               |
| `lua scripts/monthly.lua`                            | `journal-maintenance monthly`                              |
| `lua scripts/history.lua`                            | `journal-maintenance history`                              |
| `lua scripts/entry.lua OpenCode` with standard input | `journal-maintenance entry OpenCode /private/tmp/entry.md` |
| `lua scripts/publish.lua entry journal-current.md`   | `journal-maintenance publish entry journal-current.md`     |

The skill's native `lua scripts/*.lua` commands are also allowed by the global
OpenCode permission rules. Set the shell `workdir` to the skill directory instead
of using `cd`, so the command scanner sees the expected command.

## Routine workflow

Follow the installed obsidian-journal skill for ordering, templates, review and
publication. Invoke **`journal-maintenance` by command name**, from any directory,
as a separate shell command. Keep the skill's silent maintenance policy.

Publication accepts the skill's existing daily, weekly, monthly, history and entry
task types and their validated paths. Its Git subprocesses run as part of the
approved command.

For sync and publication, command-local Git options enable automatic stashing and
restoration of the staged state. This allows publication metadata updates alongside
unrelated local edits without changing repository or global Git configuration.
Actual merge conflicts still require review; preserve Git's recovery stash and
report an unresolved conflict rather than discarding edits. Git can retain an
already-applied recovery stash; leave that backup intact.

When adding summary prose, save the exact reviewed original and the complete edited
Markdown to temporary files inside the current writable workspace or temporary
directory. Update only that existing journal note:

```sh
journal-maintenance write weekly/2026-W48/summary.md /private/tmp/base.md /private/tmp/draft.md
```

`write` accepts only journal Markdown paths beneath the configured `~/.vaults/`
vault. It shares the journal lock, checks the original bytes, preserves file mode
and replaces the file atomically. A concurrent change, existing lock, symbolic link
or path outside that vault fails without overwriting the note. Review and publish
with the matching skill task afterward.

Avoid wrapping these commands in temporary scripts, shell substitutions,
redirections or combined shell blocks. The entry command opens its input file
itself. Installation, arbitrary shell execution and unrelated Git commands remain
outside this authorization.
