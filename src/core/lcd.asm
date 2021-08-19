INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "lcd", ROMX

LCD_OFF::
    ld a, 0
    ld [rLCDC], a
    ret

LCD_ON::
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
    ld [rLCDC], a
    ret

LCD_ON_BG_ONLY::
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    ret

; Wait for the display to finish updating
WaitVBlank::
    ld hl, rLCDC
.loop:
    ld a, [rLY]
    cp a, 136
    jr c, .skipSpriteReset
    res 1, [hl]
.skipSpriteReset:
    cp a, 144
    jr c, .skipSpriteSet
    set 1, [hl]
.skipSpriteSet:
    jr nz, .loop
    ret

    ; MOVE ME
ResetInRange::
    ; argument hl is starting address
    ; argument bc is distance
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, ResetInRange
    ret

ClearAllTiles::
    ld hl, _VRAM8000
    ld bc, _VRAM8800 - _VRAM8000
    call ResetInRange
    ld hl, _VRAM8800
    ld bc, _VRAM9000 - _VRAM8800
    call ResetInRange
    ld hl, _VRAM9000
    ld bc, _SCRN0 - _VRAM9000
    call ResetInRange
    ret

ClearMap::
    ld hl, _SCRN0
    ld bc, $400
    push hl
.clear_map_loop
    ;wait for hblank
    ld  hl, rSTAT
    bit 1, [hl]
    jr nz, .clear_map_loop
    pop hl
    xor a ; ld a, 0
    ld [hli], a
    push hl
    dec bc
    ld a, b
    or c
    jr nz, .clear_map_loop
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
    push af
    ld a, [global_timer]
    and	BACKGROUND_HSCROLL_SPEED
    jr nz, .end
    ldh a, [rSCX]
    add 1
    ldh  [rSCX], a
.end:
    pop af
    ret