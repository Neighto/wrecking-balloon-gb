INCLUDE "macro.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

HAND_WAVE_START_X EQU 152
HAND_WAVE_START_Y EQU 96
HAND_WAVE_TILE_1 EQU $3E
HAND_WAVE_TILE_2 EQU $40

SECTION "opening cutscene vars", WRAM0
    wHandWavingFrame:: DB
    wHandWaveOAM:: DB

SECTION "opening cutscene", ROMX

InitializeOpeningCutscene::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a
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
    ld a, HAND_WAVE_START_Y
    ld [hli], a
    ld a, HAND_WAVE_START_X
    ld [hli], a
    ld [hl], HAND_WAVE_TILE_1
    inc l
    ld [hl], OAMF_PAL0
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
.fadeIn:
    call FadeInPalettes
    cp a, 0
    ret z
.hasFadedIn:
    ld a, [wTriggerFadeOut]
    cp a, 0
    jr nz, .fadeOut
    ld a, [wPlayerY]
    add 4 ; Buffer for extra time before screen switch
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .skipFade
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .skipFade
.offscreen:
    ld a, 1 
    ld [wTriggerFadeOut], a
    jr .skipFade
.fadeOut:
    call FadeOutPalettes
    cp a, 0
    jp nz, SetupNextLevel
.skipFade:
    call HandWaveAnimation
.moveUp:
    ld a, [wPlayerY]
    add 16
    cp a, 75
    ldh a, [hGlobalTimer]
    jr c, .flyUpFast
.flyUpNormal:
    and %00000111
    ret nz
    jr .flyUp
.flyUpFast:
    and %00000001
    ret nz
.flyUp:
    ld a, 1
    ld [wPlayerSpeed], a
    call MovePlayerUpForCutscene
    ret