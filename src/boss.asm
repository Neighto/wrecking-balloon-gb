INCLUDE "hardware.inc"
INCLUDE "balloonConstants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

PORCUPINE_OAM_SPRITES EQU 9
PORCUPINE_OAM_BYTES EQU PORCUPINE_OAM_SPRITES * 4
PORCUPINE_MOVE_TIME EQU %00000001
PORCUPINE_ATTACK_TIME EQU %01111111
PORCUPINE_COLLISION_TIME EQU %00001000

PORCUPINE_HP EQU 1

PORCUPINE_BALLOON_TILE_1 EQU $56
PORCUPINE_BALLOON_TILE_2 EQU $42
PORCUPINE_BALLOON_TILE_3 EQU $48
PORCUPINE_BALLOON_TILE_4 EQU $4A

PORCUPINE_TILE_1 EQU $52
PORCUPINE_TILE_2 EQU $54
PORCUPINE_TILE_3 EQU $56
PORCUPINE_TILE_4 EQU $58
PORCUPINE_TILE_5 EQU $5A

PORCUPINE_CONFIDENT_TILE_1 EQU $5C
PORCUPINE_CONFIDENT_TILE_2 EQU $5E

PORCUPINE_SCARED_TILE_1 EQU $60
PORCUPINE_SCARED_TILE_2 EQU $62

PORCUPINE_STRING_Y_OFFSET EQU 31
PORCUPINE_STRING_X_OFFSET EQU 12

PORCUPINE_START_SPEED EQU 1
PORCUPINE_INCREASE_SPEED EQU 2
PORCUPINE_MAX_SPEED EQU 4

PORCUPINE_LEFTSIDE_POSITION_X EQU 10
PORCUPINE_RIGHTSIDE_POSITION_X EQU 132
PORCUPINE_TOPSIDE_POSITION_Y EQU 25
PORCUPINE_DOWNSIDE_POSITION_Y EQU 100

PORCUPINE_EXPRESSION_LEFT EQU 0
PORCUPINE_EXPRESSION_RIGHT EQU 1
PORCUPINE_EXPRESSION_CONFIDENT EQU 2
PORCUPINE_EXPRESSION_SCARED EQU 3

PORCUPINE_POINTS EQU 50

SECTION "boss temp vars", WRAM0
    wEnemyMoveTimer:: DB
    wEnemyDirectionUp:: DB
    wEnemyExpression:: DB
    wEnemyExpressionTimer:: DB

SECTION "boss", ROMX

ClearTempVars:
    xor a ; ld a, 0
    ld [wEnemyMoveTimer], a
    ld [wEnemyDirectionUp], a
    ld [wEnemyExpression], a
    ld [wEnemyExpressionTimer], a
    ret

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
    ldh a, [hEnemySpeed]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Enemy Invincibility Timer
    ld [hli], a
    ldh a, [hEnemyParam2] ; Enemy Projectile Timer
    ld [hli], a
    ldh a, [hEnemyDifficulty]
    ld [hl], a
    ret

UpdateBossPosition:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    UPDATE_OAM_POSITION_ENEMY 4, 2
    ldh a, [hEnemyY]
    add PORCUPINE_STRING_Y_OFFSET
    ld [hli], a
    ldh a, [hEnemyX]
    add PORCUPINE_STRING_X_OFFSET
    ld [hli], a
    ret

MakeBossConfident:
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld a, PORCUPINE_CONFIDENT_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_CONFIDENT_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ret

MakeBossScared:
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld a, PORCUPINE_SCARED_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_SCARED_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ret

MakeBossFaceRight:
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld a, PORCUPINE_TILE_5
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_TILE_3
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
    ret

MakeBossFaceLeft:
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld a, PORCUPINE_TILE_3
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_TILE_5
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
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
    call ClearTempVars ; TEMP
    call UpdateBossPosition
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
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
    ld [hli], a
.stringOAM:
    inc l
    inc l
    ld a, STRING_TILE
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

Clear:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    RESET_AT_HL PORCUPINE_OAM_BYTES
    call InitializeEnemyStructVars
    ret

HelperMoveY:
    ld b, 1 ; speed
    IF_WRAM_Z wEnemyDirectionUp, 0, .moveDown
.moveUp:
    ldh a, [hEnemyY]
    cp a, PORCUPINE_TOPSIDE_POSITION_Y
    jr nc, .moveUpStopSkip
.moveUpStop:
    ld b, 0
