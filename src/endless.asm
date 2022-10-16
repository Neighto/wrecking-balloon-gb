INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

; ENDLESS_DELAY_TIMER_RESET_TIME EQU %01111111
; ENDLESS_TIMER_RESET_TIME EQU %00000111
; ENDLESS_PREPARE_ENEMY_SLOW_TIME EQU 100
; ENDLESS_PREPARE_ENEMY_MEDIUM_TIME EQU 40
; ENDLESS_PREPARE_ENEMY_FAST_TIME EQU 20
; ENDLESS_SPAWN_ENEMY_DELAY_AFTER_PREPARE EQU 4

ENDLESS_VERTICAL_LANES EQU 4
ENDLESS_HORIZONTAL_LANES EQU 4

ENDLESS_VERTICAL_COOLDOWN EQU 20
ENDLESS_HORIZONTAL_COOLDOWN EQU 40

SECTION "endless vars", WRAM0
    wEndlessTimer:: DB
    wEndlessDelayTimer:: DB
    ; wEndlessDifficulty:: DB
    ; wEndlessSpawnTime:: DB
    ; wEndlessEnemyNumber:: DB
    ; wEndlessEnemyVariant:: DB
    ; wEndlessEnemyPosition:: DB
    ; wEndlessEnemyDirection:: DB
    ; wEndlessEnemySpawnTimer:: DB
    ; wEndlessEnemySpawnTrigger:: DB
    ; wEndlessPointBalloonSpawnTimer:: DB

    ; Vertical Lanes
    wEndlessVerticalLane:: DB
    wEndlessVerticalACooldown:: DB
    wEndlessVerticalBCooldown:: DB
    wEndlessVerticalCCooldown:: DB
    wEndlessVerticalDCooldown:: DB

    ; Vertical Enemy Info
    wEndlessVerticalEnemyNumber:: DB
    wEndlessVerticalEnemyVariant:: DB

    ; Horizontal Lanes
    wEndlessHorizontalLane:: DB
    wEndlessHorizontal_A_Cooldown:: DB
    wEndlessHorizontal_B_Cooldown:: DB
    wEndlessHorizontal_C_Cooldown:: DB
    wEndlessHorizontal_D_Cooldown:: DB

    ; Horizontal Enemy Info
    wEndlessHorizontalEnemyNumber:: DB
    wEndlessHorizontalEnemyVariant:: DB
    wEndlessHorizontalEnemyDirection:: DB

SECTION "endless", ROM0

InitializeEndless::
	xor a ; ld a, 0
    ld [wEndlessTimer], a
    ld [wEndlessDelayTimer], a
    ; ld [wEndlessEnemyNumber], a
    ; ld [wEndlessEnemyVariant], a
    ; ld [wEndlessEnemyPosition], a
    ; ld [wEndlessEnemyDirection], a
    ; ld [wEndlessDifficulty], a
    ; ld [wEndlessSpawnTime], a
    ; ld [wEndlessEnemySpawnTimer], a
    ; ld [wEndlessEnemySpawnTrigger], a
    ; ld [wEndlessPointBalloonSpawnTimer], a
    ld [wEndlessVerticalLane], a
    ld [wEndlessVerticalACooldown], a
    ld [wEndlessVerticalBCooldown], a
    ld [wEndlessVerticalCCooldown], a
    ld [wEndlessVerticalDCooldown], a
    ld [wEndlessVerticalEnemyNumber], a
    ld [wEndlessVerticalEnemyVariant], a
    ld [wEndlessHorizontalLane], a
    ld [wEndlessHorizontal_A_Cooldown], a
    ld [wEndlessHorizontal_B_Cooldown], a
    ld [wEndlessHorizontal_C_Cooldown], a
    ld [wEndlessHorizontal_D_Cooldown], a
    ld [wEndlessHorizontalEnemyNumber], a
    ld [wEndlessHorizontalEnemyVariant], a
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

; UPDATE
EndlessUpdate::

.checkEndlessTimer:
    ld a, [wEndlessDelayTimer]
    inc a
    ld [wEndlessDelayTimer], a
    cp a, 100
    jr nz, .endCheckEndlessTimer
    xor a ; ld a, 0
    ld [wEndlessDelayTimer], a
