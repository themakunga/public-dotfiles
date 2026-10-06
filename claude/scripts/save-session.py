#!/usr/bin/env python3
"""
Claude Code Stop hook — guarda un resumen de sesión en agent-wiki/journal/.
Escribe en ~/.vaults/agent-wiki/journal/YYYY-MM-DD.md y hace git commit.
"""
import json, sys, os, subprocess
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
    session_id      = ctx.get('session_id', 'unknown')

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
    now      = datetime.now()
    today    = now.strftime('%Y-%m-%d')
    time_str = now.strftime('%H:%M')
    sid      = session_id[:8] if session_id != 'unknown' else 'unknown'

    lines = [f'\n## {time_str} — `{sid}`']
    lines.append(f'\n**cwd**: `{cwd}`')

    if user_messages:
        lines.append('\n**Solicitudes:**')
        for msg in user_messages:
            lines.append(f'- {msg}')

    if files_modified:
        lines.append('\n**Archivos:**')
        for fp in files_modified[:30]:
            lines.append(f'- `{fp}`')

    lines.append('')
    entry = '\n'.join(lines)

    # Escribir al journal del día
    JOURNAL.mkdir(parents=True, exist_ok=True)
    journal_file = JOURNAL / f'{today}.md'

    if journal_file.exists():
        with open(journal_file, 'a') as f:
            f.write(entry)
    else:
        with open(journal_file, 'w') as f:
            f.write(f'# {today}\n')
            f.write(entry)

    # Git commit en el vault
    subprocess.run(['git', 'add', str(journal_file)], cwd=str(VAULT),
                   capture_output=True, timeout=10)
    subprocess.run(
        ['git', 'commit', '-m', f'journal: auto-save {today} {time_str}'],
        cwd=str(VAULT), capture_output=True, timeout=10
    )

if __name__ == '__main__':
    try:
        main()
    except Exception:
        pass  # hooks nunca deben romper el flujo de Claude
