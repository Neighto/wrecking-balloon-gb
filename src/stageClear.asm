INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "tileConstants.inc"
INCLUDE "enemyConstants.inc"

SCORE_SC_INDEX_ONE_ADDRESS EQU $98CF
TOTAL_SC_INDEX_ONE_ADDRESS EQU $990F

STAGE_TEXT_ADDRESS EQU $9884
STAGE_TEXT_TILES EQU 5
CLEAR_TEXT_TILES EQU 5
CLEAR_TEXT_ADDRESS EQU $988B
STAGE_CLEAR_DISTANCE_FROM_TOP_IN_TILES EQU 5
SCORE_TEXT_ADDRESS EQU $98C4
TOTAL_TEXT_ADDRESS EQU $9904

METER_SC_INDEX_ONE_ADDRESS EQU $9944
METER_BLOCKS EQU 11
METER_PHASES EQU 4
METER_TOTAL_PHASES EQU METER_BLOCKS * METER_PHASES
METER_MULTIPLIER EQU 46
METER_FULL_SCORE EQU METER_MULTIPLIER * METER_TOTAL_PHASES
METER_PROGRESS_SCORE EQU METER_FULL_SCORE / METER_TOTAL_PHASES
METER_INITIAL_OFFSET EQU 24 ; Sometimes not 0 so points needed is a nicer number
STAGE_CLEAR_MOVE_POINTS EQU 10

STAGE_NUMBER_SPRITES EQU 1
STAGE_NUMBER_ADDRESS EQU _VRAM8000 + STAGE_CLEAR_NUMBER_TILE * TILE_BYTES
NUMBERS_TILE_ADDRESS EQU _VRAM8000 + NUMBERS_TILE_OFFSET * TILE_BYTES

POINT_SOUND_PLAY_A EQU 0
POINT_SOUND_PLAY_B EQU 1

SECTION "stage clear vars", WRAM0
    wPointSound:: DB
    wStageNumberOAM:: DB
	wExtraLife:: DB
	wExtraLifeScoreMeter:: DB
	wExtraLifeScorePhase:: DB

SECTION "stage clear", ROMX

InitializeStageClear::
    xor a ; ld a, 0
    ld [wPointSound], a
    ld [wStageNumberOAM], a
	ld [wExtraLife], a
	ld [wExtraLifeScorePhase], a
	ld a, METER_INITIAL_OFFSET
	ld [wExtraLifeScoreMeter], a
    ld hl, hSequenceDataAddress
    ld bc, StageClearSequenceData
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
    jp RefreshStageClear

StageClearSequenceData:
    SEQUENCE_WAIT 5
    SEQUENCE_SHOW_PALETTE_2
    SEQUENCE_WAIT 40
	SEQUENCE_INCREASE_PHASE ;SEQUENCE_COPY_SCORE_TO_TOTAL
	SEQUENCE_WAIT_UNTIL IsScoreZero
    SEQUENCE_WAIT 40
	SEQUENCE_INCREASE_PHASE ;SEQUENCE_REPLACE_BAR_WITH_LIVES
	SEQUENCE_WAIT 8
	SEQUENCE_INCREASE_PHASE ;SEQUENCE_ADD_SCORE_LIVES
    SEQUENCE_WAIT 72
    SEQUENCE_HIDE_PALETTE
    SEQUENCE_WAIT 6
    SEQUENCE_END SetupNextLevel

LoadStageClearGraphics::
.loadTiles:
	; Scoreboard tiles
	ld bc, ScoreboardsTiles
	ld hl, _VRAM9000
	ld de, ScoreboardsTilesEnd - ScoreboardsTiles
	call MEMCPY
	; Number tile (for stage number sprite)
	ldh a, [hLevel]
    dec a
	ld b, a
	ld c, TILE_BYTES
	call MULTIPLY
	ld bc, NUMBERS_TILE_ADDRESS
	ADD_A_TO_BC ; Source address of stage number in VRAM
	ld hl, STAGE_NUMBER_ADDRESS ; Destination
	ld de, TILE_BYTES ; 1
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
	; Row 1
	ld bc, CloudsMap + CLOUDS_STAGE_CLEAR_1_OFFSET
	ld hl, $99C0
	call MEMCPY_PATTERN_CLOUDS
	; Row 2
	ld bc, CloudsMap + CLOUDS_STAGE_CLEAR_2_OFFSET
	call MEMCPY_PATTERN_CLOUDS
	; Row 3
	ld bc, CloudsMap + CLOUDS_STAGE_CLEAR_3_OFFSET
	call MEMCPY_PATTERN_CLOUDS
	; Row 4
	ld bc, CloudsMap + CLOUDS_STAGE_CLEAR_4_OFFSET
	call MEMCPY_PATTERN_CLOUDS
	; Draw meter
	ld hl, METER_SC_INDEX_ONE_ADDRESS - 1
	ld a, BAR_LEFT_EDGE
	ld [hli], a
	ld d, BAR_0
	ld bc, METER_BLOCKS
	call SetInRange
	ld a, BAR_100
	ld [hli], a
	ld a, BAR_RIGHT_EDGE
	ld [hl], a
	ret

SpawnStageNumber::
	ld b, STAGE_NUMBER_SPRITES
	ld hl, wStageNumberOAM
	call RequestOAMAndSetOAMOffset
	ret z
	; Has available space
	ld a, 48 ; y
	ld [hli], a
	ld a, 84 ; x
	ld [hli], a
	ld a, STAGE_CLEAR_NUMBER_TILE
	ld [hli], a
	ld [hl], OAMF_PAL0
	ret

SpawnExtraLifeBalloon::
    ld a, POINT_BALLOON
    ldh [hEnemyNumber], a
    ld a, BALLOON_STAGE_CLEAR_VARIANT
    ldh [hEnemyVariant], a
    ld a, 94
    ldh [hEnemyY], a
    ld a, 124
    ldh [hEnemyX], a
    jp SpawnPointBalloon

RefreshStageClear:
	; Score
	ld hl, SCORE_SC_INDEX_ONE_ADDRESS
	call RefreshScore
	; Total
	ld hl, TOTAL_SC_INDEX_ONE_ADDRESS
	jp RefreshTotal

RefreshLives:
	ld hl, METER_SC_INDEX_ONE_ADDRESS
	ld a, LIVES_CACTUS
	ld [hli], a
	ld a, X_AMOUNT
	ld [hli], a
	ldh a, [hPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	ret

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
	; Pop balloon
	jp SetEnemyHitForEnemy1

; UPDATE
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
	; If meter is full, continue
	ld a, [wExtraLifeScorePhase]
	cp a, METER_TOTAL_PHASES
	jr nz, .endCheckPhase
	; Clear bar
	ld bc, METER_BLOCKS + 3 ; Add two for the edges and one for the block hidden by the balloon
	ld d, DARK_GREY_BKG_TILE
	call WaitVRAMAccessible
	ld hl, METER_SC_INDEX_ONE_ADDRESS - 1 ; Back one for the left edge
	call SetInRange
	; Add lives
	call WaitVRAMAccessible
	call RefreshLives
	jr .endCheckPhase
; PHASE 3
.phase3:
	; cp a, 3
	; jr nz, .phase4
	; Skip if no extra life
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
	call RefreshLives
	; jr .endCheckPhase
.endCheckPhase:

    call RefreshStageClear
	call EnemyUpdate
    jp SequenceDataUpdate