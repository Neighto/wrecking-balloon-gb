INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BOSS_NEEDLE_OAM_SPRITES EQU 1
BOSS_NEEDLE_OAM_BYTES EQU BOSS_NEEDLE_OAM_SPRITES * 4
BOSS_NEEDLE_MOVE_TIME EQU %00000001
BOSS_NEEDLE_COLLISION_TIME EQU %00000111
BOSS_NEEDLE_TILE EQU $62

BOSS_NEEDLE_SPEED EQU 3

BOSS_NEEDLE_VERTICAL_MOVEMENT_TIME EQU 10

SECTION "boss needle", ROM0

SetStruct:
    ; Argument hl = start of free enemy struct
    ldh a, [hEnemyActive]
    ld [hli], a
    ldh a, [hEnemyNumber]
    ld [hli], a
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ldh a, [hEnemyOAM]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Vertical Movement Counter
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hl], a
    ret

SpawnBossNeedle::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jr z, .end
.availableSpace:
    ld b, BOSS_NEEDLE_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    jr z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ldh [hEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ldh [hEnemyActive], a
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

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
    call SetStruct
.end:
    pop hl
    ret

BossNeedleUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ldh [hEnemyOAM], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hli]
    ldh [hEnemyVariant], a
    ld a, [hl]

.checkMove:
    ldh a, [hGlobalTimer]
    and	BOSS_NEEDLE_MOVE_TIME
    jr nz, .endMove
.canMove:
.bossNeedleOAM:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

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
    ldh a, [hGlobalTimer]
    and	BOSS_NEEDLE_COLLISION_TIME
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 8
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
.deathOfBossNeedle:
    ld bc, BOSS_NEEDLE_OAM_BYTES
    call ClearEnemy
    call CollisionWithPlayer
    jr .setStruct
.endCollision:

.checkOffscreenX:
    ldh a, [hEnemyX]
    ld b, a
    ld a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreenX
    ld a, SCRN_VX - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreenX
.offscreenX:
    ld bc, BOSS_NEEDLE_OAM_BYTES
    call ClearEnemy
.endOffscreenX:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret