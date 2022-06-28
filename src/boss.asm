INCLUDE "hardware.inc"
INCLUDE "balloonConstants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

PORCUPINE_OAM_SPRITES EQU 9
PORCUPINE_OAM_BYTES EQU PORCUPINE_OAM_SPRITES * 4
PORCUPINE_MOVE_TIME EQU %00000001
PORCUPINE_ATTACK_TIME EQU %00111111
PORCUPINE_COLLISION_TIME EQU %00000111

PORCUPINE_HP EQU 2

PORCUPINE_TILE_1 EQU $52
PORCUPINE_TILE_2 EQU $54
PORCUPINE_TILE_3 EQU $56
PORCUPINE_TILE_3_FEET_ALT EQU $60

PORCUPINE_FACE_LEFT_TILE_1 EQU $58
PORCUPINE_FACE_LEFT_TILE_2 EQU $5A

PORCUPINE_CONFIDENT_FACE_TILE EQU $5C
PORCUPINE_SCARED_FACE_TILE EQU $5E

PORCUPINE_STRING_Y_OFFSET EQU 31
PORCUPINE_STRING_X_OFFSET EQU 12

PORCUPINE_START_SPEED EQU 1
PORCUPINE_INCREASE_SPEED EQU 1
PORCUPINE_MAX_SPEED EQU 4

PORCUPINE_VERTICAL_SPEED EQU 2

PORCUPINE_MIN_POSITION_X EQU 10
PORCUPINE_MAX_POSITION_X EQU 132
PORCUPINE_MAX_POSITION_Y EQU 50
PORCUPINE_MIN_POSITION_Y EQU 90

PORCUPINE_EXPRESSION_LEFT EQU 0
PORCUPINE_EXPRESSION_RIGHT EQU 1
PORCUPINE_EXPRESSION_CONFIDENT EQU 2
PORCUPINE_EXPRESSION_SCARED EQU 3

PORCUPINE_KNOCKED_OUT_TIME EQU 40

PORCUPINE_POINTS EQU 50

PORCUPINE_POINT_Y1 EQU 40
PORCUPINE_POINT_Y2 EQU 66
PORCUPINE_POINT_Y3 EQU 90

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
    ldh a, [hEnemyHitEnemy]
    ld [hli], a
    ldh a, [hEnemyAnimationFrame]
    ld [hli], a
    ldh a, [hEnemyAnimationTimer]
    ld [hli], a
    ldh a, [hEnemyDirectionLeft] ; 0th Bit > Left / Right, 1st Bit > Up / Down
    ld [hli], a
    ldh a, [hEnemySpeed]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Enemy To Point Y
    ld [hli], a
    ldh a, [hEnemyParam2] ; Enemy Knocked Out Timer
    ld [hli], a
    ldh a, [hEnemyParam3] ; Enemy Trigger Projectile / Balloon
    ld [hli], a
    ldh a, [hEnemyParam4] ; Enemy Direction Change Timer
    ld [hli], a
    ldh a, [hEnemyVariant]
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
    ; really ugly test hack:
    ld a, b 
    add a, 28
    ld b, a
    ; ^^^^
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
    ld a, PORCUPINE_POINT_Y1
    ldh [hEnemyParam1], a
    ld a, PORCUPINE_HP
    ldh [hEnemyAlive], a
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
    ld a, PORCUPINE_FACE_LEFT_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.bossTopMiddle2OAM:
    inc l
    inc l
    ld a, PORCUPINE_FACE_LEFT_TILE_2
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
    ld a, PORCUPINE_TILE_3
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.bossBottomMiddle2OAM:
    inc l
    inc l
    ld a, PORCUPINE_TILE_3
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

SpawnBossNotInLevelData::
	ld a, BOSS
	ldh [hEnemyNumber], a
	ld a, 68
	ldh [hEnemyY], a 
	ld a, 112
	ldh [hEnemyX], a
    call SpawnBoss
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
    ldh [hEnemyHitEnemy], a
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
    ld a, [hli]
    ldh [hEnemyParam3], a
    ld a, [hli]
    ldh [hEnemyParam4], a
    ld a, [hl]
    ldh [hEnemyVariant], a

.resetSpawn:
    xor a ; ld a, 0
    ldh [hEnemyParam3], a
.endResetSpawn:

.faceExpression:
    ldh a, [hEnemyAnimationTimer]
    cp a, 0
    jr z, .canUpdateFaceExpression
    dec a
    ldh [hEnemyAnimationTimer], a
    jr .endFaceExpression
.canUpdateFaceExpression:
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ldh a, [hEnemyAnimationFrame]
.faceExpressionLeft:
    cp a, PORCUPINE_EXPRESSION_LEFT
    jr nz, .faceExpressionRight
    ld a, PORCUPINE_FACE_LEFT_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_FACE_LEFT_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ld a, 30
    jr .setExpressionTimer
.faceExpressionRight:
    cp a, PORCUPINE_EXPRESSION_RIGHT
    jr nz, .faceExpressionConfident
    ld a, PORCUPINE_FACE_LEFT_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_FACE_LEFT_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
    ld a, 30
    jr .setExpressionTimer
.faceExpressionConfident:
    cp a, PORCUPINE_EXPRESSION_CONFIDENT
    jr nz, .faceExpressionScared
    ld a, PORCUPINE_CONFIDENT_FACE_TILE
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_CONFIDENT_FACE_TILE
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
    ld a, 40
    jr .setExpressionTimer
.faceExpressionScared:
    ld a, PORCUPINE_SCARED_FACE_TILE
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_SCARED_FACE_TILE
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
    ld a, 255
.setExpressionTimer:
    ldh [hEnemyAnimationTimer], a
    ld a, [hEnemyX]
    cp a, SCRN_X / 2
    jr c, .lookRight
.lookLeft:
    ld a, PORCUPINE_EXPRESSION_LEFT
    ldh [hEnemyAnimationFrame], a
    jr .endFaceExpression
.lookRight:
    ld a, PORCUPINE_EXPRESSION_RIGHT
    ldh [hEnemyAnimationFrame], a
.endFaceExpression:

.checkKnockedOut:
    ldh a, [hEnemyParam2]
    cp a, 0
    jr z, .endKnockedOut
    dec a 
    ldh [hEnemyParam2], a
    cp a, 0
    jp nz, .setStruct
.knockedOutDone:
    ldh a, [hEnemyDying]
    cp a, 0
    jr z, .knockedOutAndAlive
.knockedOutAndDead:
    ld a, 1
    ldh [hEnemyParam3], a
.knockedOutAndDeadShowBossFeetAndRemoveBalloon:
    SET_HL_TO_ADDRESS wOAM+22, hEnemyOAM
    ld a, PORCUPINE_TILE_3_FEET_ALT
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    ld a, PORCUPINE_TILE_3_FEET_ALT
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
    SET_HL_TO_ADDRESS wOAM+34, hEnemyOAM
    ld a, EMPTY_TILE
    ld [hl], a
    jp .setStruct
.knockedOutAndAlive:
    xor a ; ld a, 0
    ldh [hEnemyAnimationTimer], a
.endKnockedOut:

.checkAlive:
    ldh a, [hEnemyAlive]
    cp a, 0
    jr nz, .isAlive
.isAtZeroHealth:
    ldh a, [hEnemyDying]
    cp a, 0
    jr nz, .dying
.dyingDone:
    ld a, 1 
    ld [wLevelWaitBoss], a
    ld bc, PORCUPINE_OAM_BYTES
    call ClearEnemy
    jp .setStruct 
.dying:
    xor a ; ld a, 0
    ldh [hEnemyParam3], a
.dyingOffscreen:
    ld a, SCRN_Y + 16 ; buffer
    ld hl, hEnemyY
    cp a, [hl]
    jr nc, .checkFalling
.isOffScreen:
    xor a ; ld a, 0
    ldh [hEnemyDying], a
    jp .setStruct
.checkFalling:
    ldh a, [hGlobalTimer]
    and %00000001
    jp nz, .setStruct
.canFall:
    ldh a, [hEnemySpeed]
    inc a 
    ldh [hEnemySpeed], a
    ld b, 5
    call DIVISION
    ld b, a
    ldh a, [hEnemyY]
    add a, b
    ldh [hEnemyY], a
    call UpdateBossPosition
    jp .setStruct
.isAlive:

.checkDirection:
    ldh a, [hGlobalTimer]
    and %00000011
    jr nz, .endCheckDirection
    ldh a, [hEnemyParam4]
    inc a 
    ldh [hEnemyParam4], a
    ld b, a
