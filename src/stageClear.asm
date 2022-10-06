INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

STAGE_CLEAR_DISTANCE_FROM_TOP_IN_TILES EQU 33

PLUS_TILE EQU $FA
SCORE_SC_INDEX_ONE_ADDRESS EQU $98CF
TOTAL_SC_INDEX_ONE_ADDRESS EQU $990F
LIVES_SC_ADDRESS EQU $994C
LIVES_TO_ADD_SC_ADDRESS EQU $994E
STAGE_NUMBER_ADDRESS EQU $9889

SECTION "stage clear vars", WRAM0
    wLivesToAdd:: DB
    wPointSound:: DB
    wStageNumberOAM:: DB

SECTION "stage clear", ROMX

InitializeStageClear::
    xor a ; ld a, 0
    ld [wLivesToAdd], a
    ld [wPointSound], a
    ld [wStageNumberOAM], a

    ld hl, wSequenceDataAddress
    ld bc, StageClearSequenceData
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
    call RefreshStageClear
    ret

StageClearSequenceData:
    SEQUENCE_WAIT 5
    SEQUENCE_SHOW_PALETTE
    SEQUENCE_WAIT 40
    SEQUENCE_COPY_SCORE_TO_TOTAL_1
    SEQUENCE_COPY_SCORE_TO_TOTAL_2
    SEQUENCE_WAIT 40
    SEQUENCE_ADD_SCORE_LIVES
    SEQUENCE_WAIT 80
    SEQUENCE_HIDE_PALETTE
    SEQUENCE_WAIT 5
    SEQUENCE_END

LoadStageClearGraphics::
	ld bc, CutsceneTiles
	ld hl, _VRAM9000
	ld de, CutsceneTilesEnd - CutsceneTiles
	call MEMCPY

	ld bc, CutsceneMap + SCRN_X_B * STAGE_CLEAR_DISTANCE_FROM_TOP_IN_TILES
    ld hl, _SCRN0
    ld d, SCRN_Y_B
    ld e, SCRN_X_B
	call MEMCPY_SINGLE_SCREEN
	ret

SpawnStageNumber::
	ld b, 1
	call RequestOAMSpace
	jr z, .end
.availableSpace:
	ld a, b
	ld [wStageNumberOAM], a
	SET_HL_TO_ADDRESS wOAM, wStageNumberOAM
	ld a, 48 ; y
	ld [hli], a
	ld a, 84 ; x
	ld [hli], a
    ld a, [wLevel]
    dec a
    add NUMBERS_TILE_OFFSET
	ld [hli], a
	ld [hl], OAMF_PAL0
.end:
	ret

RefreshAddLives::
	ld a, [wLivesToAdd]
	cp a, 0
	jr nz, .hasLivesToAdd
	ld a, DARK_GREY_BKG_TILE
	ld hl, LIVES_TO_ADD_SC_ADDRESS
	ld [hli], a
	ld [hl], a
	ret
.hasLivesToAdd:
	ld hl, LIVES_TO_ADD_SC_ADDRESS
	ld a, PLUS_TILE
	ld [hli], a
	ld a, [wLivesToAdd]
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	ret

RefreshStageClear::
	ld hl, SCORE_SC_INDEX_ONE_ADDRESS
	call RefreshScore
	ld hl, TOTAL_SC_INDEX_ONE_ADDRESS
	call RefreshTotal

	ldh a, [hPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_SC_ADDRESS], a

	call RefreshAddLives
	ret

PointSound::
	ld a, [wPointSound]
	cp a, 0
	jr nz, .soundB
.soundA:
	ld a, 1
	ld [wPointSound], a
	call BassSoundA
	jr .endPointSound
.soundB:
	ld a, 0
	ld [wPointSound], a
	call BassSoundB
.endPointSound:
    ret

UpdateStageClear::
    UPDATE_GLOBAL_TIMER
    call RefreshStageClear
    jp SequenceDataUpdate