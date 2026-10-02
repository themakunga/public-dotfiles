"""Host checks for the actual OLED module; requires a C compiler."""
import os
import re
import subprocess
import tempfile
from pathlib import Path

root = Path(__file__).resolve().parent
source = (root / 'nicolas_oled.c').read_text()

keymap = (root / 'keymap.c').read_text()
blocks = re.findall(r'\[([012])\] = LAYOUT\((.*?)\n    \)', keymap, re.S)
assert len(blocks) == 3
presses = [('MS_BTN1', 'MS_BTN2'), ('KC_MUTE', 'KC_HOME'), ('RM_TOGG', 'RM_TOGG')]
for index, body in blocks:
    keys = [key.strip() for key in body.split(',')]
    assert len(keys) == 60
    assert tuple(keys[42:44]) == presses[int(index)]
    if index == '0':
        assert keys[24] == 'KC_LCTL' and keys[36] == 'KC_LSFT' and keys[49] == 'KC_RSFT'
        assert keys[53] == 'MO(1)' and keys[56] == 'MO(2)'
    else:
        assert keys[53] == keys[56] == 'KC_TRNS'
assert re.findall(r'ENCODER_CCW_CW\(([^)]+)\)', keymap) == [
    'MS_LEFT, MS_RGHT', 'MS_UP, MS_DOWN',
    'KC_VOLD, KC_VOLU', 'KC_PGUP, KC_PGDN',
    'RM_PREV, RM_NEXT', 'RM_VALD, RM_VALU',
]
assert 'VIA_ENABLE = no' in (root / 'rules.mk').read_text()

known = {'KC_A': 4, 'KC_Z': 29, 'KC_1': 30, 'KC_0': 39, 'KC_F1': 58, 'KC_F12': 69}
for number, name in enumerate(sorted(set(re.findall(r'\b(?:KC|MS|RM)_\w+', source)) - known.keys()), 256):
    known[name] = number
