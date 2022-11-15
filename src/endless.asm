INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

ENDLESS_TIMER_RESET_TIME EQU 100

ENDLESS_PREPARE_VERTICAL_SPAWN_TIME EQU 50
ENDLESS_PREPARE_HORIZONTAL_SPAWN_TIME EQU 55

ENDLESS_VERTICAL_SPAWN_TIME EQU 90
ENDLESS_HORIZONTAL_SPAWN_TIME EQU 95

ENDLESS_VERTICAL_LANES EQU 4
ENDLESS_HORIZONTAL_LANES EQU 4

ENDLESS_VERTICAL_COOLDOWN EQU 20
ENDLESS_HORIZONTAL_COOLDOWN EQU 40

ENDLESS_VERTICAL_COOLDOWN_TIMER EQU %00000011
ENDLESS_HORIZONTAL_COOLDOWN_TIMER EQU %00000011

; VERTICAL ENEMY SPAWN RATES

ENDLESS_VERTICAL_SPAWN_DENOMINATOR EQU 11
ENDLESS_VERTICAL_SPAWN_POINT_BALLOON_RATE EQU 5
ENDLESS_VERTICAL_SPAWN_BOMB_RATE EQU 4
ENDLESS_VERTICAL_SPAWN_ANVIL_RATE EQU 2

; VERTICAL ENEMY VARIANT SPAWN RATES

ENDLESS_SPAWN_POINT_BALLOON_VARIANT_DENOMINATOR EQU 3
ENDLESS_SPAWN_POINT_BALLOON_VARIANT_EASY_RATE EQU 1
ENDLESS_SPAWN_POINT_BALLOON_VARIANT_MEDIUM_RATE EQU 1
ENDLESS_SPAWN_POINT_BALLOON_VARIANT_HARD_RATE EQU 1

ENDLESS_SPAWN_BOMB_VARIANT_DENOMINATOR EQU 2
ENDLESS_SPAWN_BOMB_VARIANT_DIRECT_RATE EQU 1
ENDLESS_SPAWN_BOMB_VARIANT_FOLLOW_RATE EQU 1

; Only using anvil variant
; ENDLESS_SPAWN_ANVIL_VARIANT_DENOMINATOR EQU 2
; ENDLESS_SPAWN_ANVIL_VARIANT_NORMAL_RATE EQU 1
; ENDLESS_SPAWN_ANVIL_VARIANT_CACTUS_RATE EQU 1

; HORIZONTAL ENEMY SPAWN RATES

ENDLESS_HORIZONTAL_SPAWN_DENOMINATOR EQU 2
ENDLESS_HORIZONTAL_SPAWN_BALLOON_CARRIER_RATE EQU 1
ENDLESS_HORIZONTAL_SPAWN_BIRD_RATE EQU 1

; HORIZONTAL ENEMY VARIANT SPAWN RATES

ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_DENOMINATOR EQU 4
ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_NORMAL_RATE EQU 1
ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_FOLLOW_RATE EQU 1
ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_PROJECTILE_RATE EQU 1
ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_BOMB_RATE EQU 1

ENDLESS_SPAWN_BIRD_VARIANT_DENOMINATOR EQU 2
ENDLESS_SPAWN_BIRD_VARIANT_EASY_RATE EQU 1
ENDLESS_SPAWN_BIRD_VARIANT_HARD_RATE EQU 1

SECTION "endless vars", HRAM
    hEndlessTimer:: DB

    ; Vertical Lanes
    hEndlessVerticalLane:: DB
    hEndlessVertical_A_Cooldown:: DB
    hEndlessVertical_B_Cooldown:: DB
    hEndlessVertical_C_Cooldown:: DB
    hEndlessVertical_D_Cooldown:: DB

    ; Vertical Enemy Info
    hEndlessVerticalEnemyNumber:: DB
    hEndlessVerticalEnemyVariant:: DB

    ; Horizontal Lanes
    hEndlessHorizontalLane:: DB
    hEndlessHorizontal_A_Cooldown:: DB
    hEndlessHorizontal_B_Cooldown:: DB
    hEndlessHorizontal_C_Cooldown:: DB
    hEndlessHorizontal_D_Cooldown:: DB

    ; Horizontal Enemy Info
    hEndlessHorizontalEnemyNumber:: DB
    hEndlessHorizontalEnemyVariant:: DB
    hEndlessHorizontalEnemyDirection:: DB
    
    ; Level Switch
    hEndlessLevelSwitchSkip:: DB
    hEndlessLevelSwitchTimer:: DB

