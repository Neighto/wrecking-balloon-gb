INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"

; Cutscene
CUTSCENE_DISTANCE_FROM_TOP_IN_TILES EQU 10
HAND_CLAP_SPEED EQU %00000111
LEFT_HAND_CLAP_START_X EQU 58
LEFT_HAND_CLAP_START_Y EQU 110
RIGHT_HAND_CLAP_START_X EQU LEFT_HAND_CLAP_START_X + 5
RIGHT_HAND_CLAP_START_Y EQU LEFT_HAND_CLAP_START_Y
HAND_CLAP_SPRITES EQU 2

; Victory
VICTORY_TEXT_SWAP_TIME EQU %01111111
VICTORY_DISTANCE_FROM_TOP_IN_TILES EQU 5
VICTORY_TEXT_TILES EQU 8
VICTORY_ADDRESS EQU $98C4
VICTORY_TILES EQU 12
VICTORY_TEXT_BUFFER_ADDRESS EQU $9A44
TOTAL_TEXT_BUFFER_ADDRESS EQU $9A64
TOTAL_SC_INDEX_ONE_TEMP_ADDRESS EQU TOTAL_TEXT_BUFFER_ADDRESS + VICTORY_TILES - 1

; Offset
SCOREBOARD_OFFSET EQU $2D
MAN_FOR_ENDING_OFFSET EQU $0B

SECTION "ending cutscene vars", WRAM0
wVictoryTextSwapFrame:: DB
wHandClappingFrame:: DB
wHandClapOAM:: DB

SECTION "ending cutscene", ROMX

InitializeEndingCutscene::
    xor a ; ld a, 0
    ld [wHandClappingFrame], a
    ld [wVictoryTextSwapFrame], a

    ld hl, hSequenceDataAddress
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
    SEQUENCE_WAIT 63
    SEQUENCE_INCREASE_PHASE ; Man look down
    SEQUENCE_INCREASE_PHASE ; Continue moving down
    SEQUENCE_WAIT 25
    SEQUENCE_INCREASE_PHASE ; Show scoreboards
    SEQUENCE_INCREASE_PHASE ; Bob
    SEQUENCE_WAIT_UNTIL
SkipEndingSequence:
    SEQUENCE_FADE_OUT_PALETTE
    SEQUENCE_WAIT 5
    SEQUENCE_END Restart

LoadEndingCutsceneGraphics::
    ; TILES
    ; Scoreboard tiles
    ld bc, ScoreboardsTiles
    ld hl, _VRAM9000 + CutsceneTilesEnd - CutsceneTiles + 1 * TILE_BYTES
    ld de, ScoreboardsTilesEnd - ScoreboardsTiles
	call MEMCPY
    ; TILEMAP
    ; Draw scoreboard
    ld bc, ScoreboardsMap
    ld hl, $98A2
    ld d, 3
    ld e, 16
    ld a, SCOREBOARD_OFFSET
    ld [wMemcpyTileOffset], a
    call MEMCPY_SINGLE_SCREEN_WITH_OFFSET

    ; Reuse the opening cutscene
    call LoadOpeningCutsceneGraphics
    ; Draw VICTORY text buffer
    ld hl, VICTORY_TEXT_BUFFER_ADDRESS
    ld bc, VICTORY_TILES
    ld d, DARK_GREY_BKG_TILE
    call SetInRange
    ld bc, WindowMap + SCRN_X_B * VICTORY_DISTANCE_FROM_TOP_IN_TILES
    ld hl, VICTORY_TEXT_BUFFER_ADDRESS + 2
    ld de, VICTORY_TEXT_TILES
    ld a, WINDOW_TILES_8800_OFFSET
    call MEMCPY_WITH_OFFSET
    ; Draw VICTORY text
    ld bc, VICTORY_TEXT_BUFFER_ADDRESS
    ld hl, VICTORY_ADDRESS
    ld de, VICTORY_TILES
    call MEMCPY
    ; Draw TOTAL text buffer
    ld bc, TotalTextMap
    ld hl, TOTAL_TEXT_BUFFER_ADDRESS
    ld de, TotalTextMapEnd - TotalTextMap
    call MEMCPY
    ld hl, TOTAL_SC_INDEX_ONE_TEMP_ADDRESS
    call RefreshScore.total
    ; Draw over man for ending cutscene
    ld bc, ManForEndingMap + 2
    ld hl, $9966
    ld d, 2
    ld e, d
    ld a, MAN_FOR_ENDING_OFFSET
    ld [wMemcpyTileOffset], a
    jp MEMCPY_SINGLE_SCREEN_WITH_OFFSET

SpawnHandClap::
    ld b, HAND_CLAP_SPRITES
    ld hl, wHandClapOAM
    call RequestOAMAndSetOAMOffset
    ret z
    ; Has available space
    ; Left hand clap
    ld a, LEFT_HAND_CLAP_START_Y
    ld [hli], a
    ld a, LEFT_HAND_CLAP_START_X
    ld [hli], a
    ld a, HAND_CLAP_TILE
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ; Right hand clap
    ld a, RIGHT_HAND_CLAP_START_Y
    ld [hli], a
    ld a, RIGHT_HAND_CLAP_START_X
    ld [hli], a
    ld a, HAND_CLAP_TILE
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hl], a
    ret

; *************************************************************
; UPDATEENDINGCUTSCENE
; *************************************************************
UpdateEndingCutscene::

    ; Timer
    UPDATE_GLOBAL_TIMER

    call IncrementScrollOffset

    ; Play song
    ldh a, [hSequencePlaySong]
    cp a, 0
    call nz, _hUGE_dosound

    ; Check phase
    ldh a, [hSequencePhase]
.phase0:
    cp a, 0
    jr nz, .phase1
    ; Move down
    call MovePlayerAuto.autoDown
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
    call MovePlayerAuto.autoDown
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
    ; Check skip
    call ReadController
    ldh a, [hControllerDown]
    and PADF_START | PADF_A
    jr z, .endSkip
    ; Skip
    xor a ; ld a, 0
    ldh [hSequencePlaySong], a
    call ChDACs.mute
    ld hl, hSequenceDataAddress
    ld bc, SkipEndingSequence
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
.endSkip:
    ; jr .endCheckPhase
.endCheckPhase:

    ; Check animate hands
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

    ; Check animate victory / total score
    ldh a, [hGlobalTimer]
    and VICTORY_TEXT_SWAP_TIME
    jr nz, .endCheckAnimateVictory
    ; Can swap text
    ld a, [wVictoryTextSwapFrame]
    cp a, 0
    jr nz, .swapToVictoryText
.swapToTotalScoreText:
    ld a, 1
    ld [wVictoryTextSwapFrame], a
    ld bc, TOTAL_TEXT_BUFFER_ADDRESS
    ld de, VICTORY_TILES
    ld hl, VICTORY_ADDRESS
    call MEMCPY_VBLANK_SAFE
    jr .endCheckAnimateVictory
.swapToVictoryText:
    xor a ; ld a, 0
    ld [wVictoryTextSwapFrame], a
    ld bc, VICTORY_TEXT_BUFFER_ADDRESS
    ld hl, VICTORY_ADDRESS
    ld de, VICTORY_TILES
    call MEMCPY_VBLANK_SAFE
.endCheckAnimateVictory:


    jp SequenceDataUpdate