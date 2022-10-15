INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BOSS_NEEDLE_OAM_SPRITES EQU 1
BOSS_NEEDLE_OAM_BYTES EQU BOSS_NEEDLE_OAM_SPRITES * 4
BOSS_NEEDLE_COLLISION_TIME EQU %00000011
BOSS_NEEDLE_VERTICAL_MOVEMENT_TIME EQU 6

BOSS_NEEDLE_WIDTH EQU 8
BOSS_NEEDLE_HEIGHT EQU 16

BOSS_NEEDLE_TILE EQU $72

BOSS_NEEDLE_SPEED EQU 4

; hEnemyParam1 = Vertical Movement Counter

SECTION "boss needle", ROM0

; SPAWN
SpawnBossNeedle::
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
.availableSpace:
    ld b, BOSS_NEEDLE_OAM_SPRITES
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
    ldh [hEnemyFlags], a
    ; Get hl pointing to OAM address
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

.bossNeedleOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, BOSS_NEEDLE_TILE
    ld [hli], a
    ld [hl], e
.setStruct:
    LD_HL_BC
    jp SetEnemyStruct

; UPDATE
BossNeedleUpdate::

.checkMove:
.bossNeedleOAM:
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
.variantDirection:
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
    ld c, BOSS_NEEDLE_SPEED
.endVariantDirection:

.checkVerticalMovement:
    ldh a, [hEnemyParam1]
    cp a, BOSS_NEEDLE_VERTICAL_MOVEMENT_TIME
    jr c, .strayingVerticalMovement
.noMoreVerticalMovement:
    ld b, 0
    jr .endCheckVerticalMovement
.strayingVerticalMovement:
    inc a
    ldh [hEnemyParam1], a
.endCheckVerticalMovement:

    ldh a, [hEnemyY]
    add a, b
    ldh [hEnemyY], a
    ld [hli], a
    ldh a, [hEnemyX]
    add a, c
    ldh [hEnemyX], a
    ld [hl], a
.endMove:

.checkCollision:
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	BOSS_NEEDLE_COLLISION_TIME
    jr nz, .endCollision
    ; Is player alive
    ldh a, [hPlayerAlive]
    cp a, 0
    jr z, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld d, BOSS_NEEDLE_WIDTH
    ld e, BOSS_NEEDLE_HEIGHT
    call CollisionCheck
    jr z, .checkHitCactus
    call CollisionWithPlayer
    jr .deathOfBossNeedle
.checkHitCactus:
    ld bc, wPlayerCactusOAM
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld d, BOSS_NEEDLE_WIDTH
    ld e, BOSS_NEEDLE_HEIGHT
    call CollisionCheck
    jr z, .endCollision
    call CollisionWithPlayerCactus
    ; jr .deathOfBossNeedle
.deathOfBossNeedle:
    ld bc, BOSS_NEEDLE_OAM_BYTES
    call ClearEnemy
    jr .setStruct
.endCollision:

.checkOffscreenX:
    ld bc, BOSS_NEEDLE_OAM_BYTES
    call HandleEnemyOffscreenHorizontal
    ; Enemy may be cleared, must do setStruct next
.endOffscreenX:

.setStruct:
    ld hl, wEnemies
    ADD_TO_HL [wEnemyOffset]
    jp SetEnemyStruct