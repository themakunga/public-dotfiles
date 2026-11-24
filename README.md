[![CI & Auto PR](https://github.com/themakunga/public-dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/themakunga/public-dotfiles/actions/workflows/ci.yaml)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Security: Gitleaks](https://img.shields.io/badge/Security-Gitleaks-blueviolet)](https://github.com/gitleaks/gitleaks)

# Public Dotfiles

Personal application, editor, shell and desktop configuration for macOS and Linux.
Packages and host-specific deployment are declared in
[nix-systems](https://github.com/themakunga/nix-systems); this repository holds the
public configuration those declarations deploy.

## Configuration map

| Area                | Directories                                                                                                      | Notes                                                                                                 |
| ------------------- | ---------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Editor              | [nvim](nvim/), [zed](zed/)                                                                                       | Neovim plugins, native LSP configuration, syntax and regression checks.                               |
| Shell and terminals | [zsh](zsh/), [bash](bash/), [wezterm](wezterm/), [ghostty](ghostty/), [tmux](tmux/)                              | Shell startup, terminal appearance and persistent sessions.                                           |
| Linux desktop       | [hypr](hypr/), [waybar](waybar/), [wofi](wofi/)                                                                  | Hyprland startup, shortcuts, status bar and launcher.                                                 |
| macOS desktop       | [aerospace](aerospace/), [yabai](yabai/), [skhd](skhd/)                                                          | Window management and shortcuts; enabled components depend on the host.                               |
| CLI tools           | [git](git/), [gh](gh/), [lazygit](lazygit/), [yazi](yazi/), [btop](btop/)                                        | Git workflows, file navigation and monitoring.                                                        |
| Dictation and media | [handy](handy/README.md), [cliamp](cliamp/README.md)                                                             | Offline bilingual dictation and public podcast/radio starter settings.                                |
| Agents              | [agent](agent/), [codex](codex/), [claude](claude/), [hermes](hermes/), [gemini](gemini/), [zeroclaw](zeroclaw/) | Public runtime settings; private identity, authentication and speech catalogs are managed separately. |

Directories are deployed selectively. Their presence here does not mean every
application is enabled on every host.

## Deployment

The managed checkout is normally `~/.public-dotfiles` for each runtime user:

```sh
git clone https://github.com/themakunga/public-dotfiles.git ~/.public-dotfiles
```

Cloning alone does not link configuration or install applications. The
[`my.dotfiles` module](https://github.com/themakunga/nix-systems/blob/main/modules/modules/common/dotfiles.nix)
in `nix-systems` selects packages and uses GNU Stow during system activation.
For example, an application module can declare:

```nix
my.dotfiles.packages = [
  {
    name = "nvim";
    isConfig = true;
  }
];
```

This maps `nvim/` into `~/.config/nvim/`. Packages without `isConfig` target the
user's home; `output-name` and `output-path` support application-specific
locations. `my.dotfiles.additionalUsers` supplies separate checkouts and package
selections for additional Linux users.

Activation attempts a fast-forward update from `origin/main` before deployment.
An update failure emits a warning and keeps the local checkout. Changes published
only on `develop` reach managed hosts after merging into `main` and activating
that host. Review declarations and existing files first: deployment can adopt
existing files and remove conflicting Stow targets.

Declare application dependencies in `nix-systems`. There is no root `install.sh`.
The Aperture-specific script under `scripts/` is a separate manual setup path;
managed hosts use the Nix declarations.

## Neovim and terminal behavior

Neovim uses `vim.pack` and native `vim.lsp.config`/`vim.lsp.enable`. Nix supplies
system tools, while the existing Mason tool list manages additional editor
servers. LSP configuration lives in `nvim/lsp/`; overrides that must take
precedence over plugin defaults go in `nvim/after/lsp/`.

- Vue uses `vue_ls` with `ts_ls` and the `@vue/typescript-plugin` bundled with
  Mason's Vue language server. `ts_ls` handles Vue buffers; ordinary TypeScript
  and JavaScript retain the configured TypeScript 7 server.
- CSpell requires the project's own CSpell configuration. Nested Git repositories
  opt in independently; executable configurations require Neovim's native trust.
- agnix validates supported agent, skill and MCP configuration files.
- Ollama Modelfiles use native syntax highlighting rather than Docker parsing.

Run focused checks from `nvim/` after their required tools/plugins are available:

```sh
cd ~/.public-dotfiles/nvim
nvim --headless -u NONE -i NONE -l tests/project-lsp.lua
nvim --headless -u NONE -i NONE -l tests/vue.lua
```

The Vue check requires `nvim-lspconfig` and Mason's Vue/TypeScript servers; it
verifies both client attachment and real TypeScript diagnostics in a component.
Other files in `nvim/tests/` document their commands and prerequisites.

On Aperture Science, Wheatley's Hyprland session opens one fullscreen WezTerm
window and creates or reattaches the `main` tmux session. Other users retain the
existing terminal layout. Check the startup scenarios from the repository root
with `python3 hypr/check-startup.py`.

## Contributing

Base changes on an up-to-date `develop` checkout or a topic branch from it.
Preserve unrelated edits and review the diff before committing. Changes reach
`develop` first; `main` is the deployment branch.

With Git, pre-commit and the applicable formatters available, enable the configured
pre-commit, commit-message and pre-push hooks, then check affected files:

```sh
pre-commit install
pre-commit run --files README.md
```

[Local hooks](.pre-commit-config.yaml) cover YAML/JSON, whitespace, file size,
forbidden files, Prettier, StyLua and Conventional Commits. Gitleaks runs at the
pre-push stage. Use English [Conventional Commits](https://conventionalcommits.org):

```sh
git commit -m "docs: update configuration and deployment guide"
```

Push reviewed changes to `develop`. The [CI workflow](.github/workflows/ci.yaml)
checks commit messages, scans for secrets, rejects forbidden files and creates or
updates the pull request into `main` after successful checks. Application-specific
regression checks remain separate from that workflow.

Keep credentials, private account settings, runtime histories and transcripts out
of this public repository. Use the existing encrypted secrets repository for
sensitive configuration and copy only reviewed public defaults from live apps.
The Handy and cliamp guides explain their writable settings and seeding behavior.
