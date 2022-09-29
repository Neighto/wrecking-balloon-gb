INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

BIRD_OAM_SPRITES EQU 3
BIRD_OAM_BYTES EQU BIRD_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
BIRD_MOVE_TIME EQU %00000001
BIRD_COLLISION_TIME EQU %00000011

BIRD_VERTICAL_MOVE_TIME EQU %00000001
BIRD_HORIZONTAL_SPEED EQU 2
BIRD_VERTICAL_SPEED EQU 1
BIRD_FLAP_UP_SPEED EQU 3

BIRD_TILE_1 EQU $18
BIRD_TILE_2 EQU $1A
BIRD_TILE_2_ALT EQU $1E
BIRD_TILE_3 EQU $1C
BIRD_TILE_3_ALT EQU $20

BIRD_DEAD_TILE_1 EQU $28
BIRD_DEAD_TILE_2 EQU $2A
BIRD_DEAD_TILE_3 EQU $2C

BIRD_POINTS EQU 100

SECTION "bird", ROMX

SpawnBird::
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
.availableSpace:
    ld b, BIRD_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    ret z
.availableOAMSpace:
    call InitializeEnemyStructVars
    ld a, b
    ldh [hEnemyOAM], a
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    set ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.variantVisual:
    ldh a, [hEnemyVariant]
.easyVisual:
    cp a, BIRD_EASY_VARIANT
    jr nz, .hardVisual
    ld e, OAMF_PAL0
    jr .endVariantVisual
.hardVisual:
    cp a, BIRD_HARD_VARIANT
    jr nz, .endVariantVisual
    ld e, OAMF_PAL1
.endVariantVisual:

.setupByDirection:
    ldh a, [hEnemyX]
    cp a, SCRN_X / 2
    jr c, .isLeftside
    cp a, SPAWN_ENEMY_LEFT_BUFFER
    jr nc, .isLeftside
.isRightside:
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DIRECTION_BIT, a
    ldh [hEnemyFlags], a
    
.birdLeft:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld [hl], BIRD_TILE_1
    inc l
    ld a, e
    ld [hli], a
.birdMiddle:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld a, e
    ld [hli], a
.birdRight:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld [hl], BIRD_TILE_3
    inc l
    ld a, e
    ld [hl], a
    jr .setStruct
.isLeftside:
.leftBirdLeft:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld [hl], BIRD_TILE_3
    inc l
    ld a, e
    or a, OAMF_XFLIP
    ld [hli], a
.leftBirdMiddle:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld a, e
    or a, OAMF_XFLIP
    ld [hli], a
.leftBirdRight:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld [hl], BIRD_TILE_1
    inc l
    ld a, e
    or a, OAMF_XFLIP
    ld [hl], a
.setStruct:
    LD_HL_BC
    jp SetEnemyStruct

UpdateBirdPosition:
.birdLeft:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    inc l
    inc l
.birdMiddle:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.birdRight:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hl], a
    ret

BirdFall:
    ldh a, [hEnemyY]
    add a, 2
    ldh [hEnemyY], a
    call UpdateBirdPosition
.checkOffscreen:
    ldh a, [hEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ld bc, BIRD_OAM_BYTES
    call ClearEnemy
.endOffscreen:
    ret

BirdUpdate::

.checkAlive:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jp z, .isDead
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	BIRD_MOVE_TIME
    jp nz, .endMove
.canMove:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DIRECTION_MASK
    jr z, .isLeftside
.isRightside:
    ldh a, [hEnemyX]
    sub a, BIRD_HORIZONTAL_SPEED
    ldh [hEnemyX], a
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    jr .verticalMovement
.isLeftside:
    ldh a, [hEnemyX]
    add a, BIRD_HORIZONTAL_SPEED
    ldh [hEnemyX], a
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
.verticalMovement:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and BIRD_VERTICAL_MOVE_TIME
    jp nz, .endVerticalMovement
.variantMove:
    ldh a, [hEnemyVariant]    
.moveEasy:
    cp a, BIRD_EASY_VARIANT 
    jr nz, .moveHard
    ld b, BIRD_VERTICAL_SPEED
    ld c, BIRD_FLAP_UP_SPEED
    ldh a, [hEnemyAnimationFrame]
    cp a, 0
    jr z, .soar
    cp a, 6
    jr c, .moveDown
    jr z, .flap
    cp a, 7
    jr z, .moveUp
    xor a
    ldh [hEnemyAnimationFrame], a
    jr .endVerticalMovement
.moveHard:
    cp a, BIRD_HARD_VARIANT 
    jr nz, .endVerticalMovement
    ld b, BIRD_VERTICAL_SPEED * 2
    ld c, BIRD_FLAP_UP_SPEED * 2
    ldh a, [hEnemyAnimationFrame]
    cp a, 0
    jr z, .soar
    cp a, 12
    jr c, .moveDown
    jr z, .flap
    cp a, 16
    jr c, .moveUp
    xor a
    ldh [hEnemyAnimationFrame], a
    jr .endVerticalMovement
.soar:
    ld [hl], BIRD_TILE_3_ALT
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], BIRD_TILE_2_ALT
.moveDown:
    ldh a, [hEnemyY]
    add a, b
    ldh [hEnemyY], a
    jr .endFrame
.flap:
    ld [hl], BIRD_TILE_3
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], BIRD_TILE_2
.moveUp:
    ldh a, [hEnemyY]
    sub a, c
    ldh [hEnemyY], a
.endFrame:
    ldh a, [hEnemyAnimationFrame]
    inc a
    ldh [hEnemyAnimationFrame], a
.endVerticalMovement:
    call UpdateBirdPosition
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	BIRD_COLLISION_TIME
    jp nz, .endCollision
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .deathOfBird
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 24
    ld e, 8
    call CollisionCheck
    jr z, .checkHitCactus
    call CollisionWithPlayer
    jp .endCollision
.checkHitCactus:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 24
    ld e, 8
    call CollisionCheck
    jr z, .endCollision
    call CollisionWithPlayerCactus
    jr .endCollision
.deathOfBird:
    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a
    ; Points
    ld a, BIRD_POINTS
    call AddPoints
    ; Animation trigger
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ; Sound
    call FireworkSound
    ; Screaming bird
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DIRECTION_MASK
    jr z, .facingRight
.facingLeft:
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_3
    jr .endCollision
.facingRight:
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_3
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_1
.endCollision:

.checkOffscreen:
    ldh a, [hEnemyX]
    ld b, a
    ld a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VX - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    ld bc, BIRD_OAM_BYTES
    call ClearEnemy
    jr z, .setStruct
.endOffscreen:
    jr .setStruct

.isDead:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DYING_MASK
    jr z, .setStruct
.animating:
    ldh a, [hEnemyY]
    add a, 2
    ldh [hEnemyY], a
    call UpdateBirdPosition
.checkOffscreenY:
    ldh a, [hEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .setStruct
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .setStruct
.offscreenY:
    ld bc, BIRD_OAM_BYTES
    call ClearEnemy
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    jp SetEnemyStruct