.checkDirectionX:
    and %00111111
    jr nz, .endCheckDirectionX
    ldh a, [hEnemyDirectionLeft]
    and ENEMY_DIRECTION_HORIZONTAL_MASK
    jr nz, .moveToRight
.moveToLeft:
    set 0, a
    ldh [hEnemyDirectionLeft], a
    jr .endCheckDirectionX
.moveToRight:
    res 0, a
    ldh [hEnemyDirectionLeft], a
.endCheckDirectionX:

.checkDirectionY:
    ld a, b
    and %00001111
    jr nz, .endCheckDirectionY
    ldh a, [hEnemyParam1]
.pointY1:
    cp a, PORCUPINE_POINT_Y1
    jr nz, .pointY2
    ld a, PORCUPINE_POINT_Y2
    ldh [hEnemyParam1], a
    jr .endCheckDirectionY
.pointY2:
    cp a, PORCUPINE_POINT_Y2
    jr nz, .pointY3
    ld a, PORCUPINE_POINT_Y3
    ldh [hEnemyParam1], a
    jr .endCheckDirectionY
.pointY3:
    ; cp a, PORCUPINE_POINT_Y3
    ; jr nz, .endCheckDirectionY
    ld a, PORCUPINE_POINT_Y1
    ldh [hEnemyParam1], a
.endCheckDirectionY:
.endCheckDirection:

.checkMove:
    ldh a, [hGlobalTimer]
    and	PORCUPINE_MOVE_TIME
    jp nz, .endMove
.canMove: 

.moveX:
    ld hl, hEnemySpeed
    ldh a, [hEnemyDirectionLeft]
    and ENEMY_DIRECTION_HORIZONTAL_MASK
    jr z, .handleMovingRight
.handleMovingLeft:
    ldh a, [hEnemyX]
    cp a, PORCUPINE_MIN_POSITION_X
    jr c, .moveXStopSpeed
    cp a, PORCUPINE_MIN_POSITION_X + PORCUPINE_MAX_SPEED * 2
    jr c, .moveXSlowDown
    jr .moveXSpeedUp
.handleMovingRight:
    ldh a, [hEnemyX]
    cp a, PORCUPINE_MAX_POSITION_X
    jr nc, .moveXStopSpeed
    cp a, PORCUPINE_MAX_POSITION_X - PORCUPINE_MAX_SPEED * 2
    jr nc, .moveXSlowDown
.moveXSpeedUp:
    ld a, [hl]
    add a, PORCUPINE_INCREASE_SPEED
    ld b, PORCUPINE_MAX_SPEED
    cp a, b
    jr c, .moveXUpdateSpeed
    ld a, b
    jr .moveXUpdateSpeed
.moveXSlowDown:
    ld a, [hl]
    sub a, PORCUPINE_INCREASE_SPEED
    ld b, PORCUPINE_START_SPEED
    cp a, b
    jr c, .moveXUpdateSpeed
    ld a, b
    jr .moveXUpdateSpeed
.moveXStopSpeed:
    xor a ; ld a, 0
.moveXUpdateSpeed:
    ld [hl], a
    ldh a, [hEnemyDirectionLeft]
    and ENEMY_DIRECTION_HORIZONTAL_MASK
    jr z, .moveXRight
.moveXLeft:
    ldh a, [hEnemyX]
    sub a, [hl]
    jr .moveXUpdate
.moveXRight:
    ldh a, [hEnemyX]
    add a, [hl]
.moveXUpdate:
    ldh [hEnemyX], a
.endMoveX:

.moveY:
    ldh a, [hEnemyParam1]
    ld b, a
    ld hl, hEnemyY
    ld a, [hl]
    cp a, b
    jr nz, .moveYContinue
.moveYStoppedAndAttack:

; .checkMoveVariant:
;     ldh a, [hEnemyVariant]
;     cp a, PORCUPINE_HARD
;     jr nz, .endMoveY
; .endCheckMoveVariant:

    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld a, [hl]
    cp a, PORCUPINE_CONFIDENT_FACE_TILE
    jr z, .endMoveY
    ldh a, [hEnemySpeed]
    cp a, 0
    jr nz, .endMoveY
