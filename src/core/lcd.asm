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

CLEAR_OAM::
    ld  hl,_OAMRAM
    ld  bc,$A0
.clear_oam_loop
    ld  a,$0
    ld  [hli],a
    dec bc
    ld  a,b
    or  c
    jr  nz,.clear_oam_loop
    ret
  
CLEAR_RAM::
    ld  hl,$C100
    ld  bc,$A0
.clear_ram_loop
    ld  a,$0
    ld  [hli],a
    dec bc
    ld  a,b
    or  c
    jr  nz,.clear_ram_loop
    ret

; CLEAR_TILES::
;     ld hl, $8000
;     ld bc, $9800 - $8000
; .clear_tiles_loop
;     ld a, 0
;     ld [hli], a
;     dec bc
;     ld a, b
;     or c
;     jr  nz, .clear_tiles_loop
;     ret