# Handy

Offline English and Spanish dictation for terminal applications and tmux.
Press **Ctrl+Alt+Space** to start recording and press it again to transcribe and
paste. On macOS, Alt is Option. Enter is never submitted automatically.

The `nix-systems` Handy application module installs the app, pins the model and
seeds `settings_store.json` only when it is missing:

| Platform         | Model               | App data directory                              |
| ---------------- | ------------------- | ----------------------------------------------- |
| macOS            | Whisper Medium Q8_0 | `~/Library/Application Support/com.pais.handy/` |
| Aperture Science | Whisper Small Q8_0  | `~/.local/share/com.pais.handy/`                |

Settings remain writable and existing settings/models are preserved. Language is
detected automatically; translation and cloud post-processing are disabled.
Models are downloaded by Nix during the first build, then used locally.

On macOS, grant Handy Microphone and Accessibility permissions in System
Settings. Launchd starts Handy at login. On Aperture Science, Hyprland starts it
and provides the global shortcut; `wtype` and `wl-clipboard` handle terminal
pasting. Focus an editable terminal prompt, or enter insert mode in Neovim,
before dictating. The microphone belongs to the computer running Handy.

Do not copy the live settings or history into this public directory: they may
contain private transcripts or provider credentials.

References: [Linux setup](https://handy.computer/docs/linux),
[models](https://handy.computer/docs/models).
