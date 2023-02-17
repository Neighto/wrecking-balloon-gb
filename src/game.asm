INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "tileConstants.inc"

COUNTDOWN_OAM_SPRITES EQU 2
COUNTDOWN_OAM_BYTES EQU COUNTDOWN_OAM_SPRITES * 4
COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 40
COUNTDOWN_SPEED EQU %00011111
COUNTDOWN_BALLOON_POP_SPEED EQU %00000111

COUNTDOWN_FRAME_0 EQU 0
COUNTDOWN_FRAME_1 EQU 1
COUNTDOWN_FRAME_2 EQU 2
COUNTDOWN_FRAME_3 EQU 3
COUNTDOWN_FRAME_4 EQU 4 ; Becomes balloon pop instead
COUNTDOWN_FRAME_5 EQU 5
COUNTDOWN_FRAME_6 EQU 6 ; Clear

CITY_TILES_OFFSET EQU 1 ; So first tile is empty

SUN_ADDRESS EQU $9848

SECTION "game vars", WRAM0
    wCountdownFrame:: DB
    wCountdownOAM:: DB

SECTION "game", ROM0

InitializeGame::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a
	ld [wCountdownFrame], a
    ret

LoadGameSpriteAndMiscellaneousTiles::
	ld bc, GameSpriteTiles
	ld hl, _VRAM8000+$20 ; Offset first 2 tiles as empty
	ld de, GameSpriteTilesEnd - GameSpriteTiles
    call MEMCPY
    ld bc, MiscellaneousTiles
	ld hl, _VRAM8800
	ld de, MiscellaneousTilesEnd - MiscellaneousTiles
	jp MEMCPY

LoadLevelClouds:
    ; hl = Address
    ld a, CLOUDS_TILE_OFFSET
    ld [wMemcpyTileOffset], a
    ld bc, CloudsMap + $04 * 9
    ld d, $20
    ld e, 4
    call MEMCPY_SIMPLE_PATTERN_WITH_OFFSET
    ld bc, CloudsMap + $04 * 10
    ld d, $20
    ld e, 4
    jp MEMCPY_SIMPLE_PATTERN_WITH_OFFSET

LoadLevelCityGraphicsCommon:
.tiles:
	ld bc, LevelCityTiles
	ld hl, _VRAM9000 + CITY_TILES_OFFSET * TILE_BYTES
	ld de, LevelCityTilesEnd - LevelCityTiles
	call MEMCPY
.tilemap:
    ; Add city
	ld bc, LevelCityMap
	ld hl, _SCRN0 + $C0
	ld de, LevelCityMapEnd - LevelCityMap
    ld a, CITY_TILES_OFFSET
    ld [wMemcpyTileOffset], a
	call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
    ; Add scrolling clouds
    ld hl, $99C0
    jp LoadLevelClouds
    
LoadLevelCityGraphics::
    call LoadLevelCityGraphicsCommon
    ; City Planes
    ld bc, CityPlaneMap
	ld hl, $9831 ; City Plane address
    ld de, 3
    ld a, PLANE_TILE_OFFSET
	call MEMCPY_WITH_OFFSET
    ld bc, CityPlaneMap
	ld hl, $9886 ; City Plane address
    ld de, 3
    ld a, PLANE_TILE_OFFSET
	call MEMCPY_WITH_OFFSET
    ld bc, CityPlaneMap
    ld hl, $987B ; City Plane address
    ld de, 5
    ld a, PLANE_TILE_OFFSET
	jp MEMCPY_WITH_OFFSET

LoadLevelNightCityGraphics::
    call LoadLevelCityGraphicsCommon
    ; Stars
    ld a, STAR_TILE_OFFSET
    ld hl, $9821
    ld [hl], a
    ld hl, $982D
    ld [hl], a
    ld hl, $9844
    ld [hl], a
    ld hl, $984A
    ld [hl], a
    ld hl, $9853
    ld [hl], a
    ld hl, $9866
    ld [hl], a
    ld hl, $986F
    ld [hl], a
    ; UFO
    ld bc, UFOMap
    ld hl, $9897
    ld de, 2
    ld a, UFO_TILE_OFFSET
	jp MEMCPY_WITH_OFFSET

LoadLevelDesertGraphicsCommon:
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
    ; Add scrolling clouds
    ld hl, $99C0
    jp LoadLevelClouds

LoadLevelDesertGraphics::
    jp LoadLevelDesertGraphicsCommon

