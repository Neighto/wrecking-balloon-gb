INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

ENDLESS_DELAY_TIMER_RESET_TIME EQU %01111111
ENDLESS_TIMER_RESET_TIME EQU %00000111
ENDLESS_PREPARE_ENEMY_SLOW_TIME EQU 100
ENDLESS_PREPARE_ENEMY_MEDIUM_TIME EQU 40
ENDLESS_PREPARE_ENEMY_FAST_TIME EQU 20
ENDLESS_SPAWN_ENEMY_DELAY_AFTER_PREPARE EQU 4

SECTION "endless vars", WRAM0
    wEndlessTimer:: DB
    wEndlessDelayTimer:: DB
    wEndlessDifficulty:: DB
    wEndlessSpawnTime:: DB
    wEndlessEnemyNumber:: DB
    wEndlessEnemyVariant:: DB
    wEndlessEnemyPosition:: DB
    wEndlessEnemyDirection:: DB

    wEndlessEnemySpawnTimer:: DB
    wEndlessEnemySpawnTrigger:: DB
    wEndlessPointBalloonSpawnTimer:: DB

SECTION "endless", ROM0

InitializeEndless::
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
    ld [wEndlessSpawnTime], a
    ld [wEndlessEnemySpawnTimer], a
    ld [wEndlessEnemySpawnTrigger], a
    ld [wEndlessPointBalloonSpawnTimer], a
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

EndlessUpdate::
    ; Increase difficulty and gradually spawn harder enemies

.checkDifficultyRaise:
    ld a, [wEndlessDelayTimer]
    inc a
    ld [wEndlessDelayTimer], a
    and ENDLESS_DELAY_TIMER_RESET_TIME
    jr nz, .endCheckDifficultyRaise
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
.setSpawnRate:
    ; ld a, [wEndlessDifficulty]
.fastPrepareSpawnRate:
    cp a, ENDLESS_DIFFICULTY_MAX + 1
    jr nc, .mediumPrepareSpawnRate
    ld a, ENDLESS_PREPARE_ENEMY_FAST_TIME
    ld [wEndlessSpawnTime], a
    jr .endSetSpawnRate
.mediumPrepareSpawnRate:
    cp a, ENDLESS_DIFFICULTY_2
    jr nc, .slowPrepareSpawnRate
    ld a, ENDLESS_PREPARE_ENEMY_MEDIUM_TIME
    ld [wEndlessSpawnTime], a
    jr .endSetSpawnRate
.slowPrepareSpawnRate:
    ; cp a, ENDLESS_DIFFICULTY_0
    ; jr nc, .endSetSpawnRate
    ld a, ENDLESS_PREPARE_ENEMY_SLOW_TIME
    ld [wEndlessSpawnTime], a
    ; jr .endSetSpawnRate
.endSetSpawnRate:
.endCheckDifficultyRaise:

.checkEnemyToSpawn:
    ld a, [wEndlessEnemySpawnTrigger]
    cp a, 0
    jr z, .endCheckEnemyToSpawn
    xor a ; ld a, 0
    ld [wEndlessEnemySpawnTrigger], a
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
    jr nz, .anvil
    ld a, [wEndlessEnemyPosition]
    ldh [hEnemyY], a
    ld a, [wEndlessEnemyDirection]
    ldh [hEnemyX], a
    call SpawnBird
    jr .endCheckEnemyToSpawn
.anvil:
    cp a, ANVIL
    jr nz, .endCheckEnemyToSpawn
    ld a, [wEndlessEnemyDirection]
    ldh [hEnemyY], a
    ld a, [wEndlessEnemyPosition]
    ldh [hEnemyX], a
    call SpawnAnvil
    ; jr .endCheckEnemyToSpawn
.endCheckEnemyToSpawn:

.prepareEnemyToSpawn:
    ; Check the countdown timer
    ld a, [wEndlessEnemySpawnTimer]
    cp a, 0
    jr z, .canPrepareEnemy
    dec a
    ld [wEndlessEnemySpawnTimer], a
    jp .endPrepareEnemyToSpawn
.canPrepareEnemy:
    ; Reset spawn timer
    RANDOM 150
    ld b, a
    ld a, [wEndlessSpawnTime]
    add b
    ld [wEndlessEnemySpawnTimer], a
    ; Set spawn enemy trigger
    ld a, 1 
    ld [wEndlessEnemySpawnTrigger], a
    ; Prepare
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
    cp a, 0
    jr nz, .balloonCarrierRight
.balloonCarrierLeft:
    ld a, OFFSCREEN_LEFT
    jr .balloonCarrierUpdateDirection
.balloonCarrierRight:
    ld a, OFFSCREEN_RIGHT
.balloonCarrierUpdateDirection:
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
    jp .endPrepareEnemyToSpawn
    ; BIRDS =====
.prepareBirdEasy:
    cp a, ENDLESS_DIFFICULTY_3
    jr nz, .prepareBirdHard
    ld b, BIRD_EASY_VARIANT
    jr .prepareBird
.prepareBirdHard:
    cp a, ENDLESS_DIFFICULTY_7
    jr nz, .prepareAnvil
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
    cp a, 0
    jr nz, .birdRight
.birdLeft:
    ld a, OFFSCREEN_LEFT
    jr .birdUpdateDirection
.birdRight:
    ld a, OFFSCREEN_RIGHT
.birdUpdateDirection:
    ld [wEndlessEnemyDirection], a
    ; Save enemy position
    RANDOM 89
    add 24
    ld [wEndlessEnemyPosition], a
    jp .endPrepareEnemyToSpawn
.prepareAnvil:
    cp a, ENDLESS_DIFFICULTY_MAX
    jp nz, .endPrepareEnemyToSpawn
    ; Save enemy number
    ld a, ANVIL
    ld [wEndlessEnemyNumber], a
    ; Save enemy variant
    ld a, ANVIL_NORMAL_VARIANT
    ld [wEndlessEnemyVariant], a
    ; Save enemy direction
    ld a, OFFSCREEN_TOP
    ld [wEndlessEnemyDirection], a
    ; Save enemy position
    RANDOM 137
    add 12
    ld [wEndlessEnemyPosition], a
    ; jr .endPrepareEnemyToSpawn
.endPrepareEnemyToSpawn:

.checkPointBalloonToSpawn:
    ; Check the countdown timer
    ld a, [wEndlessPointBalloonSpawnTimer]
    cp a, 0
    jr z, .canSpawnPointBalloon
    dec a
    ld [wEndlessPointBalloonSpawnTimer], a
    jr .endCheckPointBalloonToSpawn
.canSpawnPointBalloon:
    ; Reset spawn timer
    RANDOM 200
    add 50
    ld [wEndlessPointBalloonSpawnTimer], a
    ; Spawn
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