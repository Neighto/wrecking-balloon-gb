INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "tileConstants.inc"

BIRD_OAM_SPRITES EQU 3
BIRD_OAM_BYTES EQU BIRD_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
BIRD_MOVE_TIME EQU %00000001
BIRD_COLLISION_TIME EQU %00000011
BIRD_VERTICAL_MOVE_TIME EQU %00000001

BIRD_HORIZONTAL_SPEED EQU 2
BIRD_VERTICAL_SPEED EQU 1
BIRD_FLAP_UP_SPEED EQU 3
BIRD_FALLING_SPEED EQU 2

BIRD_COLLISION_Y EQU 0
BIRD_COLLISION_X EQU 0
BIRD_COLLISION_HEIGHT EQU 9
BIRD_COLLISION_WIDTH EQU 24

; hEnemyParam1 = Animation Frame

SECTION "bird", ROMX

; *************************************************************
; SPAWN
; *************************************************************
SpawnBird::
    ld b, BIRD_OAM_SPRITES
    call FindRAMAndOAMForEnemy ; hl = RAM space, b = OAM offset
    ret z
    ;
    ; Initialize
    ;
    call InitializeEnemyStructVars
    ld a, b
    ldh [hEnemyOAM], a
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    set ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a
    ;
    ; Get hl pointing to OAM address
    ;
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
    ;
    ; Bird left OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld [hl], BIRD_TILE_1
    inc l
    ld a, e
    ld [hli], a
    ;
    ; Bird middle OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld a, e
    ld [hli], a
    ;
    ; Bird right OAM
    ;
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
    ;
    ; Bird left OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld [hl], BIRD_TILE_3
    inc l
    ld a, e
    or a, OAMF_XFLIP
    ld [hli], a
    ;
    ; Bird middle OAM
    ;
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
    ;
    ; Bird right OAM
    ;
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
    ;
    ; Set struct
    ;
.setStruct:
    LD_HL_BC
    jp SetEnemyStructWithHL

UpdateBirdPosition:
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    UPDATE_OAM_POSITION_ENEMY 3, 1
    ret

; *************************************************************
; UPDATE
; *************************************************************
BirdUpdate::

    ;
    ; Check alive
    ;
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jr nz, .isAlive
    ; Is dead
    ; Fall
    ldh a, [hEnemyY]
    add a, BIRD_FALLING_SPEED
    ldh [hEnemyY], a
    call UpdateBirdPosition
    jp .checkCollision
.isAlive:

    ;
    ; Check move
    ;
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	BIRD_MOVE_TIME
    jp nz, .endMove
    ; Can move
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

    ;
    ; Check hit by enemy
    ;
    ; Hit by enemy
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr z, .endHitByEnemy
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
.endHitByEnemy:

    ;
    ; Check collision
    ;
.checkCollision:
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	BIRD_COLLISION_TIME
    jr nz, .endCollision
    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .endCollision
    ; Check hit player balloon
    SETUP_ENEMY_COLLIDER BIRD_COLLISION_Y, BIRD_COLLISION_HEIGHT, BIRD_COLLISION_X, BIRD_COLLISION_WIDTH
    call CollisionCheckPlayerBalloon
    jr z, .checkHitCactus
    call CollisionWithPlayer
    jr .endCollision
    ; Check hit player cactus
.checkHitCactus:
    ; SETUP_ENEMY_COLLIDER BIRD_COLLISION_Y, BIRD_COLLISION_HEIGHT, BIRD_COLLISION_X, BIRD_COLLISION_WIDTH
    call CollisionCheckPlayerCactus
    call nz, StunPlayer
    ; jr .endCollision
.endCollision:

    ;
    ; Check offscreen
    ;
.checkOffscreen:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and %00000001
    ld bc, BIRD_OAM_BYTES
    jr z, .checkVertical
.checkHorizontal:
    call HandleEnemyOffscreenHorizontal
    jp SetEnemyStruct
.checkVertical:
    call HandleEnemyOffscreenVertical
    ; Enemy may be cleared, must do setStruct next

    ;
    ; Set struct
    ;
    jp SetEnemyStruct