.endCheckEndlessTimer:

; VERTICAL ****
.handleVertical:

; PREPARE TO SPAWN
.prepareVerticalSpawn:
    ld a, [wEndlessDelayTimer]
    cp a, 50
    jp nz, .endPrepareVerticalSpawn

    ld b, ENDLESS_VERTICAL_LANES + 1 ; for looping
    RANDOM ENDLESS_VERTICAL_LANES ; a = 0-3
.verticalLaneLoop:
    inc a
    ld d, ENDLESS_VERTICAL_LANES
    call MODULO
    ld c, a
    dec b
    ld a, b
    cp a, 0
    jr z, .cannotPrepareVerticalSpawn
    ld a, c
.verticalA:
    cp a, 0
    jr nz, .verticalB
    ld a, [wEndlessVerticalACooldown]
    cp a, 0
    jr nz, .verticalLaneLoop
    ; Lane free
    ld a, ENDLESS_VERTICAL_COOLDOWN
    ld [wEndlessVerticalACooldown], a
    jr .canPrepareVerticalSpawn
.verticalB:
    cp a, 1
    jr nz, .verticalC
    ld a, [wEndlessVerticalBCooldown]
    cp a, 0
    jr nz, .verticalLaneLoop
    ; Lane free
    ld a, ENDLESS_VERTICAL_COOLDOWN
    ld [wEndlessVerticalBCooldown], a
    jr .canPrepareVerticalSpawn
.verticalC:
    cp a, 2
    jr nz, .verticalD
    ld a, [wEndlessVerticalCCooldown]
    cp a, 0
    jr nz, .verticalLaneLoop
    ; Lane free
    ld a, ENDLESS_VERTICAL_COOLDOWN
    ld [wEndlessVerticalCCooldown], a
    jr .canPrepareVerticalSpawn
.verticalD:
    ; cp a, 3
    ; jr nz, .canPrepareVerticalSpawn
    ld a, [wEndlessVerticalDCooldown]
    cp a, 0
    jr nz, .verticalLaneLoop
    ; Lane free
    ld a, ENDLESS_VERTICAL_COOLDOWN
    ld [wEndlessVerticalDCooldown], a
    jr .canPrepareVerticalSpawn
.cannotPrepareVerticalSpawn:
    ld a, -1
    ld [wEndlessVerticalLane], a
    jr .endPrepareVerticalSpawn
.canPrepareVerticalSpawn:
    ld a, c
    ld [wEndlessVerticalLane], a
.chooseVerticalEnemy:
    RANDOM 3
; POINT BALLOON
.pointBalloon:
    cp a, 0
    jr nz, .bomb
    ld a, POINT_BALLOON
    ld [wEndlessVerticalEnemyNumber], a
.pointBalloonVariant:
    RANDOM 3
.pointBalloonEasyVariant:
    cp a, 0
    jr nz, .pointBalloonMediumVariant
    ld a, BALLOON_EASY_VARIANT
    jr .pointBalloonVariantSet
.pointBalloonMediumVariant:
    cp a, 1
    jr nz, .pointBalloonHardVariant
    ld a, BALLOON_MEDIUM_VARIANT
    jr .pointBalloonVariantSet
.pointBalloonHardVariant:
    ; cp a, 2
    ; jr nz, .endPointBalloonVariant
    ld a, BALLOON_HARD_VARIANT
    ; jr .pointBalloonVariantSet
.pointBalloonVariantSet:
    ld [wEndlessVerticalEnemyVariant], a
.endPointBalloonVariant:
    jr .endChooseVerticalEnemy
; BOMB
.bomb:
    cp a, 1
    jr nz, .anvil
    ld a, BOMB
    ld [wEndlessVerticalEnemyNumber], a
.bombVariant:
    RANDOM 2
.bombDirectVariant:
    cp a, 0
    jr nz, .bombFollowVariant
    ld a, BOMB_DIRECT_VARIANT
    jr .bombVariantSet
