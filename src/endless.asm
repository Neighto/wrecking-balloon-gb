INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

ENDLESS_DELAY_TIMER_RESET_TIME EQU 100

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

ENDLESS_VERTICAL_SPAWN_DENOMINATOR EQU 10
ENDLESS_VERTICAL_SPAWN_POINT_BALLOON_RATE EQU 5
ENDLESS_VERTICAL_SPAWN_BOMB_RATE EQU 4
ENDLESS_VERTICAL_SPAWN_ANVIL_RATE EQU 1

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

SECTION "endless vars", WRAM0
    wEndlessTimer:: DB
    wEndlessDelayTimer:: DB

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
    ld [wEndlessHorizontalEnemyDirection], a
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
    cp a, ENDLESS_DELAY_TIMER_RESET_TIME
    jr nz, .endCheckEndlessTimer
    xor a ; ld a, 0
    ld [wEndlessDelayTimer], a
.endCheckEndlessTimer:

; VERTICAL ****
.handleVertical:

; PREPARE TO SPAWN
.prepareVerticalSpawn:
    ld a, [wEndlessDelayTimer]
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
    RANDOM ENDLESS_VERTICAL_SPAWN_DENOMINATOR
; POINT BALLOON
.pointBalloon:
    cp a, ENDLESS_VERTICAL_SPAWN_POINT_BALLOON_RATE
    jr nc, .bomb
    ld a, POINT_BALLOON
    ld [wEndlessVerticalEnemyNumber], a
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
    ld [wEndlessVerticalEnemyVariant], a
.endPointBalloonVariant:
    jr .endChooseVerticalEnemy
; BOMB
.bomb:
    cp a, ENDLESS_VERTICAL_SPAWN_POINT_BALLOON_RATE + ENDLESS_VERTICAL_SPAWN_BOMB_RATE
    jr nc, .anvil
    ld a, BOMB
    ld [wEndlessVerticalEnemyNumber], a
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
    ld [wEndlessVerticalEnemyVariant], a
.endBombVariant:
    jr .endChooseVerticalEnemy
; ANVIL
.anvil:
    ; cp a, ENDLESS_VERTICAL_SPAWN_POINT_BALLOON_RATE + ENDLESS_VERTICAL_SPAWN_BOMB_RATE + ENDLESS_VERTICAL_SPAWN_ANVIL_RATE
    ; jr nc, .endChooseVerticalEnemy
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
    and ENDLESS_VERTICAL_COOLDOWN_TIMER
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
    cp a, ENDLESS_VERTICAL_SPAWN_TIME
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
    RANDOM ENDLESS_HORIZONTAL_SPAWN_DENOMINATOR
; BALLOON CARRIER
.balloonCarrier:
    cp a, ENDLESS_HORIZONTAL_SPAWN_BALLOON_CARRIER_RATE
    jr nc, .bird
    ld a, BALLOON_CARRIER
    ld [wEndlessHorizontalEnemyNumber], a
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
    ld [wEndlessHorizontalEnemyVariant], a
.endBalloonCarrierVariant:
    jr .endChooseHorizontalEnemy
; BIRD
.bird:
    ; cp a, ENDLESS_HORIZONTAL_SPAWN_BALLOON_CARRIER_RATE + ENDLESS_HORIZONTAL_SPAWN_BIRD_RATE
    ; jr nc, .endChooseHorizontalEnemy
    ld a, BIRD
    ld [wEndlessHorizontalEnemyNumber], a
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
    ld [wEndlessHorizontalEnemyVariant], a
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
    cp a, ENDLESS_HORIZONTAL_SPAWN_TIME
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