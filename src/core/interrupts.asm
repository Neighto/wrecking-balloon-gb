INCLUDE "hardware.inc"

SECTION "interrupts", ROM0

VBlank_Interrupt::
    ret

LCD_Interrupt::
	ld a, [rLYC]
	cp a, 0
    jr z, .clouds
    CP a, 72
    jr z, .ground
    cp a, 136
    jr z, .hideSpritesOnWindow
    cp a, 144
    jr z, .showSprites

    
; .classic:

.showSprites:
    ; AT LINE 144
    ld a, 0
    ldh [rLYC], a
    ld hl, rLCDC
    set 1, [hl]
    ret
.hideSpritesOnWindow:
    ; AT LINE 136
    ld a, 144
    ldh [rLYC], a
    ld hl, rLCDC
    res 1, [hl]
    ret

; .cutscene:

.clouds:
    ; AT LINE 0
    ld a, 72
	ldh [rLYC], a
    ld a, [rSCX]
    ld hl, scroll_offset
    add a, [hl]
	ldh [rSCX], a
    ret
.ground:
    ; AT LINE 72
    ld a, 136
    ldh [rLYC], a
    xor a ; ld a, 0
	ldh [rSCX], a
    ret