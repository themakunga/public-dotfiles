#!/usr/bin/env python3
import json, sys, subprocess, datetime, os

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
path = data.get("tool_input", {}).get("file_path", "")

vault = os.path.expanduser("~/.vaults/agent-wiki")
if tool in ("Write", "Edit", "NotebookEdit") and os.path.abspath(path).startswith(vault):
    ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    subprocess.run(["git", "-C", vault, "add", "-A"], capture_output=True)
    subprocess.run(["git", "-C", vault, "commit", "-m", f"vault: {ts}"], capture_output=True)
