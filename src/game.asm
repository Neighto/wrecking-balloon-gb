INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

COUNTDOWN_OAM_SPRITES EQU 2
COUNTDOWN_OAM_BYTES EQU COUNTDOWN_OAM_SPRITES * 4
COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 40
COUNTDOWN_SPEED EQU %00011111
COUNTDOWN_BALLOON_POP_SPEED EQU %00000111
COUNTDOWN_3_TILE_1 EQU $54
COUNTDOWN_3_TILE_2 EQU $56
COUNTDOWN_2_TILE_1 EQU $50
COUNTDOWN_2_TILE_2 EQU $52
COUNTDOWN_1_TILE_1 EQU $4C
COUNTDOWN_1_TILE_2 EQU $4E

COUNTDOWN_FRAME_0 EQU 0
COUNTDOWN_FRAME_1 EQU 1
COUNTDOWN_FRAME_2 EQU 2
COUNTDOWN_FRAME_3 EQU 3
COUNTDOWN_FRAME_4 EQU 4 ; Becomes balloon pop instead
COUNTDOWN_FRAME_5 EQU 5
COUNTDOWN_FRAME_6 EQU 6 ; Clear

COUNTDOWN_NEUTRAL_BALLOON_TILE EQU $1E
STAR_TILE EQU $9F
SUN_ADDRESS EQU $9848
SUN_TILE_OFFSET EQU $92

SECTION "game vars", WRAM0
    wCountdownFrame:: DB
    wCountdownOAM:: DB

SECTION "game", ROM0

InitializeGame::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a
	ld [wCountdownFrame], a
    ret

LoadGameSpriteTiles::
	ld bc, GameSpriteTiles
	ld hl, _VRAM8000+$20 ; Offset first 2 tiles as empty
	ld de, GameSpriteTilesEnd - GameSpriteTiles
	call MEMCPY
	ret

LoadGameMiscellaneousTiles::
	ld bc, MiscellaneousTiles
	ld hl, _VRAM8800
	ld de, MiscellaneousTilesEnd - MiscellaneousTiles
	call MEMCPY
    ret
    
LoadLevelCityGraphics::
.tiles:
	ld bc, LevelCityTiles
	ld hl, _VRAM9000
	ld de, LevelCityTilesEnd - LevelCityTiles
	call MEMCPY
.tilemap:
	ld bc, LevelCityMap
	ld hl, _SCRN0 + $C0
	ld de, LevelCityMapEnd - LevelCityMap
	call MEMCPY
    ; City Planes
    ld bc, CityPlaneMap
	ld hl, $9831 ; City Plane address
    ld de, 3
    ld a, $AD
	call MEMCPY_WITH_OFFSET
    ld bc, CityPlaneMap
	ld hl, $9886 ; City Plane address
    ld de, 3
    ld a, $AD
	call MEMCPY_WITH_OFFSET
    ld bc, CityPlaneMap
    ld hl, $987B ; City Plane address
    ld de, 5
    ld a, $AD
	call MEMCPY_WITH_OFFSET
	ret

LoadLevelNightCityGraphics::
.tiles:
	ld bc, LevelCityTiles
	ld hl, _VRAM9000
	ld de, LevelCityTilesEnd - LevelCityTiles
	call MEMCPY
.tilemap:
	ld bc, LevelCityMap
	ld hl, _SCRN0 + $C0
	ld de, LevelCityMapEnd - LevelCityMap
	call MEMCPY
    ; Stars
    ld hl, $9821
    ld [hl], STAR_TILE
    ld hl, $982D
    ld [hl], STAR_TILE
    ld hl, $9844
    ld [hl], STAR_TILE
    ld hl, $984A
    ld [hl], STAR_TILE
    ld hl, $9853
    ld [hl], STAR_TILE
    ld hl, $9866
    ld [hl], STAR_TILE
    ld hl, $986F
    ld [hl], STAR_TILE
    ; UFO
    ld bc, UFOMap
    ld hl, $9897
    ld de, 2
    ld a, $BA
	call MEMCPY_WITH_OFFSET
	ret

LoadLevelDesertGraphics::
.tiles:
	ld bc, LevelDesertTiles
	ld hl, _VRAM9000
	ld de, LevelDesertTilesEnd - LevelDesertTiles
	call MEMCPY