SECTION "endless", ROM0

InitializeEndless::
	xor a ; ld a, 0
    ldh [hEndlessTimer], a

    ldh [hEndlessVerticalLane], a
    ldh [hEndlessVertical_A_Cooldown], a
    ldh [hEndlessVertical_B_Cooldown], a
    ldh [hEndlessVertical_C_Cooldown], a
    ldh [hEndlessVertical_D_Cooldown], a

    ldh [hEndlessVerticalEnemyNumber], a
    ldh [hEndlessVerticalEnemyVariant], a

    ldh [hEndlessHorizontalLane], a
    ldh [hEndlessHorizontal_A_Cooldown], a
    ldh [hEndlessHorizontal_B_Cooldown], a
    ldh [hEndlessHorizontal_C_Cooldown], a
    ldh [hEndlessHorizontal_D_Cooldown], a

    ldh [hEndlessHorizontalEnemyNumber], a
    ldh [hEndlessHorizontalEnemyVariant], a
    ldh [hEndlessHorizontalEnemyDirection], a

    ldh [hEndlessLevelSwitchSkip], a
    ldh [hEndlessLevelSwitchTimer], a

    ; Set level to endless if endless mode
    ld a, [wSelectedMode]
    cp a, CLASSIC_MODE
    ret z
    ld a, LEVEL_ENDLESS
    ld [wLevel], a
    ret

LoadEndlessGraphics::
    ; Add scrolling thin clouds
	ld bc, CloudsMap + $20 * 4
	ld hl, $9900
	ld de, $20
	ld a, $80
	call MEMCPY_WITH_OFFSET
    ; Add scrolling light clouds
    ld bc, CloudsMap
    ld hl, $9980
    ld de, $20
    ld a, $80
    call MEMCPY_WITH_OFFSET
    ; Fill in light clouds space
    ld bc, $20
    ld d, $83
    call SetInRange
    ; Add scrolling dark clouds
	ld bc, CloudsMap + $20
	ld de, $20
	ld a, $80
	call MEMCPY_WITH_OFFSET
    ; Fill in dark clouds space
    ld bc, $20
    ld d, $85
    call SetInRange
    ; Add sun
    jp SpawnSun

; UPDATE
EndlessUpdate::

.checkEndlessLevel:
    ; Delay increasing level switch timer
    ldh a, [hGlobalTimer]
    and %11111111
    jr nz, .endCheckEndlessLevel
    ; Check if it's time to switch levels
    ldh a, [hEndlessLevelSwitchTimer]
    cp a, 3
    jr nc, .changeLevel
    ; Increase level switch timer
    inc a
    ldh [hEndlessLevelSwitchTimer], a
    jr .endCheckEndlessLevel
.changeLevel:
    ; Stop enemy spawns
    ; Show countdown: 3, 2, 1

    ; Set level switch skip
    ld a, 1 
    ldh [hEndlessLevelSwitchSkip], a
    ; Reset level switch timer
    xor a ; ld a, 0
    ld [hEndlessLevelSwitchTimer], a
    ; Get random level
    RANDOM 5
    inc a
    ; Compare with current
    ld hl, wLevel
    cp a, [hl]
    jr nz, .updateLevel
    ; Same so offset
    inc a
    ld d, 5
    call MODULO
.updateLevel:
    ; Update level
    ld [hl], a
    ; Load the next level
    jp SetupNextLevelEndless
.endCheckEndlessLevel:

