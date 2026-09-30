#!/usr/bin/env python3
# keyshow — muestra keypresses globales en un pane de tmux
import sys
import signal
from pynput import keyboard

KEY_LABELS = {
    keyboard.Key.cmd:       "⌘",
    keyboard.Key.ctrl:      "⌃",
    keyboard.Key.alt:       "⌥",
    keyboard.Key.shift:     "⇧",
    keyboard.Key.enter:     "↵",
    keyboard.Key.tab:       "⇥",
    keyboard.Key.backspace: "⌫",
    keyboard.Key.delete:    "⌦",
    keyboard.Key.esc:       "⎋",
    keyboard.Key.space:     "Space",
    keyboard.Key.up:        "↑",
    keyboard.Key.down:      "↓",
    keyboard.Key.left:      "←",
    keyboard.Key.right:     "→",
    keyboard.Key.caps_lock: "⇪",
}

modifiers = set()
MOD_KEYS = {keyboard.Key.cmd, keyboard.Key.ctrl, keyboard.Key.alt, keyboard.Key.shift,
            keyboard.Key.cmd_r, keyboard.Key.ctrl_r, keyboard.Key.alt_r, keyboard.Key.shift_r}

signal.signal(signal.SIGINT, lambda *_: sys.exit(0))

def label(key):
    if key in KEY_LABELS:
        return KEY_LABELS[key]
    # cmd_r / ctrl_r etc.
    base = str(key).replace("Key.", "").replace("_r", "")
    k = getattr(keyboard.Key, base, None)
    return KEY_LABELS[k] if k in KEY_LABELS else base.upper()

def on_press(key):
    canon = getattr(keyboard.Key, str(key).replace("Key.", "").replace("_r", ""), key)
    if canon in MOD_KEYS or key in MOD_KEYS:
        modifiers.add(key)
        return
    parts = []
    if any(k in modifiers for k in (keyboard.Key.ctrl, keyboard.Key.ctrl_r)):   parts.append("⌃")
    if any(k in modifiers for k in (keyboard.Key.alt, keyboard.Key.alt_r)):     parts.append("⌥")
    if any(k in modifiers for k in (keyboard.Key.shift, keyboard.Key.shift_r)): parts.append("⇧")
    if any(k in modifiers for k in (keyboard.Key.cmd, keyboard.Key.cmd_r)):     parts.append("⌘")
    parts.append(label(key) if key in KEY_LABELS else (getattr(key, "char", None) or str(key)))
    print(" ".join(parts), flush=True)

def on_release(key):
    modifiers.discard(key)

with keyboard.Listener(on_press=on_press, on_release=on_release) as l:
    l.join()
