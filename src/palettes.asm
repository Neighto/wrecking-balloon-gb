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
.fadeOut:
	ld a, [wGlobalTimer]
	and FADE_SPEED
	jr nz, .end
	ld a, [wFadeOutFrame]
	cp a, 0
	jr z, .fade1
	cp a, 1
	jr z, .fade2
	cp a, 2
	jr z, .fade3
	cp a, 3
	jr z, .fade4
	ld a, 1
	ret
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
	ld a, [wFadeOutFrame]
	inc a
	ld [wFadeOutFrame], a
.end:
	xor a ; ld a, 0
	ret

FadeInPalettes::
	; Return a for has faded (0 = false, 1 = true)
	ld a, [wFadeInFrame]
	cp a, 4
	jr c, .fadeIn
.hasFadedIn:
	ld a, 1
	ret
.fadeIn:
	ld a, [wGlobalTimer]
	and FADE_SPEED
	jr nz, .end
	ld a, [wFadeInFrame]
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
	ld a, [wFadeInFrame]
	inc a
	ld [wFadeInFrame], a
.end:
	xor a ; ld a, 0
	ret

ResetFading::
	xor a ; ld a, 0
	ld [wFadeInFrame], a
	ld [wFadeOutFrame], a
	ret