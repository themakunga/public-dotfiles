"""
nick_query.py — WeeChat nick navigator
=======================================
Alt+Shift+K  → abrir navegador de nicks del buffer actual
↑ / ↓  → moverse entre nicks (cicla)
Enter  → abrir /query con el nick seleccionado
q      → cerrar sin abrir nada
"""

import weechat

SCRIPT_NAME = "nick_query"
SCRIPT_DESC = "Keyboard nick navigator — Alt+Shift+K to open, arrows to pick, Enter to query"
SCRIPT_VERSION = "1.0"
SCRIPT_AUTHOR = "GLaDOS"
SCRIPT_LICENSE = "MIT"

_s = {}  # state


def _nicks(buf):
    il = weechat.infolist_get("nicklist", buf, "")
    out = []
    while weechat.infolist_next(il):
        if weechat.infolist_string(il, "type") == "nick":
            out.append(weechat.infolist_string(il, "name"))
    weechat.infolist_free(il)
    return sorted(out, key=str.lower)


def _draw(nav):
    weechat.buffer_clear(nav)
    nicks = _s["nicks"]
    sel = _s["sel"]
    hi = weechat.color("reverse")
    rs = weechat.color("reset")
    for i, n in enumerate(nicks):
        weechat.prnt(nav, f"{hi} {n} {rs}" if i == sel else f"   {n}")
    weechat.buffer_set(
        nav,
        "title",
        f"Nicks ({sel + 1}/{len(nicks)})  ↑↓ navegar · Enter abrir query · q cerrar",
    )


def _open_cb(data, buf, args):
    src = weechat.current_buffer()
    nicks = _nicks(src)
    if not nicks:
        weechat.prnt(src, "[nick_query] no hay nicks en este buffer")
        return weechat.WEECHAT_RC_OK

    # cerrar instancia previa si existe
    prev = weechat.buffer_search("python", SCRIPT_NAME)
    if prev:
        weechat.buffer_close(prev)

    _s.update({"src": src, "nicks": nicks, "sel": 0})

    nav = weechat.buffer_new(SCRIPT_NAME, "_input_cb", "", "_close_cb", "")
    weechat.buffer_set(nav, "short_name", "nicks")
    weechat.buffer_set(nav, "localvar_set_no_log", "1")
    # key bindings locales al buffer
    weechat.buffer_set(nav, "key_bind_meta2-A", f"/{SCRIPT_NAME}_nav up")    # ↑
    weechat.buffer_set(nav, "key_bind_meta2-B", f"/{SCRIPT_NAME}_nav down")  # ↓
    weechat.buffer_set(nav, "key_bind_ctrl-m", f"/{SCRIPT_NAME}_nav pick")   # Enter
    weechat.buffer_set(nav, "key_bind_q", f"/{SCRIPT_NAME}_nav quit")        # q

    _s["nav"] = nav
    _draw(nav)
    weechat.buffer_set(nav, "display", "1")
    return weechat.WEECHAT_RC_OK


def _nav_cb(data, buf, args):
    nicks = _s.get("nicks", [])
    if not nicks:
        return weechat.WEECHAT_RC_OK

    nav = _s.get("nav", "")
    n = len(nicks)

    if args == "up":
        _s["sel"] = (_s["sel"] - 1) % n
        _draw(nav)
    elif args == "down":
        _s["sel"] = (_s["sel"] + 1) % n
        _draw(nav)
    elif args == "pick":
        nick = nicks[_s["sel"]]
        if nav:
            weechat.buffer_close(nav)
        weechat.command(_s.get("src", ""), f"/query {nick}")
    elif args == "quit":
        if nav:
            weechat.buffer_close(nav)

    return weechat.WEECHAT_RC_OK


def _input_cb(data, buf, inp):
    return weechat.WEECHAT_RC_OK


def _close_cb(data, buf):
    _s.pop("nav", None)
    return weechat.WEECHAT_RC_OK


if __name__ == "__main__":
    weechat.register(
        SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION, SCRIPT_LICENSE, SCRIPT_DESC, "", ""
    )
    weechat.hook_command(
        SCRIPT_NAME, SCRIPT_DESC, "", "", "", "_open_cb", ""
    )
    weechat.hook_command(
        f"{SCRIPT_NAME}_nav", "control interno del navegador",
        "up|down|pick|quit", "", "", "_nav_cb", ""
    )
    # keybind configurado en weechat.conf: meta-K → /nick_query
    weechat.prnt("", f"[{SCRIPT_NAME}] cargado — Alt+Shift+K para navegar nicks")
