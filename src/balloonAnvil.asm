INCLUDE "balloonConstants.inc"
INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BALLOON_CACTUS_OAM_SPRITES EQU 4
BALLOON_CACTUS_MOVE_TIME EQU %00000011
BALLOON_CACTUS_COLLISION_TIME EQU %00001000
BALLOON_CACTUS_SCREAMING_TILE EQU $16
BALLOON_CACTUS_TILE EQU $14

PROJECTILE_RESPAWN_TIME EQU %01111111

BALLOON_CACTUS_EASY_TILE EQU $44
BALLOON_CACTUS_EASY_POINTS EQU 15

BALLOON_CACTUS_MEDIUM_TILE EQU ENEMY_BALLOON_TILE
BALLOON_CACTUS_MEDIUM_POINTS EQU 30

BALLOON_CACTUS_HARD_TILE EQU $22
BALLOON_CACTUS_HARD_POINTS EQU 50

SECTION "balloon anvil", ROM0 ; make ROMX

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
    ldh a, [hEnemyAnimationFrame]
    ld [hli], a
    ldh a, [hEnemyAnimationTimer]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Trigger Carry
    ld [hli], a
    ldh a, [hEnemyDifficulty]
    ld [hl], a
    ret

SpawnBalloonAnvil::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jp z, .end
.availableSpace:
    ld b, BALLOON_CACTUS_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    jp z, .end
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
    ldh [hEnemySpeed], a
    ldh a, [hEnemyY]
    add 16
    ldh [hEnemyY2], a
    ldh a, [hEnemyX]
    ldh [hEnemyX2], a

    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, $3A
    ld e, OAMF_PAL0
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
    ld [hli], a

    ld d, $48
    ld e, OAMF_PAL0
.cactusLeftOAM:
    ldh a, [hEnemyY2]
    ld [hli], a
    ldh a, [hEnemyX2]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a

    ld d, $4A
    ld e, OAMF_PAL0
.cactusRightOAM:
    ldh a, [hEnemyY2]
    ld [hli], a
    ldh a, [hEnemyX2]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

ClearBalloonAnvil:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    call InitializeEnemyStructVars
    ret

BalloonAnvilUpdate::
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
    ldh [hEnemyAnimationFrame], a
    ld a, [hli]
    ldh [hEnemyAnimationTimer], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hl]
    ldh [hEnemyDifficulty], a

.checkAlive:
    ldh a, [hEnemyAlive]
    cp a, 0
    jr nz, .isAlive
.isPopping:
    xor a ; ld a, 0
    ldh [hEnemyParam1], a
    ldh a, [hEnemyDying]
    cp a, 0
    jr z, .clearPopping
.animatePopping:
    call PopBalloonAnimation
    jp .setStruct
.clearPopping:
    call ClearBalloonAnvil
    jp .setStruct
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	BALLOON_CACTUS_MOVE_TIME
    jr nz, .endMove
.canMove:
.moveHorizontal:
    INCREMENT_POS hEnemyX, 1
.endMoveHorizontal:
.updatePosition:
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
    ld [hli], a
    inc l
    inc l
.carryLeftOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    inc l
    inc l
.carryRightOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BALLOON_CACTUS_COLLISION_TIME
    jp nz, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+12, hEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 16
    ld e, 12
    call CollisionCheck
    cp a, 0
    jr nz, .deathOfBalloonCarry
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld d, 16
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet
.deathOfBalloonCarry:
    xor a ; ld a, 0
    ld [hEnemyAlive], a
    ; Hide carry visual
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    ld a, EMPTY_TILE
    ld [hli], a
    inc hl
    inc hl
    inc hl
    ld [hl], a
    ; Animation trigger
    ld a, 1
    ldh [hEnemyDying], a
    ldh [hEnemyParam1], a
    ; Sound
    call PopSound
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
    call ClearBalloonAnvil
.endOffscreen:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct

.checkSpawnCarry:
    ldh a, [hEnemyParam1]
    cp a, 0
    jr z, .endSpawnCarry
.spawnCarry:
    ld a, ANVIL
    ldh [hEnemyNumber], a
    ld a, NONE
    ldh [hEnemyDifficulty], a
    ldh a, [hEnemyY]
    add 16
    ldh [hEnemyY], a
    call SpawnAnvil
.endSpawnCarry:
    ret