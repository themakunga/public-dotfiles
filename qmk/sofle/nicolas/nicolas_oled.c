#include "nicolas_oled.h"
#include "transactions.h"
#include "bongo/bongo_cat.h"
#include <string.h>

// Physical 128x32 OLED, landscape, default QMK 6x8 font.
// Three recent key labels are transient display state, not a persistent log.
typedef struct {
    uint8_t layer, mods, frame;
    char keys[3][6];
} display_state_t;
static display_state_t state;
static uint32_t last_press, last_attempt;
static bool typing;
static uint8_t stroke;
_Static_assert(sizeof(display_state_t) <= 32, "Split RPC payload too large");

static void label(uint16_t keycode, char out[6]) {
    memset(out, 0, 6);
    // Resolve common shifted US aliases before decoding their base keycodes.
    switch (keycode) {
        case KC_EXLM: strcpy(out, "!"); return;
        case KC_AT: strcpy(out, "@"); return;
        case KC_HASH: strcpy(out, "#"); return;
        case KC_DLR: strcpy(out, "$"); return;
        case KC_PERC: strcpy(out, "%"); return;
        case KC_CIRC: strcpy(out, "^"); return;
        case KC_AMPR: strcpy(out, "&"); return;
        case KC_ASTR: strcpy(out, "*"); return;
        case KC_LPRN: strcpy(out, "("); return;
        case KC_RPRN: strcpy(out, ")"); return;
        case KC_TILD: strcpy(out, "~"); return;
        case KC_LCBR: strcpy(out, "{"); return;
        case KC_RCBR: strcpy(out, "}"); return;
        case KC_UNDS: strcpy(out, "_"); return;
        case KC_PLUS: strcpy(out, "+"); return;
        case KC_PIPE: strcpy(out, "|"); return;
        case KC_COLN: strcpy(out, ":"); return;
        case KC_DQUO: strcpy(out, "\""); return;
        case KC_LABK: strcpy(out, "<"); return;
        case KC_RABK: strcpy(out, ">"); return;
        case KC_QUES: strcpy(out, "?"); return;
    }
    if (keycode >= KC_A && keycode <= KC_Z) {
        out[0] = 'A' + keycode - KC_A;
        return;
    }
    if (keycode >= KC_1 && keycode <= KC_0) {
        out[0] = "1234567890"[keycode - KC_1];
        return;
    }
    if (keycode >= KC_F1 && keycode <= KC_F12) {
        uint8_t number = keycode - KC_F1 + 1;
        out[0] = 'F';
        out[1] = number < 10 ? '0' + number : '1';
        if (number >= 10) out[2] = '0' + number % 10;
        return;
    }
    switch (keycode) {
        case KC_ESC: strcpy(out, "Esc"); break;
        case KC_TAB: strcpy(out, "Tab"); break;
        case KC_ENT: strcpy(out, "Enter"); break;
        case KC_SPC: strcpy(out, "Space"); break;
        case KC_BSPC: strcpy(out, "Bksp"); break;
        case KC_DEL: strcpy(out, "Del"); break;
        case KC_HOME: strcpy(out, "Home"); break;
        case KC_END: strcpy(out, "End"); break;
        case KC_PGUP: strcpy(out, "PgUp"); break;
        case KC_PGDN: strcpy(out, "PgDn"); break;
        case KC_LEFT: strcpy(out, "Left"); break;
        case KC_RGHT: strcpy(out, "Right"); break;
        case KC_UP: strcpy(out, "Up"); break;
        case KC_DOWN: strcpy(out, "Down"); break;
        case KC_LCTL: case KC_RCTL: strcpy(out, "Ctrl"); break;
        case KC_LSFT: case KC_RSFT: strcpy(out, "Shift"); break;
        case KC_LALT: case KC_RALT: strcpy(out, "Opt"); break;
        case KC_LGUI: case KC_RGUI: strcpy(out, "Super"); break;
        case KC_MINS: strcpy(out, "-"); break;
        case KC_EQL: strcpy(out, "="); break;
        case KC_LBRC: strcpy(out, "["); break;
        case KC_RBRC: strcpy(out, "]"); break;
        case KC_BSLS: strcpy(out, "\\"); break;
        case KC_SCLN: strcpy(out, ";"); break;
        case KC_QUOT: strcpy(out, "'"); break;
        case KC_GRV: strcpy(out, "`"); break;
        case KC_COMM: strcpy(out, ","); break;
        case KC_DOT: strcpy(out, "."); break;
        case KC_SLSH: strcpy(out, "/"); break;
        case KC_MPRV: strcpy(out, "Prev"); break;
        case KC_MPLY: strcpy(out, "Play"); break;
        case KC_MNXT: strcpy(out, "Next"); break;
        case KC_MSTP: strcpy(out, "Stop"); break;
        case KC_MUTE: strcpy(out, "Mute"); break;
        case KC_VOLD: strcpy(out, "Vol-"); break;
        case KC_VOLU: strcpy(out, "Vol+"); break;
        case MS_LEFT: strcpy(out, "MsL"); break;
        case MS_RGHT: strcpy(out, "MsR"); break;
        case MS_UP: strcpy(out, "MsUp"); break;
        case MS_DOWN: strcpy(out, "MsDn"); break;
        case MS_BTN1: strcpy(out, "Click"); break;
        case MS_BTN2: strcpy(out, "RClk"); break;
        case RM_TOGG: strcpy(out, "LED"); break;
        case RM_PREV: strcpy(out, "FX-"); break;
        case RM_NEXT: strcpy(out, "FX+"); break;
        case RM_VALD: strcpy(out, "Bri-"); break;
        case RM_VALU: strcpy(out, "Bri+"); break;
        case RM_HUED: strcpy(out, "Hue-"); break;
        case RM_HUEU: strcpy(out, "Hue+"); break;
        case MO(1): strcpy(out, "L2"); break;
        case MO(2): strcpy(out, "L3"); break;
        default: {
            // Custom keycodes still have an unambiguous visible identity.
            const char hex[] = "0123456789ABCDEF";
            out[0] = '#';
            for (uint8_t i = 0; i < 4; ++i) out[i + 1] = hex[(keycode >> (12 - 4 * i)) & 15];
        }
    }
}

