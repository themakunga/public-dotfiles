"""Cycle through unread buffers in buffer order, like Halloy's Shift+arrows."""
import weechat


def target(numbers, current, backwards):
    ordered = sorted(numbers, reverse=backwards)
    return next((n for n in ordered if (n < current if backwards else n > current)),
                ordered[0] if ordered else None)


def unread_cb(data, buffer, args):
    hotlist = weechat.infolist_get('hotlist', '', '')
    numbers = []
    try:
        while weechat.infolist_next(hotlist):
            if weechat.infolist_integer(hotlist, 'priority') >= 1:
                numbers.append(weechat.infolist_integer(hotlist, 'buffer_number'))
    finally:
        weechat.infolist_free(hotlist)
    number = target(numbers, weechat.buffer_get_integer(buffer, 'number'), args == 'previous')
    if number is not None:
        weechat.command(buffer, f'/buffer {number}')
    return weechat.WEECHAT_RC_OK


if weechat.register('unread', 'nicolas', '1.0', 'MIT', 'Cycle unread buffers', '', ''):
    weechat.hook_command('unread', 'Cycle unread buffers', 'next|previous', '',
                         'next|previous', 'unread_cb', '')
