INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "lcd", ROMX

LCD_OFF::
    push af
    ld a, 0
    ldh [rLCDC], a
    pop af
    ret

LCD_ON::
    push af
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
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

SECTION "scroll", ROM0

HorizontalScroll::
    push af
    ld a, [global_timer]
    and	BACKGROUND_HSCROLL_SPEED
    jr nz, .end
    ldh a, [rSCX]
    inc a
    ldh [rSCX], a
.end:
    pop af
    ret

ResetScroll::
    xor a ; ld a, 0
    ldh [rSCX], a
    ldh [rSCY], a
    ret