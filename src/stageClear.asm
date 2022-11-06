INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

STAGE_CLEAR_DISTANCE_FROM_TOP_IN_TILES EQU 22

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
    jp RefreshStageClear

StageClearSequenceData:
    SEQUENCE_WAIT 5
    SEQUENCE_SHOW_PALETTE
    SEQUENCE_WAIT 40
	SEQUENCE_INCREASE_PHASE ;SEQUENCE_COPY_SCORE_TO_TOTAL_1
	SEQUENCE_INCREASE_PHASE ;SEQUENCE_COPY_SCORE_TO_TOTAL_2
	SEQUENCE_WAIT_UNTIL IsScoreZero
    SEQUENCE_WAIT 40
	SEQUENCE_INCREASE_PHASE ;SEQUENCE_ADD_SCORE_LIVES
    SEQUENCE_WAIT 80
    SEQUENCE_HIDE_PALETTE
    SEQUENCE_WAIT 5
    SEQUENCE_END SetupNextLevel

LoadStageClearGraphics::
.loadTiles:
	; Scoreboard tiles
	ld bc, ScoreboardsTiles
	ld hl, _VRAM9000
	ld de, ScoreboardsTilesEnd - ScoreboardsTiles
	call MEMCPY
.drawMap:
	; Fill light grey
	ld hl, _SCRN0
	ld bc, SCRN0_SIZE
	ld d, LIGHT_GREY_BKG_TILE
	call SetInRange
	; Draw scoreboard
	ld bc, ScoreboardsMap + 16 * 5
	ld hl, $9862
	ld d, 9
	ld e, 16
	call MEMCPY_SINGLE_SCREEN
	; Draw footer
	ld bc, StageClearFooterMap
	ld hl, $99C0
	ld d, 4
	ld e, SCRN_X_B
	ld a, $B5
	ld [wMemcpyTileOffset], a
	call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
	; Draw lives icons
	ld a, $D7
	ld [$994A], a
	ld a, $D8
	ld [$994B], a
	ret

SpawnStageNumber::
	ld b, 1
	call RequestOAMSpace
	ret z
.availableSpace:
	ld a, b
	ld [wStageNumberOAM], a
	ld hl, wOAM
	ADD_A_TO_HL
	ld a, 48 ; y
	ld [hli], a
	ld a, 84 ; x
	ld [hli], a
    ld a, [wLevel]
    dec a
    add NUMBERS_TILE_OFFSET
	ld [hli], a
	ld [hl], OAMF_PAL0
	ret

RefreshStageClear:
	; Score
	ld hl, SCORE_SC_INDEX_ONE_ADDRESS
	call RefreshScore
	; Total
	ld hl, TOTAL_SC_INDEX_ONE_ADDRESS
	call RefreshTotal
	; Current lives
	ldh a, [hPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_SC_ADDRESS], a
	; Add lives
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

UpdateStageClear::
    UPDATE_GLOBAL_TIMER

.checkPhase:
    ld a, [wSequencePhase]
.phase0:
    cp a, 0
    jr nz, .phase1
	; Nothing
	jr .endCheckPhase
.phase1:
    cp a, 1
    jr nz, .phase2
	; Copy first digit score to total
	ld a, [wScore]
    and HIGH_HALF_BYTE_MASK
    ld d, a
    call AddTotal
    ld a, [wScore]
    and HIGH_HALF_BYTE_MASK
    ld d, a
    call DecrementPoints
	jr .endCheckPhase
.phase2:
    cp a, 2
    jr nz, .phase3
	; Copy score to total
	ldh a, [hGlobalTimer]
	and %00000001
	jr nz, .endCheckPhase
	call IsScoreZero
    jr nz, .copyingScoreToTotal
.doneCopyingScoreToTotal::
	ld a, 1
	ld [wSequenceWaitUntilCheck], a
	jr .endCheckPhase
.copyingScoreToTotal:
    ld d, 10
    call AddTotal
    ld d, 10
    call DecrementPoints
.checkPointSound
	ld a, [wPointSound]
	cp a, 0
	jr nz, .soundB
.soundA:
	inc a
	ld [wPointSound], a
	call BassSoundA
	jr .endPointSound
.soundB:
	xor a ; ld a, 0
	ld [wPointSound], a
	call BassSoundB
.endPointSound:
	jr .endCheckPhase
.phase3:
	; cp a, 3
    ; jr nz, .endCheckPhase
	; Add gained lives
	ld a, [wLivesToAdd]
    cp a, 0
    jr z, .endCheckPhase
    dec a
    ld [wLivesToAdd], a
    ldh a, [hPlayerLives]
    cp a, PLAYER_MAX_LIVES
	jr nc, .endCheckPhase
    inc a
    ldh [hPlayerLives], a
    call CollectSound
	; jr .endCheckPhase
.endCheckPhase:

    call RefreshStageClear
    jp SequenceDataUpdate