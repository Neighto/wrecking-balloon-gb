INCLUDE "hardware.inc"

SECTION "interrupts", ROM0

VBlank_Interrupt::
    ret

LCD_Interrupt::
	ld a, [rLYC]
	cp a, 0
    jr z, .clouds
    cp a, 56
    jr z, .ground
    ret
.clouds:
    ld a, 56
	ld [rLYC], a
    ; Scroll Screen
    ld a, [rSCX]
    ld hl, scroll_offset
    add a, [hl]
	ldh [rSCX], a
    ret
.ground:
    xor a ; ld a, 0
	ld [rLYC], a
    ; Reset Scroll Screen
	ldh [rSCX], a
    ret