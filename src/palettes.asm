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
	; Return a for has faded (0 = false, 1 = true)
	ld a, [rBGP]
	cp a, FADE_PALETTE_4
	jr nz, .fadeOut
.hasFadedOut:
	ld a, 1
	ret
.fadeOut:
	ld a, [global_timer]
	and FADE_SPEED
	jr nz, .end
	ld a, [wFadeFrame]
	cp a, 0
	jr z, .fade1
	cp a, 1
	jr z, .fade2
	cp a, 2
	jr z, .fade3
	cp a, 3
	jr z, .fade4
	jr .end
.fade1:
    ld a, FADE_PALETTE_1
	jr .fadePalettes
.fade2:
	ld a, FADE_PALETTE_2
	jr .fadePalettes
.fade3:
	ld a, FADE_PALETTE_3
	jr .fadePalettes
.fade4:
	ld a, FADE_PALETTE_4
.fadePalettes:
	ldh [rBGP], a
    ldh [rOCPD], a
	ldh [rOBP1], a
	ldh [rOBP0], a
	ld a, [wFadeFrame]
	inc a
	ld [wFadeFrame], a
.end:
	xor a ; ld a, 0
	ret

FadeInPalettes::
	; Return a for has faded (0 = false, 1 = true)
	ld a, [rBGP]
	cp a, FADE_PALETTE_1
	jr nz, .fadeIn
.hasFadedIn:
	ld a, 1
	ret
.fadeIn:
	ld a, [global_timer]
	and FADE_SPEED
	jr nz, .end
	ld a, [wFadeFrame]
	cp a, 4
	jr z, .fade1
	cp a, 3
	jr z, .fade2
	cp a, 2
	jr z, .fade3
	cp a, 1
	jr z, .fade4
	jr .end
.fade1:
    ld a, FADE_PALETTE_4
	jr .fadePalettes
.fade2:
	ld a, FADE_PALETTE_3
	jr .fadePalettes
.fade3:
	ld a, FADE_PALETTE_2
	jr .fadePalettes
.fade4:
	ld a, FADE_PALETTE_1
.fadePalettes:
	ldh [rBGP], a
    ldh [rOCPD], a
	ldh [rOBP1], a
	ldh [rOBP0], a
	ld a, [wFadeFrame]
	dec a
	ld [wFadeFrame], a
.end:
	xor a ; ld a, 0
	ret