.tilemap:
    ; Add in desert
	ld bc, LevelDesertMap
	ld hl, $98E0
	ld de, LevelDesertMapEnd - LevelDesertMap
	call MEMCPY
    ; Add in sun
    call SpawnSun
    ret

LoadLevelNightDesertGraphics::
.tiles:
	ld bc, LevelDesertTiles
	ld hl, _VRAM9000
	ld de, LevelDesertTilesEnd - LevelDesertTiles
	call MEMCPY
.tilemap:
    ld bc, LevelDesertMap
	ld hl, $98E0
	ld de, LevelDesertMapEnd - LevelDesertMap
	call MEMCPY
    ld hl, $9826
    ld [hl], STAR_TILE
    ld hl, $9832
    ld [hl], STAR_TILE
    ld hl, $9842
    ld [hl], STAR_TILE
    ld hl, $984E
    ld [hl], STAR_TILE
    ld hl, $9864
    ld [hl], STAR_TILE
    ld hl, $9871
    ld [hl], STAR_TILE
    ; Add in sun
    jp SpawnSun

LoadLevelShowdownGraphics::
.tiles:
	ld bc, LevelShowdownTiles
	ld hl, _VRAM9000
	ld de, LevelShowdownTilesEnd - LevelShowdownTiles
	call MEMCPY
.tilemap:
    ; Add in rain layer 1
	ld bc, LevelShowdownMap
	ld hl, _SCRN0
    ld d, 14 ; height of rain
    ld e, SCRN_X_B
	call MEMCPY_SINGLE_SCREEN
    ; Add in rain layer 2
    ld bc, LevelShowdownMap
    ld d, 14 ; height of rain
    ld e, SCRN_X_B
	call MEMCPY_SINGLE_SCREEN
    ; Fill in dark clouds space
    ld hl, _SCRN0
    ld bc, $60
    ld d, $85
    call SetInRange
    ; Add scrolling rain clouds
	ld bc, CloudsMap + $20 * 2
	ld de, $40
	ld a, $80
	call MEMCPY_WITH_OFFSET
    ; Add scrolling water
	ld bc, ShowdownWaterMap
	ld hl, $9BA0
	ld de, ShowdownWaterMapEnd - ShowdownWaterMap
	ld a, $A0
	call MEMCPY_WITH_OFFSET
    ret

SpawnSun::
    ld bc, SunMap
	ld hl, SUN_ADDRESS
    ld de, 4
    ld a, SUN_TILE_OFFSET
	call MEMCPY_WITH_OFFSET
	ld hl, SUN_ADDRESS + $20
    ld de, 4
	call MEMCPY_WITH_OFFSET
	ld hl, SUN_ADDRESS + $40
    ld de, 4
	call MEMCPY_WITH_OFFSET
	ld hl, SUN_ADDRESS + $60
    ld de, 4
	call MEMCPY_WITH_OFFSET
    ret

SpawnCountdown::
	ld b, 2
	call RequestOAMSpace
    ret z
.availableSpace:
    ld a, b
	ld [wCountdownOAM], a
    ld hl, wOAM
    ; ld a, [wCountdownOAM]
    ADD_A_TO_HL
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X
    ld [hli], a
    ld a, EMPTY_TILE
    ld [hl], a
    inc l
    inc l
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X+8
    ld [hli], a
    ld a, EMPTY_TILE
    ld [hl], a
	ret

ClearCountdown::
    ld hl, wOAM
    ld a, [wCountdownOAM]
    ADD_TO_HL [wCountdownOAM]
    ld bc, COUNTDOWN_OAM_BYTES
    call ResetHLInRange
    ret

IsCountdownAtBalloonPop::
    ; Returns z flag as yes / nz flag as no
    ld a, [wCountdownFrame]
    cp a, COUNTDOWN_FRAME_4
    ret

Countdown::
    ; Returns z flag as still running / nz flag as finished
    ; Frame speed
.frameSpeed:
    ld a, [wCountdownFrame]
    cp a, COUNTDOWN_FRAME_4
    jr nc, .countdownBalloonPopSpeed
