#!/usr/bin/env python3
"""Exercise the real terminal startup commands without opening GUI windows."""

import os
from pathlib import Path
import shlex
import subprocess
import tempfile

config = Path(__file__).with_name("conf") / "autostart.conf"
commands = []
for line in config.read_text().splitlines():
    if line.startswith("exec-once = [workspace ") and "wezterm" in line:
        rule, command = line.removeprefix("exec-once = ").split("] ", 1)
        commands.append((rule + "]", command))

with tempfile.TemporaryDirectory(prefix="hypr startup ") as temporary:
    directory = Path(temporary)
    wezterm = directory / "wezterm"
    wezterm.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$STARTUP_LOG"\n')
    wezterm.chmod(0o755)
    log = directory / "calls"
    for user in ("wheatley", "nicolas"):
        selected = []
        env = dict(os.environ, USER=user, STARTUP_LOG=str(log))
        env["PATH"] = str(directory) + os.pathsep + env["PATH"]
        for rule, command in commands:
            log.write_text("")
            result = subprocess.run(shlex.split(command), env=env, capture_output=True)
            assert result.returncode == 0 and not result.stderr, result.stderr
            selected.extend((rule, call) for call in log.read_text().splitlines())
        if user == "wheatley":
            assert selected == [(
                "[workspace 1; fullscreen on]",
                "start --always-new-process -- tmux new-session -A -s main",
            )], selected
        else:
            assert selected == [
                ("[workspace 1 silent]", ""),
                ("[workspace 1 silent]", ""),
                ("[workspace 2 silent]", ""),
            ], selected
        print(f"{user}: terminal count, workspace, fullscreen and command OK")
