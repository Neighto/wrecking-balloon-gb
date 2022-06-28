INCLUDE "hardware.inc"

COMMON_LCD_SETTINGS EQU LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_WIN9C00
ENABLE_LCD_SETTINGS_NO_WINDOW EQU COMMON_LCD_SETTINGS | LCDCF_OBJ16 | LCDCF_WINOFF
ENABLE_LCD_SETTINGS_NO_WINDOW_8_SPR_MODE EQU COMMON_LCD_SETTINGS | LCDCF_OBJ8 | LCDCF_WINOFF

ENABLE_LCD_SETTINGS EQU COMMON_LCD_SETTINGS | LCDCF_OBJ16 | LCDCF_WINON

SECTION "lcd", ROMX

; Some naming convention exceptions for function clarity

LCD_OFF::
    ld a, 0
    ldh [rLCDC], a
    ret

LCD_ON::
    ld a, ENABLE_LCD_SETTINGS
    ldh [rLCDC], a
    ret

LCD_ON_NO_WINDOW::
    ld a, ENABLE_LCD_SETTINGS_NO_WINDOW
    ldh [rLCDC], a
    ret

LCD_ON_NO_WINDOW_8_SPR_MODE::
    ld a, ENABLE_LCD_SETTINGS_NO_WINDOW_8_SPR_MODE
    ldh [rLCDC], a
    ret

WaitVBlank::
    ei
    ld hl, wVBlankFlag
    xor a ; ld a, 0
.loop:
    halt 
    nop
    cp a, [hl]
    jr z, .loop
    ld [hl], a
    di
    ret

SetupWindow::
    ld a, 128
	ldh [rWY], a
	ld a, 7
	ldh [rWX], a
    ret