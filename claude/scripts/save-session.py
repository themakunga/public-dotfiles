#!/usr/bin/env python3
"""
Claude Code Stop hook — guarda un resumen de sesión en agent-wiki/journal/.
Delega la transacción pull/append/commit/push al escritor compartido.
"""
import hashlib, json, sys, os, subprocess
from datetime import datetime
from pathlib import Path

VAULT = Path.home() / '.vaults' / 'agent-wiki'
JOURNAL = VAULT / 'journal'

def main():
    # Leer contexto del hook (stdin)
    try:
        ctx = json.loads(sys.stdin.read())
    except Exception:
        return

    transcript_path = ctx.get('transcript_path', '')
    cwd             = ctx.get('cwd', os.getcwd())
    session_id      = str(ctx.get('session_id', 'unknown'))

    # Parsear transcript
    files_modified = []
    user_messages  = []

    if transcript_path and os.path.exists(transcript_path):
        seen_files = set()
        with open(transcript_path) as f:
            for raw in f:
                try:
                    entry = json.loads(raw)
                except Exception:
                    continue

                kind = entry.get('type')

                # Mensajes del usuario (primeros 5, máx 120 chars)
                if kind == 'user' and len(user_messages) < 5:
                    msg = entry.get('message', {})
                    content = msg.get('content', '')
                    if isinstance(content, str):
                        text = content.strip()
                    elif isinstance(content, list):
                        text = ' '.join(
                            c.get('text', '') for c in content
                            if isinstance(c, dict) and c.get('type') == 'text'
                        ).strip()
                    else:
                        text = ''
                    # Ignorar mensajes de sistema, XML interno, continuaciones
                    skip = (
                        not text
                        or len(text) <= 3
                        or text.startswith('<')
                        or text.startswith('[SYSTEM')
                        or text.startswith('# AGENTS.md instructions')
                        or text.startswith('Caveat:')
                        or text.startswith('This session is being continued')
                        or 'task-notification' in text
                    )
                    if not skip:
                        user_messages.append(text[:120].replace('\n', ' '))

                # Archivos modificados (Edit / Write)
                elif kind == 'assistant':
                    for c in entry.get('message', {}).get('content', []):
                        if not isinstance(c, dict) or c.get('type') != 'tool_use':
                            continue
                        if c.get('name') in ('Edit', 'Write'):
                            fp = c.get('input', {}).get('file_path', '')
                            if fp and fp not in seen_files:
                                seen_files.add(fp)
                                files_modified.append(fp)

    # No guardar sesiones vacías
    if not files_modified and not user_messages:
        return

    # Construir entrada
    timestamp = datetime.now().astimezone().isoformat(timespec='microseconds')
    session_hash = hashlib.sha256(session_id.encode()).hexdigest()[:8]
    hostname = subprocess.run(['hostname', '-s'], capture_output=True, text=True, timeout=5).stdout.strip() or 'local'
    lines = [f'### {timestamp[11:16]} - {session_hash} - Claude Code - {hostname}', f'<!-- journal-timestamp: {timestamp} -->', '', '**Work:** Session driven by the following requests:']
    if user_messages:
        for msg in user_messages:
            lines.append(f'- {msg}')
    lines.extend(['', f'**cwd:** `{cwd}`', '', '**Files:**'])
    if files_modified:
        for fp in files_modified[:30]:
            lines.append(f'- `{fp}`')
    else:
        lines.append('- unavailable (Stop hook did not observe file edits)')
    lines.extend(['', '**Verification:** Auto-captured by Stop hook; content not independently verified.', '', '**Tokens:** unavailable (runtime does not expose usage to hooks)', '', '**Pending:** none'])
    entry = '\n'.join(lines)
    subprocess.run(
        [sys.executable, str(VAULT / 'scripts' / 'journal_append.py')],
        input=entry, text=True, check=True, timeout=180,
    )

if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f'journal hook failed: {exc}', file=sys.stderr)
