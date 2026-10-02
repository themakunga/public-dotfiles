#include QMK_KEYBOARD_H
#include "nicolas_oled.h"

enum tap_dance_actions { TD_SPC_ENT };
tap_dance_action_t tap_dance_actions[] = {
    [TD_SPC_ENT] = ACTION_TAP_DANCE_DOUBLE(KC_SPC, KC_ENT),
};

// Shift + pulgar derecho → Enter (sin activar el tap dance)
const key_override_t sft_td_ent   = ko_make_basic(MOD_MASK_SHIFT, TD(TD_SPC_ENT), KC_ENT);
const key_override_t *key_overrides[] = {&sft_td_ent, NULL};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT(
        KC_ESC,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_BSPC,
        KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSLS,
        KC_LCTL, KC_A,    KC_S,    KC_D,    KC_F,    KC_G,    KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_QUOT,
        KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    MS_BTN1, MS_BTN2, KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_RSFT,
        KC_LCTL, KC_LALT, KC_LGUI, MO(1),   KC_SPC,  TD(TD_SPC_ENT),  MO(2),   KC_LEFT, KC_DOWN, KC_RGHT
    ),
    [1] = LAYOUT(
        KC_GRV,  KC_EXLM, KC_AT,   KC_HASH, KC_DLR,  KC_PERC, KC_CIRC, KC_AMPR, KC_ASTR, KC_LPRN, KC_RPRN, KC_DEL,
        KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TILD, KC_LBRC, KC_RBRC, KC_MINS, KC_EQL,  KC_PIPE,
        KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_LCBR, KC_RCBR, KC_UNDS, KC_PLUS, KC_COLN, KC_DQUO,
        KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_MUTE, KC_HOME, KC_TRNS, KC_TRNS, KC_LABK, KC_RABK, KC_QUES, KC_TRNS,
        KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_ENT,  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS
    ),
    [2] = LAYOUT(
        KC_F11,  KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F12,
        KC_TRNS, KC_MPRV, KC_MPLY, KC_MNXT, KC_MUTE, KC_MSTP, KC_HOME, KC_PGDN, KC_PGUP, KC_END,  KC_DEL,  KC_TRNS,
        KC_TRNS, KC_VOLD, KC_VOLU, RM_VALD, RM_VALU, RM_TOGG, KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_TRNS, KC_TRNS,
        KC_TRNS, RM_PREV, RM_NEXT, RM_HUED, RM_HUEU, KC_TRNS, KC_MUTE, G(C(KC_Q)), KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
        KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_ENT,  KC_TRNS, KC_TRNS, KC_TRNS, KC_UP,   KC_TRNS
    ),
};

const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    // L0: izq = Shift+↑/↓  |  der = Shift+←/→
    [0] = {ENCODER_CCW_CW(S(KC_UP),   S(KC_DOWN)), ENCODER_CCW_CW(S(KC_LEFT), S(KC_RGHT))},
    // L1 (símbolos): igual pero Alt
    [1] = {ENCODER_CCW_CW(A(KC_UP),   A(KC_DOWN)), ENCODER_CCW_CW(A(KC_LEFT), A(KC_RGHT))},
    // L2 (media): izq = volumen  |  der = brillo pantalla
    [2] = {ENCODER_CCW_CW(KC_VOLD,    KC_VOLU),    ENCODER_CCW_CW(KC_BRMD,    KC_BRMU)},
};

void keyboard_post_init_user(void) { nicolas_oled_init(); }

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    nicolas_oled_record(keycode, record);
    // En L1 y L2, ↓ → ↑ (no interfiere con nvim en base)
    if (keycode == KC_DOWN && (IS_LAYER_ON(1) || IS_LAYER_ON(2))) {
        if (record->event.pressed) register_code(KC_UP);
        else                       unregister_code(KC_UP);
        return false;
    }
    return true;
}

void housekeeping_task_user(void) { nicolas_oled_housekeeping(); }
oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    (void)rotation;
    return OLED_ROTATION_0;
}
bool oled_task_user(void) {
    if (is_keyboard_left()) {
        oled_set_cursor(0, 0);
        oled_write_ln_P(PSTR("SOFLE / EVA-01"), false);
        oled_write_ln_P(PSTR("L2: symbols"), false);
        oled_write_ln_P(PSTR("L3: media + RGB"), false);
        return false;
    }
    return nicolas_oled_render();
}
