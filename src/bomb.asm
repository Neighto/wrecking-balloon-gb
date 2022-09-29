INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BOMB_DEFAULT_SPEED EQU 2
BOMB_OAM_SPRITES EQU 2
BOMB_OAM_BYTES EQU BOMB_OAM_SPRITES * 4
BOMB_FOLLOW_TIME EQU %00000011
BOMB_COLLISION_TIME EQU %00000011

BOMB_DIRECT_TILE EQU $22
BOMB_DIRECT_POINTS EQU 10

BOMB_FOLLOW_TILE EQU $4C
BOMB_FOLLOW_POINTS EQU 20

SECTION "bomb", ROMX

SpawnBomb::
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
.availableSpace:
    ld b, BOMB_OAM_SPRITES
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

.balloonLeftOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
.balloonRightOAM:
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
.setStruct:
    LD_HL_BC
    jp SetEnemyStruct

BombUpdate::

.checkAlive:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jr nz, .isAlive
.isPopped:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DYING_MASK
    jr z, .clear
.triggerExplosion:
    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
.setStructSpawn:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetEnemyStruct
.spawnExplosion:
    ld a, EXPLOSION
    ldh [hEnemyNumber], a
    ld a, EXPLOSION_BOMB_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyX]
    sub 4
    ldh [hEnemyX], a
    call SpawnExplosion
    ret
.clear:
    ld bc, BOMB_OAM_BYTES
    call ClearEnemy
    jp .setStruct
.isAlive:

.checkMove:
    ldh a, [hEnemyY]
    sub a, BOMB_DEFAULT_SPEED
    ldh [hEnemyY], a    
.variantMove:
    ldh a, [hEnemyVariant]
    cp a, BOMB_FOLLOW_VARIANT
    jr nz, .endVariantMove
.horizontalFollow:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and BOMB_FOLLOW_TIME
    jr nz, .endVariantMove
    ldh a, [hEnemyX]
    ld hl, hPlayerX
    cp a, [hl]
    jr z, .endVariantMove
    ld hl, hEnemyX
    jr c, .moveRight
.moveLeft:
    dec [hl]
    jr .endVariantMove
.moveRight:
    inc [hl]
.endVariantMove:

.balloonLeftOAM:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    inc l
    inc l
.balloonRightOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hl], a
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	BOMB_COLLISION_TIME
    jr nz, .endCollision
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .deathOfBomb
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    jr z, .checkHitByBullet
    call CollisionWithPlayer
    jr .deathOfBomb
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld d, 8
    ld e, 4
    call CollisionCheck
    jr z, .endCollision
    call ClearBullet
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
    ld bc, BOMB_OAM_BYTES
    call ClearEnemy
.endOffscreen:
    
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    jp SetEnemyStruct