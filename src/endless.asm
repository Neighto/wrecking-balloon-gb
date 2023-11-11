INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

; PREPARE / SPAWN TIMING
ENDLESS_TIMER_RESET_TIME_EASY EQU 200
ENDLESS_TIMER_RESET_TIME_MEDIUM EQU 150
ENDLESS_TIMER_RESET_TIME_HARD EQU 100
ENDLESS_PREPARE_VERTICAL_SPAWN_TIME EQU 50 ; Must be < ENDLESS_TIMER_RESET_TIME_<DIFFICULTY>
ENDLESS_PREPARE_HORIZONTAL_SPAWN_TIME EQU 60 ; Must be < ENDLESS_TIMER_RESET_TIME_<DIFFICULTY>
ENDLESS_VERTICAL_SPAWN_TIME EQU 90 ; Must be < ENDLESS_TIMER_RESET_TIME_<DIFFICULTY>
ENDLESS_HORIZONTAL_SPAWN_TIME EQU 95 ; Must be < ENDLESS_TIMER_RESET_TIME_<DIFFICULTY>

; LANES

ENDLESS_VERTICAL_LANES EQU 4
ENDLESS_HORIZONTAL_LANES EQU 4
ENDLESS_VERTICAL_COOLDOWN EQU 20 ; Cooldown before that lane is available again
ENDLESS_HORIZONTAL_COOLDOWN EQU 40 ; Cooldown before that lane is available again
ENDLESS_VERTICAL_COOLDOWN_TIMER EQU %00000011 ; Wait time before decrementing cooldown counter
ENDLESS_HORIZONTAL_COOLDOWN_TIMER EQU %00000011 ; Wait time before decrementing cooldown counter

; LEVEL SWITCHING MID-GAME

ENDLESS_LEVEL_SWITCH_OFF EQU 0
ENDLESS_LEVEL_SWITCH_ON EQU 1
ENDLESS_LEVEL_DURATION EQU 22
ENDLESS_LEVEL_STOP_SPAWN_DURATION EQU 1
ENDLESS_LEVEL_DURATION_TIMER EQU %01111111

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
hEndlessResetTime:: DB ; Changes based on difficulty

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
hEndlessLevelSwitch:: DB
hEndlessLevelSwitchSkip:: DB
hEndlessLevelSwitchTimer:: DB
hEndlessLevelOrder:: DS ENDLESS_LEVEL_SWITCH_TOTAL

SECTION "endless", ROM0

; *************************************************************
; INITIALIZE
; *************************************************************
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

    ld a, ENDLESS_TIMER_RESET_TIME_EASY
    ldh [hEndlessResetTime], a

    ; Reset the random level order for endless array
    ld hl, hEndlessLevelOrder
    ld bc, ENDLESS_LEVEL_SWITCH_TOTAL
    ld d, NOT_LEVEL
    call SetInRange
    ; Always start with endless level
    ld hl, hEndlessLevelOrder
    ld a, LEVEL_ENDLESS
    ld [hl], a
    ; Choose random following order
    ld b, LEVEL_1
.setLevelOrderLoop:
    ; Get random level index (levels 1-5)
    RANDOM ENDLESS_LEVEL_SWITCH_TOTAL - 1
    inc a
    ld d, a ; D = index
.findSpaceFreeLoop:
    ld hl, hEndlessLevelOrder
    ADD_A_TO_HL ; HL = address
    ld a, NOT_LEVEL
    cp a, [hl]
    jr nz, .spaceNotFree
    ; Space is free
.spaceFree:
    ld a, b
    ld [hl], a
    ; Check if end of loop
    inc b
    ld a, b
    cp a, ENDLESS_LEVEL_SWITCH_TOTAL
    jr nz, .setLevelOrderLoop
    ret
    ; Space is not free
.spaceNotFree:
    inc d
    ld a, d
    ld d, ENDLESS_LEVEL_SWITCH_TOTAL - 1
    call MODULO
    inc a
    ld d, a
    jr .findSpaceFreeLoop
    ; Update level order
    ld [hli], a
    jr .setLevelOrderLoop

; *************************************************************
; GRAPHICS
; *************************************************************
LoadEndlessGraphics::
    ; Add Road
    ld hl, $9920
    call LoadRoadCommon ; Loads in tiles too important for other calls
    ; Lamps
    ld hl, $98C2
    call LoadLamp
    ld hl, $98D2
    call LoadLamp
    ; Hydrant
    ld hl, $9963
    call LoadHydrant
    ; Add hot air balloons
    ld a, HOT_AIR_BALLOON_TILE_OFFSET ; Top
    ld [$9848], a
    ld [$982D], a
    ld [$983E], a
    ld a, HOT_AIR_BALLOON_TILE_OFFSET + 1 ; Bottom
    ld [$9868], a
    ld [$984D], a
    ld [$985E], a
    ; Add scrolling thin clouds
    ld bc, CloudsMap + CLOUDS_THIN_OFFSET
    ld hl, $9880
    call MEMCPY_PATTERN_CLOUDS
    ; Add scrolling white clouds
    ld hl, $99C0
    ld bc, CloudsMap + CLOUDS_CUTSCENE_8_OFFSET
	call MEMCPY_PATTERN_CLOUDS
    ; Fill in while clouds space
    ld bc, SCRN_VX_B
    ld d, WHITE_BKG_TILE
    jp SetInRange

; *************************************************************
; UPDATE
; *************************************************************
EndlessUpdate::

    ;
    ; Check countdown
    ; Countdown and call to load new level
    ;
    ; Run countdown if not ended
    call Countdown
    jr nz, .endCheckCountdown
    ; Countdown is running
    ldh a, [hEndlessLevelSwitch]
    cp a, ENDLESS_LEVEL_SWITCH_ON
    jr nz, .endCheckCountdown
    call IsCountdownAtBalloonPop
    jr nz, .endCheckCountdown
    ; LEVEL SWITCH
    ; Update reset time (difficulty)
    ldh a, [hEndlessResetTime]
.easyResetTime:
    cp a, ENDLESS_TIMER_RESET_TIME_EASY
    jr nz, .mediumResetTime
    ld a, ENDLESS_TIMER_RESET_TIME_MEDIUM
    jr .updateResetTime
.mediumResetTime:
    cp a, ENDLESS_TIMER_RESET_TIME_MEDIUM
    jr nz, .hardResetTime
    ld a, ENDLESS_TIMER_RESET_TIME_HARD
    jr .updateResetTime
.hardResetTime:
    ; cp a, ENDLESS_TIMER_RESET_TIME_HARD
    ; jr nz, .veryHardResetTime
    ld a, ENDLESS_TIMER_RESET_TIME_HARD
    ; jr .updateResetTime
.updateResetTime:
    ldh [hEndlessResetTime], a
    ; Set level switch skip
    ld a, 1 
    ldh [hEndlessLevelSwitchSkip], a
    ; Reset level switch timer
    xor a ; ld a, 0
    ld [hEndlessLevelSwitchTimer], a
    ; Find current level
    ld hl, hEndlessLevelOrder
    ldh a, [hLevel]
    ld c, a
    ld b, 0
.findCurrentLevelLoop:
    ld a, [hli]
    cp a, c
    jr z, .getNextLevel
    inc b
    jr .findCurrentLevelLoop
    ; Get next level
.getNextLevel:
    ld a, b 
    cp a, ENDLESS_LEVEL_SWITCH_TOTAL - 1
    ld a, [hl]
    jr nz, .updateLevel
    ; Handle end of level array
    ldh a, [hEndlessLevelOrder] ; Back to start
    ; Update level
.updateLevel:
    ldh [hLevel], a
    ; Reset level switch
    ld a, ENDLESS_LEVEL_SWITCH_OFF
    ldh [hEndlessLevelSwitch], a
    ; Load the next level
    jp SetupNextLevelEndless
.endCheckCountdown:

    ;
    ; Check endless level
    ; Assess if enough time has passed and we can stop enemies spawning and begin countdown
    ;
    ld hl, hEndlessLevelSwitchTimer
    ; Delay increasing level switch timer
    ldh a, [hGlobalTimer]
    and ENDLESS_LEVEL_DURATION_TIMER
    jr nz, .checkEndlessLevelCommon
    ; Check if it's time to switch levels
    ld a, [hl]
    cp a, ENDLESS_LEVEL_DURATION
    jr nc, .initiateCountdown
    ; Increase level switch timer
    inc [hl]
    jr .checkEndlessLevelCommon
.initiateCountdown:
    ldh a, [hEndlessLevelSwitch] ; TODO maybe checkCountdown can just be part of this
    cp a, ENDLESS_LEVEL_SWITCH_ON
    jr z, .checkEndlessLevelCommon
    ; Set level switch
    ld a, ENDLESS_LEVEL_SWITCH_ON
    ldh [hEndlessLevelSwitch], a
    ; Initiate countdown for level switch
    call InitializeGame
    call SpawnCountdown
    ; Mute music
    call ChDACs.mute
.checkEndlessLevelCommon:
    ; Check if it's time to stop enemy spawns
    ld a, [hl]
    cp a, ENDLESS_LEVEL_DURATION - ENDLESS_LEVEL_STOP_SPAWN_DURATION
    ret nc
.endCheckEndlessLevel:

    ;
    ; Check endless timer
    ; Timer for enemy spawnings
    ;
    ldh a, [hEndlessResetTime]
    ld b, a
    ldh a, [hEndlessTimer]
    inc a
    ldh [hEndlessTimer], a
    cp a, b
    jr nz, .endCheckEndlessTimer
    xor a ; ld a, 0
    ldh [hEndlessTimer], a
.endCheckEndlessTimer:

    ;
    ; HANDLE VERTICAL
    ;

    ; 1 - PREPARE TO SPAWN
    ldh a, [hEndlessTimer]
    cp a, ENDLESS_PREPARE_VERTICAL_SPAWN_TIME
    jp nz, .endPrepareVerticalSpawn
    ; Determine which lane is free to spawn at if any
    ld b, ENDLESS_VERTICAL_LANES + 1 ; For looping
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
    ; No available vertical lanes
.cannotPrepareVerticalSpawn:
    ld a, -1
    ldh [hEndlessVerticalLane], a
    jr .endPrepareVerticalSpawn
    ; We have a vertical lane available
.canPrepareVerticalSpawn:
    ld a, c
    ldh [hEndlessVerticalLane], a

    ; Choose vertical enemy to prepare randomly
    RANDOM ENDLESS_VERTICAL_SPAWN_DENOMINATOR
    ; -- POINT BALLOON
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
    ; -- BOMB
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
    ; -- ANVIL
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

    ; 2 - COOLDOWN LANES
    ldh a, [hGlobalTimer]
    and ENDLESS_VERTICAL_COOLDOWN_TIMER
    jr nz, .endCooldownVerticalLanes
    ld b, 0
.verticalACooldown:
    ldh a, [hEndlessVertical_A_Cooldown]
    cp a, b
    jr z, .verticalBCooldown
    dec a
    ldh [hEndlessVertical_A_Cooldown], a
.verticalBCooldown:
    ldh a, [hEndlessVertical_B_Cooldown]
    cp a, b
    jr z, .verticalCCooldown
    dec a
    ldh [hEndlessVertical_B_Cooldown], a
.verticalCCooldown:
    ldh a, [hEndlessVertical_C_Cooldown]
    cp a, b
    jr z, .verticalDCooldown
    dec a
    ldh [hEndlessVertical_C_Cooldown], a
.verticalDCooldown:
    ldh a, [hEndlessVertical_D_Cooldown]
    cp a, b
    jr z, .endCooldownVerticalLanes
    dec a
    ldh [hEndlessVertical_D_Cooldown], a
.endCooldownVerticalLanes: 

    ; 3 - TRY TO SPAWN
    ldh a, [hEndlessTimer]
    cp a, ENDLESS_VERTICAL_SPAWN_TIME
    jr nz, .endTryToVerticalSpawn
    ; Is lane available
    ldh a, [hEndlessVerticalLane]
    cp a, -1
    jr z, .endTryToVerticalSpawn
    ; Can vertical spawn
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

    ;
    ; HANDLE HORIZONTAL
    ;

    ; 1 - PREPARE TO SPAWN
    ldh a, [hEndlessTimer]
    cp a, ENDLESS_PREPARE_HORIZONTAL_SPAWN_TIME
    jp nz, .endPrepareHorizontalSpawn
    ; Determine which lane is free to spawn at if any
    ld b, ENDLESS_HORIZONTAL_LANES + 1 ; For looping
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
    ; No available horizontal lanes
.cannotPrepareHorizontalSpawn:
    ld a, -1
    ldh [hEndlessHorizontalLane], a
    jr .endPrepareHorizontalSpawn
    ; We have a horizontal lane available
.canPrepareHorizontalSpawn:
    ld a, c
    ldh [hEndlessHorizontalLane], a

    ; Choose direction
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
; .endChooseDirection:

    ; Choose horizontal enemy to prepare randomly
    RANDOM ENDLESS_HORIZONTAL_SPAWN_DENOMINATOR
    ; -- BALLOON CARRIER
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
    ; -- BIRD
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

    ; 2 - COOLDOWN LANES
    ldh a, [hGlobalTimer]
    and ENDLESS_HORIZONTAL_COOLDOWN_TIMER
    jr nz, .endCooldownHorizontalLanes
    ld b, 0
.horizontalACooldown:
    ldh a, [hEndlessHorizontal_A_Cooldown]
    cp a, b
    jr z, .horizontalBCooldown
    dec a
    ldh [hEndlessHorizontal_A_Cooldown], a
.horizontalBCooldown:
    ldh a, [hEndlessHorizontal_B_Cooldown]
    cp a, b
    jr z, .horizontalCCooldown
    dec a
    ldh [hEndlessHorizontal_B_Cooldown], a
.horizontalCCooldown:
    ldh a, [hEndlessHorizontal_C_Cooldown]
    cp a, b
    jr z, .horizontalDCooldown
    dec a
    ldh [hEndlessHorizontal_C_Cooldown], a
.horizontalDCooldown:
    ldh a, [hEndlessHorizontal_D_Cooldown]
    cp a, b
    jr z, .endCooldownHorizontalLanes
    dec a
    ldh [hEndlessHorizontal_D_Cooldown], a
.endCooldownHorizontalLanes: 

    ; 3 - TRY TO SPAWN
    ldh a, [hEndlessTimer]
    cp a, ENDLESS_HORIZONTAL_SPAWN_TIME
    jr nz, .endTryToHorizontalSpawn
    ; Is lane available
    ldh a, [hEndlessHorizontalLane]
    cp a, -1
    jr z, .endTryToHorizontalSpawn
    ; Can horizontal spawn
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
    ret