static void receive_state(uint8_t size, const void *data, uint8_t out_size, void *out) {
    (void)out_size;
    (void)out;
    if (size != sizeof(state)) return;
    memcpy(&state, data, sizeof(state));
    for (uint8_t i = 0; i < 3; ++i) state.keys[i][5] = '\0';
}

void nicolas_oled_init(void) {
    transaction_register_rpc(EVA_OLED_SYNC, receive_state);
}

void nicolas_oled_record(uint16_t keycode, keyrecord_t *record) {
    if (!is_keyboard_master() || !record->event.pressed) return;
    memmove(state.keys[1], state.keys[0], 2 * sizeof(state.keys[0]));
    label(keycode, state.keys[0]);
    last_press = timer_read32();
    typing = true;
    stroke ^= 1;
}

void nicolas_oled_housekeeping(void) {
    if (!is_keyboard_master()) return;
    state.layer = get_highest_layer(layer_state | default_layer_state);
    state.mods = get_mods() | get_weak_mods();
#ifndef NO_ACTION_ONESHOT
    state.mods |= get_oneshot_mods();
#endif
    if (typing && timer_elapsed32(last_press) >= 220) typing = false;
    state.frame = typing ? 1 + stroke : 0;
    // Throttle failures too, so a disconnected half cannot stall every scan.
    if (timer_elapsed32(last_attempt) >= 50) {
        last_attempt = timer_read32();
        transaction_rpc_send(EVA_OLED_SYNC, sizeof(state), &state);
    }
}

static void text_at(uint8_t col, uint8_t row, const char *text, bool inverted) {
    oled_set_cursor(col, row);
    oled_write(text, inverted);
}

bool nicolas_oled_render(void) {
    if (is_keyboard_left()) return false;
    render_bongo_cat(state.frame);
    // Clear left zone (x=0..46) and right zone (x=96..127); x=47 reserved for separator.
    for (uint8_t y = 0; y < 32; ++y) {
        for (uint8_t x = 0;  x < 47;  ++x) oled_write_pixel(x, y, false);
        for (uint8_t x = 96; x < 128; ++x) oled_write_pixel(x, y, false);
    }
    // Row 0: layer name as inverted title bar (full left zone width = 8 chars)
    const char *name = state.layer == 0 ? " BASE   " :
                       state.layer == 1 ? " SYMBOL " : "   FN   ";
    text_at(0, 0, name, true);
    // Rows 1-2: modifier blocks — inverted when active, 3-char labels at cols 0-2 and 4-6
    // (stops at col 6 so x=47 is never overwritten by inactive text)
    text_at(0, 1, "CMD", state.mods & MOD_MASK_GUI);
    text_at(4, 1, "CTL", state.mods & MOD_MASK_CTRL);
    text_at(0, 2, "OPT", state.mods & MOD_MASK_ALT);
    text_at(4, 2, "SFT", state.mods & MOD_MASK_SHIFT);
    // Right zone: last 3 keys, rows 0-2 (header removed — keys speak for themselves)
    for (uint8_t i = 0; i < 3; ++i) text_at(16, i, state.keys[i], false);
    // Separator drawn last so it overrides any pixel at x=47
    for (uint8_t y = 0; y < 32; ++y) oled_write_pixel(47, y, true);
    return false;
}
