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
METER_TOTAL_PHASES EQU METER_BLOCKS * METER_PHASES
METER_FULL_SCORE EQU 50 * METER_TOTAL_PHASES
METER_PROGRESS_SCORE EQU METER_FULL_SCORE / METER_TOTAL_PHASES

STAGE_CLEAR_MOVE_POINTS EQU 10

POINT_SOUND_PLAY_A EQU 0
POINT_SOUND_PLAY_B EQU 1

EXTRA_LIFE_BLINK_TIME EQU %00011111
EXTRA_LIFE_BLINK_SPEED EQU %00000011

SECTION "stage clear vars", WRAM0
    wPointSound:: DB
    wStageNumberOAM:: DB
	wExtraLife:: DB
	wExtraLifeScoreMeter:: DB
	wExtraLifeScorePhase:: DB
	wExtraLifeBlinkTimer:: DB

SECTION "stage clear", ROMX

InitializeStageClear::
    xor a ; ld a, 0
    ld [wPointSound], a
    ld [wStageNumberOAM], a
	ld [wExtraLife], a
	ld [wExtraLifeScoreMeter], a
	ld [wExtraLifeScorePhase], a
	ld a, EXTRA_LIFE_BLINK_TIME
	ld [wExtraLifeBlinkTimer], a
    ld hl, hSequenceDataAddress
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
	SEQUENCE_INCREASE_PHASE ;SEQUENCE_BLINK_LIVES
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
    ldh a, [hLevel]
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
	; a = Points to fill
	ld d, a
	; Is full
	ld a, [wExtraLifeScorePhase]
	cp a, METER_TOTAL_PHASES
	ret z
	; Add points from score to our meter
	ld a, [wExtraLifeScoreMeter]
	add d
	ld [wExtraLifeScoreMeter], a
	; Check if enough score to bump progress
	sub METER_PROGRESS_SCORE
	ret c
	ld [wExtraLifeScoreMeter], a
	; Step 1: Get meter address based on phase
	ld hl, METER_SC_INDEX_ONE_ADDRESS
	ld a, [wExtraLifeScorePhase]
	ld b, METER_PHASES
	call DIVISION
	add l
	ld l, a
	; Step 2: Get % full based on phase
	ld a, [wExtraLifeScorePhase]
	ld d, METER_PHASES
	call MODULO
.phase1:
	cp a, 0
	jr nz, .phase2
	ld a, BAR_25
	jr .next
.phase2:
	cp a, 1
	jr nz, .phase3
	ld a, BAR_50
	jr .next
.phase3:
	cp a, 2
	jr nz, .phase4
	ld a, BAR_75
	jr .next
.phase4:
	; cp a, 3
	; jr nz, .phase5
	ld a, BAR_100
	; jr .next
.next:
	ld [hl], a
	; Increment phase so we know which chunk we are adding progress to
	ld a, [wExtraLifeScorePhase]
	inc a
	ld [wExtraLifeScorePhase], a
	; Flag we have life to add if full
	ld a, [wExtraLifeScorePhase]
	cp a, METER_TOTAL_PHASES
	ret nz
	ld a, [wExtraLife]
	inc a
	ld [wExtraLife], a
    jp PopSound

UpdateStageClear::
    UPDATE_GLOBAL_TIMER

.checkPhase:
    ldh a, [hSequencePhase]
; PHASE 0
.phase0:
    cp a, 0
    jr nz, .phase1
	; Nothing
	jp .endCheckPhase
; PHASE 1
.phase1:
    cp a, 1
    jr nz, .phase2
	; Copy score to total
	ldh a, [hGlobalTimer]
	and %00000001
	jp nz, .endCheckPhase
	call IsScoreZero
    jr nz, .copyingScoreToTotal
.doneCopyingScoreToTotal::
	ld a, 1
	ldh [hSequenceWaitUntilCheck], a
	jp .endCheckPhase
.copyingScoreToTotal:
	; Copy over score at 0th (does not fill meter)
    ld a, [wScore]
    and LOW_HALF_BYTE_MASK
    call AddTotal
    ld a, [wScore]
    and LOW_HALF_BYTE_MASK
    call DecrementPoints
	; Copy over score by 10s
    ld a, STAGE_CLEAR_MOVE_POINTS
    call AddTotal
    ld a, STAGE_CLEAR_MOVE_POINTS
    call DecrementPoints
	ld a, STAGE_CLEAR_MOVE_POINTS
	call FillMeter
.checkPointSound
	ld a, [wPointSound]
	cp a, POINT_SOUND_PLAY_A
	jr nz, .soundB
.soundA:
	call BassSoundA
	ld a, POINT_SOUND_PLAY_B
	jr .endPointSound
.soundB:
	call BassSoundB
	ld a, POINT_SOUND_PLAY_A
.endPointSound:
	ld [wPointSound], a
	jr .endCheckPhase
; PHASE 2
.phase2:
	cp a, 2
    jr nz, .phase3
	; Skip if added or no extra life
	ld a, [wExtraLife]
	cp a, 0
	jr z, .endCheckPhase
	; Flag off extra life
	xor a ; ld a, 0
	ld [wExtraLife], a
	call CollectSound
	; Confirm we are not at max lives
	ldh a, [hPlayerLives]
	cp a, PLAYER_MAX_LIVES
	jr nc, .endCheckPhase
	; Add life
	inc a
	ldh [hPlayerLives], a
	jr .endCheckPhase
; PHASE 3
.phase3:
	; cp a, 3
    ; jr nz, .phase4
	ld hl, METER_SC_INDEX_ONE_ADDRESS + METER_BLOCKS
	; If meter is full, blink
	ld a, [wExtraLifeScorePhase]
	cp a, METER_TOTAL_PHASES
	jr nz, .endCheckPhase
	; Time
	ld a, [wExtraLifeBlinkTimer]
	cp a, 0
	jr z, .showExtraLife
	dec a
	ld [wExtraLifeBlinkTimer], a
	and EXTRA_LIFE_BLINK_SPEED
	jr nz, .endCheckPhase
	; Can blink
	ld a, BAR_RIGHT_EDGE_AND_PLUS
	cp a, [hl]
	jr z, .showNothing
.showExtraLife:
	ld a, BAR_RIGHT_EDGE_AND_PLUS
	ld [hli], a
	ld a, LIVES_CACTUS
	ld [hl], a
	jr .endCheckPhase
.showNothing:
	ld a, BAR_RIGHT_EDGE
	ld [hli], a
	ld a, DARK_GREY_BKG_TILE
	ld [hl], a
	; jr .endCheckPhase
.endCheckPhase:

    call RefreshStageClear
    jp SequenceDataUpdate