.bombFollowVariant:
    ; cp a, 0
    ; jr nz, .endBombVariant
    ld a, BOMB_FOLLOW_VARIANT
    ; jr .bombVariantSet
.bombVariantSet:
    ld [wEndlessVerticalEnemyVariant], a
.endBombVariant:
    jr .endChooseVerticalEnemy
; ANVIL
.anvil:
    ; cp a, 2
    ; jr nz, .endChooseVerticalEnemy
    ld a, ANVIL
    ld [wEndlessVerticalEnemyNumber], a
    ld a, ANVIL_NORMAL_VARIANT
    ld [wEndlessVerticalEnemyVariant], a
    ; jr .endChooseVerticalEnemy
.endChooseVerticalEnemy:
.endPrepareVerticalSpawn:

; COOLDOWN LANES
.cooldownVerticalLanes:
    ldh a, [hGlobalTimer]
    and %00000011
    jr nz, .endCooldownVerticalLanes
.verticalACooldown:
    ld a, [wEndlessVerticalACooldown]
    cp a, 0
    jr z, .verticalBCooldown
    dec a
    ld [wEndlessVerticalACooldown], a
.verticalBCooldown:
    ld a, [wEndlessVerticalBCooldown]
    cp a, 0
    jr z, .verticalCCooldown
    dec a
    ld [wEndlessVerticalBCooldown], a
.verticalCCooldown:
    ld a, [wEndlessVerticalCCooldown]
    cp a, 0
    jr z, .verticalDCooldown
    dec a
    ld [wEndlessVerticalCCooldown], a
.verticalDCooldown:
    ld a, [wEndlessVerticalDCooldown]
    cp a, 0
    jr z, .endCooldownVerticalLanes
    dec a
    ld [wEndlessVerticalDCooldown], a
.endCooldownVerticalLanes: 

; TRY TO SPAWN
.tryToVerticalSpawn:
    ld a, [wEndlessDelayTimer]
    cp a, 90
    jr nz, .endTryToVerticalSpawn

    ld a, [wEndlessVerticalLane]
    cp a, -1
    jr z, .endTryToVerticalSpawn
.canVerticalSpawn:
    ; hEnemyX
    ld c, a
    RANDOM 35
    ld e, a
    ld b, 34
    call MULTIPLY
    add e
    add 12
    ldh [hEnemyX], a
    ; hEnemyY
    ld a, OFFSCREEN_BOTTOM
    ldh [hEnemyY], a
    ; hEnemyVariant
    ld a, [wEndlessVerticalEnemyVariant]
    ldh [hEnemyVariant], a
    ; hEnemyNumber
    ld a, [wEndlessVerticalEnemyNumber]
    ldh [hEnemyNumber], a
.spawnPointBalloon:
    cp a, POINT_BALLOON
    jr nz, .spawnBomb
    call SpawnPointBalloon
    jr .endHandleVertical
.spawnBomb:
    cp a, BOMB
    jr nz, .spawnAnvil
    call SpawnBomb
    jr .endHandleVertical
.spawnAnvil:
    ; cp a, ANVIL
    ; jr nz, .endTryToVerticalSpawn
    ; hEnemyY *update for anvil special case
    ld a, OFFSCREEN_TOP
    ldh [hEnemyY], a
    call SpawnAnvil
    ; jr .endHandleVertical
.endTryToVerticalSpawn:

.endHandleVertical:

; HORIZONTAL ****
.handleHorizontal:

; PREPARE TO SPAWN
.prepareHorizontalSpawn:
    ld a, [wEndlessDelayTimer]
    cp a, 60
    jp nz, .endPrepareHorizontalSpawn

    ld b, ENDLESS_HORIZONTAL_LANES + 1 ; for looping
    RANDOM ENDLESS_HORIZONTAL_LANES ; a = 0-3
.horizontalLaneLoop:
    inc a
    ld d, ENDLESS_HORIZONTAL_LANES
    call MODULO
    ld c, a
    dec b
    ld a, b
    cp a, 0
    jr z, .cannotPrepareHorizontalSpawn
    ld a, c
