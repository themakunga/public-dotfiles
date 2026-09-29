# WeeChat / Halloy

`weechat.conf` contains the public Tokyo Night UI. `deploy.sh` copies it and
renders `irc.conf` from `secrets/shared-conf/halloy/config.toml` (plain TOML,
not SOPS). No credentials are stored here. Python 3.11+ is required.

Close WeeChat before running `bash weechat/deploy.sh`. The generated files are
private, writable copies; edits made inside WeeChat are replaced at the next
deployment. Nix uses the same deploy script after deploying public-dotfiles.
Connections follow the Halloy configuration in the pinned Nix secrets input;
update that input when changing the private repository.

Shared settings: enabled servers, TLS, passwords, nicknames, usernames,
channels, connect commands, user modes, monitored contacts, ignored users,
highlight words, and join/part/quit visibility. Commented servers stay disabled.
The translator covers the current password-based bouncer configuration;
additional authentication methods need explicit mapping before use.

| Key | Action |
| --- | --- |
| Shift+Up / Down | Previous / next buffer |
| Shift+Left / Right | Previous / next unread buffer |
| Shift+Enter | Scroll to bottom |
| Alt+End | Scroll to bottom if the terminal cannot distinguish Shift+Enter |
| Alt+Shift+N | Toggle user list |
| Alt+Shift+B | Toggle channel list |

The channel list is on the left, the user list on the right. Mouse clicks and
scrolling are enabled. Exact RGB rendering depends on terminal support.
Halloy's image previews, emoji picker, desktop notification sounds, and infinite
server history scrolling are not reproduced by this terminal configuration.

Offline checks: `PYTHONDONTWRITEBYTECODE=1 python3 weechat/check.py`.
For a real parser check, deploy into a temporary `WEECHAT_HOME`, then run
`weechat-headless -a -d "$WEECHAT_HOME" -r '/unread next;/quit'`.
The `-a` flag prevents connections and automatic server commands.