LoadLevelNightDesertGraphics::
    call LoadLevelDesertGraphicsCommon
    ; Add stars
    ld a, STAR_TILE_OFFSET
    ld hl, $9826
    ld [hl], a
    ld hl, $9832
    ld [hl], a
    ld hl, $9842
    ld [hl], a
    ld hl, $984E
    ld [hl], a
    ld hl, $9864
    ld [hl], a
    ld hl, $9871
    ld [hl], a
    ret

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
    ld d, DARK_GREY_BKG_TILE
    call SetInRange
    ; Add scrolling rain clouds
    ld bc, CloudsMap + $04 * 2
	ld d, $20
	ld e, 4
	ld a, CLOUDS_TILE_OFFSET
	ld [wMemcpyTileOffset], a
	call MEMCPY_SIMPLE_PATTERN_WITH_OFFSET
    ld bc, CloudsMap + $04 * 3
	ld d, $20
	ld e, 4
	call MEMCPY_SIMPLE_PATTERN_WITH_OFFSET
    ; Add scrolling mountains
	ld bc, ShowdownWaterMap
	ld hl, $9BA0
	ld de, ShowdownWaterMapEnd - ShowdownWaterMap
	ld a, SHOWDOWN_MOUTAINS_OFFSET
    call MEMCPY_WITH_OFFSET
    ; Add scrolling clouds
    jp LoadLevelClouds

    ld bc, CloudsMap + $04 * 9
	ld d, $20
	ld e, 4
	call MEMCPY_SIMPLE_PATTERN_WITH_OFFSET
    ld bc, CloudsMap + $04 * 10
	ld d, $20
	ld e, 4
	jp MEMCPY_SIMPLE_PATTERN_WITH_OFFSET

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
	jp MEMCPY_WITH_OFFSET

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
    ld a, WHITE_SPR_TILE
    ld [hli], a
    inc l
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X + 8
    ld [hli], a
    ld a, WHITE_SPR_TILE
    ld [hl], a
	ret

ClearCountdown::
    ld hl, wOAM
    ld a, [wCountdownOAM]
    ADD_TO_HL [wCountdownOAM]
    ld bc, COUNTDOWN_OAM_BYTES
    jp ResetHLInRange

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
    ld a, [wCountdownFrame]
.frame0:
    cp a, COUNTDOWN_FRAME_0
    jr nz, .frame1
    call CountdownSound
    ld b, COUNTDOWN_3_TILE_1
    ld c, COUNTDOWN_3_TILE_2
    jr .updateFrame
.frame1:
    cp a, COUNTDOWN_FRAME_1
    jr nz, .frame2
    call CountdownSound
    ld b, COUNTDOWN_2_TILE_1
    ld c, COUNTDOWN_2_TILE_2
    jr .updateFrame
.frame2:
    cp a, COUNTDOWN_FRAME_2
    jr nz, .frame3
    call CountdownSound
    ld b, COUNTDOWN_1_TILE_1
    ld c, COUNTDOWN_1_TILE_2
    jr .updateFrame
.frame3:
    cp a, COUNTDOWN_FRAME_3
    jr nz, .frame4
    ld hl, wOAM+7
    ADD_TO_HL [wCountdownOAM]
    ld a, OAMF_XFLIP
    ld [hl], a
    ld b, COUNTDOWN_NEUTRAL_BALLOON_TILE
    ld c, COUNTDOWN_NEUTRAL_BALLOON_TILE
    jr .updateFrame
.frame4:
    cp a, COUNTDOWN_FRAME_4
    jr nz, .frame5
    call PopSound
    ld b, POP_BALLOON_FRAME_0_TILE
    ld c, POP_BALLOON_FRAME_0_TILE
    jr .updateFrame
.frame5:
    cp a, COUNTDOWN_FRAME_5
    jr nz, .frame6
    ld b, POP_BALLOON_FRAME_1_TILE
    ld c, POP_BALLOON_FRAME_1_TILE
    jr .updateFrame
.frame6:
    cp a, COUNTDOWN_FRAME_6
    jr nz, .hasFinished
    call ClearCountdown
    jr .nextFrame
.updateFrame:
    ld hl, wOAM+2
    ADD_TO_HL [wCountdownOAM]
    ld a, b
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, c
    ld [hl], a
.nextFrame:
    ld a, [wCountdownFrame]
    inc a 
    ld [wCountdownFrame], a
.hasNotFinished:
    xor a ; ld a, 0
    ret
.hasFinished:
    or a, 1
    ret

; UPDATE GAME COUNTDOWN ======================================

UpdateGameCountdown::

    UPDATE_GLOBAL_TIMER
    call IncrementScrollOffset

.checkFadeIn:
    ; Only in endless
    ldh a, [hLevel]
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
	cp a, PAUSE_OFF
	jr z, .isNotPaused
    cp a, PAUSE_ON
    jr z, .isPaused
.pauseToggled:
    call ClearSound
    ld a, PAUSE_ON
    ldh [hPaused], a
.isPaused:
	call ReadController
	ldh a, [hControllerPressed]
    and PADF_START
    ret z
	ld a, PAUSE_OFF
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
    ldh a, [hLevel]
    cp a, LEVEL_BOSS
    call z, BossUpdate
    jr .endModeSpecific
.endlessMode:
    call EndlessUpdate
.endModeSpecific:
    call RefreshWindow
    call IncrementScrollOffset
    jp _hUGE_dosound