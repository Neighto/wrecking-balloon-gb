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
COUNTDOWN_3_TILE_1 EQU $36
COUNTDOWN_3_TILE_2 EQU $38
COUNTDOWN_2_TILE_1 EQU $32
COUNTDOWN_2_TILE_2 EQU $34
COUNTDOWN_1_TILE_1 EQU $2E
COUNTDOWN_1_TILE_2 EQU $30
COUNTDOWN_NEUTRAL_BALLOON_TILE EQU $3A
STAR_TILE EQU $99
SUN_ADDRESS EQU $9848

ENDLESS_DELAY_TIMER_RESET_TIME EQU 127
ENDLESS_TIMER_RESET_TIME EQU %00000111
ENDLESS_PREPARE_ENEMY_TIME EQU 60 ; Must be less than ENDLESS_DELAY_TIMER_RESET_TIME
ENDLESS_SPAWN_ENEMY_TIME EQU ENDLESS_PREPARE_ENEMY_TIME + 4 ; Must be less than ENDLESS_DELAY_TIMER_RESET_TIME
ENDLESS_SPAWN_POINT_BALLOON_TIME EQU 63 ; Must be less than ENDLESS_DELAY_TIMER_RESET_TIME

SECTION "game vars", WRAM0
    wCountdownFrame:: DB
    wCountdownOAM:: DB
    wEndlessTimer:: DB
    wEndlessDelayTimer:: DB
    wEndlessDifficulty:: DB
    wEndlessEnemyNumber:: DB
    wEndlessEnemyVariant:: DB
    wEndlessEnemyPosition:: DB
    wEndlessEnemyDirection:: DB

SECTION "game", ROM0

InitializeGame::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a
	ld [wCountdownFrame], a
    ld [wEndlessTimer], a
    ld [wEndlessDelayTimer], a
    ld [wEndlessEnemyNumber], a
    ld [wEndlessEnemyVariant], a
    ld [wEndlessEnemyPosition], a
    ld [wEndlessEnemyDirection], a
    ld [wEndlessDifficulty], a
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

LoadEndlessGraphics::
    ; Add scrolling dark clouds
	ld bc, DarkCloudsMap
	ld hl, $99C0
	ld de, DarkCloudsMapEnd - DarkCloudsMap
	ld a, $80
	call MEMCPY_WITH_OFFSET
    ; Fill in dark clouds space
    ld hl, $99E0
    ld bc, $20
    ld d, $81
    call SetInRange
    ; Add scrolling light clouds
    ld bc, LightCloudsMap
	ld hl, $9980
	ld de, LightCloudsMapEnd - LightCloudsMap
	ld a, $84
	call MEMCPY_WITH_OFFSET
    ; Fill in light clouds space
    ld hl, $99A0
    ld bc, $20
    ld d, $87
    call SetInRange
    ; Add scrolling thin clouds
	ld bc, ThinCloudsMap
	ld hl, $9900
	ld de, ThinCloudsMapEnd - ThinCloudsMap
	ld a, $88
	call MEMCPY_WITH_OFFSET
    ; Add sun
    call SpawnSun
    ret

SpawnSun:
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
    SET_HL_TO_ADDRESS wOAM, wCountdownOAM
    ld bc, COUNTDOWN_OAM_BYTES
    call ResetHLInRange
.gameLoop:
    jp GameLoop

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
    jr .endModeSpecific
.endlessMode:
    call EndlessUpdate
.endModeSpecific:
    call RefreshWindow
    call IncrementScrollOffset
    call _hUGE_dosound_with_end
    ret

; UPDATE ENDLESS ======================================

EndlessUpdate:
    ; Increase difficulty and gradually spawn harder enemies

.checkDifficultyRaise:
    ld a, [wEndlessDelayTimer]
    inc a
    ld [wEndlessDelayTimer], a
    cp a, ENDLESS_DELAY_TIMER_RESET_TIME
    jr nz, .endCheckDifficultyRaise
    xor a ; ld a, 0
    ld [wEndlessDelayTimer], a
    ld a, [wEndlessTimer]
    inc a
    ld [wEndlessTimer], a
    and ENDLESS_TIMER_RESET_TIME
    jr nz, .endCheckDifficultyRaise
.difficultyRaise:
    ld a, [wEndlessDifficulty]
    cp a, ENDLESS_DIFFICULTY_MAX + 1
    jr nc, .endCheckDifficultyRaise
    inc a
    ld [wEndlessDifficulty], a
.endCheckDifficultyRaise:

.prepareEnemyToSpawn:
    ld a, [wEndlessDelayTimer]
    cp a, ENDLESS_PREPARE_ENEMY_TIME
    jp nz, .checkEnemyToSpawn
    ld a, [wEndlessDifficulty]
    cp a, 0
    jp z, .endPrepareEnemyToSpawn
    ; Randomly choose an enemy to prepare to spawn if the difficulty allows
    RANDOM a
    ; BALLOON CARRIERS =====
.prepareBalloonCarrierNormal:
    cp a, ENDLESS_DIFFICULTY_0
    jr nz, .prepareBalloonCarrierFollow
    ld b, CARRIER_NORMAL_VARIANT
    jr .prepareBalloonCarrier
.prepareBalloonCarrierFollow:
    cp a, ENDLESS_DIFFICULTY_1
    jr nz, .prepareBalloonCarrierProjectile
    ld b, CARRIER_FOLLOW_VARIANT
    jr .prepareBalloonCarrier
