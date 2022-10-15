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
BIRD_FALLING_SPEED EQU 2

BIRD_TILE_1 EQU $30
BIRD_TILE_2 EQU $32
BIRD_TILE_2_ALT EQU $36
BIRD_TILE_3 EQU $34
BIRD_TILE_3_ALT EQU $38

BIRD_DEAD_TILE_1 EQU $3A
BIRD_DEAD_TILE_2 EQU $3C
BIRD_DEAD_TILE_3 EQU $3E

BIRD_WIDTH EQU 24
BIRD_HEIGHT EQU 8

BIRD_POINTS EQU 100

; hEnemyParam1 = Animation Frame

SECTION "bird", ROMX

; SPAWN
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
    ; Initialize
    call InitializeEnemyStructVars
    ld a, b
    ldh [hEnemyOAM], a
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    set ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a
    ; Get hl pointing to OAM address
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
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
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    UPDATE_OAM_POSITION_ENEMY 3, 1
    ret

; UPDATE
BirdUpdate::

.checkAlive:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jr nz, .isAlive
.isDead:
    ; Fall
    ldh a, [hEnemyY]
    add a, BIRD_FALLING_SPEED
    ldh [hEnemyY], a
    call UpdateBirdPosition
.checkOffscreenY:
    ld bc, BIRD_OAM_BYTES
    call HandleEnemyOffscreenVertical
    jp .setStruct
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
    ld hl, wOAM+10
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    jr .verticalMovement
.isLeftside:
    ldh a, [hEnemyX]
    add a, BIRD_HORIZONTAL_SPEED
    ldh [hEnemyX], a
    ld hl, wOAM+2
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
.verticalMovement:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and BIRD_VERTICAL_MOVE_TIME
    jr nz, .endVerticalMovement
.variantMove:
    ldh a, [hEnemyVariant]    
.moveEasy:
    cp a, BIRD_EASY_VARIANT 
    jr nz, .moveHard
    ld b, BIRD_VERTICAL_SPEED
    ld c, BIRD_FLAP_UP_SPEED
    ldh a, [hEnemyParam1]
    cp a, 0
    jr z, .soar
    cp a, 6
    jr c, .moveDown
    jr z, .flap
    cp a, 7
    jr z, .moveUp
    xor a
    ldh [hEnemyParam1], a
    jr .endVerticalMovement
.moveHard:
    cp a, BIRD_HARD_VARIANT 
    jr nz, .endVerticalMovement
    ld b, BIRD_VERTICAL_SPEED * 2
    ld c, BIRD_FLAP_UP_SPEED * 2
    ldh a, [hEnemyParam1]
    cp a, 0
    jr z, .soar
    cp a, 12
    jr c, .moveDown
    jr z, .flap
    cp a, 16
    jr c, .moveUp
    xor a
    ldh [hEnemyParam1], a
    jr .endVerticalMovement
.soar:
    ld [hl], BIRD_TILE_3_ALT
    ld hl, wOAM+6
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld [hl], BIRD_TILE_2_ALT
.moveDown:
    ldh a, [hEnemyY]
    add a, b
    ldh [hEnemyY], a
    jr .endFrame
.flap:
    ld [hl], BIRD_TILE_3
    ld hl, wOAM+6
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld [hl], BIRD_TILE_2
.moveUp:
    ldh a, [hEnemyY]
    sub a, c
    ldh [hEnemyY], a
.endFrame:
    ldh a, [hEnemyParam1]
    inc a
    ldh [hEnemyParam1], a
.endVerticalMovement:
    call UpdateBirdPosition
.endMove:

.checkCollision:
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	BIRD_COLLISION_TIME
    jr nz, .endCollision
    ; Hit by enemy
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .deathOfBird
    ; Is player alive
    ldh a, [hPlayerAlive]
    cp a, 0
    jr z, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld d, BIRD_WIDTH
    ld e, BIRD_HEIGHT
    call CollisionCheck
    jr z, .checkHitCactus
    call CollisionWithPlayer
    jr .endCollision
.checkHitCactus:
    ld bc, wPlayerCactusOAM
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld d, BIRD_WIDTH
    ld e, BIRD_HEIGHT
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
    ; Sound
    call FireworkSound
    ; Screaming bird
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DIRECTION_MASK
    jr z, .facingRight
.facingLeft:
    ld b, BIRD_DEAD_TILE_1
    ld c, BIRD_DEAD_TILE_2
    ld d, BIRD_DEAD_TILE_3
    jr .facingCommon
.facingRight:
    ld b, BIRD_DEAD_TILE_3
    ld c, BIRD_DEAD_TILE_2
    ld d, BIRD_DEAD_TILE_1
.facingCommon:
    ld hl, wOAM+2
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld a, b
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, c
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, d
    ld [hl], a
.endCollision:

.checkOffscreen:
    ld bc, BIRD_OAM_BYTES
    call HandleEnemyOffscreenHorizontal
    ; Enemy may be cleared, must do setStruct next
.endOffscreen:

.setStruct:
    ld hl, wEnemies
    ADD_TO_HL [wEnemyOffset]
    jp SetEnemyStruct