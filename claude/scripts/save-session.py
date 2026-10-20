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


def run_rollup() -> list:
    """Run rollup and return list of actions taken."""
    r = subprocess.run(
        [sys.executable, str(VAULT / 'scripts' / 'journal_rollup.py'), '--run'],
        cwd=str(VAULT), capture_output=True, text=True, timeout=30,
    )
    return [l.strip() for l in r.stdout.splitlines() if l.strip()]


def pending_summary() -> str:
    """Check if any rollup work is still pending after run."""
    r = subprocess.run(
        [sys.executable, str(VAULT / 'scripts' / 'journal_rollup.py')],
        cwd=str(VAULT), capture_output=True, text=True, timeout=10,
    )
    try:
        data = json.loads(r.stdout)
        missing = [k for k, v in data.get('missing', {}).items() if v]
        old = data.get('old_daily_files', [])
        items = missing + [f'stale: {f}' for f in old]
        return ', '.join(items) if items else 'none'
    except Exception:
        return 'unavailable'


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
    rollup_actions = run_rollup()

    now      = datetime.now()
    today    = now.strftime('%Y-%m-%d')
    time_str = now.strftime('%H:%M')
    sid      = session_id[:8] if session_id != 'unknown' else 'unknown'

    hostname = subprocess.run(
        ['hostname', '-s'], capture_output=True, text=True, timeout=5,
    ).stdout.strip() or 'local'

    lines = [f'\n### {time_str} - {sid} - Claude Code - {hostname}\n']

    # Work: resumen de solicitudes como contexto de lo trabajado
    if user_messages:
        lines.append('\n**Work:** Session driven by the following requests:\n')
        for msg in user_messages:
            lines.append(f'- {msg}\n')
    else:
        lines.append(f'\n**Work:** Automated session — no user prompts captured.\n')

    lines.append(f'\n**cwd:** `{cwd}`\n')

    lines.append('\n**Files:**\n')
    if files_modified:
        for fp in files_modified[:30]:
            lines.append(f'- `{fp}`\n')
    else:
        lines.append('- none\n')

    lines.append('\n**Verification:** Auto-captured by Stop hook; content not independently verified.\n')
    lines.append('\n**Tokens:** unavailable (runtime does not expose usage to hooks)\n')

    pending = pending_summary()
    lines.append(f'\n**Pending:** {pending}\n')

    if rollup_actions:
        lines.append('\n**Rollup:**\n')
        for action in rollup_actions:
            lines.append(f'- {action}\n')

    entry = ''.join(lines)

    journal_file = JOURNAL / f'{today}.md'
    subprocess.run(
        [sys.executable, str(VAULT / 'scripts' / 'journal_append.py')],
        input=entry, text=True, check=True, timeout=10,
    )

    if (VAULT / '.git/rebase-merge').exists() or (VAULT / '.git/rebase-apply').exists():
        return

    # Git commit — solo journal/, identidad GLaDOS
    subprocess.run(['git', 'add', str(journal_file)], cwd=str(VAULT), capture_output=True, timeout=10)
    subprocess.run(
        [
            'git', '-c', 'user.name=GLaDOS',
            '-c', f'user.email=GLaDOS@{hostname}',
            'commit', '--only', '-m', f'journal: auto-save {today} {time_str}', '--', str(journal_file),
        ],
        cwd=str(VAULT), capture_output=True, timeout=10,
    )


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f'journal hook failed: {exc}', file=sys.stderr)
