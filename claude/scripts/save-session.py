#!/usr/bin/env python3
"""Claude Code Stop hook — appends a session entry to the obsidian-journal vault."""
import hashlib, json, sys, os, subprocess
from datetime import datetime
from pathlib import Path

VAULT   = Path.home() / '.vaults' / 'journal'
SCRIPTS = Path.home() / 'Projects/personal/skills/obsidian-journal/scripts'
AGENT   = 'Claude Code'


def lua(script, *args, stdin=None):
    cmd = ['lua', str(SCRIPTS / script), *args]
    result = subprocess.run(cmd, input=stdin, text=True, capture_output=True, timeout=60, cwd=SCRIPTS)
    if result.returncode != 0:
        raise RuntimeError(f'{script} failed: {result.stderr.strip()}')
    return result.stdout


def main():
    try:
        ctx = json.loads(sys.stdin.read())
    except Exception:
        ctx = {}

    transcript_path = ctx.get('transcript_path', '')
    cwd             = ctx.get('cwd', os.getcwd())
    session_id      = str(ctx.get('session_id', 'unknown'))

    user_messages  = []
    files_modified = []

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
                    text = (
                        content.strip() if isinstance(content, str)
                        else ' '.join(
                            c.get('text', '') for c in content
                            if isinstance(c, dict) and c.get('type') == 'text'
                        ).strip()
                    )
                    skip = (
                        not text or len(text) <= 3
                        or text.startswith('<')
                        or text.startswith('[SYSTEM')
                        or text.startswith('# AGENTS.md')
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

    if not user_messages and not files_modified:
        return

    now       = datetime.now().astimezone()
    clock     = now.strftime('%H:%M')
    timestamp = now.isoformat(timespec='microseconds')
    shash     = hashlib.sha256(session_id.encode()).hexdigest()[:8]
    host      = subprocess.run(['hostname', '-s'], capture_output=True, text=True, timeout=5).stdout.strip() or 'local'

    work_lines = '\n'.join(f'- {m}' for m in user_messages) if user_messages else '- none'
    file_lines = '\n'.join(f'- `{f}`' for f in files_modified[:30]) if files_modified else '- none'

    entry = (
        f'### {clock} - {shash} - {AGENT} - {host}\n'
        f'<!-- journal-timestamp: {timestamp} -->\n'
        f'\n'
        f'**Work:**\n'
        f'\n'
        f'{work_lines}\n'
        f'\n'
        f'**CWD:** `{cwd}`\n'
        f'\n'
        f'**Files:**\n'
        f'\n'
        f'{file_lines}\n'
        f'\n'
        f'**Verification:**\n'
        f'\n'
        f'Auto-captured by Stop hook; not independently verified.\n'
        f'\n'
        f'**Pending:**\n'
        f'\n'
        f'none\n'
    )

    lua('entry.lua', AGENT, stdin=entry)
    lua('publish.lua', 'entry', 'journal-current.md')


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f'[obsidian-journal] hook failed: {exc}', file=sys.stderr)