.checkEndlessTimer:
    ldh a, [hEndlessTimer]
    inc a
    ldh [hEndlessTimer], a
    cp a, ENDLESS_TIMER_RESET_TIME
    jr nz, .endCheckEndlessTimer
    xor a ; ld a, 0
    ldh [hEndlessTimer], a
.endCheckEndlessTimer:

; VERTICAL ****
.handleVertical:

; PREPARE TO SPAWN
.prepareVerticalSpawn:
    ldh a, [hEndlessTimer]
    cp a, ENDLESS_PREPARE_VERTICAL_SPAWN_TIME
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
    ldh a, [hEndlessVertical_A_Cooldown]
    cp a, 0
    jr nz, .verticalLaneLoop
    ; Lane free
    ld a, ENDLESS_VERTICAL_COOLDOWN
    ldh [hEndlessVertical_A_Cooldown], a
    jr .canPrepareVerticalSpawn
.verticalB:
    cp a, 1
    jr nz, .verticalC
    ldh a, [hEndlessVertical_B_Cooldown]
    cp a, 0
    jr nz, .verticalLaneLoop
    ; Lane free
    ld a, ENDLESS_VERTICAL_COOLDOWN
    ldh [hEndlessVertical_B_Cooldown], a
    jr .canPrepareVerticalSpawn
.verticalC:
    cp a, 2
    jr nz, .verticalD
    ldh a, [hEndlessVertical_C_Cooldown]
    cp a, 0
    jr nz, .verticalLaneLoop
    ; Lane free
    ld a, ENDLESS_VERTICAL_COOLDOWN
    ldh [hEndlessVertical_C_Cooldown], a
    jr .canPrepareVerticalSpawn
.verticalD:
    ; cp a, 3
    ; jr nz, .canPrepareVerticalSpawn
    ldh a, [hEndlessVertical_D_Cooldown]
    cp a, 0
    jr nz, .verticalLaneLoop
    ; Lane free
    ld a, ENDLESS_VERTICAL_COOLDOWN
    ldh [hEndlessVertical_D_Cooldown], a
    jr .canPrepareVerticalSpawn
.cannotPrepareVerticalSpawn:
    ld a, -1
    ldh [hEndlessVerticalLane], a
    jr .endPrepareVerticalSpawn
.canPrepareVerticalSpawn:
    ld a, c
    ldh [hEndlessVerticalLane], a
.chooseVerticalEnemy:
    RANDOM ENDLESS_VERTICAL_SPAWN_DENOMINATOR
; POINT BALLOON
.pointBalloon:
    cp a, ENDLESS_VERTICAL_SPAWN_POINT_BALLOON_RATE
    jr nc, .bomb
    ld a, POINT_BALLOON
    ldh [hEndlessVerticalEnemyNumber], a
.pointBalloonVariant:
    RANDOM ENDLESS_SPAWN_POINT_BALLOON_VARIANT_DENOMINATOR
.pointBalloonEasyVariant:
    cp a, ENDLESS_SPAWN_POINT_BALLOON_VARIANT_EASY_RATE
    jr nc, .pointBalloonMediumVariant
    ld a, BALLOON_EASY_VARIANT
    jr .pointBalloonVariantSet
.pointBalloonMediumVariant:
    cp a, ENDLESS_SPAWN_POINT_BALLOON_VARIANT_EASY_RATE + ENDLESS_SPAWN_POINT_BALLOON_VARIANT_MEDIUM_RATE
    jr nc, .pointBalloonHardVariant
    ld a, BALLOON_MEDIUM_VARIANT
    jr .pointBalloonVariantSet
.pointBalloonHardVariant:
    ; cp a, ENDLESS_SPAWN_POINT_BALLOON_VARIANT_EASY_RATE + ENDLESS_SPAWN_POINT_BALLOON_VARIANT_MEDIUM_RATE + ENDLESS_SPAWN_POINT_BALLOON_VARIANT_HARD_RATE
    ; jr nc, .endPointBalloonVariant
    ld a, BALLOON_HARD_VARIANT
    ; jr .pointBalloonVariantSet
.pointBalloonVariantSet:
    ldh [hEndlessVerticalEnemyVariant], a
