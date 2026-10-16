#!/usr/bin/env python3
"""
Claude Code Stop hook — guarda un resumen de sesión en agent-wiki/journal/.
Escribe en ~/.vaults/agent-wiki/journal/YYYY-MM-DD.md y hace git commit.
"""
import json, sys, os, re, subprocess
from datetime import datetime
from pathlib import Path

VAULT = Path.home() / '.vaults' / 'agent-wiki'
JOURNAL = VAULT / 'journal'
RE_UPDATED = re.compile(r"^(updated_at:\s*).*$", re.MULTILINE)


def run_rollup():
    """Ensure today's file exists and stale daily files are moved to week dirs."""
    subprocess.run(
        [sys.executable, str(VAULT / 'scripts' / 'journal_rollup.py'), '--run'],
        cwd=str(VAULT), capture_output=True, timeout=30,
    )


def main():
    try:
        ctx = json.loads(sys.stdin.read())
    except Exception:
        return

    transcript_path = ctx.get('transcript_path', '')
    cwd             = ctx.get('cwd', os.getcwd())
    session_id      = ctx.get('session_id', 'unknown')

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

                elif kind == 'assistant':
                    for c in entry.get('message', {}).get('content', []):
                        if not isinstance(c, dict) or c.get('type') != 'tool_use':
                            continue
                        if c.get('name') in ('Edit', 'Write'):
                            fp = c.get('input', {}).get('file_path', '')
                            if fp and fp not in seen_files:
                                seen_files.add(fp)
                                files_modified.append(fp)

    if not files_modified and not user_messages:
        return

    # Rollup: crea el archivo de hoy si no existe, mueve viejos a su semana
    run_rollup()

    now      = datetime.now()
    today    = now.strftime('%Y-%m-%d')
    time_str = now.strftime('%H:%M')
    ts       = now.strftime('%Y-%m-%dT%H:%M:%S')
    sid      = session_id[:8] if session_id != 'unknown' else 'unknown'

    # Entrada en formato de plantilla: ### HH:MM - hash - Claude Code
    lines = [f'\n### {time_str} - {sid} - Claude Code\n']
    lines.append(f'\n**cwd:** `{cwd}`\n')

    if user_messages:
        lines.append('\n**Solicitudes:**\n')
        for msg in user_messages:
            lines.append(f'- {msg}\n')

    if files_modified:
        lines.append('\n**Archivos:**\n')
        for fp in files_modified[:30]:
            lines.append(f'- `{fp}`\n')

    entry = ''.join(lines)

    journal_file = JOURNAL / f'{today}.md'

    if journal_file.exists():
        text = journal_file.read_text()
        # Actualizar updated_at en frontmatter
        text = RE_UPDATED.sub(rf'\g<1>{ts}', text, count=1)
        journal_file.write_text(text + entry)
    else:
        # Rollup debería haberlo creado; fallback mínimo
        journal_file.write_text(
            f'# {today}\n\n## Details\n<!-- one for each entry -->\n{entry}'
        )

    # Git commit — solo journal/, identidad GLaDOS
    hostname = subprocess.run(
        ['hostname', '-s'], capture_output=True, text=True, timeout=5,
    ).stdout.strip() or 'local'

    subprocess.run(['git', 'add', 'journal/'], cwd=str(VAULT), capture_output=True, timeout=10)
    subprocess.run(
        [
            'git', '-c', 'user.name=GLaDOS',
            '-c', f'user.email=GLaDOS@{hostname}',
            'commit', '-m', f'journal: auto-save {today} {time_str}',
        ],
        cwd=str(VAULT), capture_output=True, timeout=10,
    )


if __name__ == '__main__':
    try:
        main()
    except Exception:
        pass  # hooks nunca deben romper el flujo de Claude