.moveUpStopSkip:
    sub a, b
    ldh [hEnemyY], a
    ret
.moveDown:
    ldh a, [hEnemyY]
    cp a, PORCUPINE_DOWNSIDE_POSITION_Y
    jr c, .moveDownStopSkip
.moveDownStop:
    ld b, 0
.moveDownStopSkip:
    add a, b
    ldh [hEnemyY], a
    ret

HelperMoveX:
    ld hl, hEnemySpeed
    IF_HRAM_Z hEnemyDirectionLeft, 0, .handleMovingRight
.handleMovingLeft:
    ldh a, [hEnemyX]
    cp a, PORCUPINE_LEFTSIDE_POSITION_X
    jr c, .stopSpeed
    cp a, PORCUPINE_LEFTSIDE_POSITION_X + PORCUPINE_MAX_SPEED * 2
    jr c, .slowDown
    jr .speedUp
.handleMovingRight:
    ldh a, [hEnemyX]
    cp a, PORCUPINE_RIGHTSIDE_POSITION_X
    jr nc, .stopSpeed
    cp a, PORCUPINE_RIGHTSIDE_POSITION_X - PORCUPINE_MAX_SPEED * 2
    jr nc, .slowDown
.speedUp:
    ld a, [hl]
    add a, PORCUPINE_INCREASE_SPEED
    ld b, PORCUPINE_MAX_SPEED
    cp a, b
    jr c, .updateSpeed
    ld a, b
    jr .updateSpeed
.slowDown:
    ld a, [hl]
    sub a, PORCUPINE_INCREASE_SPEED
    ld b, PORCUPINE_START_SPEED
    cp a, b
    jr c, .updateSpeed
    ld a, b
    jr .updateSpeed
.stopSpeed:
    xor a ; ld a, 0
.updateSpeed:
    ld [hl], a
.move:
    IF_HRAM_Z hEnemyDirectionLeft, 0, .moveRight
.moveLeft:
    ldh a, [hEnemyX]
    sub a, [hl]
    ldh [hEnemyX], a
    ret
.moveRight:
    ldh a, [hEnemyX]
    add a, [hl]
    ldh [hEnemyX], a
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
    ldh [hEnemySpeed], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hli]
    ldh [hEnemyParam2], a
    ld a, [hl]
    ldh [hEnemyDifficulty], a

.faceExpression:
    ld a, [wEnemyExpressionTimer]
    cp a, 0
    jr z, .canUpdateFaceExpression
    dec a
    ld [wEnemyExpressionTimer], a
    jr .endFaceExpression
.canUpdateFaceExpression:
    ld a, [wEnemyExpression]
.faceExpressionLeft:
    cp a, PORCUPINE_EXPRESSION_LEFT
    jr nz, .faceExpressionRight
    call MakeBossFaceLeft
    jr .setExpressionTimer
.faceExpressionRight:
    cp a, PORCUPINE_EXPRESSION_RIGHT
    jr nz, .faceExpressionConfident
    call MakeBossFaceRight
    jr .setExpressionTimer
.faceExpressionConfident:
    cp a, PORCUPINE_EXPRESSION_CONFIDENT
    jr nz, .faceExpressionScared
    call MakeBossConfident
    jr .setExpressionTimer
.faceExpressionScared:
    call MakeBossScared
.setExpressionTimer:
    ld a, 30
    ld [wEnemyExpressionTimer], a
    ld a, [hEnemyX]
    cp a, SCRN_X / 2
    jr c, .lookRight
.lookLeft:
    ld a, PORCUPINE_EXPRESSION_LEFT
    ld [wEnemyExpression], a
    jr .endFaceExpression
.lookRight:
    ld a, PORCUPINE_EXPRESSION_RIGHT
    ld [wEnemyExpression], a
.endFaceExpression:

.checkAlive:
    ldh a, [hEnemyAlive]
    cp a, 0
    jp z, .isDead
.isAlive:

    ; Boss may have 2 phases,
    ; 1 - floats around and shoots needles
    ; AND oscillates up and down, and every so often hops from right side of screen to left 
    ; 2 - navigates the bottom of the screen and jumps up to try to hit the player
    ; Could also just fly fast off screen left + shoot with needles (maybe another boss)
    ; TODO what if cactus gets hit by something, he goes cross-eyed, blinks, and can't move for like 1 second?

.pointPicker:
    ld hl, wEnemyMoveTimer