.endPointBalloonVariant:
    jr .endChooseVerticalEnemy
; BOMB
.bomb:
    cp a, ENDLESS_VERTICAL_SPAWN_POINT_BALLOON_RATE + ENDLESS_VERTICAL_SPAWN_BOMB_RATE
    jr nc, .anvil
    ld a, BOMB
    ldh [hEndlessVerticalEnemyNumber], a
.bombVariant:
    RANDOM ENDLESS_SPAWN_BOMB_VARIANT_DENOMINATOR
.bombDirectVariant:
    cp a, ENDLESS_SPAWN_BOMB_VARIANT_DIRECT_RATE
    jr nc, .bombFollowVariant
    ld a, BOMB_DIRECT_VARIANT
    jr .bombVariantSet
.bombFollowVariant:
    ; cp a, ENDLESS_SPAWN_BOMB_VARIANT_DIRECT_RATE + ENDLESS_SPAWN_BOMB_VARIANT_FOLLOW_RATE
    ; jr nc, .endBombVariant
    ld a, BOMB_FOLLOW_VARIANT
    ; jr .bombVariantSet
.bombVariantSet:
    ldh [hEndlessVerticalEnemyVariant], a
.endBombVariant:
    jr .endChooseVerticalEnemy
; ANVIL
.anvil:
    ; cp a, ENDLESS_VERTICAL_SPAWN_POINT_BALLOON_RATE + ENDLESS_VERTICAL_SPAWN_BOMB_RATE + ENDLESS_VERTICAL_SPAWN_ANVIL_RATE
    ; jr nc, .endChooseVerticalEnemy
    ld a, ANVIL
    ldh [hEndlessVerticalEnemyNumber], a
    ld a, ANVIL_WARNING_VARIANT
    ldh [hEndlessVerticalEnemyVariant], a
    ; jr .endChooseVerticalEnemy
.endChooseVerticalEnemy:
.endPrepareVerticalSpawn:

; COOLDOWN LANES
.cooldownVerticalLanes:
    ldh a, [hGlobalTimer]
    and ENDLESS_VERTICAL_COOLDOWN_TIMER
    jr nz, .endCooldownVerticalLanes
.verticalACooldown:
    ldh a, [hEndlessVertical_A_Cooldown]
    cp a, 0
    jr z, .verticalBCooldown
    dec a
    ldh [hEndlessVertical_A_Cooldown], a
.verticalBCooldown:
    ldh a, [hEndlessVertical_B_Cooldown]
    cp a, 0
    jr z, .verticalCCooldown
    dec a
    ldh [hEndlessVertical_B_Cooldown], a
.verticalCCooldown:
    ldh a, [hEndlessVertical_C_Cooldown]
    cp a, 0
    jr z, .verticalDCooldown
    dec a
    ldh [hEndlessVertical_C_Cooldown], a
.verticalDCooldown:
    ldh a, [hEndlessVertical_D_Cooldown]
    cp a, 0
    jr z, .endCooldownVerticalLanes
    dec a
    ldh [hEndlessVertical_D_Cooldown], a
.endCooldownVerticalLanes: 

; TRY TO SPAWN
.tryToVerticalSpawn:
    ldh a, [hEndlessTimer]
    cp a, ENDLESS_VERTICAL_SPAWN_TIME
    jr nz, .endTryToVerticalSpawn

    ldh a, [hEndlessVerticalLane]
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
    ldh a, [hEndlessVerticalEnemyVariant]
    ldh [hEnemyVariant], a
    ; hEnemyNumber
    ldh a, [hEndlessVerticalEnemyNumber]
    ldh [hEnemyNumber], a
.spawnPointBalloon:
    cp a, POINT_BALLOON
    jr nz, .spawnBomb
    call SpawnPointBalloon
    jr .endTryToVerticalSpawn
.spawnBomb:
    cp a, BOMB
    jr nz, .spawnAnvil
    call SpawnBomb
    jr .endTryToVerticalSpawn
