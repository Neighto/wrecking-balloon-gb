INCLUDE "hardware.inc"

SECTION "lcd", ROMX

LCD_Off::
    ld a, 0
    ld [rLCDC], a
    ret

LCD_On::
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    ret

Wait_VBlank::
    ld a, [rLY]
    cp 144
    jr c, Wait_VBlank
    ret

Clear_BGMap::
    ld HL, $9C00

.clear_Loop
    ld [HL], B
    inc HL
    ld A, H
    cp $9F
    jr nz, .clear_Loop
    ld A, L
    cp $FF
    jr nz, .clear_Loop
    ret