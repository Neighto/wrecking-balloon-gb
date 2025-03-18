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
ROAD_TILES_OFFSET EQU 1 ; So first tile is empty
HYDRANT_TILE_OFFSET EQU $26
LAMP_OFFSET EQU $20

RAIN_HEIGHT_IN_TILES EQU 14

SHOWDOWN_MOUNTAIN_ADDRESS EQU $9B60
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
    ld hl, _VRAM8000 + TILE_BYTES * 2 ; Offset first 2 tiles as empty
    ld de, GameSpriteTilesEnd - GameSpriteTiles
    call MEMCPY
    ld bc, MiscellaneousTiles
    ld hl, _VRAM8800
    ld de, MiscellaneousTilesEnd - MiscellaneousTiles
    jp MEMCPY

; Arg: HL = Destination address
LoadLevelClouds:
    ld bc, CloudsMap + CLOUDS_WHITE_1_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ld bc, CloudsMap + CLOUDS_WHITE_2_OFFSET
    jp MEMCPY_PATTERN_CLOUDS

LoadLevelCityGraphicsCommon:
    ; TILES
    ld bc, LevelCityTiles
    ld hl, _VRAM9000 + CITY_TILES_OFFSET * TILE_BYTES
    ld de, LevelCityTilesEnd - LevelCityTiles
    call MEMCPY
    ; TILEMAP
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

; Arg: HL = Destination address
LoadLamp::
    ld a, LAMP_OFFSET
    ld [wMemcpyTileOffset], a
    ld bc, LampMap
    ld d, 6
    ld e, 1
    jp MEMCPY_SINGLE_SCREEN_WITH_OFFSET

; Arg: HL = Destination address
LoadHydrant::
    ld a, HYDRANT_TILE_OFFSET
    ld [wMemcpyTileOffset], a
    ld bc, HydrantMap
    ld d, 3
    ld e, 2
    jp MEMCPY_SINGLE_SCREEN_WITH_OFFSET

; Arg: HL = Destination address
LoadRoadCommon::
    push hl
    ; TILES
    ld bc, CutsceneTiles
    ld hl, _VRAM9000 + ROAD_TILES_OFFSET * TILE_BYTES
    ld de, CutsceneTilesEnd - CutsceneTiles
    call MEMCPY
    ; TILEMAP
    ; Add road
    pop hl
    ld bc, CloudsMap + CLOUDS_CUTSCENE_1_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ld bc, CloudsMap + CLOUDS_CUTSCENE_2_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ld bc, CloudsMap + CLOUDS_CUTSCENE_3_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ld bc, CloudsMap + CLOUDS_CUTSCENE_4_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ld bc, CloudsMap + CLOUDS_CUTSCENE_5_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ld bc, CloudsMap + CLOUDS_CUTSCENE_6_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ld bc, CloudsMap + CLOUDS_CUTSCENE_7_OFFSET
    jp MEMCPY_PATTERN_CLOUDS

; *************************************************************
; LoadLevelCityGraphics
; *************************************************************
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

; *************************************************************
; LoadLevelNightCityGraphics
; *************************************************************
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

; *************************************************************
; LoadLevelDesertGraphics
; *************************************************************
LoadLevelDesertGraphics::
    ; TILES
    ld bc, LevelDesertTiles
    ld hl, _VRAM9000
    ld de, LevelDesertTilesEnd - LevelDesertTiles
    call MEMCPY
    ; TILEMAP
    ; Add in desert
    ld bc, LevelDesertMap
    ld hl, $98E0
    ld de, LevelDesertMapEnd - LevelDesertMap
    call MEMCPY
    ; Add in sun
    ld hl, SUN_ADDRESS
    ld a, SUN_TILE_OFFSET
    ld [wMemcpyTileOffset], a
    ld bc, SunMap
    ld d, 4
    ld e, d
    call MEMCPY_SINGLE_SCREEN_WITH_OFFSET
    ; Add scrolling clouds
    ld hl, $99C0
    jp LoadLevelClouds

; *************************************************************
; LoadLevelNightDesertGraphics
; *************************************************************
LoadLevelNightDesertGraphics::
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
    ; Add desert
    jp LoadLevelDesertGraphics