.spawnAnvil:
    ; cp a, ANVIL
    ; jr nz, .endTryToVerticalSpawn
    ; hEnemyY *update for anvil special case
    ld a, OFFSCREEN_TOP
    ldh [hEnemyY], a
    call SpawnAnvil
    ; jr .endTryToVerticalSpawn
.endTryToVerticalSpawn:

.endHandleVertical:

; HORIZONTAL ****
.handleHorizontal:

; PREPARE TO SPAWN
.prepareHorizontalSpawn:
    ldh a, [hEndlessTimer]
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
    ldh a, [hEndlessHorizontal_A_Cooldown]
    cp a, 0
    jr nz, .horizontalLaneLoop
    ; Lane free
    ld a, ENDLESS_HORIZONTAL_COOLDOWN
    ldh [hEndlessHorizontal_A_Cooldown], a
    jr .canPrepareHorizontalSpawn
.horizontalB:
    cp a, 1
    jr nz, .horizontalC
    ldh a, [hEndlessHorizontal_B_Cooldown]
    cp a, 0
    jr nz, .horizontalLaneLoop
    ; Lane free
    ld a, ENDLESS_HORIZONTAL_COOLDOWN
    ldh [hEndlessHorizontal_B_Cooldown], a
    jr .canPrepareHorizontalSpawn
.horizontalC:
    cp a, 2
    jr nz, .horizontalD
    ldh a, [hEndlessHorizontal_C_Cooldown]
    cp a, 0
    jr nz, .horizontalLaneLoop
    ; Lane free
    ld a, ENDLESS_HORIZONTAL_COOLDOWN
    ldh [hEndlessHorizontal_C_Cooldown], a
    jr .canPrepareHorizontalSpawn
.horizontalD:
    ; cp a, 3
    ; jr nz, .canPrepareHorizontalSpawn
    ldh a, [hEndlessHorizontal_D_Cooldown]
    cp a, 0
    jr nz, .horizontalLaneLoop
    ; Lane free
    ld a, ENDLESS_HORIZONTAL_COOLDOWN
    ldh [hEndlessHorizontal_D_Cooldown], a
    jr .canPrepareHorizontalSpawn
.cannotPrepareHorizontalSpawn:
    ld a, -1
    ldh [hEndlessHorizontalLane], a
    jr .endPrepareHorizontalSpawn
.canPrepareHorizontalSpawn:
    ld a, c
    ldh [hEndlessHorizontalLane], a
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
    ldh [hEndlessHorizontalEnemyDirection], a
.endChooseDirection:
.chooseHorizontalEnemy:
    RANDOM ENDLESS_HORIZONTAL_SPAWN_DENOMINATOR
; BALLOON CARRIER
.balloonCarrier:
    cp a, ENDLESS_HORIZONTAL_SPAWN_BALLOON_CARRIER_RATE
    jr nc, .bird
    ld a, BALLOON_CARRIER
    ldh [hEndlessHorizontalEnemyNumber], a
.balloonCarrierVariant:
    RANDOM ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_DENOMINATOR
.balloonCarrierNormalVariant:
    cp a, ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_NORMAL_RATE
    jr nc, .balloonCarrierProjectileVariant
    ld a, CARRIER_NORMAL_VARIANT
    jr .balloonCarrierVariantSet
.balloonCarrierProjectileVariant:
    cp a, ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_NORMAL_RATE + ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_PROJECTILE_RATE
    jr nc, .balloonCarrierFollowVariant
    ld a, CARRIER_PROJECTILE_VARIANT
    jr .balloonCarrierVariantSet
.balloonCarrierFollowVariant:
    cp a, ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_NORMAL_RATE + ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_PROJECTILE_RATE + ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_FOLLOW_RATE
    jr nc, .balloonCarrierBombVariant
    ld a, CARRIER_FOLLOW_VARIANT
    jr .balloonCarrierVariantSet
.balloonCarrierBombVariant:
    ; cp a, ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_NORMAL_RATE + ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_PROJECTILE_RATE + ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_FOLLOW_RATE + ENDLESS_SPAWN_BALLOON_CARRIER_VARIANT_BOMB_RATE
    ; jr nc, .endBalloonCarrierVariant
    ld a, CARRIER_BOMB_VARIANT
    ; jr .balloonCarrierVariantSet
