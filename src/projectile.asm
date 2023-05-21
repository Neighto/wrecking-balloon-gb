INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "tileConstants.inc"

PROJECTILE_OAM_SPRITES EQU 1
PROJECTILE_OAM_BYTES EQU PROJECTILE_OAM_SPRITES * 4
PROJECTILE_COLLISION_TIME EQU %00000001
PROJECTILE_FLICKER_TIME EQU %00000011
PROJECTILE_WAIT_TO_KILL_DURATION EQU 7

PROJECTILE_COLLISION_Y EQU 1
PROJECTILE_COLLISION_X EQU 1
PROJECTILE_COLLISION_HEIGHT EQU 6
PROJECTILE_COLLISION_WIDTH EQU 6

PROJECTILE_Y_X_SIMILARITY_BUFFER EQU 25
; Y~=X
PROJECTILE_Y_EQUALS_X_Y_TIME EQU %00000001
PROJECTILE_Y_EQUALS_X_X_TIME EQU %00000000
; Y>X
PROJECTILE_Y_GREATER_THAN_X_Y_TIME EQU %00000000
PROJECTILE_Y_GREATER_THAN_X_X_TIME EQU %00000001
; Y<X
PROJECTILE_Y_LESS_THAN_X_Y_TIME EQU %00000111
PROJECTILE_Y_LESS_THAN_X_X_TIME EQU %00000000

; 0: Up, 1: Down
PROJECTILE_FLAG_Y_DIRECTION_MASK EQU ENEMY_FLAG_PARAM1_MASK
PROJECTILE_FLAG_Y_DIRECTION_BIT EQU ENEMY_FLAG_PARAM1_BIT
; 0: Left, 1: Right
PROJECTILE_FLAG_X_DIRECTION_MASK EQU ENEMY_FLAG_PARAM2_MASK
PROJECTILE_FLAG_X_DIRECTION_BIT EQU ENEMY_FLAG_PARAM2_BIT

; hEnemyParam1 = Update Y frequency
; hEnemyParam2 = Update X frequency
; hEnemyParam3 = Can Kill Timer

SECTION "enemy projectile", ROMX

; *************************************************************
; SPAWN
; *************************************************************
SpawnProjectile::
    ld b, PROJECTILE_OAM_SPRITES
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
    ldh [hEnemyFlags], a
    ;
    ; Setup movement direction
    ;
    ; Handle Y
    ldh a, [hEnemyY]
    ld d, a
    ldh a, [hPlayerY]
    sub a, d
    jr c, .negY
.posY:
    ; Set the direction flag
    ld d, a
    ldh a, [hEnemyFlags]
    set PROJECTILE_FLAG_Y_DIRECTION_BIT, a
    ldh [hEnemyFlags], a
    ld a, d
    jr .yUpdate
.negY:
    ; Get the absolute value
    cpl
    inc a
    ; jr .yUpdate
.yUpdate:
    ldh [hEnemyParam1], a ; Absolute value of Y2 - Y1
    ; Handle X
    ldh a, [hEnemyX]
    ld d, a
    ldh a, [hPlayerX]
    sub a, d
    jr c, .negX
.posX:
    ; Set the direction flag
    ld d, a
    ldh a, [hEnemyFlags]
    set PROJECTILE_FLAG_X_DIRECTION_BIT, a
    ldh [hEnemyFlags], a
    ld a, d
    jr .xUpdate
.negX:
    ; Get the absolute value
    cpl
    inc a
    ; jr .xUpdate
.xUpdate:
    ldh [hEnemyParam2], a ; Absolute value of X2 - X1
    ; Now compare
    ld d, a
    ldh a, [hEnemyParam1]
    ld e, a
    ; Check for similar
.checkSimilar1:
    sub a, PROJECTILE_Y_X_SIMILARITY_BUFFER
    jr c, .checkSimilar2
    cp a, d
    jr nc, .checkForExtremes
.checkSimilar2:
    add a, PROJECTILE_Y_X_SIMILARITY_BUFFER * 2
    ; jr c, .ySimilarToX ; Should never need to be checked
    cp a, d
    jr c, .checkForExtremes
