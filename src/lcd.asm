INCLUDE "hardware.inc"

ENABLE_LCD_SETTINGS EQU LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00

SECTION "lcd", ROMX

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

LCD_ON_BG_ONLY::
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
    ldh [rLCDC], a
    ret

WaitVBlank::
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
    ret

SetupWindow::
    ld a, 128
	ld [rWY], a
	ld a, 7
	ld [rWX], a
    ret