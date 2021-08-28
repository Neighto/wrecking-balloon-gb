INCLUDE "hardware.inc"

SECTION "interrupts", ROM0

VBlank_Interrupt::
    ret

LCD_Interrupt::
	; ld a, [rLYC]
	; cp a, 50
	; jr nz, .end
	; ld a, 140
	; ld [rLYC], a
	; ld a, [rSCX]
	; dec a
	; ldh [rSCX], a
	; reti
; .end:
	; ld a, 50
	; ld [rLYC], a
	ld a, [rSCX]
	inc a
	ldh [rSCX], a
    ret