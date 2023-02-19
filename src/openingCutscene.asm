INCLUDE "macro.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "tileConstants.inc"

HAND_DOWN_START_X EQU 51
HAND_DOWN_START_Y EQU 104
HAND_WAVE_START_X EQU HAND_DOWN_START_X - 2
HAND_WAVE_START_Y EQU 96

SECTION "opening cutscene vars", WRAM0
    wHandWavingFrame:: DB
    wHandWaveOAM:: DB

SECTION "opening cutscene", ROMX

InitializeOpeningCutscene::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a

    ld hl, hSequenceDataAddress
    ld bc, OpeningCutsceneSequenceData
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
    ret

OpeningCutsceneSequenceData:
    SEQUENCE_WAIT 5
    SEQUENCE_PLAY_SONG
    SEQUENCE_FADE_IN_PALETTE
    SEQUENCE_WAIT 90
    SEQUENCE_INCREASE_PHASE ; Hand up
    SEQUENCE_INCREASE_PHASE ; Wave and fly away
    SEQUENCE_WAIT 120
SkipOpeningSequence:
    SEQUENCE_HIDE_PALETTE
    SEQUENCE_WAIT 5
    SEQUENCE_END SetupNextLevel

LoadOpeningCutsceneGraphics::
    ; Road
    ld hl, $9900
    call LoadRoadCommon ; Loads in tiles too important for other calls
    ; Lamps
    ld hl, $98A2
    call LoadLamp
    ld hl, $98B2
    call LoadLamp
    ; Hydrant
    ld hl, $9943
    call LoadHydrant
    ; Flowers
    ld a, $2C ; FLOWER_OFFSET
    ld [$99C5], a
    ld [$99CD], a
    ld [$99D3], a
    ; Man
    ld a, $01 ; MAN_OFFSET
    ld [wMemcpyTileOffset], a
    ld bc, ManMap
    ld hl, $9926
    ld d, 5
    ld e, 2
    call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
    ; Cart
    ld a, $11 ; CART_OFFSET
    ld [wMemcpyTileOffset], a
    ld bc, CartMap
    ld hl, $996C
    ld d, 3
    ld e, 5
    call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
    ; Add scrolling thin clouds
    ld bc, CloudsMap + CLOUDS_THIN_OFFSET
    ld hl, $9880
    call MEMCPY_PATTERN_CLOUDS
    ; Top banner
    ld hl, _SCRN0
    ld bc, $60
    ld d, BLACK_BKG_TILE
    call SetInRange
    ; Bottom banner
    ld hl, $99E0
    ld bc, $60
    ld d, BLACK_BKG_TILE
    jp SetInRange

SpawnHandWave::
	ld b, 1
	call RequestOAMSpace
    ret z
    ld a, b
	ld [wHandWaveOAM], a
    ld hl, wOAM
    ; ld a, [wHandWaveOAM]
    ADD_A_TO_HL
    ld a, HAND_DOWN_START_Y
    ld [hli], a
    ld a, HAND_DOWN_START_X
    ld [hli], a
    ld a, HAND_WAVE_TILE_1
    ld [hli], a
    ld [hl], OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
	ret

SpawnCartBalloons::
    ; MEDIUM
    ld a, POINT_BALLOON
    ldh [hEnemyNumber], a
    ld a, BALLOON_MEDIUM_VARIANT
    ldh [hEnemyVariant], a
    ld a, 85
    ldh [hEnemyY], a
    ld a, 23 + 96
    ldh [hEnemyX], a
    call SpawnPointBalloon
    ; EASY
    ld a, POINT_BALLOON
    ldh [hEnemyNumber], a
    ld a, BALLOON_EASY_VARIANT
    ldh [hEnemyVariant], a
    ld a, 84
    ldh [hEnemyY], a
    ld a, 8 + 96
    ldh [hEnemyX], a
    call SpawnPointBalloon
    ; HARD
    ld a, POINT_BALLOON
    ldh [hEnemyNumber], a
    ld a, BALLOON_HARD_VARIANT
    ldh [hEnemyVariant], a
    ld a, 83
    ldh [hEnemyY], a
    ld a, 34 + 96
    ldh [hEnemyX], a
    jp SpawnPointBalloon

UpdateOpeningCutscene::
    UPDATE_GLOBAL_TIMER

    ; Play song
    ldh a, [hSequencePlaySong]
    cp a, 0
    call nz, _hUGE_dosound

.checkSkip:
	call ReadController
	ldh a, [hControllerDown]
    and PADF_START | PADF_A
    jr z, .endSkip
.skip:
    xor a ; ld a, 0
    ldh [hSequencePlaySong], a
    call ClearSound
    ld hl, hSequenceDataAddress
    ld bc, SkipOpeningSequence
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
.endSkip:

.checkPhase:
    ldh a, [hSequencePhase]
.phase0:
    cp a, 0
    jr nz, .phase1
    ; bob
    call BobPlayer
    jr .endCheckPhase
.phase1:
    cp a, 1
    jr nz, .phase2
    ; move hand up
    ld hl, wOAM
    ADD_TO_HL [wHandWaveOAM]
    ld a, HAND_WAVE_START_Y
    ld [hli], a
    ld a, HAND_WAVE_START_X
    ld [hli], a
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endCheckPhase
.phase2:
    ; cp a, 2
    ; jr nz, .endCheckPhase
    ; wave and fly away
    call MovePlayerAuto.autoUp
    ; hand wave animation
.checkAnimateWave:
    ld a, [wHandWavingFrame]
.frame0:
    cp a, 0
    jr nz, .frame1
    ldh a, [hGlobalTimer]
    and 15
    jr nz, .endCheckAnimateWave
    ld hl, wOAM+2
    ADD_TO_HL [wHandWaveOAM]
    ld [hl], HAND_WAVE_TILE_2
    ld hl, wHandWavingFrame
    ld [hl], 1
    jr .endCheckAnimateWave
.frame1:
    ; cp a, 1
    ; jr nz, .endCheckAnimateWave
    ldh a, [hGlobalTimer]
    and 15
    jr nz, .endCheckAnimateWave
    ld hl, wOAM+2
    ADD_TO_HL [wHandWaveOAM]
    ld [hl], HAND_WAVE_TILE_1
    ld hl, wHandWavingFrame
    ld [hl], 0
    ; jr .endCheckAnimateWave
.endCheckAnimateWave:
    ; jr .endCheckPhase
.endCheckPhase:

    jp SequenceDataUpdate