.balloonCarrierVariantSet:
    ldh [hEndlessHorizontalEnemyVariant], a
.endBalloonCarrierVariant:
    jr .endChooseHorizontalEnemy
; BIRD
.bird:
    ; cp a, ENDLESS_HORIZONTAL_SPAWN_BALLOON_CARRIER_RATE + ENDLESS_HORIZONTAL_SPAWN_BIRD_RATE
    ; jr nc, .endChooseHorizontalEnemy
    ld a, BIRD
    ldh [hEndlessHorizontalEnemyNumber], a
.birdVariant:
    RANDOM ENDLESS_SPAWN_BIRD_VARIANT_DENOMINATOR
.birdEasyVariant:
    cp a, ENDLESS_SPAWN_BIRD_VARIANT_EASY_RATE
    jr nc, .birdHardVariant
    ld a, BIRD_EASY_VARIANT
    jr .birdVariantSet
.birdHardVariant:
    ; cp a, ENDLESS_SPAWN_BIRD_VARIANT_EASY_RATE + ENDLESS_SPAWN_BIRD_VARIANT_HARD_RATE
    ; jr nc, .endBirdVariant
    ld a, BIRD_HARD_VARIANT
    ; jr .birdVariantSet
.birdVariantSet:
    ldh [hEndlessHorizontalEnemyVariant], a
.endBirdVariant:
    ; jr .endChooseHorizontalEnemy
.endChooseHorizontalEnemy:
.endPrepareHorizontalSpawn:

; COOLDOWN LANES
.cooldownHorizontalLanes:
    ldh a, [hGlobalTimer]
    and ENDLESS_HORIZONTAL_COOLDOWN_TIMER
    jr nz, .endCooldownHorizontalLanes
.horizontalACooldown:
    ldh a, [hEndlessHorizontal_A_Cooldown]
    cp a, 0
    jr z, .horizontalBCooldown
    dec a
    ldh [hEndlessHorizontal_A_Cooldown], a
.horizontalBCooldown:
    ldh a, [hEndlessHorizontal_B_Cooldown]
    cp a, 0
    jr z, .horizontalCCooldown
    dec a
    ldh [hEndlessHorizontal_B_Cooldown], a
.horizontalCCooldown:
    ldh a, [hEndlessHorizontal_C_Cooldown]
    cp a, 0
    jr z, .horizontalDCooldown
    dec a
    ldh [hEndlessHorizontal_C_Cooldown], a
.horizontalDCooldown:
    ldh a, [hEndlessHorizontal_D_Cooldown]
    cp a, 0
    jr z, .endCooldownHorizontalLanes
    dec a
    ldh [hEndlessHorizontal_D_Cooldown], a
.endCooldownHorizontalLanes: 

; TRY TO SPAWN
.tryToHorizontalSpawn:
    ldh a, [hEndlessTimer]
    cp a, ENDLESS_HORIZONTAL_SPAWN_TIME
    jr nz, .endTryToHorizontalSpawn

    ldh a, [hEndlessHorizontalLane]
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
    ldh a, [hEndlessHorizontalEnemyDirection]
    ldh [hEnemyX], a
    ; hEnemyVariant
    ldh a, [hEndlessHorizontalEnemyVariant]
    ldh [hEnemyVariant], a
    ; hEnemyNumber
    ldh a, [hEndlessHorizontalEnemyNumber]
    ldh [hEnemyNumber], a
.spawnBalloonCarrier:
    cp a, BALLOON_CARRIER
    jr nz, .spawnBird
    call SpawnBalloonCarrier
    jr .endTryToHorizontalSpawn
.spawnBird:
    ; cp a, BIRD
    ; jr nz, .endTryToHorizontalSpawn
    call SpawnBird
    ; jr .endTryToHorizontalSpawn
.endTryToHorizontalSpawn:

.endHandleHorizontal:
    ret