#!/usr/bin/env python3
"""Offline regression check: python3 weechat/check.py."""
import importlib.util
from pathlib import Path
import sys
import types

root = Path(__file__).parent
spec = importlib.util.spec_from_file_location('sync', root / 'sync-halloy.py')
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)
config = sync.render({'servers': {'example': {
    'server': 'localhost', 'port': 6501, 'use_tls': False,
    'nickname': 'user/network', 'password': 'secret',
    'monitor': ['friend'], 'filters': {'ignore': ['bad.nick']},
    'channels': ['#test'], 'on_connect': ['/part #other'],
}}})
for expected in ['example.tls = off', 'example.notify = "friend"',
                 'ignore = example;*;^bad\\.nick$', 'example.password = "secret"',
                 'example.autojoin = "#test"', 'example.username = "user"']:
    assert expected in config, expected
assert 'example.tls = on' in sync.render({'servers': {'example': {'server': 'localhost', 'nickname': 'me'}}})
try:
    sync.quote('bad\nsetting')
except ValueError:
    pass
else:
    raise AssertionError('Config injection accepted')
sys.modules['weechat'] = types.SimpleNamespace(register=lambda *args: False)
spec = importlib.util.spec_from_file_location('unread', root / 'python/unread.py')
unread = importlib.util.module_from_spec(spec)
spec.loader.exec_module(unread)
assert unread.target([2, 5, 8], 5, False) == 8
assert unread.target([2, 5, 8], 5, True) == 2
assert unread.target([2, 5, 8], 8, False) == 2
assert unread.target([2, 5, 8], 2, True) == 8
assert unread.target([], 1, False) is None
print('IRC translation and unread navigation: OK')
