INCLUDE "hardware.inc"

SECTION "lcd", ROMX

LCD_Off::
    ld a, 0
    ld [rLCDC], a
    ret

LCD_On::
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a
    ret

Wait_VBlank::
    ld a, [rLY]
    cp 144
    jr c, Wait_VBlank
    ret

CLEAR_MAP::
    ld hl, _SCRN0
    ld  bc,$400
    push hl

    .clear_map_loop
    ;wait for hblank
    ld  hl, rSTAT
    bit 1, [hl]
    jr  nz, .clear_map_loop
    pop hl
  
    ld  a,$0
    ld  [hli],a
    push hl
    
    dec bc
    ld  a,b
    or  c
    jr  nz, .clear_map_loop
    pop hl
    ret