INCLUDE "hardware.inc"

SECTION "interrupts", ROM0

VBlank_Interrupt::
    ret

LCD_Interrupt::
	ld a, [rLYC]
	or a, 0
    jr nz, .ground
.clouds:
    ld a, 56
	ldh [rLYC], a
    ; Scroll Screen
    ld a, [rSCX]
    ld hl, scroll_offset
    add a, [hl]
	ldh [rSCX], a
    ret
.ground:
    xor a ; ld a, 0
	ldh [rLYC], a
    ; ; Reset Scroll Screen
	ldh [rSCX], a
.end:
    ret