INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "tileConstants.inc"

SCORE_SC_INDEX_ONE_ADDRESS EQU $98CF
TOTAL_SC_INDEX_ONE_ADDRESS EQU $990F
LIVES_SC_ADDRESS EQU $994F
LIVES_TO_ADD_SC_ADDRESS EQU $9948

STAGE_TEXT_ADDRESS EQU $9884
STAGE_TEXT_TILES EQU 5
STAGE_NUMBER_ADDRESS EQU $9889
CLEAR_TEXT_TILES EQU 5
CLEAR_TEXT_ADDRESS EQU $988B
STAGE_CLEAR_DISTANCE_FROM_TOP_IN_TILES EQU 5
SCORE_TEXT_ADDRESS EQU $98C4
TOTAL_TEXT_ADDRESS EQU $9904

METER_SC_INDEX_ONE_ADDRESS EQU $9944
METER_BLOCKS EQU 10
METER_PHASES EQU 4
METER_FULL_SCORE EQU 50 * METER_BLOCKS * METER_PHASES
METER_PROGRESS_SCORE EQU METER_FULL_SCORE / (METER_BLOCKS * METER_PHASES)

STAGE_CLEAR_MOVE_POINTS EQU 10

SECTION "stage clear vars", WRAM0
    wLivesToAdd:: DB
    wPointSound:: DB
    wStageNumberOAM:: DB
	wExtraLifeFromScoreMeter:: DB
	wExtraLifeFromScorePhase:: DB

SECTION "stage clear", ROMX

InitializeStageClear::
    xor a ; ld a, 0
    ld [wLivesToAdd], a
    ld [wPointSound], a
    ld [wStageNumberOAM], a
	ld [wExtraLifeFromScoreMeter], a
	ld [wExtraLifeFromScorePhase], a
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
	SEQUENCE_INCREASE_PHASE ;SEQUENCE_COPY_SCORE_TO_TOTAL
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
	; Draw STAGE CLEAR text
	ld bc, WindowMap + SCRN_X_B * STAGE_CLEAR_DISTANCE_FROM_TOP_IN_TILES + 8
	ld hl, STAGE_TEXT_ADDRESS
	ld de, STAGE_TEXT_TILES
	ld a, WINDOW_TILES_8800_OFFSET
	call MEMCPY_WITH_OFFSET
	ld hl, CLEAR_TEXT_ADDRESS
	ld de, CLEAR_TEXT_TILES
	ld a, WINDOW_TILES_8800_OFFSET
	call MEMCPY_WITH_OFFSET
	; Draw SCORE text
	ld bc, ScoreTextMap
	ld hl, SCORE_TEXT_ADDRESS
	ld de, ScoreTextMapEnd - ScoreTextMap
	call MEMCPY
	; Draw TOTAL text
	ld bc, TotalTextMap
	ld hl, TOTAL_TEXT_ADDRESS
	ld de, TotalTextMapEnd - TotalTextMap
	call MEMCPY
	; Draw footer
	ld bc, StageClearFooterMap
	ld hl, $99C0
	ld d, 4
	ld e, SCRN_X_B
	ld a, STAGE_CLEAR_FOOTER_TILE_OFFSET
	ld [wMemcpyTileOffset], a
	call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
	; Draw meter
	ld hl, METER_SC_INDEX_ONE_ADDRESS - 1
	ld a, BAR_LEFT_EDGE
	ld [hli], a
	ld d, BAR_0
	ld bc, METER_BLOCKS
	call SetInRange
	ld a, BAR_RIGHT_EDGE_AND_PLUS
	ld [hli], a
	ld a, LIVES_CACTUS
	ld [hl], a
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
	jp RefreshTotal

FillMeter:
	; d = Points to fill
	; Is full
	ld a, [wExtraLifeFromScorePhase]
	cp a, METER_BLOCKS * METER_PHASES
	ret z
	; Add points from score to our meter
	ld a, [wExtraLifeFromScoreMeter]
	add d
	ld [wExtraLifeFromScoreMeter], a
	; Check if enough score to bump progress
	sub METER_PROGRESS_SCORE
	ret c
	ld [wExtraLifeFromScoreMeter], a
	; Step 1: Get meter address based on phase
	ld hl, METER_SC_INDEX_ONE_ADDRESS
	ld a, [wExtraLifeFromScorePhase]
	ld b, METER_PHASES
	call DIVISION
	add l
	ld l, a
	; Step 2: Get % full based on phase
	ld a, [wExtraLifeFromScorePhase]
	ld d, METER_PHASES
	call MODULO
.phase1:
	cp a, 0
	jr nz, .phase2
	ld a, BAR_25
	ld [hl], a
	jr .next
.phase2:
	cp a, 1
	jr nz, .phase3
	ld a, BAR_50
	ld [hl], a
	jr .next
.phase3:
	cp a, 2
	jr nz, .phase4
	ld a, BAR_75
	ld [hl], a
	jr .next
.phase4:
	; cp a, 3
	; jr nz, .phase5
	ld a, BAR_100
	ld [hl], a
	; jr .next
.next:
	; Increment phase so we know which chunk we are adding progress to
	ld a, [wExtraLifeFromScorePhase]
	inc a
	ld [wExtraLifeFromScorePhase], a
	; Add to lives to add if full
	ld a, [wExtraLifeFromScorePhase]
	cp a, METER_BLOCKS * METER_PHASES
	ret nz
	ld a, [wLivesToAdd]
	cp a, PLAYER_MAX_LIVES
    ret nc
    inc a
    ld [wLivesToAdd], a
    jp PopSound

UpdateStageClear::
    UPDATE_GLOBAL_TIMER

.checkPhase:
    ld a, [wSequencePhase]
; PHASE 0
.phase0:
    cp a, 0
    jr nz, .phase1
	; Nothing
	jr .endCheckPhase
; PHASE 1
.phase1:
    cp a, 1
    jr nz, .phase2
	; Copy score to total
	ldh a, [hGlobalTimer]
	and %00000001
	jr nz, .endCheckPhase
	; TODO if first score pos is not 0 just add it
	call IsScoreZero
    jr nz, .copyingScoreToTotal
.doneCopyingScoreToTotal::
	ld a, 1
	ld [wSequenceWaitUntilCheck], a
	jr .endCheckPhase
.copyingScoreToTotal:
    ld d, STAGE_CLEAR_MOVE_POINTS
    call AddTotal
    ld d, STAGE_CLEAR_MOVE_POINTS
    call DecrementPoints
	ld d, STAGE_CLEAR_MOVE_POINTS
	call FillMeter
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
; PHASE 2 ; TODO add an intermediate phase that will hide the +1, empty the meter tiles, and insert livesXcurrentLives, then phase3 1 sec later will increment it
.phase2:
	; cp a, 2
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