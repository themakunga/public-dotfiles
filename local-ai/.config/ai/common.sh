# Shared settings; sourced by the CLI commands.
set -euo pipefail
AI_CONFIG="$HOME/.config/ai"
AI_DATA="$HOME/.local/share/ai/models"
AI_URL=http://127.0.0.1:8080
AI_STATE="$HOME/.local/state/ai"
die() { printf '%s\n' "$*" >&2; exit 1; }
need_file() { [[ -f "$1" ]] || die "Missing file: $1"; }
# Cooperative lock: all heavy standalone tools and the managed server use it.
lock_heavy() {
  mkdir -p "$AI_STATE"
  mkdir "$AI_STATE/heavy.lock" 2>/dev/null || die "AI busy. Stop ai-server or wait for the current job. See README for stale locks."
  trap 'rmdir "$AI_STATE/heavy.lock"' EXIT
}
server_ready() { curl -fsS --max-time 3 "$AI_URL/health" >/dev/null; }
