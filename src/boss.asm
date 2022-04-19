INCLUDE "hardware.inc"
INCLUDE "balloonConstants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

PORCUPINE_OAM_SPRITES EQU 14
PORCUPINE_OAM_BYTES EQU PORCUPINE_OAM_SPRITES * 4
PORCUPINE_MOVE_TIME EQU %00000011
PORCUPINE_ATTACK_TIME EQU %01111111
PORCUPINE_COLLISION_TIME EQU %00001000

PORCUPINE_HP EQU 2

PORCUPINE_BALLOON_TILE_1 EQU $40
PORCUPINE_BALLOON_TILE_2 EQU $42
PORCUPINE_BALLOON_TILE_3 EQU $48
PORCUPINE_BALLOON_TILE_4 EQU $4A

PORCUPINE_TILE_1 EQU $44
PORCUPINE_TILE_2 EQU $46
PORCUPINE_TILE_3 EQU $4C
PORCUPINE_TILE_4 EQU $4E
PORCUPINE_TILE_5 EQU $50

PORCUPINE_LAUGH_TILE_1 EQU $6C
PORCUPINE_LAUGH_TILE_2 EQU $6E

PORCUPINE_POINTS EQU 1

SECTION "boss", ROMX

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
    ldh a, [hEnemyDirectionLeft]
    ld [hli], a
    ldh a, [hEnemyY2]
    ld [hli], a
    ldh a, [hEnemyX2]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Enemy Invincibility Timer
    ld [hli], a
    ldh a, [hEnemyDifficulty]
    ld [hl], a
    ret

SpawnBoss::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jp z, .end
.availableSpace:
    ld b, PORCUPINE_OAM_SPRITES
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
    ld a, PORCUPINE_HP
    ldh [hEnemyAlive], a
    ldh a, [hEnemyY]
    add 32
    ldh [hEnemyY2], a
    ldh a, [hEnemyX]
    sub 4
    ldh [hEnemyX2], a
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    UPDATE_OAM_POSITION_ENEMY 3, 2
    UPDATE_OAM_POSITION_ENEMY2 4, 2
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
.balloonTopLeftOAM:
    inc l
    inc l
    ld a, PORCUPINE_BALLOON_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.balloonTopMiddleOAM:
    inc l
    inc l
    ld a, PORCUPINE_BALLOON_TILE_3
    ld [hli], a
    ld a, OAMF_PAL1
    ld [hli], a
.balloonTopRightOAM:
    inc l
    inc l
    ld a, PORCUPINE_BALLOON_TILE_1
    ld [hli], a
    ld a, OAMF_PAL1 | OAMF_XFLIP
    ld [hli], a
.balloonBottomLeftOAM:
    inc l
    inc l
    ld a, PORCUPINE_BALLOON_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.balloonBottomMiddleOAM:
    inc l
    inc l
    ld a, PORCUPINE_BALLOON_TILE_4
    ld [hli], a
    ld a, OAMF_PAL1
    ld [hli], a
.balloonBottomRightOAM:
    inc l
    inc l
    ld a, PORCUPINE_BALLOON_TILE_2
    ld [hli], a
    ld a, OAMF_PAL1 | OAMF_XFLIP
    ld [hli], a
.bossTopLeftOAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.bossTopMiddleOAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_3
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.bossTopMiddle2OAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_5
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.bossTopRightOAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.bossBottomLeftOAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.bossBottomMiddleOAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_4
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.bossBottomMiddle2OAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_4
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.bossBottomRightOAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

Move:
    ; Follow player
.moveVertical:
    ld a, [wPlayerY]
    ld b, a
    ldh a, [hEnemyY]
    cp a, b
    jr z, .moveHorizontal
    jr nc, .moveDown
.moveUp:
    inc a
    ldh [hEnemyY], a
    jr .moveHorizontal
.moveDown:
    dec a
    ldh [hEnemyY], a
.moveHorizontal:
    ld a, [wPlayerX]
    ld b, a
    ldh a, [hEnemyX]
    cp a, b
    jr z, .updatePosition
    jr c, .moveRight
.moveLeft:
    dec a
    ldh [hEnemyX], a
    ld a, 1
    ldh [hEnemyDirectionLeft], a
    jr .updatePosition
.moveRight:
    inc a
    ldh [hEnemyX], a
    xor a ; ld a, 0
    ldh [hEnemyDirectionLeft], a
.updatePosition:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    UPDATE_OAM_POSITION_ENEMY 3, 2
    UPDATE_OAM_POSITION_ENEMY2 4, 2
    ret

BossLaugh:
    SET_HL_TO_ADDRESS wOAM+28, hEnemyOAM
.bossTopMiddleOAM:
    inc l
    inc l
    ld a, PORCUPINE_LAUGH_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.bossTopMiddle2OAM:
    inc l
    inc l
    ld a, PORCUPINE_LAUGH_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ret

Clear:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    RESET_AT_HL PORCUPINE_OAM_BYTES
    call InitializeEnemyStructVars
    ret

BossUpdate::
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
    ldh [hEnemyDirectionLeft], a
    ld a, [hli]
    ldh [hEnemyY2], a
    ld a, [hli]
    ldh [hEnemyX2], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hl]
    ldh [hEnemyDifficulty], a

.checkAlive:
    ldh a, [hEnemyAlive]
    cp a, 0
    jr z, .isDead
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_MOVE_TIME
    jr nz, .endMove
.canMove:
.endMove:

.checkAttack:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_ATTACK_TIME
    jr nz, .endAttack

.canAttack:
    call BossLaugh
.endAttack:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_COLLISION_TIME
    jr nz, .endCollision
    ldh a, [hEnemyDying]
    cp a, 0
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .checkHitByBullet
    jr .bossDamaged
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
.bossDamaged:
    ; ldh a, [hEnemyAlive]
    ; dec a
    ; ldh [hEnemyAlive], a
    ld a, 1
    ldh [hEnemyDying], a
.endCollision:

; .popped:
;     ldh a, [hEnemyDying]
;     cp a, 0
;     call nz, PopBalloonAnimation
;     ldh a, [hEnemyDying]
;     cp a, 0
;     jr nz, .endPopped
; .poppingAnimationDone:
;     xor a ; ld a, 0
;     ldh [hEnemyAnimationFrame], a
;     ldh [hEnemyAnimationTimer], a


;     ; ld a, 150
;     ; ldh [hEnemyParam1], a
; .endPopped:

; .checkInvincible:
;     ldh a, [hEnemyParam1]
;     cp a, 0
;     jr z, .endInvincible
;     dec a
;     ldh [hEnemyParam1], a
; .blinkBoss:
; .endInvincible:

.checkOffscreen:
.offscreen:
.endOffscreen:

    jr .setStruct
.isDead:
    ; Points
    ld d, PORCUPINE_POINTS
    call AddPoints
    ; Animation trigger
    ; None
    ; Sound
    call PopSound
    call Clear
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret