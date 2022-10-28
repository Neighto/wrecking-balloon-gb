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

COUNTDOWN_NEUTRAL_BALLOON_TILE EQU $1E
STAR_TILE EQU $99
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
    ld a, $AF
	call MEMCPY_WITH_OFFSET
    ld bc, CityPlaneMap
	ld hl, $9886 ; City Plane address
    ld de, 3
    ld a, $AF
	call MEMCPY_WITH_OFFSET
    ld bc, CityPlaneMap
    ld hl, $987B ; City Plane address
    ld de, 5
    ld a, $AF
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
    ld a, $BC
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
    call SpawnSun
    ret

LoadLevelShowdownGraphics::
.tiles:
	ld bc, LevelShowdownTiles
	ld hl, _VRAM9000
	ld de, LevelShowdownTilesEnd - LevelShowdownTiles
	call MEMCPY
.tilemap:
    ; Add in rain
	ld bc, LevelShowdownMap
	ld hl, _SCRN0
    ld d, SCRN_VY_B - 4 ; height of scrolling water on the bottom
    ld e, SCRN_X_B
	call MEMCPY_SINGLE_SCREEN
    ; Add scrolling rain clouds
	ld bc, RainCloudsMap
	ld hl, _SCRN0
	ld de, RainCloudsMapEnd - RainCloudsMap
	ld a, $9A
	call MEMCPY_WITH_OFFSET
    ; Add scrolling water
	ld bc, ShowdownWaterMap
	ld hl, $9BA0
	ld de, ShowdownWaterMapEnd - ShowdownWaterMap
	ld a, $A2
	call MEMCPY_WITH_OFFSET
    ret

SpawnSun::
    ld bc, SunMap
	ld hl, SUN_ADDRESS
    ld de, 4
    ld a, $8C
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

; UPDATE GAME COUNTDOWN ======================================

UpdateGameCountdown::
    UPDATE_GLOBAL_TIMER
    call IncrementScrollOffset

.checkCountdownAnimation:
    ld a, [wCountdownFrame]
    cp a, 4
    jr nc, .countdownBalloonPopSpeed
.countdownSpeed:
    ldh a, [hGlobalTimer]
    and COUNTDOWN_SPEED
    ret nz
    jr .frames
.countdownBalloonPopSpeed:
    ldh a, [hGlobalTimer]
    and COUNTDOWN_BALLOON_POP_SPEED
    ret nz
.frames:
    ld a, [wCountdownFrame]
    cp a, 0
    jr nz, .frame0End
.frame0:
    inc a 
    ld [wCountdownFrame], a
    call CountdownSound
    SET_HL_TO_ADDRESS wOAM+2, wCountdownOAM
    ld [hl], COUNTDOWN_3_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wCountdownOAM
    ld [hl], COUNTDOWN_3_TILE_2
    ret
.frame0End:
    cp a, 1
    jr nz, .frame1End
.frame1:
    inc a 
    ld [wCountdownFrame], a
    call CountdownSound
    SET_HL_TO_ADDRESS wOAM+2, wCountdownOAM
    ld [hl], COUNTDOWN_2_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wCountdownOAM
    ld [hl], COUNTDOWN_2_TILE_2
    ret
.frame1End:
    cp a, 2
    jr nz, .frame2End
.frame2:
    inc a 
    ld [wCountdownFrame], a
    call CountdownSound
    SET_HL_TO_ADDRESS wOAM+2, wCountdownOAM
    ld [hl], COUNTDOWN_1_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wCountdownOAM
    ld [hl], COUNTDOWN_1_TILE_2
    ret
.frame2End:
    cp a, 3
    jr nz, .frame3End
.frame3:
    inc a 
    ld [wCountdownFrame], a
    SET_HL_TO_ADDRESS wOAM+2, wCountdownOAM
    ld [hl], COUNTDOWN_NEUTRAL_BALLOON_TILE
    SET_HL_TO_ADDRESS wOAM+6, wCountdownOAM
    ld [hl], COUNTDOWN_NEUTRAL_BALLOON_TILE
    inc l 
    ld [hl], OAMF_XFLIP
    ret
.frame3End:
    cp a, 4
    jr nz, .frame4End
.frame4:
    inc a 
    ld [wCountdownFrame], a
    call PopSound
    SET_HL_TO_ADDRESS wOAM+2, wCountdownOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    SET_HL_TO_ADDRESS wOAM+6, wCountdownOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    ret
.frame4End:
    cp a, 5
    jr nz, .frame5End
.frame5:
    inc a 
    ld [wCountdownFrame], a
    SET_HL_TO_ADDRESS wOAM+2, wCountdownOAM
    ld [hl], POP_BALLOON_FRAME_1_TILE
    SET_HL_TO_ADDRESS wOAM+6, wCountdownOAM
    ld [hl], POP_BALLOON_FRAME_1_TILE
    ret
.frame5End:
.clear:
    inc a 
    ld [wCountdownFrame], a
    call ClearCountdown
.gameLoop:
    jp PreGameLoop

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
    cp a, 0
    jr nz, .endlessMode
.classicMode:
    call LevelDataHandler
    ld a, [wLevel]
    cp a, BOSS_LEVEL
    call z, BossUpdate
    jr .endModeSpecific
.endlessMode:
    call EndlessUpdate
.endModeSpecific:
    call RefreshWindow
    call IncrementScrollOffset
    jp _hUGE_dosound_with_end