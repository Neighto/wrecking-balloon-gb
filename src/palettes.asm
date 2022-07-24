INCLUDE "hardware.inc"
INCLUDE "constants.inc"

FADE_SPEED EQU %00000011

; PAL0
FADE_PALETTE_1 EQU MAIN_PAL0
FADE_PALETTE_2 EQU %10000100
FADE_PALETTE_3 EQU %01000000
FADE_PALETTE_4 EQU %00000000

; PAL1
FADE_PALETTE2_1 EQU MAIN_PAL1
FADE_PALETTE2_2 EQU %10000001
FADE_PALETTE2_3 EQU %01000000
FADE_PALETTE2_4 EQU %00000000

SECTION "palettes vars", WRAM0
	wFadeInFrame:: DB
	wFadeOutFrame:: DB
	wTriggerFadeIn:: DB
	wTriggerFadeOut:: DB
	wFlickerTimer:: DB

SECTION "palettes", ROMX

ResetFading::
	xor a ; ld a, 0
	ld [wFadeInFrame], a
	ld [wFadeOutFrame], a
	ld [wTriggerFadeIn], a
	ld [wTriggerFadeOut], a
	ret

InitializePalettes::
	call ResetFading
	ld a, MAIN_PAL0
	ldh [rBGP], a
	ldh [rOBP0], a
	ld a, MAIN_PAL1
	ldh [rOBP1], a
	ret

InitializeNightSpritePalettes::
	ld a, NIGHT_SPRITE_PAL0
    ldh [rOBP0], a
    ld a, NIGHT_SPRITE_PAL1
    ldh [rOBP1], a
	ret
	
InitializeEmptyPalettes::
	xor a ; ld a, 0
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ret

InitializeFadedPalettes::
	ld a, FADE_PALETTE_4
	ldh [rBGP], a
	ldh [rOBP0], a
	ret

FadeOutPalettes::
	; Returns z flag as faded / nz flag as not faded
	ld a, [wFadeOutFrame]
	cp a, 5
	jr c, .fadeOut
.hasFadedIn:
	ld a, 1
	and a
	ret
.fadeOut:
	ldh a, [hGlobalTimer]
	and FADE_SPEED
	jr nz, .end
	ld a, [wFadeOutFrame]
.fade1:
	cp a, 0
	jr nz, .fade2
	ld a, FADE_PALETTE2_1
	ldh [rOBP1], a
    ld a, FADE_PALETTE_1
	jr .fadePalettes
.fade2:
	cp a, 1
	jr nz, .fade3
	ld a, FADE_PALETTE2_2
	ldh [rOBP1], a
	ld a, FADE_PALETTE_2
	jr .fadePalettes
.fade3:
	cp a, 2
	jr nz, .fade4
	ld a, FADE_PALETTE2_3
	ldh [rOBP1], a
	ld a, FADE_PALETTE_3
	jr .fadePalettes
.fade4:
	cp a, 3
	jr nz, .fade5
	ld a, FADE_PALETTE2_4
	ldh [rOBP1], a
	ld a, FADE_PALETTE_4
	jr .fadePalettes
.fade5:
	jr .increaseFrame
.fadePalettes:
	ldh [rBGP], a
	ldh [rOBP0], a
.increaseFrame:
	ld a, [wFadeOutFrame]
	inc a
	ld [wFadeOutFrame], a
.end:
	xor a ; ld a, 0
	and a
	ret

FadeInPalettes::
	; Returns z flag as faded / nz flag as not faded
	ld a, [wFadeInFrame]
	cp a, 5
	jr c, .fadeIn
.hasFadedIn:
	ld a, 1
	and a
	ret
.fadeIn:
	ldh a, [hGlobalTimer]
	and FADE_SPEED
	jr nz, .end
	ld a, [wFadeInFrame]
.fade1:
	cp a, 0
	jr nz, .fade2
	ld a, FADE_PALETTE2_4
	ldh [rOBP1], a
    ld a, FADE_PALETTE_4
	jr .fadePalettes
.fade2:
	cp a, 1
	jr nz, .fade3
	ld a, FADE_PALETTE2_3
	ldh [rOBP1], a
	ld a, FADE_PALETTE_3
	jr .fadePalettes
.fade3:
	cp a, 2
	jr nz, .fade4
	ld a, FADE_PALETTE2_2
	ldh [rOBP1], a
	ld a, FADE_PALETTE_2
	jr .fadePalettes
.fade4:
	cp a, 3
	jr nz, .fade5
	ld a, FADE_PALETTE2_1
	ldh [rOBP1], a
	ld a, FADE_PALETTE_1
	jr .fadePalettes
.fade5:
	jr .increaseFrame
.fadePalettes:
	ldh [rBGP], a
	ldh [rOBP0], a
.increaseFrame:
	ld a, [wFadeInFrame]
	inc a
	ld [wFadeInFrame], a
.end:
	xor a ; ld a, 0
	and a
	ret