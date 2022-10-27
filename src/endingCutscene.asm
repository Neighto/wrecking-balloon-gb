INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "constants.inc"

CUTSCENE_DISTANCE_FROM_TOP_IN_TILES EQU 10
HAND_CLAP_SPEED EQU %00000111
LEFT_HAND_CLAP_START_X EQU 58
LEFT_HAND_CLAP_START_Y EQU 110
RIGHT_HAND_CLAP_START_X EQU LEFT_HAND_CLAP_START_X + 5
RIGHT_HAND_CLAP_START_Y EQU LEFT_HAND_CLAP_START_Y
HAND_CLAP_TILE EQU $5C
TOTAL_SC_INDEX_ONE_ADDRESS EQU $98CF

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

    ld hl, wSequenceDataAddress
    ld bc, EndingCutsceneSequenceData
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
    ret

EndingCutsceneSequenceData:
    SEQUENCE_FADE_IN_PALETTE
    SEQUENCE_WAIT 90
    SEQUENCE_INCREASE_PHASE ; Hand up
    SEQUENCE_INCREASE_PHASE ; Wave and fly away
    SEQUENCE_WAIT 120
SkipOpeningSequence:
    SEQUENCE_HIDE_PALETTE
    SEQUENCE_WAIT 5
    SEQUENCE_END

LoadEndingCutsceneGraphics::
    ; Reuse the opening cutscene
    call LoadOpeningCutsceneGraphics
.loadTiles:
    ; Scoreboard tiles
    ld bc, ScoreboardsTiles
	ld hl, _VRAM9000 + CutsceneTilesEnd - CutsceneTiles
	ld de, ScoreboardsTilesEnd - ScoreboardsTiles
	call MEMCPY
    ; Special ending tiles
    ld bc, EndingCutsceneTiles
	ld hl, _VRAM9000 + CutsceneTilesEnd - CutsceneTiles + ScoreboardsTilesEnd - ScoreboardsTiles
	ld de, EndingCutsceneTilesEnd - EndingCutsceneTiles
	call MEMCPY
.drawMap:
    ; Draw scoreboard
    ld bc, ScoreboardsMap
    ld hl, $9862
    ld d, 5
    ld e, 16
    ld a, $34
    ld [wMemcpyTileOffset], a
    call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
    ; Draw over man for ending cutscene
    ld bc, ManForEndingMap
	ld hl, $9946
    ld d, 3
    ld e, 2
    ld a, $5E
    ld [wMemcpyTileOffset], a
	call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
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
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
	ret

UpdateEndingCutscene::
    UPDATE_GLOBAL_TIMER
    call _hUGE_dosound
    call BobPlayer

.checkAnimateHands:
    ldh a, [hGlobalTimer]
    and HAND_CLAP_SPEED
    jr nz, .endCheckAnimateHands
.animateHands:
    ld hl, wOAM+1
    ADD_TO_HL [wHandClapOAM]
    ld a, [wHandClappingFrame]
    cp a, 0
    jr nz, .frame1
.frame0:
    inc [hl]
    ADD_TO_HL 4
    dec [hl]
    ld hl, wHandClappingFrame
    ld [hl], 1
    jr .endCheckAnimateHands
.frame1:
    dec [hl]
    ADD_TO_HL 4
    inc [hl]
    ld hl, wHandClappingFrame
    ld [hl], 0
.endCheckAnimateHands:

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