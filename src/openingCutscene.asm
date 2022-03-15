INCLUDE "macro.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

OPENING_CUTSCENE_UPDATE_TIME EQU %00000011
OPENING_CUTSCENE_PAUSE_LENGTH EQU 15

HAND_DOWN_START_X EQU 149
HAND_DOWN_START_Y EQU 105
HAND_WAVE_START_X EQU 151
HAND_WAVE_START_Y EQU 96
HAND_WAVE_TILE_1 EQU $3E
HAND_WAVE_TILE_2 EQU $40

SECTION "opening cutscene vars", WRAM0
    wHandWavingFrame:: DB
    wHandWaveOAM:: DB
    wOpeningCutsceneFrame:: DB
    wOpeningCutsceneTimer:: DB

SECTION "opening cutscene", ROMX

InitializeOpeningCutscene::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a
    ld [wOpeningCutsceneFrame], a
    ld a, OPENING_CUTSCENE_PAUSE_LENGTH
    ld [wOpeningCutsceneTimer], a
    ret

LoadOpeningCutsceneGraphics::
	ld bc, CutsceneTiles
	ld hl, _VRAM9000
	ld de, CutsceneTilesEnd - CutsceneTiles
	call MEMCPY
	ld bc, CutsceneMap
	ld hl, _SCRN0
    ld d, SCRN_Y_B
	call MEMCPY_SINGLE_SCREEN
	ret

SpawnHandWave::
	ld b, 1
	call RequestOAMSpace
    cp a, 0
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
    ld [hl], OAMF_PAL0 | OAMF_YFLIP
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
.checkWreckingBalloon:
.canFlyUp:
    ldh a, [hGlobalTimer]
    and %00000011
    jr nz, .endCanFlyUp
    ld a, [wOpeningCutsceneFrame]
    cp a, 4
    jr nc, .bobUp
.endCanFlyUp:
    ldh a, [hGlobalTimer]
    and %00011111
    ld d, %00000000
    jr nz, .endWreckingBalloonCheck
    ld a, 1
    ld [wPlayerSpeed], a
    ld a, [wPlayerBobbedUp]
    cp a, 0
    jr z, .bobUp
.bobDown:
    xor a ; ld a, 0
    ld [wPlayerBobbedUp], a
    ld d, %10000000
    jr .endWreckingBalloonCheck
.bobUp:
    ld a, 1
    ld [wPlayerBobbedUp], a
    ld d, %01000000
.endWreckingBalloonCheck:
    call MovePlayerForCutscene
    
.updates:
    ldh a, [hGlobalTimer]
    and OPENING_CUTSCENE_UPDATE_TIME
    cp a, 0
    ret nz
    ld a, [wOpeningCutsceneFrame]
    cp a, 0
    jr z, .fadeIn
    cp a, 1
    jr z, .pause
    cp a, 2
    jr z, .pause
    cp a, 3
    jr z, .pause
    cp a, 4
    jr z, .pause
    cp a, 5
    jr z, .triggerHandWave
    push af
    call HandWaveAnimation
    pop af
    cp a, 6
    jr z, .pause
    cp a, 7
    jr z, .pause
    cp a, 8
    jr z, .pause
    cp a, 9
    jr z, .fadeOut
    jp SetupNextLevel
.fadeIn:
    call FadeInPalettes
    cp a, 0
    ret z
    jr .endFrame
.pause:
    ld a, [wOpeningCutsceneTimer]
    dec a 
    ld [wOpeningCutsceneTimer], a
    cp a, 0
    ret nz
    ld a, OPENING_CUTSCENE_PAUSE_LENGTH
    ld [wOpeningCutsceneTimer], a
    jr .endFrame
.triggerHandWave:
    SET_HL_TO_ADDRESS wOAM, wHandWaveOAM
    ld a, HAND_WAVE_START_Y
    ld [hli], a
    ld a, HAND_WAVE_START_X
    ld [hli], a
    inc l
    ld [hl], OAMF_PAL0
    jr .endFrame
.fadeOut:
    call FadeOutPalettes
    cp a, 0
    ret z
.endFrame:
    ld a, [wOpeningCutsceneFrame]
    inc a
    ld [wOpeningCutsceneFrame], a
    ret