.horizontalA:
    cp a, 0
    jr nz, .horizontalB
    ld a, [wEndlessHorizontal_A_Cooldown]
    cp a, 0
    jr nz, .horizontalLaneLoop
    ; Lane free
    ld a, ENDLESS_HORIZONTAL_COOLDOWN
    ld [wEndlessHorizontal_A_Cooldown], a
    jr .canPrepareHorizontalSpawn
.horizontalB:
    cp a, 1
    jr nz, .horizontalC
    ld a, [wEndlessHorizontal_B_Cooldown]
    cp a, 0
    jr nz, .horizontalLaneLoop
    ; Lane free
    ld a, ENDLESS_HORIZONTAL_COOLDOWN
    ld [wEndlessHorizontal_B_Cooldown], a
    jr .canPrepareHorizontalSpawn
.horizontalC:
    cp a, 2
    jr nz, .horizontalD
    ld a, [wEndlessHorizontal_C_Cooldown]
    cp a, 0
    jr nz, .horizontalLaneLoop
    ; Lane free
    ld a, ENDLESS_HORIZONTAL_COOLDOWN
    ld [wEndlessHorizontal_C_Cooldown], a
    jr .canPrepareHorizontalSpawn
.horizontalD:
    ; cp a, 3
    ; jr nz, .canPrepareHorizontalSpawn
    ld a, [wEndlessHorizontal_D_Cooldown]
    cp a, 0
    jr nz, .horizontalLaneLoop
    ; Lane free
    ld a, ENDLESS_HORIZONTAL_COOLDOWN
    ld [wEndlessHorizontal_D_Cooldown], a
    jr .canPrepareHorizontalSpawn
.cannotPrepareHorizontalSpawn:
    ld a, -1
    ld [wEndlessHorizontalLane], a
    jr .endPrepareHorizontalSpawn
.canPrepareHorizontalSpawn:
    ld a, c
    ld [wEndlessHorizontalLane], a
.chooseDirection:
    RANDOM 2
.left:
    cp a, LEFT
    jr nz, .right
    ld a, OFFSCREEN_LEFT
    jr .directionSet
.right:
    ; cp a, RIGHT
    ; jr nz, .endChooseDirection
    ld a, OFFSCREEN_RIGHT
    ; jr .directionSet
.directionSet:
    ld [wEndlessHorizontalEnemyDirection], a
.endChooseDirection:
.chooseHorizontalEnemy:
    ; RANDOM 3
; BIRD
.bird:
    ; cp a, 0
    ; jr nz, .endChooseHorizontalEnemy ; change
    ld a, BIRD
    ld [wEndlessHorizontalEnemyNumber], a
.birdVariant:
    RANDOM 2
.birdEasyVariant:
    cp a, 0
    jr nz, .birdHardVariant
    ld a, BIRD_EASY_VARIANT
    jr .birdVariantSet
.birdHardVariant:
    ; cp a, 1
    ; jr nz, .endBirdVariant
    ld a, BIRD_HARD_VARIANT
    ; jr .birdVariantSet
.birdVariantSet:
    ld [wEndlessHorizontalEnemyVariant], a
.endBirdVariant:
    jr .endChooseHorizontalEnemy
    ; ****************************
.endChooseHorizontalEnemy:
.endPrepareHorizontalSpawn:

; COOLDOWN LANES
.cooldownHorizontalLanes:
    ldh a, [hGlobalTimer]
    and %00000011
    jr nz, .endCooldownHorizontalLanes
.horizontalACooldown:
    ld a, [wEndlessHorizontal_A_Cooldown]
    cp a, 0
    jr z, .horizontalBCooldown
    dec a
    ld [wEndlessHorizontal_A_Cooldown], a
.horizontalBCooldown:
    ld a, [wEndlessHorizontal_B_Cooldown]
    cp a, 0
    jr z, .horizontalCCooldown
    dec a
    ld [wEndlessHorizontal_B_Cooldown], a
.horizontalCCooldown:
    ld a, [wEndlessHorizontal_C_Cooldown]
    cp a, 0
    jr z, .horizontalDCooldown
    dec a
    ld [wEndlessHorizontal_C_Cooldown], a