.canAttack:
    ld a, PORCUPINE_EXPRESSION_CONFIDENT
    ldh [hEnemyAnimationFrame], a
    xor a ; ld a, 0
    ldh [hEnemyAnimationTimer], a
    inc a
    ldh [hEnemyParam3], a
    jr .endMoveY
.moveYContinue:
    jr c, .moveYDown
.moveYUp:
    sub a, PORCUPINE_VERTICAL_SPEED
    jr .moveYUpdate
.moveYDown:
    add a, PORCUPINE_VERTICAL_SPEED
.moveYUpdate:
    ld [hl], a
.endMoveY:

    call UpdateBossPosition
.endMove:

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
    jp nz, .endCollision
    ldh a, [hEnemyHitEnemy]
    cp a, 0
    jr nz, .bossDamaged
; .checkHitBullet: ; FOR DEBUGGING *****
;     ld bc, wPlayerBulletOAM
;     SET_HL_TO_ADDRESS wOAM, hEnemyOAM
;     ld d, 32
;     ld e, 32
;     call CollisionCheck
;     cp a, 0
;     jr nz, .bossDamaged
;     ; ***********
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 32
    ld e, 32
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
    jr .endCollision
.bossDamaged:
    ; Points
    ld d, PORCUPINE_POINTS
    call AddPoints
    ; Sound
    call PercussionSound
    ; Stop enemy hit
    xor a ; ld a, 0
    ldh [hEnemyHitEnemy], a
    ; Stop speed
    ldh [hEnemySpeed], a
    ; Decrease life
    ldh a, [hEnemyAlive]
    dec a
    ldh [hEnemyAlive], a
    cp a, 0
    jr nz, .bossDamagedAndAlive
.bossDamagedAndDead:
    ld a, 1
    ldh [hEnemyDying], a
.bossDamagedAndAlive:
    ld a, PORCUPINE_KNOCKED_OUT_TIME
    ldh [hEnemyParam2], a
    ld a, PORCUPINE_EXPRESSION_SCARED
    ldh [hEnemyAnimationFrame], a
    xor a ; ld a, 0
    ldh [hEnemyAnimationTimer], a
.endCollision:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct

.checkBossSpawns:
    ldh a, [hEnemyAlive]
    cp a, 0
    jr z, .checkSpawnPointBalloon
.checkSpawnBossNeedle:
    ldh a, [hEnemyParam3]
    cp a, 0
    jr z, .endSpawnBossNeedle
.spawnBossNeedle:
    ld a, BOSS_NEEDLE
    ldh [hEnemyNumber], a

    ldh a, [hEnemyDirectionLeft]
    and ENEMY_DIRECTION_HORIZONTAL_MASK
    jr nz, .upRightNeedle
.upLeftNeedle:
    ld a, NEEDLE_UP_MOVE_LEFT_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyY]
    add a, 8
    ldh [hEnemyY], a
    ldh a, [hEnemyX]
    add a, 8
    ldh [hEnemyX], a
    call SpawnBossNeedle
.downLeftNeedle:
    ld a, NEEDLE_DOWN_MOVE_LEFT_VARIANT
    ldh [hEnemyVariant], a
    call SpawnBossNeedle
    jr .endSpawnBossNeedle
.upRightNeedle:
    ld a, NEEDLE_UP_MOVE_RIGHT_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyY]
    add a, 8
    ldh [hEnemyY], a
    ldh a, [hEnemyX]
    add a, 24
    ldh [hEnemyX], a
    call SpawnBossNeedle
.downRightNeedle:
    ld a, NEEDLE_DOWN_MOVE_RIGHT_VARIANT
    ldh [hEnemyVariant], a
    call SpawnBossNeedle
.endSpawnBossNeedle:
    jr .endCheckBossSpawns

.checkSpawnPointBalloon:
    ldh a, [hEnemyParam3]
    cp a, 0
    jr z, .endSpawnPointBalloon
.spawnPointBalloon:
    ld a, POINT_BALLOON
    ldh [hEnemyNumber], a
    ld a, BALLOON_MEDIUM_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyY]
    add a, 19
    ldh [hEnemyY], a
    ldh a, [hEnemyX]
    add a, 8
    ldh [hEnemyX], a
    call SpawnPointBalloon
.endSpawnPointBalloon:

.endCheckBossSpawns:
    ret