.ySimilarToX:
    ld a, PROJECTILE_Y_EQUALS_X_Y_TIME
    ld d, PROJECTILE_Y_EQUALS_X_X_TIME
    jr .updateDirectionDimmers
    ; Check for extremes
.checkForExtremes:
    ld a, e
    cp a, d
    jr c, .yLessThanX
.yGreaterThanX:
    ld a, PROJECTILE_Y_GREATER_THAN_X_Y_TIME
    ld d, PROJECTILE_Y_GREATER_THAN_X_X_TIME
    jr .updateDirectionDimmers
.yLessThanX:
    ld a, PROJECTILE_Y_LESS_THAN_X_Y_TIME
    ld d, PROJECTILE_Y_LESS_THAN_X_X_TIME
    ; jr .updateDirectionDimmers
.updateDirectionDimmers:
    ldh [hEnemyParam1], a
    ld a, d
    ldh [hEnemyParam2], a
    ;
    ; Get hl pointing to OAM address
    ;
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ;
    ; Projectile OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, PROJECTILE_TILE
    ld [hli], a
    ld [hl], OAMF_PAL0
    ;
    ; Projectile sound
    ;
    call ProjectileSound
    ;
    ; Set struct
    ;
    LD_HL_BC
    jp SetEnemyStructWithHL

; *************************************************************
; UPDATE
; *************************************************************
ProjectileUpdate::

    ;
    ; Check flicker
    ;
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	PROJECTILE_FLICKER_TIME
    jr nz, .endFlicker
.canFlicker:
    ld hl, wOAM+3
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld a, [hl]
    cp a, OAMF_PAL0
    jr z, .palette1
.palette0:
    ld [hl], OAMF_PAL0
    jr .endFlicker
.palette1:
    ld [hl], OAMF_PAL1
.endFlicker:

    ;
    ; Check move
    ;
    ; Get OAM
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ; Get timer
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    ld b, a
    ; Check move Y
    ldh a, [hEnemyParam1]
    ld c, a
    ld a, b
    and a, c
    jr nz, .dontMoveY
    ; MOVE Y
    ldh a, [hEnemyFlags]
    and PROJECTILE_FLAG_Y_DIRECTION_MASK
    ldh a, [hEnemyY]
    jr nz, .moveYDown
.moveYUp:
    dec a
    dec a
    jr .moveY
.moveYDown:
    inc a
    inc a
.moveY:
    ldh [hEnemyY], a
    ld [hl], a
.dontMoveY:
    inc hl
    ; Check move X
    ldh a, [hEnemyParam2]
    ld c, a
    ld a, b
    and a, c
    jr nz, .dontMoveX
    ; MOVE X
    ldh a, [hEnemyFlags]
    and PROJECTILE_FLAG_X_DIRECTION_MASK
    ldh a, [hEnemyX]
    jr nz, .moveXRight
.moveXLeft:
    dec a
    dec a
    jr .moveX
.moveXRight:
    inc a
    inc a
.moveX:
    ldh [hEnemyX], a
    ld [hl], a
.dontMoveX:

    ;
    ; Check collision
    ;
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	PROJECTILE_COLLISION_TIME
    jr nz, .endCollision

    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .endCollision

    ; Check hit player
    SETUP_ENEMY_COLLIDER PROJECTILE_COLLISION_Y, PROJECTILE_COLLISION_HEIGHT, PROJECTILE_COLLISION_X, PROJECTILE_COLLISION_WIDTH
    call CollisionCheckPlayerBalloon
    jr z, .checkHitCactus
    call CollisionWithPlayer
    jr .deathOfProjectile
    ; Check hit cactus
.checkHitCactus:
    ; SETUP_ENEMY_COLLIDER PROJECTILE_COLLISION_Y, PROJECTILE_COLLISION_HEIGHT, PROJECTILE_COLLISION_X, PROJECTILE_COLLISION_WIDTH
    call CollisionCheckPlayerCactus
    jr z, .endCollision
    call StunPlayer
.deathOfProjectile:
    ld bc, PROJECTILE_OAM_BYTES
    call ClearEnemy
    jp SetEnemyStruct
.endCollision:

    ;
    ; Check offscreen
    ;
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and %00000001
    ld bc, PROJECTILE_OAM_BYTES
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