# Journal settings

`journal-settings.json` supplies installation values to the existing
obsidian-journal installer. The installer renders its own configuration template;
these settings contain no credentials and do not replace journal documents.

On Aperture Science, Nix prepares the existing shared journal repository at
`/opt/wheatley/.vaults/journal`, selects it through
`/opt/wheatley/.obsidian-journal-vault` and uses the runtime-local configuration at
`/opt/wheatley/.config/obsidian-journal/config.toml`. This keeps the shared vault's
legacy host-specific configuration unchanged.

Existing local configuration and skill installations are preserved. Journal
maintenance runs through the installed skill; skill discovery does not approve
native Codex hooks or enable voice for other runtimes.

The shared workspace now covers every configured interactive and service AI user
on both macOS and Linux. `shared-workspace.py` links one portable skill catalog
into all seven native runtime directories, preserves conflicting copies in local
backups and prepares runtime-local journal configuration from the installed skill
template. It includes OpenCode in the configured agent names and retains a single
upstream journal. See [WORKSPACE.md](WORKSPACE.md) for the mandatory protocol.
