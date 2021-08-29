INCLUDE "hardware.inc"

SECTION "interrupts", ROM0

VBlank_Interrupt::
    ret

LCD_Interrupt::
	ld a, [rLYC]
	cp a, 0
    jr z, .clouds
    cp a, 72
    jr z, .ground
    ret
.clouds:
    ld a, 72
	ld [rLYC], a
    ld a, [rSCX]
    ld hl, scroll_speed
    add a, [hl]
	ldh [rSCX], a
    ret
.ground:
    ld a, 0
	ld [rLYC], a
    xor a
	ldh [rSCX], a
    ret