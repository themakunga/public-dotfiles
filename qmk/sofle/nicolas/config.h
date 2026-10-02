#pragma once

// Standard Sofle RGB with Pro Micro ATmega32U4, USB on the left half.
#define MASTER_LEFT
#define SPLIT_TRANSACTION_IDS_USER EVA_OLED_SYNC
#define OLED_TIMEOUT 60000
#define OLED_UPDATE_INTERVAL 50

// Initial cursor step per encoder detent; tune on the physical keyboard.
#define MOUSEKEY_MOVE_DELTA 16  // ponytail: tune up/down per detent feel
#define ENCODER_MAP_KEY_DELAY 10

#define RGB_MATRIX_MAXIMUM_BRIGHTNESS 100
#define RGB_MATRIX_DEFAULT_VAL 64
#define RGB_MATRIX_DEFAULT_HUE 191
#define RGB_MATRIX_DEFAULT_SAT 255
#define RGB_MATRIX_DEFAULT_MODE RGB_MATRIX_SOLID_COLOR
#define ENABLE_RGB_MATRIX_BREATHING
#define ENABLE_RGB_MATRIX_CYCLE_ALL
#define ENABLE_RGB_MATRIX_CYCLE_LEFT_RIGHT

// This keymap uses dedicated modifiers and momentary layers, not tap-hold.
#define NO_ACTION_TAPPING
#define NO_ACTION_ONESHOT
#define OLED_FONT_H "keyboards/sofle/keymaps/nicolas/font_ascii.c"
#define OLED_FONT_START 32
#define OLED_FONT_END 126
