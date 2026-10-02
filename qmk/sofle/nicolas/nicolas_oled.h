#pragma once
#include QMK_KEYBOARD_H

void nicolas_oled_init(void);
void nicolas_oled_record(uint16_t keycode, keyrecord_t *record);
void nicolas_oled_housekeeping(void);
bool nicolas_oled_render(void);
