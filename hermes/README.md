# Hermes

`config.kanagawa.yaml` configures the native CLI on macOS.
`config.aperture-science.yaml` configures the native CLI for Wheatley and Nicolas
on Aperture Science. Nix seeds `~/.hermes/config.yaml` once, preserving later
runtime changes. The working directory starts in the user's home.

Nix links `~/.hermes/.env` to a private SOPS runtime template and links `SOUL.md`
to the user's shared vault under `~/.vaults/amgmt/agents/`. Credentials never
belong in these public templates. GLaDOS lifecycle hooks are managed by the
standalone skill in the vault.

The legacy `config.yaml` is a container template, not the native CLI config.
