INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "tileConstants.inc"

BOSS_NEEDLE_OAM_SPRITES EQU 1
BOSS_NEEDLE_OAM_BYTES EQU BOSS_NEEDLE_OAM_SPRITES * 4
BOSS_NEEDLE_COLLISION_TIME EQU %00000011
BOSS_NEEDLE_VERTICAL_MOVEMENT_TIME EQU 6

BOSS_NEEDLE_COLLISION_Y EQU 0
BOSS_NEEDLE_COLLISION_X EQU 0
BOSS_NEEDLE_COLLISION_HEIGHT EQU 16
BOSS_NEEDLE_COLLISION_WIDTH EQU 8

BOSS_NEEDLE_SPEED EQU 4

; hEnemyParam1 = Vertical Movement Counter

SECTION "boss needle", ROMX

; *************************************************************
; SPAWN
; *************************************************************
SpawnBossNeedle::
    ld b, BOSS_NEEDLE_OAM_SPRITES
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
    ; Get hl pointing to OAM address
    ;
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
.variantDirection:
    ldh a, [hEnemyVariant]
.leftDirection:
    cp a, NEEDLE_UP_MOVE_LEFT_VARIANT
    jr z, .isLeftDirection
    cp a, NEEDLE_DOWN_MOVE_LEFT_VARIANT
    jr nz, .rightDirection
.isLeftDirection:
    ld e, OAMF_PAL0
    jr .endVariantDirection
.rightDirection:
    cp a, NEEDLE_UP_MOVE_RIGHT_VARIANT
    jr z, .isRightDirection
    cp a, NEEDLE_DOWN_MOVE_RIGHT_VARIANT
    jr nz, .endVariantDirection
.isRightDirection:
    ld e, OAMF_PAL0 | OAMF_XFLIP
.endVariantDirection:
    ;
    ; Boss needle OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, BOSS_NEEDLE_TILE
    ld [hli], a
    ld [hl], e
    ;
    ; Set struct
    ;
    LD_HL_BC
    jp SetEnemyStructWithHL

; *************************************************************
; UPDATE
; *************************************************************
BossNeedleUpdate::

    ;
    ; Check move
    ;
.bossNeedleOAM:
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ; Variant direction
    ldh a, [hEnemyVariant]
.upLeftDirection:
    cp a, NEEDLE_UP_MOVE_LEFT_VARIANT
    jr nz, .upRightDirection
    ld b, BOSS_NEEDLE_SPEED * -1
    ld c, BOSS_NEEDLE_SPEED * -1
    jr .endVariantDirection
.upRightDirection:
    cp a, NEEDLE_UP_MOVE_RIGHT_VARIANT
    jr nz, .downLeftDirection
    ld b, BOSS_NEEDLE_SPEED * -1
    ld c, BOSS_NEEDLE_SPEED
    jr .endVariantDirection
.downLeftDirection:
    cp a, NEEDLE_DOWN_MOVE_LEFT_VARIANT
    jr nz, .downRightDirection
    ld b, BOSS_NEEDLE_SPEED
    ld c, BOSS_NEEDLE_SPEED * -1
    jr .endVariantDirection
.downRightDirection:
    cp a, NEEDLE_DOWN_MOVE_RIGHT_VARIANT
    jr nz, .endVariantDirection
    ld b, BOSS_NEEDLE_SPEED
    ld c, b
.endVariantDirection:
    ; Check vertical movement
    ldh a, [hEnemyParam1]
    cp a, BOSS_NEEDLE_VERTICAL_MOVEMENT_TIME
    jr c, .strayingVerticalMovement
.noMoreVerticalMovement:
    ld b, 0
    jr .updateMove
.strayingVerticalMovement:
    inc a
    ldh [hEnemyParam1], a
    ; Update move
.updateMove:
    ldh a, [hEnemyY]
    add a, b
    ldh [hEnemyY], a
    ld [hli], a
    ldh a, [hEnemyX]
    add a, c
    ldh [hEnemyX], a
    ld [hl], a
.endMove:

    ;
    ; Check collision
    ;
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	BOSS_NEEDLE_COLLISION_TIME
    jr nz, .endCollision
    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .endCollision
    ; Check hit player balloon
    SETUP_ENEMY_COLLIDER BOSS_NEEDLE_COLLISION_Y, BOSS_NEEDLE_COLLISION_HEIGHT, BOSS_NEEDLE_COLLISION_X, BOSS_NEEDLE_COLLISION_WIDTH
    call CollisionCheckPlayerBalloon
    jr z, .checkHitCactus
    call CollisionWithPlayer
    jr .deathOfBossNeedle
    ; Check hit player cactus
.checkHitCactus:
    ; SETUP_ENEMY_COLLIDER BOSS_NEEDLE_COLLISION_Y, BOSS_NEEDLE_COLLISION_HEIGHT, BOSS_NEEDLE_COLLISION_X, BOSS_NEEDLE_COLLISION_WIDTH
    call CollisionCheckPlayerCactus
    jr z, .endCollision
    call StunPlayer
    ; jr .deathOfBossNeedle
.deathOfBossNeedle:
    ld bc, BOSS_NEEDLE_OAM_BYTES
    call ClearEnemy
    jp SetEnemyStruct
.endCollision:

    ;
    ; Check offscreen
    ;
    ld bc, BOSS_NEEDLE_OAM_BYTES
    call HandleEnemyOffscreenHorizontal
    ; Enemy may be cleared, must do setStruct next

    ;
    ; Set struct
    ;
    jp SetEnemyStruct