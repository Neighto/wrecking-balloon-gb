INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "tileConstants.inc"

BOMB_OAM_SPRITES EQU 2
BOMB_OAM_BYTES EQU BOMB_OAM_SPRITES * 4
BOMB_FOLLOW_TIME EQU %00000011
BOMB_COLLISION_TIME EQU %00000011
BOMB_EXPLOSION_X_OFFSET EQU -4

BOMB_DEFAULT_SPEED EQU 2

BOMB_COLLISION_Y EQU 0
BOMB_COLLISION_X EQU 0
BOMB_COLLISION_WIDTH EQU 16
BOMB_COLLISION_HEIGHT EQU 14

SECTION "bomb", ROMX

; *************************************************************
; SPAWN
; *************************************************************
SpawnBomb::
    ld b, BOMB_OAM_SPRITES
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
.directVisual:
    cp a, BOMB_DIRECT_VARIANT
    jr nz, .followVisual
    ld d, BOMB_DIRECT_TILE
    jr .endVariantVisual
.followVisual:
    cp a, BOMB_FOLLOW_VARIANT
    jr nz, .endVariantVisual
    ld d, BOMB_FOLLOW_TILE
.endVariantVisual:
.checkNightSprite:
    ldh a, [rOBP1]
    cp a, NIGHT_SPRITE_PAL1
    jr nz, .isNotNightSprite
.isNightSprite:
    ld e, OAMF_PAL0
    jr .endCheckNightSprite
.isNotNightSprite:
    ld e, OAMF_PAL1
.endCheckNightSprite:
    ;
    ; Balloon left OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
    ;
    ; Balloon right OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    or a, OAMF_XFLIP
    ld [hl], a
    ;
    ; Set struct
    ;
    LD_HL_BC
    jp SetEnemyStructWithHL

; *************************************************************
; UPDATE
; *************************************************************
BombUpdate::

    ;
    ; Check alive
    ;
    ldh a, [hEnemyFlags]
    ld b, a
    and ENEMY_FLAG_ALIVE_MASK
    jr nz, .isAlive
    ; Is popped
    ld a, b
    and ENEMY_FLAG_DYING_MASK
    jr z, .clear
    ; Trigger explosion
    ld a, b
    res ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ; Set struct before spawn
    call SetEnemyStruct
    ; Spawn explosion
    ld a, EXPLOSION
    ldh [hEnemyNumber], a
    ld a, EXPLOSION_BOMB_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyX]
    add BOMB_EXPLOSION_X_OFFSET
    ldh [hEnemyX], a
    jp SpawnExplosion
    ; Clear
.clear:
    ld bc, BOMB_OAM_BYTES
    call ClearEnemy
    jp SetEnemyStruct
.isAlive:

    ;
    ; Check move
    ;
    ; Vertical movement
    ldh a, [hEnemyY]
    sub a, BOMB_DEFAULT_SPEED
    ldh [hEnemyY], a
    ; Check special variant
    ldh a, [hEnemyVariant]
    cp a, BOMB_FOLLOW_VARIANT
    jr nz, .moveOtherVariant
.moveFollowVariant:
    ; Horizontal movement
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and BOMB_FOLLOW_TIME
    jr nz, .setOAM
    ldh a, [hPlayerX]
    ld b, a
    ldh a, [hEnemyX]
    cp a, b
    jr z, .setOAM
    ld hl, hEnemyX
    jr c, .moveRight
.moveLeft:
    dec [hl]
    jr .setOAM
.moveRight:
    inc [hl]
.moveOtherVariant:
.setOAM:
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    UPDATE_OAM_POSITION_ENEMY 2, 1
.endMove:

    ;
    ; Check collision
    ;
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and BOMB_COLLISION_TIME
    jr nz, .endCollision
    ; Hit by enemy
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .deathOfBomb
    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .checkHitByBullet
    ; Check hit player cactus
    SETUP_ENEMY_COLLIDER BOMB_COLLISION_Y, BOMB_COLLISION_HEIGHT, BOMB_COLLISION_X, BOMB_COLLISION_WIDTH
    call CollisionCheckPlayerCactus
    jr z, .checkHitByBullet
    call CollisionWithPlayer
    jr .deathOfBomb
    ; Check hit bullet
.checkHitByBullet:
    call EnemyHitBullet
    jr z, .endCollision
.deathOfBomb:
    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_ALIVE_BIT, a
    set ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ; Points
.variantPoints:
    ldh a, [hEnemyVariant]
.directPoints:
    cp a, BOMB_DIRECT_VARIANT
    jr nz, .followPoints
    ld a, BOMB_DIRECT_POINTS
    jr .updatePoints
.followPoints:
    cp a, BOMB_FOLLOW_VARIANT
    jr nz, .endVariantPoints
    ld a, BOMB_FOLLOW_POINTS
.updatePoints:
    call AddPoints
.endVariantPoints:
.endCollision:

    ;
    ; Check offscreen
    ;
    ld bc, BOMB_OAM_BYTES
    call HandleEnemyOffscreenVertical
    ; Enemy may be cleared, must do setStruct next

    ;
    ; Set struct
    ;
    jp SetEnemyStruct