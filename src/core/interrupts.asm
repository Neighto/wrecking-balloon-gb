INCLUDE "hardware.inc"

SECTION "interrupts", ROM0

VBlank_Interrupt::
    ret

LCD_Interrupt::
	ld a, [rLYC]
	or a, 0
    jr z, .clouds
    cp a, 48
    jr z, .farClouds
    jr .ground
.clouds:
    ld a, 48
	ldh [rLYC], a
    ; Scroll Screen
    ld a, [rSCX]
    ld hl, scroll_offset
    add a, [hl]
	ldh [rSCX], a
    ret
.farClouds:
    ld a, 72
	ldh [rLYC], a
    ; Reset Scroll Screen
    xor a ; ld a, 0
	ldh [rSCX], a
    ; Scroll Screen
    ld a, [rSCX]
    ld hl, scroll_offset2
    add a, [hl]
	ldh [rSCX], a
    ret
.ground:
    xor a ; ld a, 0
	ldh [rLYC], a
    ; Reset Scroll Screen
	ldh [rSCX], a
    ret