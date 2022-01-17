INCLUDE "hardware.inc"

ENABLE_LCD_SETTINGS_NO_WINDOW EQU LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINOFF ;| LCDCF_BG8000
ENABLE_LCD_SETTINGS EQU LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00

SECTION "lcd", ROMX

; Some naming convention exceptions for function clarity

LCD_OFF::
    push af
    ld a, 0
    ldh [rLCDC], a
    pop af
    ret

LCD_ON::
    push af
    ld a, ENABLE_LCD_SETTINGS
    ldh [rLCDC], a
    pop af
    ret

LCD_ON_NO_WINDOW::
    push af
    ld a, ENABLE_LCD_SETTINGS_NO_WINDOW
    ldh [rLCDC], a
    pop af
    ret

WaitVBlank::
    push af
    push hl
    ei
    ld hl, vblank_flag
    xor a ; ld a, 0
.loop:
    halt 
    nop
    cp a, [hl]
    jr z, .loop
    ld [hl], a
    di
    pop hl
    pop af
    ret

SetupWindow::
    push af
    ld a, 128
	ld [rWY], a
	ld a, 7
	ld [rWX], a
    pop af
    ret