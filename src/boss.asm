INCLUDE "hardware.inc"
INCLUDE "balloonConstants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

PORCUPINE_OAM_SPRITES EQU 10
PORCUPINE_OAM_BYTES EQU PORCUPINE_OAM_SPRITES * 4
PORCUPINE_MOVE_TIME EQU %00000011
PORCUPINE_COLLISION_TIME EQU %00001000

PORCUPINE_HP EQU 2

PORCUPINE_TILE_1 EQU $42
PORCUPINE_TILE_2 EQU $44
PORCUPINE_TILE_3 EQU $46
PORCUPINE_TILE_4 EQU $48
PORCUPINE_TILE_5 EQU $4A
PORCUPINE_TILE_6 EQU $4C
PORCUPINE_TILE_7 EQU $4E

PORCUPINE_BALL_TILE_1 EQU $50
PORCUPINE_BALL_TILE_2 EQU $52
PORCUPINE_BALL_TILE_3 EQU $54
PORCUPINE_BALL_TILE_4 EQU $56

PORCUPINE_POINTS EQU 1

SECTION "boss", ROMX

SetStruct:
    ; Argument hl = start of free enemy struct
    ld a, [wEnemyActive]
    ld [hli], a
    ld a, [wEnemyNumber]
    ld [hli], a
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld a, [wEnemyOAM]
    ld [hli], a
    ld a, [wEnemyAlive]
    ld [hli], a
    ld a, [wEnemyRightside]
    ld [hl], a
    ret

UpdateBossPosition:
.balloonLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    sub 15
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], $22
    inc l
    ld [hl], OAMF_PAL0
    inc l
.balloonRight:
    ld a, [wEnemyY]
    sub 15
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], $22
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    inc l
.checkFacing:
    ld a, [wEnemyRightside]
    cp a, 0
    jp nz, .facingLeft
.facingRight:
.facingRightTopLeft:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], PORCUPINE_TILE_1
    inc l
    ld [hl], OAMF_PAL0
.facingRightTopMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], PORCUPINE_TILE_3
    inc l
    ld [hl], OAMF_PAL0
.facingRightTopMiddle2:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], PORCUPINE_TILE_5
    inc l
    ld [hl], OAMF_PAL0
.facingRightTopRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], PORCUPINE_TILE_7
    inc l
    ld [hl], OAMF_PAL0
.facingRightBottomLeft:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], PORCUPINE_TILE_2
    inc l
    ld [hl], OAMF_PAL0
.facingRightBottomMiddle:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], PORCUPINE_TILE_4
    inc l
    ld [hl], OAMF_PAL0
.facingRightBottomMiddle2:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], PORCUPINE_TILE_6
    inc l
    ld [hl], OAMF_PAL0
.facingRightBottomRight:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], EMPTY_TILE
    inc l
    ld [hl], OAMF_PAL0
    ret
.facingLeft:
.facingLeftTopLeft:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], PORCUPINE_TILE_7
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.facingLeftTopMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], PORCUPINE_TILE_5
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.facingLeftTopMiddle2:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], PORCUPINE_TILE_3
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.facingLeftTopRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], PORCUPINE_TILE_1
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.facingLeftBottomLeft:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], EMPTY_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.facingLeftBottomMiddle:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], PORCUPINE_TILE_6
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.facingLeftBottomMiddle2:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], PORCUPINE_TILE_4
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.facingLeftBottomRight:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], PORCUPINE_TILE_2
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    ret

UpdateBossBallPosition:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
.topLeft:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], PORCUPINE_BALL_TILE_1
    inc l
    ld [hl], OAMF_PAL0
.topMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], PORCUPINE_BALL_TILE_2
    inc l
    ld [hl], OAMF_PAL0
.topMiddle2:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], PORCUPINE_BALL_TILE_3
    inc l
    ld [hl], OAMF_PAL0
.topRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], PORCUPINE_BALL_TILE_4
    inc l
    ld [hl], OAMF_PAL0
.bottomLeft:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], PORCUPINE_BALL_TILE_1
    inc l
    ld [hl], OAMF_PAL0 | OAMF_YFLIP
.bottomMiddle:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], PORCUPINE_BALL_TILE_2
    inc l
    ld [hl], OAMF_PAL0 | OAMF_YFLIP
.bottomMiddle2:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], PORCUPINE_BALL_TILE_2
    inc l
    ld [hl], OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
.bottomRight:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], PORCUPINE_BALL_TILE_1
    inc l
    ld [hl], OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
.empty:
    inc l
    RESET_AT_HL 8
    ret

SpawnBoss::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    cp a, 0
    jp z, .end
.availableSpace:
    ld b, PORCUPINE_OAM_SPRITES
	call RequestOAMSpace ; b now contains OAM address
    cp a, 0
    jp z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ld [wEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ld [wEnemyActive], a
    ld a, PORCUPINE_HP
    ld [wEnemyAlive], a
    ld a, BOSS
    ld [wEnemyNumber], a
    call UpdateBossPosition
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
    ld a, [wEnemyY]
    cp a, b
    jr nc, .moveDown
.moveUp:
    inc a
    ld [wEnemyY], a
    jr .moveHorizontal
.moveDown:
    dec a
    ld [wEnemyY], a
.moveHorizontal:
    ld a, [wPlayerX]
    ld b, a
    ld a, [wEnemyX]
    cp a, b
    jr c, .moveRight
.moveLeft:
    dec a
    ld [wEnemyX], a
    ld a, 1
    ld [wEnemyRightside], a
    jr .updatePosition
.moveRight:
    inc a
    ld [wEnemyX], a
    xor a ; ld a, 0
    ld [wEnemyRightside], a
.updatePosition:
    ; call UpdateBossPosition
    call UpdateBossBallPosition
    ret

    ; he'll roll towards you
    ; pop the balloon and he'll fall right away or blink
    ; falls near the bottom of the screen then goes ball mode
    ; avoid until done with the pattern;
    ; repeat until donzo
    ; any other moves?

MoveBall:

    ret

Clear:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    RESET_AT_HL PORCUPINE_OAM_BYTES
    call InitializeEnemyStructVars
    ret

BossUpdate::
    ; Get rest of struct
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, [hli]
    ld [wEnemyOAM], a
    ld a, [hli]
    ld [wEnemyAlive], a
    ld a, [hl]
    ld [wEnemyRightside], a

.checkAlive:
    ld a, [wEnemyAlive]
    cp a, 0
    jr z, .isDead
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_MOVE_TIME
    jr nz, .endMove
.canMove:
    call Move
    ; call MoveBall
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_COLLISION_TIME
    jr nz, .endCollision
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld d, 16
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet
    ld a, [wEnemyAlive]
    dec a
    ld [wEnemyAlive], a
.endCollision:

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