INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "balloonConstants.inc"

COUNTDOWN_OAM_SPRITES EQU 2
COUNTDOWN_OAM_BYTES EQU COUNTDOWN_OAM_SPRITES * 4
COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 40
COUNTDOWN_SPEED EQU %00011111
COUNTDOWN_BALLOON_POP_SPEED EQU %00000111
COUNTDOWN_3_TILE_1 EQU $36
COUNTDOWN_3_TILE_2 EQU $38
COUNTDOWN_2_TILE_1 EQU $32
COUNTDOWN_2_TILE_2 EQU $34
COUNTDOWN_1_TILE_1 EQU $2E
COUNTDOWN_1_TILE_2 EQU $30
COUNTDOWN_NEUTRAL_BALLOON_TILE EQU $3A
CITY_STAR_TILE EQU $48
DESERT_STAR_TILE EQU $4E

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
    
LoadLevelCityGraphics::
	ld bc, LevelCityTiles
	ld hl, _VRAM9000
	ld de, LevelCityTilesEnd - LevelCityTiles
	call MEMCPY
	ld bc, LevelCityMap
	ld hl, _SCRN0
	ld de, LevelCityMapEnd - LevelCityMap
	call MEMCPY
	ret

LoadLevelNightCityGraphics::
	ld bc, LevelCityTiles
	ld hl, _VRAM9000
	ld de, LevelCityTilesEnd - LevelCityTiles
	call MEMCPY
	ld bc, LevelCityMap
	ld hl, _SCRN0
	ld de, LevelCityMapEnd - LevelCityMap
	call MEMCPY
    ld hl, $9821
    ld [hl], CITY_STAR_TILE
    ld hl, $982D
    ld [hl], CITY_STAR_TILE
    ld hl, $9844
    ld [hl], CITY_STAR_TILE
    ld hl, $984A
    ld [hl], CITY_STAR_TILE
    ld hl, $9853
    ld [hl], CITY_STAR_TILE
    ld hl, $9866
    ld [hl], CITY_STAR_TILE
    ld hl, $986F
    ld [hl], CITY_STAR_TILE
	ret

LoadLevelDesertGraphics::
	ld bc, LevelDesertTiles
	ld hl, _VRAM9000
	ld de, LevelDesertTilesEnd - LevelDesertTiles
	call MEMCPY
	ld bc, LevelDesertMap
	ld hl, _SCRN0
	ld de, LevelDesertMapEnd - LevelDesertMap
	call MEMCPY
    ret

LoadLevelNightDesertGraphics::
	ld bc, LevelDesertTiles
	ld hl, _VRAM9000
	ld de, LevelDesertTilesEnd - LevelDesertTiles
	call MEMCPY
    ld bc, LevelDesertMap
	ld hl, _SCRN0
	ld de, LevelDesertMapEnd - LevelDesertMap
	call MEMCPY
    ld hl, $9826
    ld [hl], DESERT_STAR_TILE
    ld hl, $9832
    ld [hl], DESERT_STAR_TILE
    ld hl, $9842
    ld [hl], DESERT_STAR_TILE
    ld hl, $984E
    ld [hl], DESERT_STAR_TILE
    ld hl, $9864
    ld [hl], DESERT_STAR_TILE
    ld hl, $9871
    ld [hl], DESERT_STAR_TILE
    ret

LoadLevelShowdownGraphics::
	ld bc, LevelShowdownTiles
	ld hl, _VRAM9000
	ld de, LevelShowdownTilesEnd - LevelShowdownTiles
	call MEMCPY
	ld bc, LevelShowdownMap
	ld hl, _SCRN0
    ld d, SCRN_VY_B
	call MEMCPY_SINGLE_SCREEN

    ld bc, RainCloudsTiles
	ld hl, _VRAM8800
	ld de, RainCloudsTilesEnd - RainCloudsTiles
	call MEMCPY
	ld bc, RainCloudsMap
	ld hl, _SCRN0
	ld de, RainCloudsMapEnd - RainCloudsMap
	ld a, $80
	call MEMCPY_WITH_OFFSET

    ld bc, ShowdownWaterTiles
	ld hl, _VRAM8800 + $100
	ld de, ShowdownWaterTilesEnd - ShowdownWaterTiles
	call MEMCPY
	ld bc, ShowdownWaterMap
	ld hl, $9BA0
	ld de, ShowdownWaterMapEnd - ShowdownWaterMap
	ld a, $90
	call MEMCPY_WITH_OFFSET
    ret

LoadLevelBossGraphics::
	ld bc, CloudsTiles
	ld hl, _VRAM8800
	ld de, CloudsTilesEnd - CloudsTiles
	call MEMCPY
    ld hl, _VRAM9000
    ld bc, $10
    call ResetHLInRange
	ld bc, CloudsMap
	ld hl, $99C0
	ld de, CloudsMapEnd - CloudsMap
	ld a, $80
	call MEMCPY_WITH_OFFSET
    ret

SpawnCountdown::
	ld b, 2
	call RequestOAMSpace
    ret z
    ld a, b
	ld [wCountdownOAM], a
	SET_HL_TO_ADDRESS wOAM, wCountdownOAM
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X
    ld [hli], a
    ld [hl], EMPTY_TILE
    inc l
    inc l
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X+8
    ld [hli], a
    ld [hl], EMPTY_TILE
	ret

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
    SET_HL_TO_ADDRESS wOAM, wCountdownOAM
    ld bc, COUNTDOWN_OAM_BYTES
    call ResetHLInRange
.gameLoop:
    jp GameLoop

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
    call LevelDataHandler
    call RefreshWindow
    call IncrementScrollOffset
    call SoundUpdate
    call _hUGE_dosound
    ret