; *************************************************************
; LoadLevelShowdownGraphics
; *************************************************************
LoadLevelShowdownGraphics::
    ; TILES
    ld bc, LevelShowdownTiles
    ld hl, _VRAM9000
    ld de, LevelShowdownTilesEnd - LevelShowdownTiles
    call MEMCPY
    ; TILEMAP
    ; Add in rain layer 1
    ld bc, LevelShowdownMap
    ld hl, _SCRN0
    ld d, RAIN_HEIGHT_IN_TILES
    ld e, SCRN_X_B
    call MEMCPY_SINGLE_SCREEN
    ; Add in rain layer 2
    ld bc, LevelShowdownMap
    ld d, RAIN_HEIGHT_IN_TILES
    ld e, SCRN_X_B
    call MEMCPY_SINGLE_SCREEN
    ; Fill in dark clouds space
    ld hl, _SCRN0
    ld bc, SCRN_VX_B * 3
    ld d, DARK_GREY_BKG_TILE
    call SetInRange
    ; Add scrolling rain clouds
    ld bc, CloudsMap + CLOUDS_DARK_INV_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ld bc, CloudsMap + CLOUDS_LIGHT_INV_OFFSET
    call MEMCPY_PATTERN_CLOUDS
    ; Add scrolling mountains
    ld bc, ShowdownMountainsMap
    ld hl, SHOWDOWN_MOUNTAIN_ADDRESS
    ld de, ShowdownMountainsMapEnd - ShowdownMountainsMap
    ld a, SHOWDOWN_MOUTAINS_OFFSET
    call MEMCPY_WITH_OFFSET
    ; Add scrolling clouds
    jp LoadLevelClouds

; *************************************************************
; SPAWNCOUNTDOWN
; *************************************************************
SpawnCountdown::
    ld b, COUNTDOWN_OAM_SPRITES
    ld hl, wCountdownOAM
    call RequestOAMAndSetOAMOffset
    ret z
    ; Has available space
    ld b, COUNTDOWN_START_Y
    ld c, COUNTDOWN_START_X
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a
    ld a, WHITE_SPR_TILE
    ld [hli], a
    inc hl
    ld a, b
    ld [hli], a
    ld a, c
    add a, 8
    ld [hli], a
    ld a, WHITE_SPR_TILE
    ld [hl], a
    ret

; Ret: Z/NZ = Failed / succeeded respectively
IsCountdownAtBalloonPop::
    ld a, [wCountdownFrame]
    cp a, COUNTDOWN_FRAME_4
    ret

; *************************************************************
; COUNTDOWN
; *************************************************************
; Ret: Z/NZ = Still running / finished respectively
Countdown::
    ; Frame speed
    ld a, [wCountdownFrame]
    cp a, COUNTDOWN_FRAME_4
    ldh a, [hGlobalTimer]
    jr nc, .countdownBalloonPopSpeed
.countdownSpeed:
    and COUNTDOWN_SPEED
    jp nz, .hasNotFinished
    jr .frames
.countdownBalloonPopSpeed:
    and COUNTDOWN_BALLOON_POP_SPEED
    jp nz, .hasNotFinished
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
    ld hl, wOAM + 7
    ADD_TO_HL [wCountdownOAM]
    ld a, OAMF_XFLIP
    ld [hl], a
    ld b, COUNTDOWN_NEUTRAL_BALLOON_TILE
    ld c, b
    jr .updateFrame
.frame4:
    cp a, COUNTDOWN_FRAME_4
    jr nz, .frame5
    call PopSound
    ld b, POP_BALLOON_FRAME_0_TILE
    ld c, b
    jr .updateFrame
.frame5:
    cp a, COUNTDOWN_FRAME_5
    jr nz, .frame6
    ld b, POP_BALLOON_FRAME_1_TILE
    ld c, b
    jr .updateFrame
.frame6:
    cp a, COUNTDOWN_FRAME_6
    jr nz, .hasFinished
    ; Clear
    ld hl, wOAM
    ADD_TO_HL [wCountdownOAM]
    ld bc, COUNTDOWN_OAM_BYTES
    call ResetHLInRange
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

; *************************************************************
; UPDATEGAMECOUNTDOWN
; *************************************************************
UpdateGameCountdown::
    ; Timer
    UPDATE_GLOBAL_TIMER

    call IncrementScrollOffset

    ; Check fade in (only endless)
    ldh a, [hLevel]
    cp a, LEVEL_ENDLESS
    jr nz, .isFadedIn
    call FadeInPalettes
    ret z
.isFadedIn:

    ; Check countdown animation and jump to main game loop when done
    call Countdown
    jp nz, GameLoop
    ret

; *************************************************************
; UPDATEGAME
; *************************************************************
UpdateGame::
    ; Check paused
    ldh a, [hPaused]
    cp a, PAUSE_OFF
    jr z, .isNotPaused
    cp a, PAUSE_ON
    jr z, .isPaused
    ; Pause transition state PAUSE_TOGGLED
    ld a, PAUSE_ON
    ldh [hPaused], a
    call ChDACs.mute
    jp ShowPauseWindow
.isPaused:
    call ShowPauseWindow.skipResetTimer
    call ReadController
    ldh a, [hControllerPressed]
    and PADF_START
    ret z
    ld a, PAUSE_OFF
    ldh [hPaused], a
    call ChDACs.unmute
    jp ToggleWindow.winon
.isNotPaused:

    call _hUGE_dosound

    ; Update sprites
    call PlayerUpdate
    call EnemyUpdate
    call BulletUpdate

    ; Timer
    UPDATE_GLOBAL_TIMER

    ; Handle mode specific
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

    ; Handle common
    call RefreshWindow
    jp IncrementScrollOffset