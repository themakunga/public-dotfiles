#!/usr/bin/env python3
"""
Codex SessionEnd hook — guarda un resumen de sesión en agent-wiki/journal/.
Recibe JSON por stdin desde Codex (puede estar vacío o contener script_path/cwd).
"""
import json, sys, os, subprocess
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
    session_id = 'unknown'
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
                session_id = payload.get('session_id', 'unknown')
                cwd = payload.get('cwd', cwd)

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
                        or 'task-notification' in text
                    )
                    if not skip and text not in seen_texts:
                        seen_texts.add(text)
                        user_messages.append(text[:120].replace('\n', ' '))

    if not user_messages:
        return

    now = datetime.now()
    today = now.strftime('%Y-%m-%d')
    time_str = now.strftime('%H:%M')
    sid = session_id[:8] if session_id != 'unknown' else 'unknown'

    lines = [f'\n## {time_str} — `{sid}` (codex)']
    lines.append(f'\n**cwd**: `{cwd}`')
    lines.append('\n**Solicitudes:**')
    for msg in user_messages:
        lines.append(f'- {msg}')
    lines.append('')
    entry_text = '\n'.join(lines)

    JOURNAL.mkdir(parents=True, exist_ok=True)
    journal_file = JOURNAL / f'{today}.md'
    if journal_file.exists():
        existing = journal_file.read_text()
        if sid != 'unknown' and sid in existing:
            return  # ya guardado
        with open(journal_file, 'a') as f:
            f.write(entry_text)
    else:
        with open(journal_file, 'w') as f:
            f.write(f'# {today}\n')
            f.write(entry_text)

    subprocess.run(['git', 'add', str(journal_file)], cwd=str(VAULT), capture_output=True, timeout=10)
    subprocess.run(
        ['git', 'commit', '-m', f'journal: codex {today} {time_str}'],
        cwd=str(VAULT), capture_output=True, timeout=10,
    )


if __name__ == '__main__':
    try:
        main()
    except Exception:
        pass
