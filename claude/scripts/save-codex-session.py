#!/usr/bin/env python3
"""
Codex SessionEnd hook — guarda un resumen de sesión en agent-wiki/journal/.
Recibe JSON por stdin desde Codex (puede estar vacío o contener script_path/cwd).
"""
import hashlib, json, sys, os, subprocess
from datetime import datetime
from pathlib import Path

VAULT = Path.home() / '.vaults' / 'agent-wiki'
JOURNAL = VAULT / 'journal'
SESSIONS_DIR = Path.home() / '.codex' / 'sessions'


def find_recent_session():
    """Busca el JSONL de sesión Codex más reciente."""
    candidates = list(SESSIONS_DIR.rglob('rollout-*.jsonl'))
    if not candidates:
        return None
    return max(candidates, key=lambda p: p.stat().st_mtime)


def main():
    try:
        ctx = json.loads(sys.stdin.read())
    except Exception:
        ctx = {}

    # Codex puede pasar script_path o transcript_path
    session_path = ctx.get('script_path') or ctx.get('transcript_path', '')
    if not session_path or not os.path.exists(session_path):
        session_path = find_recent_session()

    if not session_path:
        return

    cwd = ctx.get('cwd', os.getcwd())
    session_id = str(ctx.get('session_id', 'unknown'))
    user_messages = []
    seen_texts = set()

    with open(session_path) as f:
        for raw in f:
            try:
                entry = json.loads(raw)
            except Exception:
                continue
            t = entry.get('type')
            payload = entry.get('payload', {})

            if t == 'session_meta':
                cwd = payload.get('cwd', cwd)
                session_id = str(payload.get('session_id') or payload.get('id') or session_id)

            elif t == 'response_item' and payload.get('role') == 'user':
                if len(user_messages) >= 5:
                    continue
                for c in payload.get('content', []):
                    if c.get('type') != 'input_text':
                        continue
                    text = c.get('text', '').strip()
                    skip = (
                        not text or len(text) <= 3
                        or text.startswith('<')
                        or text.startswith('[SYSTEM')
                        or text.startswith('# AGENTS.md instructions')
                        or 'task-notification' in text
                    )
                    if not skip and text not in seen_texts:
                        seen_texts.add(text)
                        user_messages.append(text[:120].replace('\n', ' '))

    if not user_messages:
        return

    timestamp = datetime.now().astimezone().isoformat(timespec='microseconds')
    session_hash = hashlib.sha256(session_id.encode()).hexdigest()[:8]
    hostname = subprocess.run(['hostname', '-s'], capture_output=True, text=True, timeout=5).stdout.strip() or 'local'
    lines = [f'### {timestamp[11:16]} - {session_hash} - Codex - {hostname}', f'<!-- journal-timestamp: {timestamp} -->', '', '**Work:** Session driven by the following requests:']
    for msg in user_messages:
        lines.append(f'- {msg}')
    lines.extend(['', f'**cwd:** `{cwd}`', '', '**Files:**', '- unavailable (SessionEnd hook does not inspect file changes)', '', '**Verification:** Auto-captured by SessionEnd hook; content not independently verified.', '', '**Tokens:** unavailable (runtime does not expose usage to hooks)', '', '**Pending:** none'])
    entry_text = '\n'.join(lines)

    subprocess.run(
        [sys.executable, str(VAULT / 'scripts' / 'journal_append.py')],
        input=entry_text, text=True, check=True, timeout=180,
    )


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f'journal hook failed: {exc}', file=sys.stderr)