.countdownSpeed:
    ldh a, [hGlobalTimer]
    and COUNTDOWN_SPEED
    jp nz, .hasNotFinished
    jr .endFrameSpeed
.countdownBalloonPopSpeed:
    ldh a, [hGlobalTimer]
    and COUNTDOWN_BALLOON_POP_SPEED
    jp nz, .hasNotFinished
.endFrameSpeed:

    ; Update frame
.frames:
    ld hl, wOAM+2
    ADD_TO_HL [wCountdownOAM]
    ld a, [wCountdownFrame]
.frame0:
    cp a, COUNTDOWN_FRAME_0
    jr nz, .frame1
    call CountdownSound
    ld a, COUNTDOWN_3_TILE_1
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, COUNTDOWN_3_TILE_2
    ld [hl], a
    jr .endFrame
.frame1:
    cp a, COUNTDOWN_FRAME_1
    jr nz, .frame2
    call CountdownSound
    ld a, COUNTDOWN_2_TILE_1
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, COUNTDOWN_2_TILE_2
    ld [hl], a
    jr .endFrame
.frame2:
    cp a, COUNTDOWN_FRAME_2
    jr nz, .frame3
    call CountdownSound
    ld a, COUNTDOWN_1_TILE_1
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, COUNTDOWN_1_TILE_2
    ld [hl], a
    jr .endFrame
.frame3:
    cp a, COUNTDOWN_FRAME_3
    jr nz, .frame4
    ld a, COUNTDOWN_NEUTRAL_BALLOON_TILE
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, COUNTDOWN_NEUTRAL_BALLOON_TILE
    ld [hli], a
    ld a, OAMF_XFLIP
    ld [hl], a
    jr .endFrame
.frame4:
    cp a, COUNTDOWN_FRAME_4
    jr nz, .frame5
    call PopSound
    ld a, POP_BALLOON_FRAME_0_TILE
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, POP_BALLOON_FRAME_0_TILE
    ld [hl], a
    jr .endFrame
.frame5:
    cp a, COUNTDOWN_FRAME_5
    jr nz, .frame6
    ld a, POP_BALLOON_FRAME_1_TILE
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, POP_BALLOON_FRAME_1_TILE
    ld [hl], a
    jr .endFrame
.frame6:
    cp a, COUNTDOWN_FRAME_6
    jr nz, .hasFinished
    call ClearCountdown
    ; jr .endFrame
.endFrame:
    ld a, [wCountdownFrame]
    inc a 
    ld [wCountdownFrame], a
.hasNotFinished:
    xor a ; ld a, 0
    ret
.hasFinished:
    ld a, 1
    and a
    ret

; UPDATE GAME COUNTDOWN ======================================

UpdateGameCountdown::

    UPDATE_GLOBAL_TIMER
    call IncrementScrollOffset

.checkFadeIn:
    ; Only in endless
    ld a, [wLevel]
    cp a, LEVEL_ENDLESS
    jr nz, .endCheckFadeIn
    call FadeInPalettes
    ret z
.hasFadedIn:
.endCheckFadeIn:

.checkCountdownAnimation:
    call Countdown
    jp nz, GameLoop
.endCheckCountdownAnimation:
    ret

; UPDATE GAME ======================================

UpdateGame::

.tryToUnpause:
    ldh a, [hPaused]
	cp a, 0
	jr z, .isNotPaused
    ldh a, [rBGP]
    cp a, 0
    jr z, .isNotPaused
.isPaused:
    call ClearSound
	call ReadController
	ldh a, [hControllerPressed]
    and PADF_START
    ret z
	xor a ; ld a, 0
	ldh [hPaused], a
    ret
.isNotPaused:

.updateSprites:
    call PlayerUpdate
    call BulletUpdate
    call EnemyUpdate
.rest:
    UPDATE_GLOBAL_TIMER

.modeSpecific:
    ld a, [wSelectedMode]
    cp a, CLASSIC_MODE
    jr nz, .endlessMode
.classicMode:
    call LevelDataHandler
    ld a, [wLevel]
    cp a, LEVEL_BOSS
    call z, BossUpdate
    jr .endModeSpecific
.endlessMode:
    call EndlessUpdate
.endModeSpecific:
    call RefreshWindow
    call IncrementScrollOffset
    jp _hUGE_dosound