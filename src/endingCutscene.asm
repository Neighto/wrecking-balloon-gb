INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"

CUTSCENE_DISTANCE_FROM_TOP_IN_TILES EQU 10
HAND_CLAP_SPEED EQU %00000111
LEFT_HAND_CLAP_START_X EQU 58
LEFT_HAND_CLAP_START_Y EQU 110
RIGHT_HAND_CLAP_START_X EQU LEFT_HAND_CLAP_START_X + 5
RIGHT_HAND_CLAP_START_Y EQU LEFT_HAND_CLAP_START_Y
TOTAL_SC_INDEX_ONE_ADDRESS EQU $98CF

VICTORY_DISTANCE_FROM_TOP_IN_TILES EQU 5
VICTORY_TEXT_ADDRESS EQU $9886
VICTORY_TEXT_TILES EQU 8
TOTAL_TEXT_ADDRESS EQU $98C4

SCOREBOARD_OFFSET EQU $3A
MAN_FOR_ENDING_OFFSET EQU $34

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
    SEQUENCE_WAIT 5
    SEQUENCE_PLAY_SONG
    SEQUENCE_FADE_IN_PALETTE
    SEQUENCE_WAIT 65
    SEQUENCE_INCREASE_PHASE ; Man look down
    SEQUENCE_INCREASE_PHASE ; Continue moving down
    SEQUENCE_WAIT 25
    SEQUENCE_INCREASE_PHASE ; Show scoreboards
    SEQUENCE_INCREASE_PHASE ; Bob
    SEQUENCE_WAIT_UNTIL
SkipEndingSequence:
    SEQUENCE_FADE_OUT_PALETTE
    SEQUENCE_WAIT 5
    SEQUENCE_END Start

LoadEndingCutsceneGraphics::
    ; Reuse the opening cutscene
    call LoadOpeningCutsceneGraphics
.loadTiles:
    ; Scoreboard tiles
    ld bc, ScoreboardsTiles
	ld hl, _VRAM9000 + CutsceneTilesEnd - CutsceneTiles
	ld de, ScoreboardsTilesEnd - ScoreboardsTiles
	call MEMCPY
.drawMap:
    ; Draw scoreboard
    ld bc, ScoreboardsMap
    ld hl, $9862
    ld d, 5
    ld e, 16
    ld a, SCOREBOARD_OFFSET
    ld [wMemcpyTileOffset], a
    call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
    ; Draw VICTORY text
    ld bc, WindowMap + SCRN_X_B * VICTORY_DISTANCE_FROM_TOP_IN_TILES
	ld hl, VICTORY_TEXT_ADDRESS
	ld de, VICTORY_TEXT_TILES
	ld a, WINDOW_TILES_8800_OFFSET
	call MEMCPY_WITH_OFFSET
    ; Draw TOTAL text
    ld bc, TotalTextMap
	ld hl, TOTAL_TEXT_ADDRESS
	ld de, TotalTextMapEnd - TotalTextMap
	call MEMCPY
    ; Draw over man for ending cutscene
    ld bc, ManForEndingMap + 2
	ld hl, $9966
    ld d, 2
    ld e, 2
    ld a, MAN_FOR_ENDING_OFFSET
    ld [wMemcpyTileOffset], a
	jp MEMCPY_SINGLE_SCREEN_WITH_OFFSET

SpawnHandClap::
	ld b, 2
	call RequestOAMSpace
    ret z
    ld a, b
	ld [wHandClapOAM], a
    ld hl, wOAM
    ADD_A_TO_HL 
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

    ; Play song
    ld a, [wSequencePlaySong]
    cp a, 0
    call nz, _hUGE_dosound

.checkSkip:
	call ReadController
	ldh a, [hControllerDown]
    and PADF_START | PADF_A
    jr z, .endSkip
.skip:
    xor a ; ld a, 0
    ld [wSequencePlaySong], a
    call ClearSound
    ld hl, wSequenceDataAddress
    ld bc, SkipEndingSequence
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
.endSkip:

.checkPhase:
    ld a, [wSequencePhase]
.phase0:
    cp a, 0
    jr nz, .phase1
    ; Move down
    call MovePlayerAutoDown
    jr .endCheckPhase
.phase1:
    cp a, 1
    jr nz, .phase2
    ; Man look down
    ld bc, ManForEndingMap
	ld hl, $9946
    ld d, 1
    ld e, 2
    ld a, MAN_FOR_ENDING_OFFSET
    ld [wMemcpyTileOffset], a
	call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
    jr .endCheckPhase
.phase2:
    cp a, 2
    jr nz, .phase3
    ; Move down more
    call MovePlayerAutoDown
    jr .endCheckPhase
.phase3:
    cp a, 3
    jr nz, .phase4
    ; TODO NO PHASE 3
    jr .endCheckPhase
.phase4:
    ; cp a, 4
    ; jr nz, .endCheckPhase
    call BobPlayer
    ; jr .endCheckPhase
.endCheckPhase:

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

    jp SequenceDataUpdate