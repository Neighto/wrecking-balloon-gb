INCLUDE "macro.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "enemyConstants.inc"

HAND_DOWN_START_X EQU 51
HAND_DOWN_START_Y EQU 106
HAND_WAVE_START_X EQU HAND_DOWN_START_X - 2
HAND_WAVE_START_Y EQU 97
HAND_WAVE_TILE_1 EQU $58
HAND_WAVE_TILE_2 EQU $5A

SECTION "opening cutscene vars", WRAM0
    wHandWavingFrame:: DB
    wHandWaveOAM:: DB

SECTION "opening cutscene", ROMX

InitializeOpeningCutscene::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a

    ld hl, wSequenceDataAddress
    ld bc, OpeningCutsceneSequenceData
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
    ret

OpeningCutsceneSequenceData:
    SEQUENCE_FADE_IN_PALETTE
    SEQUENCE_WAIT 90
    SEQUENCE_INCREASE_PHASE ; Hand up
    SEQUENCE_INCREASE_PHASE ; Wave and fly away
    SEQUENCE_WAIT 120
SkipOpeningSequence:
    SEQUENCE_HIDE_PALETTE
    SEQUENCE_WAIT 5
    SEQUENCE_END

LoadOpeningCutsceneGraphics::
.loadTiles:
	ld bc, CutsceneTiles
	ld hl, _VRAM9000
	ld de, CutsceneTilesEnd - CutsceneTiles
	call MEMCPY
.drawMap:
	ld bc, CutsceneMap
	ld hl, $98A0
    ld d, 13
    ld e, SCRN_X_B
	call MEMCPY_SINGLE_SCREEN
    ; Add thin clouds
	ld bc, ThinCloudsMap
	ld hl, $9880
	ld de, ThinCloudsMapEnd - ThinCloudsMap
	ld a, $88
	call MEMCPY_WITH_OFFSET
.addBorders:
    ; Top
    ld hl, _SCRN0
    ld bc, $60
    ld d, BLACK_BKG_TILE
    call SetInRange
    ; Bottom
    ld hl, $99E0
    ld bc, $60
    ld d, BLACK_BKG_TILE
    call SetInRange
	ret

SpawnHandWave::
	ld b, 1
	call RequestOAMSpace
    ret z
    ld a, b
	ld [wHandWaveOAM], a
	SET_HL_TO_ADDRESS wOAM, wHandWaveOAM
    ld a, HAND_DOWN_START_Y
    ld [hli], a
    ld a, HAND_DOWN_START_X
    ld [hli], a
    ld [hl], HAND_WAVE_TILE_1
    inc l
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
    ld a, 24
    ldh [hEnemyX], a
    call SpawnPointBalloon
    ; EASY
    ld a, POINT_BALLOON
    ldh [hEnemyNumber], a
    ld a, BALLOON_EASY_VARIANT
    ldh [hEnemyVariant], a
    ld a, 84
    ldh [hEnemyY], a
    ld a, 8
    ldh [hEnemyX], a
    call SpawnPointBalloon
    ; HARD
    ld a, POINT_BALLOON
    ldh [hEnemyNumber], a
    ld a, BALLOON_HARD_VARIANT
    ldh [hEnemyVariant], a
    ld a, 84
    ldh [hEnemyY], a
    ld a, 32
    ldh [hEnemyX], a
    call SpawnPointBalloon
    ret

HandWaveAnimation::
    ld a, [wHandWavingFrame]
    cp a, 0
    jr nz, .frame1
.frame0:
    ldh a, [hGlobalTimer]
    and 15
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+2, wHandWaveOAM
    ld [hl], HAND_WAVE_TILE_2
    ld hl, wHandWavingFrame
    ld [hl], 1
    ret
.frame1:
    ldh a, [hGlobalTimer]
    and 15
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+2, wHandWaveOAM
    ld [hl], HAND_WAVE_TILE_1
    ld hl, wHandWavingFrame
    ld [hl], 0
.end:
	ret

UpdateOpeningCutscene::
    UPDATE_GLOBAL_TIMER
    call _hUGE_dosound

.checkSkip:
	call ReadController
	ldh a, [hControllerDown]
    and PADF_START | PADF_A
    jr z, .endSkip
.skip:
    call ClearSound
    ld hl, wSequenceDataAddress
    ld bc, SkipOpeningSequence
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
.endSkip:

.checkPhase:
    ld a, [wPhase]

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
    SET_HL_TO_ADDRESS wOAM, wHandWaveOAM
    ld a, HAND_WAVE_START_Y
    ld [hli], a
    ld a, HAND_WAVE_START_X
    ld [hli], a
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.phase2:
    ; cp a, 2
    ; jr nz, .endCheckPhase
    ; wave and fly away
    call MovePlayerUp
    call HandWaveAnimation
.endCheckPhase:

    jp SequenceDataUpdate