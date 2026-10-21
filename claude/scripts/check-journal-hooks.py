import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

SCRIPT_DIR = Path(__file__).resolve().parent
HOOKS = {
    "claude": SCRIPT_DIR / "save-session.py",
    "codex": SCRIPT_DIR / "save-codex-session.py",
}
INJECTED = "# AGENTS.md instructions for /tmp/project\n<INSTRUCTIONS>hidden</INSTRUCTIONS>"
REAL = "repair the journal"


def run_hook(kind, hook):
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        writer = root / ".vaults/agent-wiki/scripts/journal_append.py"
        writer.parent.mkdir(parents=True)
        writer.write_text("import os, pathlib, sys\npathlib.Path(os.environ['CAPTURE']).write_text(sys.stdin.read())\n")
        transcript = root / "session.jsonl"
        if kind == "claude":
            entries = [
                {"type": "user", "message": {"content": text}}
                for text in (INJECTED, REAL)
            ]
            payload = {"transcript_path": str(transcript), "session_id": "test", "cwd": str(root)}
        else:
            entries = [
                {"type": "response_item", "payload": {"role": "user", "content": [{"type": "input_text", "text": text}]}}
                for text in (INJECTED, REAL)
            ]
            payload = {"script_path": str(transcript), "session_id": "test", "cwd": str(root)}
        transcript.write_text("".join(json.dumps(entry) + "\n" for entry in entries))
        capture = root / "entry.md"
        result = subprocess.run(
            [sys.executable, str(hook)],
            input=json.dumps(payload),
            text=True,
            capture_output=True,
            env={**os.environ, "HOME": str(root), "CAPTURE": str(capture)},
        )
        assert result.returncode == 0, result.stderr
        output = capture.read_text()
        assert REAL in output
        assert "AGENTS.md instructions" not in output, output


for name, path in HOOKS.items():
    run_hook(name, path)
print("Journal hooks exclude injected AGENTS instructions")
