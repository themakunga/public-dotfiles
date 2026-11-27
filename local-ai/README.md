# Local AI and OpenCode

`applicationModules.ai` in nix-systems owns the Codex, Claude Code, OpenCode,
Gemini CLI and llama.cpp switches. Stow deploys this package into the user's home.
Public configuration lives here; identities, journals and speech catalogs stay in
`~/.vaults/amgmt`. Authentication is runtime-private and must never be committed.

## Usage

```sh
ai-server                         # foreground llama.cpp router; only one instance
ai                                # OpenCode mini with the coding model
ai --model flash "Explain DNS"     # smallest local model, thinking disabled
ai --model fast                    # interactive Qwen3 4B
ai --model coder "Explain this code"
ai --model reasoning "Compare these designs"
```

The router loads at most one model at a time and downloads missing Q4_K_M weights
from Hugging Face on demand. Flash uses Qwen3 0.6B, fast uses Qwen3 4B, coder uses
Qwen2.5 Coder 7B, and reasoning uses Qwen3 8B. Flash is a local quick-question
profile; it does not use Gemini Flash or any cloud inference API.

Chat presets and OpenCode agree on a 32,768-token context. Automatic compaction
keeps 4,096 recent tokens with a 4,096-token buffer. This does not expand the
model's trained context; compaction can discard detail. Small models cannot
provide the same reasoning or instruction-following reliability as Codex models.
Qwen3 thinking is disabled for fast/flash requests and retained for reasoning.

OpenCode reads the shared SOUL and OpenCode JOURNAL instructions. It discovers
portable skills through `~/.agents/skills` and `~/.claude/skills`; Codex-only app
connectors and plugin tools are not transferred. The GLaDOS plugin maps native
OpenCode events to the existing shared adapter and preserves its voice gates.

When the Nix llama router service is enabled, do not also start `ai-server`.
Standalone heavy commands share `~/.local/state/ai/heavy.lock`; do not delete an
active lock. After a crash, verify no heavy job is running before removing a stale
empty lock directory. Keep client URLs in sync if changing the server bind/port.
Do not bind to a public interface without adding authentication and network controls.

`opencode/service.json` is generated private state. It is ignored even when the
configuration directory is a Stow symlink. A previously published service password
must be rotated through the owner's service lifecycle; removing a tracked file
does not remove earlier Git history.

Run `python3 local-ai/check.py` from the repository root to check CLI arguments,
unknown-model rejection and published client/server context agreement. These
checks use command stubs and do not download weights or exercise model inference.