.prepareBalloonCarrierProjectile:
    cp a, ENDLESS_DIFFICULTY_4
    jr nz, .prepareBalloonCarrierBomb
    ld b, CARRIER_PROJECTILE_VARIANT
    jr .prepareBalloonCarrier
.prepareBalloonCarrierBomb:
    cp a, ENDLESS_DIFFICULTY_6
    jr nz, .prepareBombDirect
    ld b, CARRIER_BOMB_VARIANT
.prepareBalloonCarrier:
    ; Save enemy number
    ld a, BALLOON_CARRIER
    ld [wEndlessEnemyNumber], a
    ; Save enemy variant
    ld a, b
    ld [wEndlessEnemyVariant], a
    ; Save enemy direction
    RANDOM 2
    ld b, a
    ld c, 168
    call MULTIPLY
    ld [wEndlessEnemyDirection], a
    ; Save enemy position
    RANDOM 89
    add 24
    ld [wEndlessEnemyPosition], a
    jp .endPrepareEnemyToSpawn
    ; BOMBS =====
.prepareBombDirect:
    cp a, ENDLESS_DIFFICULTY_2
    jr nz, .prepareBombFollow
    ld b, BOMB_DIRECT_VARIANT
    jr .prepareBomb
.prepareBombFollow:
    cp a, ENDLESS_DIFFICULTY_5
    jr nz, .prepareBirdEasy
    ld b, BOMB_FOLLOW_VARIANT
.prepareBomb:
    ; Save enemy number
    ld a, BOMB
    ld [wEndlessEnemyNumber], a
    ; Save enemy variant
    ld a, b
    ld [wEndlessEnemyVariant], a
    ; Save enemy direction
    ld a, OFFSCREEN_BOTTOM
    ld [wEndlessEnemyDirection], a
    ; Save enemy position
    RANDOM 137
    add 12
    ld [wEndlessEnemyPosition], a
    jr .endPrepareEnemyToSpawn
    ; BIRDS =====
.prepareBirdEasy:
    cp a, ENDLESS_DIFFICULTY_3
    jr nz, .prepareBirdHard
    ld b, BIRD_EASY_VARIANT
    jr .prepareBird
.prepareBirdHard:
    cp a, ENDLESS_DIFFICULTY_MAX
    jr nz, .endPrepareEnemyToSpawn
    ld b, BIRD_HARD_VARIANT
.prepareBird:
    ; Save enemy number
    ld a, BIRD
    ld [wEndlessEnemyNumber], a
    ; Save enemy variant
    ld a, b
    ld [wEndlessEnemyVariant], a
    ; Save enemy direction
    RANDOM 2
    ld b, a
    ld c, 168
    call MULTIPLY
    ld [wEndlessEnemyDirection], a
    ; Save enemy position
    RANDOM 89
    add 24
    ld [wEndlessEnemyPosition], a
    ; jr .endPrepareEnemyToSpawn
.checkEnemyToSpawn:
    ld a, [wEndlessDelayTimer]
    cp a, ENDLESS_SPAWN_ENEMY_TIME
    jr nz, .endCheckEnemyToSpawn
.spawnEnemy:
    ld a, [wEndlessEnemyVariant]
    ldh [hEnemyVariant], a
    ld a, [wEndlessEnemyNumber]
    ldh [hEnemyNumber], a
.balloonCarrier:
    cp a, BALLOON_CARRIER
    jr nz, .bomb
    ld a, [wEndlessEnemyPosition]
    ldh [hEnemyY], a
    ld a, [wEndlessEnemyDirection]
    ldh [hEnemyX], a
    call SpawnBalloonCarrier
    jr .endCheckEnemyToSpawn
.bomb:
    cp a, BOMB
    jr nz, .bird
    ld a, [wEndlessEnemyDirection]
    ldh [hEnemyY], a
    ld a, [wEndlessEnemyPosition]
    ldh [hEnemyX], a
    call SpawnBomb
    jr .endCheckEnemyToSpawn
.bird:
    cp a, BIRD
    jr nz, .endCheckEnemyToSpawn
    ld a, [wEndlessEnemyPosition]
    ldh [hEnemyY], a
    ld a, [wEndlessEnemyDirection]
    ldh [hEnemyX], a
    call SpawnBird
.endCheckEnemyToSpawn:
.endPrepareEnemyToSpawn:

.checkPointBalloonToSpawn:
    ld a, [wEndlessDelayTimer]
    cp a, ENDLESS_SPAWN_POINT_BALLOON_TIME
    jr nz, .endCheckPointBalloonToSpawn
.tryToSpawnPointBalloon:
    RANDOM 2
    cp a, 0
    jr nz, .endCheckPointBalloonToSpawn
.canSpawnPointBalloon:
    ld a, POINT_BALLOON
    ldh [hEnemyNumber], a
.checkPointBalloonVariant:
    RANDOM 3
.pointBalloonEasy:
    cp a, 0
    jr nz, .pointBalloonMedium
    ld a, BALLOON_EASY_VARIANT
    jr .endCheckPointBalloonVariant
.pointBalloonMedium:
    cp a, 1
    jr nz, .pointBalloonHard
    ld a, BALLOON_MEDIUM_VARIANT
    jr .endCheckPointBalloonVariant
.pointBalloonHard:
    ld a, BALLOON_HARD_VARIANT
.endCheckPointBalloonVariant:
    ldh [hEnemyVariant], a
    ld a, OFFSCREEN_BOTTOM
    ldh [hEnemyY], a
    RANDOM 137
    add 12
    ldh [hEnemyX], a
    call SpawnPointBalloon
.endCheckPointBalloonToSpawn:
    ret