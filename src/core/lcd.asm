INCLUDE "hardware.inc"

SECTION "lcd", ROMX

LCD_OFF::
    ld a, 0
    ld [rLCDC], a
    ret

LCD_ON::
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
    ld [rLCDC], a
    ret

; Wait for the display to finish updating
WaitVBlank::
    ld a, [rLY]
    cp 144
    jr c, WaitVBlank
    ret

ClearMap::
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

SetupWindow::
    ld a, 136
	ld [rWY], a
	ld a, 7
	ld [rWX], a
    ret

SECTION "scroll", ROM0
VBlankHScroll::
    di ; TODO: might not need this?
    push af
    ld a, [scroll_timer]
    inc	a
    ld [scroll_timer], a
    and	%00001111
    jr nz, .end
    ldh a, [rSCX]
    add 1
    ldh  [rSCX], a
.end:
    pop af
    ei
    reti