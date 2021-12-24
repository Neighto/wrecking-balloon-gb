INCLUDE "hardware.inc"
INCLUDE "constants.inc"

FADE_SPEED EQU %00000011
FADE_PALETTE_1 EQU %11100100
FADE_PALETTE_2 EQU %10000100
FADE_PALETTE_3 EQU %01000000
FADE_PALETTE_4 EQU %00000000

SECTION "palettes", ROMX

SetupPalettes::
	push af
    ld a, MAIN_PALETTE
	ldh [rBGP], a
    ldh [rOCPD], a
	ldh [rOBP1], a
	ldh [rOBP0], a
	ld a, MAIN_PALETTE2
	ldh [rOBP1], a
	pop af
    ret

SetupParkPalettes::
	push af
	ld a, MAIN_PALETTE
    ldh [rBGP], a
    ldh [rOCPD], a
	ldh [rOBP0], a
	ld a, MAIN_PALETTE2
	ldh [rOBP1], a
	pop af
    ret

FadeOutPalettes::
	ld a, [global_timer]
	and FADE_SPEED
	jr z, .fadeOut
	ret
.fadeOut:
	ld a, [fade_frame]
	cp a, 0
	jr z, .fade1
	cp a, 1
	jr z, .fade2
	cp a, 2
	jr z, .fade3
	cp a, 3
	jr z, .fade4
	ret
.fade1:
    ld a, FADE_PALETTE_1
	jr .end
.fade2:
	ld a, FADE_PALETTE_2
	jr .end
.fade3:
	ld a, FADE_PALETTE_3
	jr .end
.fade4:
	ld a, FADE_PALETTE_4
.end:
	ldh [rBGP], a
    ldh [rOCPD], a
	ldh [rOBP1], a
	ldh [rOBP0], a
	ld a, [fade_frame]
	inc a
	ld [fade_frame], a
	ret

FadeInPalettes::
	ld a, [global_timer]
	and FADE_SPEED
	jr z, .fadeIn
	ret
.fadeIn:
	ld a, [fade_frame]
	cp a, 0
	jr z, .fade1
	cp a, 1
	jr z, .fade2
	cp a, 2
	jr z, .fade3
	cp a, 3
	jr z, .fade4
	ret
.fade1:
    ld a, FADE_PALETTE_4
	jr .end
.fade2:
	ld a, FADE_PALETTE_3
	jr .end
.fade3:
	ld a, FADE_PALETTE_2
	jr .end
.fade4:
	ld a, FADE_PALETTE_1
.end:
	ldh [rBGP], a
    ldh [rOCPD], a
	ldh [rOBP1], a
	ldh [rOBP0], a
	ld a, [fade_frame]
	inc a
	ld [fade_frame], a
	ret

HasFadedOut::
	; => A as 1 or 0
	ld a, [rBGP]
	cp a, FADE_PALETTE_4
	jr z, .true
.false:
	xor a ; ld a, 0
	ret
.true:
	ld a, 1
	ret

HasFadedIn::
	; => A as 1 or 0
	ld a, [rBGP]
	cp a, FADE_PALETTE_1
	jr z, .true
.false:
	xor a ; ld a, 0
	ret
.true:
	ld a, 1
	ret