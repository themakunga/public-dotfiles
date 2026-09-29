#!/usr/bin/env python3
"""Render WeeChat's private config from Halloy without connecting to IRC."""
import os
from pathlib import Path
import re
import sys
import tempfile
import tomllib


def quote(value):
    value = str(value)
    if any(c in value for c in '\r\n\x00"'):
        raise ValueError('Unsupported control character or quote in IRC setting')
    return f'"{value}"'


def render(halloy):
    lines = ['config_version = 2', '', '[look]', 'server_buffer = independent',
             'color_nicks_in_nicklist = on', 'nick_mode = prefix', '', '[ignore]']
    for name, server in halloy['servers'].items():
        if not re.fullmatch(r'[A-Za-z0-9_-]+', name):
            raise ValueError('Invalid server name')
        for nick in server.get('filters', {}).get('ignore', []):
            if any(c in nick for c in ';\r\n'):
                raise ValueError('Invalid ignore nickname')
            lines.append(f'ignore = {name};*;^{re.escape(nick)}$')
    lines += ['', '[server_default]', 'autoconnect = on', '', '[server]']
    for name, server in halloy['servers'].items():
        settings = {
            'addresses': f"{server['server']}/{server.get('port', 6697 if server.get('use_tls', True) else 6667)}",
            'nicks': server['nickname'],
            'username': server.get('username', server['nickname'].split('/')[0]),
            'realname': server.get('realname', server['nickname']),
            'password': server.get('password', ''),
            'autojoin': ','.join(server.get('channels', [])),
            'usermode': server.get('umodes', ''),
            'notify': ','.join(server.get('monitor', [])),
            'command': ';'.join(server.get('on_connect', [])),
        }
        lines.append(f"{name}.tls = {'on' if server.get('use_tls', True) else 'off'}")
        lines += [f'{name}.{key} = {quote(value)}' for key, value in settings.items()]
    return '\n'.join(lines) + '\n'


def write_private(path, content):
    # Atomic replacement also replaces old symlinks without writing into the repo.
    fd, temporary = tempfile.mkstemp(dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(content)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def main():
    source, destination = map(Path, sys.argv[1:])
    halloy = tomllib.loads(source.read_text())
    irc = render(halloy)
    ui = Path(__file__).with_name('weechat.conf').read_text()
    words = [word for match in halloy.get('highlights', {}).get('match', [])
             for word in match.get('words', [])]
    ui = ui.replace('highlight = ""', f'highlight = {quote(",".join(words))}', 1)
    filters = []
    for event, rule in halloy.get('buffer', {}).get('server_messages', {}).items():
        if event not in ('join', 'part', 'quit'):
            continue
        buffers = [f'irc.*.{channel}' for channel in rule.get('exclude', [])]
        buffers += [f'!irc.*.{channel}' for channel in rule.get('include', [])]
        if buffers:
            filters.append(f'halloy_{event} = on;{",".join(buffers)};irc_{event};*')
    ui = ui.replace('[filter]\n', '[filter]\n' + '\n'.join(filters) + '\n', 1)
    destination.mkdir(parents=True, exist_ok=True)
    write_private(destination / 'irc.conf', irc)
    write_private(destination / 'weechat.conf', ui)
    scripts = destination / 'python'
    scripts.mkdir(parents=True, exist_ok=True)
    write_private(scripts / 'unread.py', Path(__file__).with_name('python').joinpath('unread.py').read_text())


if __name__ == '__main__':
    main()