.checkPointPickerX:
    ld a, [hl]
    cp a, 50 ; MAKE RANDOM
    jr nz, .endPointPickerX
    ldh a, [hEnemyX]
    cp a, SCRN_X / 2
    jr c, .moveToRight
.moveToLeft:
    ld a, 1
    ldh [hEnemyDirectionLeft], a
    jr .endPointPickerX
.moveToRight:
    xor a ; ld a, 0 
    ldh [hEnemyDirectionLeft], a
.endPointPickerX:
.checkPointPickerY:
    ld a, [hl]
    and %00111111
    jr nz, .endPointPickerY
    ldh a, [hEnemyY]
    cp a, SCRN_Y / 2
    jr c, .moveToDown
.moveToUp:
    ld a, 1
    ld [wEnemyDirectionUp], a
    jr .endPointPickerY
.moveToDown:
    xor a ; ld a, 0
    ld [wEnemyDirectionUp], a
.endPointPickerY:
    inc [hl]
.endPointPicker:

.checkMove:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_MOVE_TIME
    jr nz, .endMove
.canMove: 
    call HelperMoveX
    call HelperMoveY
    call UpdateBossPosition
.endMove:

.checkAttack:
    ; ldh a, [hGlobalTimer]
    ; and	PORCUPINE_ATTACK_TIME
    ; jr nz, .endAttack
.canAttack:
    ldh a, [hEnemyParam2]
    inc a
    ldh [hEnemyParam2], a
    cp a, %01111111 + 1
    jr c, .endAttack
    xor a ; ld a, 0
    ldh [hEnemyParam2], a
.endAttack:

.checkString:
    ldh a, [hGlobalTimer]
    and STRING_MOVE_TIME
    jr nz, .endString
    SET_HL_TO_ADDRESS wOAM+35, hEnemyOAM
    ld a, [hl]
    cp a, OAMF_PAL0
    jr z, .flipX
    ld a, OAMF_PAL0
    ld [hl], a
    jr .endString
.flipX:
    ld a, OAMF_XFLIP | OAMF_PAL0
    ld [hl], a
.endString:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_COLLISION_TIME
    jr nz, .endCollision
    ; ldh a, [hEnemyDying]
    ; cp a, 0
    ; jr nz, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 32
    ld e, 32
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
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
    ; Points
    ld d, PORCUPINE_POINTS
    call AddPoints
    ; Sound
    call PopSound
    ldh a, [hEnemyAlive]
    dec a
    ldh [hEnemyAlive], a
    ; ld a, 1
    ; ldh [hEnemyDying], a
    ld a, PORCUPINE_EXPRESSION_SCARED
    ld [wEnemyExpression], a
.endCollision:

.checkOffscreen:
.offscreen:
.endOffscreen:

    jr .setStruct
.isDead:
    ; call Clear
    ld a, 1 
    ld [wLevelWaitBoss], a
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct

.checkSpawnBossNeedle:
    ldh a, [hEnemyParam2]
    cp a, %01111111
    ret nz
.spawnBossNeedle:
    ld a, PORCUPINE_EXPRESSION_CONFIDENT
    ld [wEnemyExpression], a
    xor a ; ld a, 0
    ld [wEnemyExpressionTimer], a
    ld a, BOSS_NEEDLE
    ldh [hEnemyNumber], a
.topLeftNeedle:
    ld a, NONE ; Alias for aim top-left
    ldh [hEnemyDifficulty], a
    ldh a, [hEnemyY]
    add a, 8
    ldh [hEnemyY], a
    ldh a, [hEnemyX]
    add a, 8
    ldh [hEnemyX], a
    call SpawnBossNeedle
.topRightNeedle:
    ld a, EASY ; Alias for aim top-right
    ldh [hEnemyDifficulty], a
    ldh a, [hEnemyX]
    add a, 8
    ldh [hEnemyX], a
    call SpawnBossNeedle
.bottomRightNeedle:
    ld a, HARD ; Alias for aim bottom-right
    ldh [hEnemyDifficulty], a
    ldh a, [hEnemyY]
    add a, 16
    ldh [hEnemyY], a
    call SpawnBossNeedle
.bottomLeftNeedle:
    ld a, MEDIUM ; Alias for aim bottom-left
    ldh [hEnemyDifficulty], a
    ldh a, [hEnemyX]
    sub a, 8
    ldh [hEnemyX], a
    call SpawnBossNeedle
.endSpawnBossNeedle:
    ret