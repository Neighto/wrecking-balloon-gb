INCLUDE "hardware.inc"
INCLUDE "macro.inc"

CUTSCENE_DISTANCE_FROM_TOP_IN_TILES EQU 15
HAND_CLAP_SPEED EQU %00000111
LEFT_HAND_CLAP_START_X EQU 61
LEFT_HAND_CLAP_START_Y EQU 114
RIGHT_HAND_CLAP_START_X EQU LEFT_HAND_CLAP_START_X
RIGHT_HAND_CLAP_START_Y EQU LEFT_HAND_CLAP_START_Y - 13
HAND_CLAP_TILE EQU $42
TOTAL_SC_INDEX_ONE_ADDRESS EQU $98EF

SECTION "ending cutscene vars", WRAM0
    wHandClappingFrame:: DB
    wHandClapOAM:: DB

SECTION "ending cutscene", ROMX

InitializeEndingCutscene::
    xor a ; ld a, 0
    ld [wHandClappingFrame], a
    call AddScoreToTotal
    ld hl, TOTAL_SC_INDEX_ONE_ADDRESS
	call RefreshTotal
    ret

LoadEndingCutsceneGraphics::
	ld bc, CutsceneTiles
	ld hl, _VRAM9000
	ld de, CutsceneTilesEnd - CutsceneTiles
	call MEMCPY

    ld hl, _SCRN0
    ld bc, _SCRN1 - _SCRN0
    ld d, $01
    call SetInRange

	ld bc, CutsceneMap + SCRN_X_B * CUTSCENE_DISTANCE_FROM_TOP_IN_TILES
	ld hl, _SCRN0
    ld d, SCRN_Y_B
	call MEMCPY_SINGLE_SCREEN
	ret

SpawnHandClap::
	ld b, 2
	call RequestOAMSpace
    ret z
    ld a, b
	ld [wHandClapOAM], a
	SET_HL_TO_ADDRESS wOAM, wHandClapOAM
.leftHandClap:
    ld a, LEFT_HAND_CLAP_START_Y
    ld [hli], a
    ld a, LEFT_HAND_CLAP_START_X
    ld [hli], a
    ld [hl], HAND_CLAP_TILE
    inc l
    ld [hl], OAMF_PAL0
    inc l
.rightHandClap:
    ld a, RIGHT_HAND_CLAP_START_Y
    ld [hli], a
    ld a, RIGHT_HAND_CLAP_START_X
    ld [hli], a
    ld [hl], HAND_CLAP_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
	ret

MoveHands:
    SET_HL_TO_ADDRESS wOAM, wHandClapOAM
    ld a, [wHandClappingFrame]
    cp a, 0
    jr nz, .frame1
.frame0:
    inc [hl]
    ADD_TO_HL 4
    dec [hl]
    ld hl, wHandClappingFrame
    ld [hl], 1
    ret
.frame1:
    dec [hl]
    ADD_TO_HL 4
    inc [hl]
    ld hl, wHandClappingFrame
    ld [hl], 0
    ret

UpdateEndingCutscene::
    UPDATE_GLOBAL_TIMER
    call IncrementScrollOffset
    call BobPlayer

.animateHands:
    ldh a, [hGlobalTimer]
    and HAND_CLAP_SPEED
    call z, MoveHands
.endAnimateHands:

.checkTriggerFadeOut:
    call ReadController
    ldh a, [hControllerDown]
    and PADF_START | PADF_A
    jr z, .endTriggerFadeOut
    ld a, 1
    ld [wTriggerFadeOut], a
.endTriggerFadeOut:

.fadeOut:
    ld a, [wTriggerFadeOut]
    cp a, 0
    jr z, .endFadeOut
    call FadeOutPalettes
    jp nz, Start
.endFadeOut:
    ret