header = '''
#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#define PROGMEM
#define pgm_read_byte(p) (*(const unsigned char *)(p))
#define MO(n) (0x5000 + (n))
#define EVA_OLED_SYNC 1
#define MOD_MASK_GUI 0x88
#define MOD_MASK_CTRL 0x11
#define MOD_MASK_ALT 0x44
#define MOD_MASK_SHIFT 0x22
typedef struct { struct { bool pressed; } event; } keyrecord_t;
static uint32_t now, layer_state = 1, default_layer_state = 1;
static bool master = true, left = false;
static uint8_t mods, weak_mods;
static bool is_keyboard_master(void) { return master; }
static bool is_keyboard_left(void) { return left; }
static uint32_t timer_read32(void) { return now; }
static uint32_t timer_elapsed32(uint32_t start) { return now - start; }
static uint8_t get_mods(void) { return mods; }
static uint8_t get_weak_mods(void) { return weak_mods; }
static uint8_t get_highest_layer(uint32_t value) {
    uint8_t result = 0;
    while (value >>= 1) ++result;
    return result;
}
static void oled_set_cursor(uint8_t x, uint8_t y);
static void oled_write(const char *text, bool inverted);
static void oled_write_pixel(uint8_t x, uint8_t y, bool on);
static void oled_write_raw_P(const char *data, uint16_t size);
'''
header += '\n'.join(f'#define {name} {value}' for name, value in known.items())
transactions = '''
static unsigned sends;
static void (*receiver)(uint8_t, const void *, uint8_t, void *);
static void transaction_register_rpc(int id, void (*fn)(uint8_t, const void *, uint8_t, void *)) {
    (void)id; receiver = fn;
}
static bool transaction_rpc_send(int id, uint8_t size, const void *data) {
    (void)id; (void)size; (void)data; ++sends; return false;
}
'''
test = r'''
#include <assert.h>
#include <stdio.h>
#include "nicolas_oled.c"
#include "bongo/bongo_cat.c"
static unsigned pixels;
static uint8_t cursor_row, cursor_col;
static char lines[4][22];
static bool inverse[4][22];
static bool canvas[32][128];
static void oled_set_cursor(uint8_t x, uint8_t y) {
    assert(x < 22 && y < 4); cursor_row = y; cursor_col = x;
}
static void oled_write(const char *text, bool inverted) {
    assert(cursor_col + strlen(text) <= 21);
    memcpy(lines[cursor_row] + cursor_col, text, strlen(text));
    for (size_t i = 0; i < strlen(text); ++i) inverse[cursor_row][cursor_col+i] = inverted;
}
static void oled_write_pixel(uint8_t x, uint8_t y, bool on) {
    assert(x < 128 && y < 32); canvas[y][x] = on; ++pixels;
}
static void oled_write_raw_P(const char *data, uint16_t size) {
    assert(cursor_col == 0 && cursor_row == 0 && size == 512);
    for (unsigned y = 0; y < 32; ++y)
        for (unsigned x = 0; x < 128; ++x)
            canvas[y][x] = ((uint8_t)data[y/8*128+x] >> (y%8)) & 1;
    memset(lines, 0, sizeof(lines));
    memset(inverse, 0, sizeof(inverse));
}
int main(void) {
    char name[6];
    label(KC_AT, name); assert(!strcmp(name, "@"));
    label(MS_BTN2, name); assert(!strcmp(name, "RClk"));
    label(RM_NEXT, name); assert(!strcmp(name, "FX+"));
    label(KC_A, name); assert(!strcmp(name, "A"));
    label(KC_0, name); assert(!strcmp(name, "0"));
    label(KC_F12, name); assert(!strcmp(name, "F12"));
    label(0xFFFF, name); assert(!strcmp(name, "#FFFF"));
    nicolas_oled_init(); assert(receiver);
    keyrecord_t event = {.event.pressed = true};
    now = 100; nicolas_oled_record(KC_A, &event);
    nicolas_oled_record(KC_AT, &event);
    nicolas_oled_record(KC_HOME, &event);
    assert(!strcmp(state.keys[0], "Home") && !strcmp(state.keys[2], "A"));
    event.event.pressed = false; nicolas_oled_record(KC_Z, &event);
    assert(!strcmp(state.keys[0], "Home"));
    layer_state = 4; mods = MOD_MASK_CTRL; weak_mods = MOD_MASK_GUI;
    nicolas_oled_housekeeping(); assert(state.layer == 2 && state.frame != 0);
    assert(sends == 1);
    nicolas_oled_housekeeping(); assert(sends == 1);
    now += 50; nicolas_oled_housekeeping(); assert(sends == 2);
    now += 220; nicolas_oled_housekeeping(); assert(state.frame == 0);
    nicolas_oled_render(); assert(pixels && inverse[1][0] && inverse[1][4] && !inverse[2][0]);
    assert(!strncmp(lines[0]+2, "L3", 2));
    unsigned previous = pixels; left = true; nicolas_oled_render(); assert(pixels == previous);
    left = false; master = false; event.event.pressed = true;
    nicolas_oled_record(KC_Z, &event); assert(!strcmp(state.keys[0], "Home"));
    display_state_t packet = {.layer = 1, .frame = 2, .keys = {"B"}};
    receiver(1, &packet, 0, NULL); assert(state.layer == 2);
    receiver(sizeof(packet), &packet, 0, NULL); assert(state.layer == 1);
    nicolas_oled_render(); assert(!strcmp(lines[1]+16, "B"));
    assert(sizeof(waiting_frame) == 512);
    assert(memcmp(animation_frames[0], animation_frames[1], 512));
    const char *frames[] = {waiting_frame, animation_frames[0], animation_frames[1], ready_frame};
    for (uint8_t frame = 0; frame < 4; ++frame) {
        state.frame = frame;
        nicolas_oled_render();
        // All original central sprite pixels survive the status overlays.
        for (unsigned y = 0; y < 32; ++y)
            for (unsigned x = 48; x < 96; ++x)
                assert(canvas[y][x] == (((uint8_t)frames[frame][y/8*128+x] >> (y%8)) & 1));
    }
    puts("OK: labels, history, modifiers, layer, upstream sprite, pixel bounds, RPC, retry throttle");
}
'''
with tempfile.TemporaryDirectory() as directory:
    tmp = Path(directory)
    (tmp / 'mock.h').write_text(header)
    (tmp / 'transactions.h').write_text(transactions)
    (tmp / 'test.c').write_text(test)
    binary = tmp / 'test'
    subprocess.run([os.environ.get('CC', 'cc'), '-std=c11', '-Wall', '-Wextra', '-Werror',
                    '-DNO_ACTION_ONESHOT', '-DQMK_KEYBOARD_H="mock.h"', '-I', str(tmp), '-I', str(root),
                    str(tmp / 'test.c'), '-o', str(binary)], check=True)
    subprocess.run([str(binary)], check=True)
