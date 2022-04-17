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

PORCUPINE_TILE_1 EQU $40
PORCUPINE_TILE_2 EQU $42
PORCUPINE_TILE_3 EQU $44
PORCUPINE_TILE_4 EQU $46
PORCUPINE_TILE_5 EQU $48
PORCUPINE_TILE_6 EQU $4A
PORCUPINE_TILE_7 EQU $4C

PORCUPINE_BALL_TILE_1 EQU $4E
PORCUPINE_BALL_TILE_2 EQU $50
PORCUPINE_BALL_TILE_3 EQU $52
PORCUPINE_BALL_TILE_4 EQU $54

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
    ldh a, [hEnemyAnimationFrame]
    ld [hli], a
    ldh a, [hEnemyDirectionLeft]
    ld [hli], a
    ldh a, [hEnemyDifficulty]
    ld [hl], a
    ret

UpdateBossPosition:
.balloonLeftOAM:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ldh a, [hEnemyY]
    sub 15
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, $22
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.balloonRightOAM:
    ldh a, [hEnemyY]
    sub 15
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, $22
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.checkFacing:
    ldh a, [hEnemyDirectionLeft]
    cp a, 0
    jp nz, .facingLeft
.facingRight:
.facingRightTopLeftOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, PORCUPINE_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.facingRightTopMiddleOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, PORCUPINE_TILE_3
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.facingRightTopMiddle2OAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, PORCUPINE_TILE_5
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.facingRightTopRightOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 24
    ld [hli], a
    ld a, PORCUPINE_TILE_7
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.facingRightBottomLeftOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, PORCUPINE_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.facingRightBottomMiddleOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, PORCUPINE_TILE_4
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.facingRightBottomMiddle2OAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, PORCUPINE_TILE_6
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.facingRightBottomRightOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 24
    ld [hli], a
    ld a, EMPTY_TILE
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hl], a
    ret
.facingLeft:
.facingLeftTopLeftOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, PORCUPINE_TILE_7
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.facingLeftTopMiddleOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, PORCUPINE_TILE_5
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.facingLeftTopMiddle2OAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, PORCUPINE_TILE_3
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.facingLeftTopRightOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 24
    ld [hli], a
    ld a, PORCUPINE_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.facingLeftBottomLeftOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, EMPTY_TILE
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.facingLeftBottomMiddleOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, PORCUPINE_TILE_6
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.facingLeftBottomMiddle2OAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, PORCUPINE_TILE_4
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
.facingLeftBottomRightOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 24
    ld [hli], a
    ld a, PORCUPINE_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hl], a
    ret

GetBallTileTopLeft:
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    ld a, PORCUPINE_BALL_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, PORCUPINE_BALL_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ret

GetBallTileTopRight:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, PORCUPINE_BALL_TILE_3
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 24
    ld [hli], a
    ld a, PORCUPINE_BALL_TILE_4
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ret

GetBallTileBottomLeft:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, PORCUPINE_BALL_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_YFLIP
    ld [hli], a
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, PORCUPINE_BALL_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_YFLIP
    ld [hli], a
    ret

GetBallTileBottomRight:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, PORCUPINE_BALL_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    ld [hli], a
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 24
    ld [hli], a
    ld a, PORCUPINE_BALL_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    ld [hli], a
    ret

UpdateBossBallPosition:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    UPDATE_POSITION 8
    call GetBallTileTopLeft
    call GetBallTileTopRight
    call GetBallTileBottomLeft
    call GetBallTileBottomRight
.empty:
    RESET_AT_HL 8

; .rotate:
;     ldh a, [hEnemyAnimationFrame]
;     inc a
;     cp a, 4
;     jr c, .skipReset
;     xor a ; ld a, 0
; .skipReset:
;     ldh [hEnemyAnimationFrame], a
; .endRotate:
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
    ld a, BOSS
    ldh [hEnemyNumber], a
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
    ldh a, [hEnemyY]
    cp a, b
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
    ldh [hEnemyAnimationFrame], a
    ld a, [hli]
    ldh [hEnemyDirectionLeft], a
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
    call Move
    call MoveBall
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_COLLISION_TIME
    jr nz, .endCollision
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
    ldh a, [hEnemyAlive]
    dec a
    ldh [hEnemyAlive], a
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