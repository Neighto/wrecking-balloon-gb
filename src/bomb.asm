INCLUDE "balloonConstants.inc"
INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BOMB_DEFAULT_SPEED EQU 2
BOMB_OAM_SPRITES EQU 2
BOMB_OAM_BYTES EQU BOMB_OAM_SPRITES * 4
BOMB_MOVE_TIME EQU %00000001
BOMB_FOLLOW_TIME EQU %00000111
BOMB_COLLISION_TIME EQU %00000111

BOMB_EASY_TILE EQU $22
BOMB_EASY_POINTS EQU 10

BOMB_MEDIUM_TILE EQU $4C
BOMB_MEDIUM_POINTS EQU 20

BOMB_HARD_TILE EQU $4C
BOMB_HARD_POINTS EQU 30

SECTION "bomb", ROMX

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
    ldh a, [hEnemyAlive]
    ld [hli], a
    ldh a, [hEnemyDying]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Enemy Trigger Explosion
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hl], a
    ret

SpawnBomb::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jr z, .end
.availableSpace:
    ld b, BOMB_OAM_SPRITES
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
    ldh [hEnemyAlive], a
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.variantVisual:
    ldh a, [hEnemyVariant]
.easyVisual:
    cp a, EASY
    jr nz, .mediumVisual
    ld d, BOMB_EASY_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisual
.mediumVisual:
    cp a, MEDIUM
    jr nz, .hardVisual
    ld d, BOMB_MEDIUM_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisual
.hardVisual:
    cp a, HARD
    jr nz, .endVariantVisual
    ld d, BOMB_HARD_TILE
    ld e, OAMF_PAL0
.endVariantVisual:

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
    call SetStruct
.end:
    pop hl
    ret

BombUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ldh [hEnemyOAM], a
    ld a, [hli]
    ldh [hEnemyAlive], a
    ld a, [hli]
    ldh [hEnemyDying], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hl]
    ldh [hEnemyVariant], a

.checkAlive:
    ldh a, [hEnemyAlive]
    cp a, 0
    jr nz, .isAlive
.isPopped:
    ldh a, [hEnemyDying]
    cp a, 0
    jr z, .clear
.triggerExplosion:
    xor a ; ld a, 0
    ldh [hEnemyDying], a
    ld a, 1
    ldh [hEnemyParam1], a
    jp .setStruct
.clear:
    ld bc, BOMB_OAM_BYTES
    call ClearEnemy
    jp .setStruct
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	BOMB_MOVE_TIME
    jr nz, .endMove
.canMove:
    DECREMENT_POS hEnemyY, BOMB_DEFAULT_SPEED
    
.variantMove:
    ldh a, [hEnemyVariant]
    cp a, MEDIUM
    jr nz, .endVariantMove
.horizontalMedium:
    ldh a, [hGlobalTimer]
    and BOMB_FOLLOW_TIME
    jr nz, .endVariantMove
    ldh a, [hEnemyX]
    ld hl, hPlayerX
    cp a, [hl]
    jr z, .endVariantMove
    jr c, .moveRight
.moveLeft:
    DECREMENT_POS hEnemyX, 1
    jr .endVariantMove
.moveRight:
    INCREMENT_POS hEnemyX, 1
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
    and	BOMB_COLLISION_TIME
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
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
    cp a, 0
    jr z, .endCollision
    call ClearBullet
.deathOfBomb:
    xor a ; ld a, 0
    ldh [hEnemyAlive], a
    ; Points
.variantPoints:
    ldh a, [hEnemyVariant]
.easyPoints:
    cp a, EASY
    jr nz, .mediumPoints
    ld d, BOMB_EASY_POINTS
    jr .endVariantPoints
.mediumPoints:
    cp a, MEDIUM
    jr nz, .hardPoints
    ld d, BOMB_MEDIUM_POINTS
    jr .endVariantPoints
.hardPoints:
    cp a, HARD
    jr nz, .endVariantPoints
    ld d, BOMB_HARD_POINTS
.endVariantPoints:
    call AddPoints
    ; Animation trigger
    ld a, 1
    ldh [hEnemyDying], a
    ; Sound
    call ExplosionSound ; conflicts with the pop sound
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
    call SetStruct


.checkSpawnExplosion:
    ldh a, [hEnemyParam1]
    cp a, 0
    jr z, .endCheckSpawnExplosion
.spawnExplosion:
    ld a, EXPLOSION
    ldh [hEnemyNumber], a
    ld a, NONE
    ldh [hEnemyVariant], a
    ldh a, [hEnemyX]
    sub 4
    ldh [hEnemyX], a
    call SpawnExplosion
.endCheckSpawnExplosion:
    ret