.horizontalDCooldown:
    ld a, [wEndlessHorizontal_D_Cooldown]
    cp a, 0
    jr z, .endCooldownHorizontalLanes
    dec a
    ld [wEndlessHorizontal_D_Cooldown], a
.endCooldownHorizontalLanes: 

; TRY TO SPAWN
.tryToHorizontalSpawn:
    ld a, [wEndlessDelayTimer]
    cp a, 93
    jr nz, .endTryToHorizontalSpawn

    ld a, [wEndlessHorizontalLane]
    cp a, -1
    jr z, .endTryToHorizontalSpawn
.canHorizontalSpawn:
    ; hEnemyY
    ld c, a
    RANDOM 23
    ld e, a
    ld b, 22
    call MULTIPLY
    add e
    add 24
    ldh [hEnemyY], a
    ; hEnemyX
    ld a, [wEndlessHorizontalEnemyDirection]
    ldh [hEnemyX], a
    ; hEnemyVariant
    ld a, [wEndlessHorizontalEnemyVariant]
    ldh [hEnemyVariant], a
    ; hEnemyNumber
    ld a, [wEndlessHorizontalEnemyNumber]
    ldh [hEnemyNumber], a
    call SpawnBird

.endTryToHorizontalSpawn:

.endHandleHorizontal:

; .checkDifficultyRaise:
;     ld a, [wEndlessDelayTimer]
;     inc a
;     ld [wEndlessDelayTimer], a
;     and ENDLESS_DELAY_TIMER_RESET_TIME
;     jr nz, .endCheckDifficultyRaise
;     ld a, [wEndlessTimer]
;     inc a
;     ld [wEndlessTimer], a
;     and ENDLESS_TIMER_RESET_TIME
;     jr nz, .endCheckDifficultyRaise
; .difficultyRaise:
;     ld a, [wEndlessDifficulty]
;     cp a, ENDLESS_DIFFICULTY_MAX + 1
;     jr nc, .endCheckDifficultyRaise
;     inc a
;     ld [wEndlessDifficulty], a
; .setSpawnRate:
;     ; ld a, [wEndlessDifficulty]
; .fastPrepareSpawnRate:
;     cp a, ENDLESS_DIFFICULTY_MAX + 1
;     jr nc, .mediumPrepareSpawnRate
;     ld a, ENDLESS_PREPARE_ENEMY_FAST_TIME
;     ld [wEndlessSpawnTime], a
;     jr .endSetSpawnRate
; .mediumPrepareSpawnRate:
;     cp a, ENDLESS_DIFFICULTY_2
;     jr nc, .slowPrepareSpawnRate
;     ld a, ENDLESS_PREPARE_ENEMY_MEDIUM_TIME
;     ld [wEndlessSpawnTime], a
;     jr .endSetSpawnRate
; .slowPrepareSpawnRate:
;     ; cp a, ENDLESS_DIFFICULTY_0
;     ; jr nc, .endSetSpawnRate
;     ld a, ENDLESS_PREPARE_ENEMY_SLOW_TIME
;     ld [wEndlessSpawnTime], a
;     ; jr .endSetSpawnRate
; .endSetSpawnRate:
; .endCheckDifficultyRaise:

; .checkEnemyToSpawn:
;     ld a, [wEndlessEnemySpawnTrigger]
;     cp a, 0
;     jr z, .endCheckEnemyToSpawn
;     xor a ; ld a, 0
;     ld [wEndlessEnemySpawnTrigger], a
; .spawnEnemy:
;     ld a, [wEndlessEnemyVariant]
;     ldh [hEnemyVariant], a
;     ld a, [wEndlessEnemyNumber]
;     ldh [hEnemyNumber], a
; .balloonCarrier:
;     cp a, BALLOON_CARRIER
;     jr nz, .bomb
;     ld a, [wEndlessEnemyPosition]
;     ldh [hEnemyY], a
;     ld a, [wEndlessEnemyDirection]
;     ldh [hEnemyX], a
;     call SpawnBalloonCarrier
;     jr .endCheckEnemyToSpawn
; .bomb:
;     cp a, BOMB
;     jr nz, .bird
;     ld a, [wEndlessEnemyDirection]
;     ldh [hEnemyY], a
;     ld a, [wEndlessEnemyPosition]
;     ldh [hEnemyX], a
;     call SpawnBomb
;     jr .endCheckEnemyToSpawn
; .bird:
;     cp a, BIRD
;     jr nz, .anvil
;     ld a, [wEndlessEnemyPosition]
;     ldh [hEnemyY], a
;     ld a, [wEndlessEnemyDirection]
;     ldh [hEnemyX], a
;     call SpawnBird
;     jr .endCheckEnemyToSpawn
; .anvil:
;     cp a, ANVIL
;     jr nz, .endCheckEnemyToSpawn
;     ld a, [wEndlessEnemyDirection]
;     ldh [hEnemyY], a
;     ld a, [wEndlessEnemyPosition]
;     ldh [hEnemyX], a
;     call SpawnAnvil
;     ; jr .endCheckEnemyToSpawn
; .endCheckEnemyToSpawn:

; .prepareEnemyToSpawn:
;     ; Check the countdown timer
;     ld a, [wEndlessEnemySpawnTimer]
;     cp a, 0
;     jr z, .canPrepareEnemy
;     dec a
;     ld [wEndlessEnemySpawnTimer], a
;     jp .endPrepareEnemyToSpawn
; .canPrepareEnemy:
;     ; Reset spawn timer
;     RANDOM 150
;     ld b, a
;     ld a, [wEndlessSpawnTime]
;     add b
;     ld [wEndlessEnemySpawnTimer], a
;     ; Set spawn enemy trigger
;     ld a, 1 
;     ld [wEndlessEnemySpawnTrigger], a
;     ; Prepare
;     ld a, [wEndlessDifficulty]
;     cp a, 0
;     jp z, .endPrepareEnemyToSpawn
;     ; Randomly choose an enemy to prepare to spawn if the difficulty allows
;     RANDOM a
;     ; BALLOON CARRIERS =====
; .prepareBalloonCarrierNormal:
;     cp a, ENDLESS_DIFFICULTY_0
;     jr nz, .prepareBalloonCarrierFollow
;     ld b, CARRIER_NORMAL_VARIANT
;     jr .prepareBalloonCarrier
; .prepareBalloonCarrierFollow:
;     cp a, ENDLESS_DIFFICULTY_1
;     jr nz, .prepareBalloonCarrierProjectile
;     ld b, CARRIER_FOLLOW_VARIANT
;     jr .prepareBalloonCarrier
; .prepareBalloonCarrierProjectile:
;     cp a, ENDLESS_DIFFICULTY_4
;     jr nz, .prepareBalloonCarrierBomb
;     ld b, CARRIER_PROJECTILE_VARIANT
;     jr .prepareBalloonCarrier
; .prepareBalloonCarrierBomb:
;     cp a, ENDLESS_DIFFICULTY_6
;     jr nz, .prepareBombDirect
;     ld b, CARRIER_BOMB_VARIANT
; .prepareBalloonCarrier:
;     ; Save enemy number
;     ld a, BALLOON_CARRIER
;     ld [wEndlessEnemyNumber], a
;     ; Save enemy variant
;     ld a, b
;     ld [wEndlessEnemyVariant], a
;     ; Save enemy direction
;     RANDOM 2
;     cp a, 0
;     jr nz, .balloonCarrierRight
; .balloonCarrierLeft:
;     ld a, OFFSCREEN_LEFT
;     jr .balloonCarrierUpdateDirection
; .balloonCarrierRight:
;     ld a, OFFSCREEN_RIGHT
; .balloonCarrierUpdateDirection:
;     ld [wEndlessEnemyDirection], a
;     ; Save enemy position
;     RANDOM 89
;     add 24
;     ld [wEndlessEnemyPosition], a
;     jp .endPrepareEnemyToSpawn
;     ; BOMBS =====
; .prepareBombDirect:
;     cp a, ENDLESS_DIFFICULTY_2
;     jr nz, .prepareBombFollow
;     ld b, BOMB_DIRECT_VARIANT
;     jr .prepareBomb
; .prepareBombFollow:
;     cp a, ENDLESS_DIFFICULTY_5
;     jr nz, .prepareBirdEasy
;     ld b, BOMB_FOLLOW_VARIANT
; .prepareBomb:
;     ; Save enemy number
;     ld a, BOMB
;     ld [wEndlessEnemyNumber], a
;     ; Save enemy variant
;     ld a, b
;     ld [wEndlessEnemyVariant], a
;     ; Save enemy direction
;     ld a, OFFSCREEN_BOTTOM
;     ld [wEndlessEnemyDirection], a
;     ; Save enemy position
;     RANDOM 137
;     add 12
;     ld [wEndlessEnemyPosition], a
;     jp .endPrepareEnemyToSpawn
;     ; BIRDS =====
; .prepareBirdEasy:
;     cp a, ENDLESS_DIFFICULTY_3
;     jr nz, .prepareBirdHard
;     ld b, BIRD_EASY_VARIANT
;     jr .prepareBird
; .prepareBirdHard:
;     cp a, ENDLESS_DIFFICULTY_7
;     jr nz, .prepareAnvil
;     ld b, BIRD_HARD_VARIANT
; .prepareBird:
;     ; Save enemy number
;     ld a, BIRD
;     ld [wEndlessEnemyNumber], a
;     ; Save enemy variant
;     ld a, b
;     ld [wEndlessEnemyVariant], a
;     ; Save enemy direction
;     RANDOM 2
;     cp a, 0
;     jr nz, .birdRight
; .birdLeft:
;     ld a, OFFSCREEN_LEFT
;     jr .birdUpdateDirection
; .birdRight:
;     ld a, OFFSCREEN_RIGHT
; .birdUpdateDirection:
;     ld [wEndlessEnemyDirection], a
;     ; Save enemy position
;     RANDOM 89
;     add 24
;     ld [wEndlessEnemyPosition], a
;     jp .endPrepareEnemyToSpawn
; .prepareAnvil:
;     cp a, ENDLESS_DIFFICULTY_MAX
;     jp nz, .endPrepareEnemyToSpawn
;     ; Save enemy number
;     ld a, ANVIL
;     ld [wEndlessEnemyNumber], a
;     ; Save enemy variant
;     ld a, ANVIL_NORMAL_VARIANT
;     ld [wEndlessEnemyVariant], a
;     ; Save enemy direction
;     ld a, OFFSCREEN_TOP
;     ld [wEndlessEnemyDirection], a
;     ; Save enemy position
;     RANDOM 137
;     add 12
;     ld [wEndlessEnemyPosition], a
;     ; jr .endPrepareEnemyToSpawn
; .endPrepareEnemyToSpawn:

; .checkPointBalloonToSpawn:
;     ; Check the countdown timer
;     ld a, [wEndlessPointBalloonSpawnTimer]
;     cp a, 0
;     jr z, .canSpawnPointBalloon
;     dec a
;     ld [wEndlessPointBalloonSpawnTimer], a
;     jr .endCheckPointBalloonToSpawn
; .canSpawnPointBalloon:
;     ; Reset spawn timer
;     RANDOM 200
;     add 50
;     ld [wEndlessPointBalloonSpawnTimer], a
;     ; Spawn
;     ld a, POINT_BALLOON
;     ldh [hEnemyNumber], a
; .checkPointBalloonVariant:
;     RANDOM 3
; .pointBalloonEasy:
;     cp a, 0
;     jr nz, .pointBalloonMedium
;     ld a, BALLOON_EASY_VARIANT
;     jr .endCheckPointBalloonVariant
; .pointBalloonMedium:
;     cp a, 1
;     jr nz, .pointBalloonHard
;     ld a, BALLOON_MEDIUM_VARIANT
;     jr .endCheckPointBalloonVariant
; .pointBalloonHard:
;     ld a, BALLOON_HARD_VARIANT
; .endCheckPointBalloonVariant:
;     ldh [hEnemyVariant], a
;     ld a, OFFSCREEN_BOTTOM
;     ldh [hEnemyY], a
;     RANDOM 137
;     add 12
;     ldh [hEnemyX], a
;     call SpawnPointBalloon
; .endCheckPointBalloonToSpawn:
    ret