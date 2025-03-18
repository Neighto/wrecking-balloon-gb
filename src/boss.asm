INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"

PORCUPINE_OAM_SPRITES EQU 9
PORCUPINE_OAM_BYTES EQU PORCUPINE_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
PORCUPINE_OAM_BUFFER_FOR_SPAWNS_SPRITES EQU 3
PORCUPINE_OAM_BUFFER_FOR_SPAWNS_BYTES EQU PORCUPINE_OAM_BUFFER_FOR_SPAWNS_SPRITES * OAM_ATTRIBUTES_COUNT
PORCUPINE_MOVE_TIME EQU %00000001
PORCUPINE_COLLISION_TIME EQU %00000111
PORCUPINE_ATTACK_COOLDOWN_TIMER EQU 50

PORCUPINE_SPAWN_Y EQU 68
PORCUPINE_SPAWN_X EQU 112

PORCUPINE_STRING_Y_OFFSET EQU 31
PORCUPINE_STRING_X_OFFSET EQU 12

PORCUPINE_START_SPEED EQU 2
PORCUPINE_INCREASE_SPEED EQU 2
PORCUPINE_VERTICAL_SPEED EQU 2

PORCUPINE_MIN_POSITION_X EQU 10
PORCUPINE_MAX_POSITION_X EQU 132

PORCUPINE_EXPRESSION_LEFT EQU 0
PORCUPINE_EXPRESSION_RIGHT EQU 1
PORCUPINE_EXPRESSION_CONFIDENT EQU 2
PORCUPINE_EXPRESSION_SCARED EQU 3

PORCUPINE_EXPRESSION_LEFT_TIMER EQU 255
PORCUPINE_EXPRESSION_RIGHT_TIMER EQU 255
PORCUPINE_EXPRESSION_CONFIDENT_TIMER EQU 35
PORCUPINE_EXPRESSION_SCARED_TIMER EQU 255

PORCUPINE_KNOCKED_OUT_TIME EQU 40

PORCUPINE_POINT_Y1 EQU 46
PORCUPINE_POINT_Y2 EQU 66
PORCUPINE_POINT_Y3 EQU 86

PORCUPINE_CHANGE_DIRECTION_X_TIME EQU %11111111
PORCUPINE_CHANGE_DIRECTION_Y_TIME EQU %00011111
PORCUPINE_ABOUT_TO_CHANGE_DIRECTION_X_TIME EQU %11110000

PORCUPINE_FLAG_TRIGGER_SPAWN_MASK EQU ENEMY_FLAG_PARAM1_MASK
PORCUPINE_FLAG_TRIGGER_SPAWN_BIT EQU ENEMY_FLAG_PARAM1_BIT
PORCUPINE_FLAG_HEALTH_MASK EQU ENEMY_FLAG_PARAM2_MASK | ENEMY_FLAG_PARAM3_MASK
PORCUPINE_FLAG_HEALTH_BIT1 EQU ENEMY_FLAG_PARAM2_BIT
PORCUPINE_FLAG_HEALTH_BIT2 EQU ENEMY_FLAG_PARAM3_BIT

PORCUPINE_OAM_OFFSET EQU 26 * OAM_ATTRIBUTES_COUNT

PORCUPINE_COLLISION_Y EQU 0
PORCUPINE_COLLISION_X EQU 2
PORCUPINE_COLLISION_HEIGHT EQU 32
PORCUPINE_COLLISION_WIDTH EQU 28


PORCUPINE_DYING_VOICE_TIME EQU %00010111

BOSS_KILLER_START_TIME EQU %00111100
BOSS_KILLER_WAIT_TIME EQU %00111111

SECTION "boss vars", HRAM
hBossFlags:: DB
hBossY:: DB
hBossX:: DB
hBossOAM:: DB
hBossAnimationFrame:: DB
hBossAnimationTimer:: DB
hBossSpeed:: DB
hBossToY:: DB
hBossKnockedOutTimer:: DB
hBossDirectionChangeTimer:: DB
hBossAttackCooldownTimer:: DB

SECTION "boss", ROMX

InitializeBoss::
    xor a ; ld a, 0
    ldh [hBossFlags], a
    ldh [hBossY], a
    ldh [hBossX], a
    ldh [hBossOAM], a
    ldh [hBossAnimationFrame], a
    ldh [hBossAnimationTimer], a
    ldh [hBossSpeed], a
    ldh [hBossToY], a
    ldh [hBossKnockedOutTimer], a
    ldh [hBossDirectionChangeTimer], a
    ldh [hBossAttackCooldownTimer], a
    ret

UpdateBossPosition:
    ld hl, wOAM
    ldh a, [hBossOAM]
    ADD_A_TO_HL
    UPDATE_OAM_POSITION_HRAM 4, 2, [hBossX], [hBossY], 0
    ldh a, [hBossY]
    add PORCUPINE_STRING_Y_OFFSET
    ld [hli], a
    ldh a, [hBossX]
    add PORCUPINE_STRING_X_OFFSET
    ld [hli], a
    ret

CollisionWithBoss::
    ld hl, hBossFlags
    set ENEMY_FLAG_HIT_ENEMY_BIT, [hl]
    ret


; *************************************************************
; SPAWN
; *************************************************************
SpawnBoss::
    ;
    ; Initialize
    ;
    ; OAM offset
    ld a, PORCUPINE_OAM_OFFSET
    ldh [hBossOAM], a
    ; Flags
    ldh a, [hBossFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    set ENEMY_FLAG_ALIVE_BIT, a
    set PORCUPINE_FLAG_HEALTH_BIT1, a ; Boss health + 1
    set PORCUPINE_FLAG_HEALTH_BIT2, a ; Boss health + 2
    ldh [hBossFlags], a
    ; Position
    ld a, PORCUPINE_SPAWN_Y
    ldh [hBossY], a
    ld a, PORCUPINE_SPAWN_X
    ldh [hBossX], a
    ld a, PORCUPINE_POINT_Y3
    ldh [hBossToY], a
    call UpdateBossPosition
    ;
    ; Get hl pointing to OAM address
    ;
    ld hl, wOAM + 2
    ldh a, [hBossOAM]
    ADD_A_TO_HL
    ;
    ; Porcupine OAM
    ;
    ld bc, PorcupineMap
    ld de, PorcupineMapEnd - PorcupineMap
    jp MEMCPY_OAM_TILE_AND_ATTRIBUTES_DATA

; *************************************************************
; UPDATE
; *************************************************************
BossUpdate::

    ;
    ; Check is active
    ;
    ldh a, [hBossFlags]
    and ENEMY_FLAG_ACTIVE_MASK
    ret z

    ;
    ; Check spawn (boss needle attack or balloon when dead)
    ;
    ldh a, [hBossFlags]
    ld b, a
    and PORCUPINE_FLAG_TRIGGER_SPAWN_MASK
    jr z, .endCheckSpawn
    ; Spawn trigger active
    ld a, b
    res PORCUPINE_FLAG_TRIGGER_SPAWN_BIT, a
    ldh [hBossFlags], a
    ; Match boss position
    ldh a, [hBossY]
    ldh [hEnemyY], a
    ldh a, [hBossX]
    ldh [hEnemyX], a
    ; Choose spawn type (attack or drop balloon)
    ld a, b
    and ENEMY_FLAG_ALIVE_MASK
    jr z, .spawnPointBalloon
    ; -- SPAWN BOSS NEEDLE
.spawnBossNeedle:
    ld a, BOSS_NEEDLE
    ldh [hEnemyNumber], a
    ld a, b
    and ENEMY_FLAG_DIRECTION_MASK
    jr nz, .spawnBossNeedlesRight
.spawnBossNeedlesLeft:
    ; Up left needle
    ld a, NEEDLE_UP_MOVE_LEFT_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyX]
    add a, 8
    ldh [hEnemyX], a
    call SpawnBossNeedle
    ; Down left needle
    ld a, NEEDLE_DOWN_MOVE_LEFT_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyY]
    add a, 16
    ldh [hEnemyY], a
    call SpawnBossNeedle
    jp BossNeedleSound
.spawnBossNeedlesRight:
    ; Up right needle
    ld a, NEEDLE_UP_MOVE_RIGHT_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyX]
    add a, 24
    ldh [hEnemyX], a
    call SpawnBossNeedle
    ; Down right needle
    ld a, NEEDLE_DOWN_MOVE_RIGHT_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyY]
    add a, 16
    ldh [hEnemyY], a
    call SpawnBossNeedle
.endSpawnBossNeedle:
    jp BossNeedleSound
    ; -- SPAWN POINT BALLOON
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
    jp SpawnPointBalloon
.endCheckSpawn:

    ;
    ; Face expression
    ;
    ; Check cooldown for animation has expired
    ldh a, [hBossAnimationTimer]
    cp a, 0
    jr z, .canUpdateFaceExpression
.cannotUpdateFaceExpression:
    dec a
    ldh [hBossAnimationTimer], a
    jr .endFaceExpression
.canUpdateFaceExpression:
    ; Point hl to enemy oam
    ld hl, wOAM + 6
    ldh a, [hBossOAM]
    ADD_A_TO_HL
    ; Update frame
    ldh a, [hBossAnimationFrame]
.faceExpressionLeft:
    cp a, PORCUPINE_EXPRESSION_LEFT
    jr nz, .faceExpressionRight
    ld bc, PorcupineExpressionLeftMap
    ld de, PorcupineExpressionLeftMapEnd - PorcupineExpressionLeftMap
    call MEMCPY_OAM_TILE_AND_ATTRIBUTES_DATA
    ld a, PORCUPINE_EXPRESSION_LEFT_TIMER
    jr .updateFaceExpressionCommon
.faceExpressionRight:
    cp a, PORCUPINE_EXPRESSION_RIGHT
    jr nz, .faceExpressionConfident
    ld bc, PorcupineExpressionRightMap
    ld de, PorcupineExpressionRightMapEnd - PorcupineExpressionRightMap
    call MEMCPY_OAM_TILE_AND_ATTRIBUTES_DATA
    ld a, PORCUPINE_EXPRESSION_RIGHT_TIMER
    jr .updateFaceExpressionCommon
.faceExpressionConfident:
    cp a, PORCUPINE_EXPRESSION_CONFIDENT
    jr nz, .faceExpressionScared
    ld bc, PorcupineExpressionConfidentMap
    ld de, PorcupineExpressionConfidentMapEnd - PorcupineExpressionConfidentMap
    call MEMCPY_OAM_TILE_AND_ATTRIBUTES_DATA
    ld a, PORCUPINE_EXPRESSION_CONFIDENT_TIMER
    jr .updateFaceExpressionCommon
.faceExpressionScared:
    ; cp a, PORCUPINE_EXPRESSION_SCARED
    ; jr nz, .updateFaceExpressionCommon
    ld bc, PorcupineExpressionScaredMap
    ld de, PorcupineExpressionScaredMapEnd - PorcupineExpressionScaredMap
    call MEMCPY_OAM_TILE_AND_ATTRIBUTES_DATA
    ld a, PORCUPINE_EXPRESSION_SCARED_TIMER
    ; jr .updateFaceExpressionCommon
.updateFaceExpressionCommon:
    ; Set expression timer
    ldh [hBossAnimationTimer], a
    ; Set default next frame to be facing a direction
    ldh a, [hBossX]
    cp a, SCRN_X / 2
    jr c, .lookRight
.lookLeft:
    ld a, PORCUPINE_EXPRESSION_LEFT
    jr .updateLook
.lookRight:
    ld a, PORCUPINE_EXPRESSION_RIGHT
.updateLook:
    ldh [hBossAnimationFrame], a
.endFaceExpression:

    ;
    ; Check knocked out
    ;
    ldh a, [hBossKnockedOutTimer]
    cp a, 0
    jr z, .endKnockedOut
    dec a
    ldh [hBossKnockedOutTimer], a
    cp a, 0
    ret nz
    ; Knocked out done
    ldh a, [hBossFlags]
    and ENEMY_FLAG_DYING_MASK
    jr z, .knockedOutAndAlive
    ; Knocked out and dead
    ldh a, [hBossFlags]
    set PORCUPINE_FLAG_TRIGGER_SPAWN_BIT, a
    ldh [hBossFlags], a
    ; Knocked out and dead, show boss feet and remove balloon
    ld hl, wOAM + 22
    ldh a, [hBossOAM]
    ADD_A_TO_HL
    ld bc, PorcupineFeetMap
    ld de, PorcupineFeetMapEnd - PorcupineFeetMap
    call MEMCPY_OAM_TILE_AND_ATTRIBUTES_DATA
    ld hl, wOAM + 34
    ldh a, [hBossOAM]
    ADD_A_TO_HL
    ld a, WHITE_SPR_TILE
    ld [hl], a
    ret
    ; Knocked out and alive
.knockedOutAndAlive:
    xor a ; ld a, 0
    ldh [hBossAnimationTimer], a
.endKnockedOut:

    ;
    ; Check alive
    ;
    ldh a, [hBossFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jr nz, .isAlive

    ;
    ; Is dying (at zero health)
    ;
    ; Dying sounds
    ldh a, [hGlobalTimer]
    and PORCUPINE_DYING_VOICE_TIME
    call z, HelpVoiceSound
    ; Dying offscreen
    ld a, SCRN_Y + 16 ; buffer
    ld hl, hBossY
    cp a, [hl]
    jr nc, .checkFalling
    ; Is offscreen
    ldh a, [hBossFlags]
    res ENEMY_FLAG_ACTIVE_BIT, a
    ldh [hBossFlags], a
    ld a, 1
    ldh [hLevelWaitBoss], a
    ret
.checkFalling:
    ldh a, [hGlobalTimer]
    and %00000001
    ret nz
    ; Can fall
    ldh a, [hBossSpeed]
    inc a
    ldh [hBossSpeed], a
    ld b, 5
    call DIVISION
    ld b, a
    ldh a, [hBossY]
    add a, b
    ldh [hBossY], a
    jp UpdateBossPosition

    ;
    ; Is alive
    ;
.isAlive:

    ;
    ; Check direction
    ;
    ldh a, [hGlobalTimer]
    and %00000001
    jr nz, .endCheckDirection
    ldh a, [hBossDirectionChangeTimer]
    inc a
    ldh [hBossDirectionChangeTimer], a
    ld b, a
    ; -- Check direction X
    and PORCUPINE_CHANGE_DIRECTION_X_TIME
    jr nz, .endCheckDirectionX
    ; Aim low when changing direction
    ld a, PORCUPINE_POINT_Y3
    ldh [hBossToY], a
    ; Change direction
    ldh a, [hBossFlags]
    ld c, a
    and ENEMY_FLAG_DIRECTION_MASK
    ld a, c
    jr nz, .moveToRight
.moveToLeft:
    set ENEMY_FLAG_DIRECTION_BIT, a
    ldh [hBossFlags], a
    jr .endCheckDirection
.moveToRight:
    res ENEMY_FLAG_DIRECTION_BIT, a
    ldh [hBossFlags], a
    jr .endCheckDirection
.endCheckDirectionX:

    ; -- Check direction Y
    ld a, b
    and PORCUPINE_CHANGE_DIRECTION_Y_TIME
    jr nz, .endCheckDirectionY
    ldh a, [hBossToY]
.pointY1:
    cp a, PORCUPINE_POINT_Y1
    jr nz, .pointY2
    ld a, PORCUPINE_POINT_Y2
    ldh [hBossToY], a
    jr .endCheckDirectionY
.pointY2:
    cp a, PORCUPINE_POINT_Y2
    jr nz, .pointY3
    ld a, PORCUPINE_POINT_Y3
    ldh [hBossToY], a
    jr .endCheckDirectionY
.pointY3:
    ; cp a, PORCUPINE_POINT_Y3
    ; jr nz, .endCheckDirectionY
    ld a, PORCUPINE_POINT_Y1
    ldh [hBossToY], a
.endCheckDirectionY:
.endCheckDirection:

    ;
    ; Check attack cooldown
    ;
    ldh a, [hBossAttackCooldownTimer]
    cp a, 0
    jr z, .endCheckAttackCooldown
    dec a
    ldh [hBossAttackCooldownTimer], a
.endCheckAttackCooldown:

    ;
    ; Check move
    ;
    ldh a, [hGlobalTimer]
    and PORCUPINE_MOVE_TIME
    jp nz, .endMove

    ;
    ; Can move
    ;
    ; -- Move X
    ; TODO skip moveX if we can
    ld hl, hBossSpeed
    ldh a, [hBossFlags]
    and ENEMY_FLAG_DIRECTION_MASK
    jr z, .handleMovingRight
.handleMovingLeft:
    ldh a, [hBossX]
    cp a, PORCUPINE_MIN_POSITION_X
    jr c, .moveXStop
    cp a, SCRN_X / 2
    jr c, .moveXSpeedDown
    jr .moveXSpeedUp
.handleMovingRight:
    ldh a, [hBossX]
    cp a, PORCUPINE_MAX_POSITION_X
    jr nc, .moveXStop
    cp a, SCRN_X / 2
    jr nc, .moveXSpeedDown
.moveXSpeedUp:
    ld a, [hl]
    add a, PORCUPINE_INCREASE_SPEED
    jr .moveXUpdateSpeed
.moveXSpeedDown:
    ld a, [hl]
    cp a, PORCUPINE_INCREASE_SPEED
    jr nc, .speedDownContinue
.speedDownMin:
    ld a, PORCUPINE_START_SPEED
    jr .moveXUpdateSpeed
.speedDownContinue:
    sub a, PORCUPINE_INCREASE_SPEED
.moveXUpdateSpeed:
    ld [hl], a
    ld b, 8
    call DIVISION
    cp a, 0
    jr nz, .valueOneOrGreater
.valueZero:
    inc a
.valueOneOrGreater:
    ld b, a
    ldh a, [hBossFlags]
    and ENEMY_FLAG_DIRECTION_MASK
    jr z, .moveXRight
.moveXLeft:
    ldh a, [hBossX]
    sub a, b
    jr .moveXUpdate
.moveXRight:
    ldh a, [hBossX]
    add a, b
.moveXUpdate:
    ldh [hBossX], a
    jr .endMoveX
.moveXStop:
    xor a ; ld a, 0
    ld [hl], a
.endMoveX:

    ; -- Move Y
    ldh a, [hBossToY]
    ld b, a
    ld hl, hBossY
    ld a, [hl]
    cp a, b
    jr nz, .moveYContinue
.moveYStoppedAndAttack:
    ldh a, [hBossSpeed]
    cp a, 0
    jr nz, .endMoveY
    ldh a, [hBossAttackCooldownTimer]
    cp a, 0
    jr nz, .endMoveY
    ; About to swoop
    ldh a, [hBossDirectionChangeTimer]
    cp a, PORCUPINE_ABOUT_TO_CHANGE_DIRECTION_X_TIME
    jr nc, .endMoveY
.canAttack:
    ld a, PORCUPINE_EXPRESSION_CONFIDENT
    ldh [hBossAnimationFrame], a
    xor a ; ld a, 0
    ldh [hBossAnimationTimer], a
    ldh a, [hBossFlags]
    set PORCUPINE_FLAG_TRIGGER_SPAWN_BIT, a
    ldh [hBossFlags], a
    ; Set attack cooldown timer
    ld a, PORCUPINE_ATTACK_COOLDOWN_TIMER
    ldh [hBossAttackCooldownTimer], a
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

    ;
    ; Check string
    ;
    ldh a, [hGlobalTimer]
    and STRING_MOVE_TIME
    jr nz, .endString
    ld hl, wOAM + 35
    ldh a, [hBossOAM]
    ADD_A_TO_HL
    ld a, [hl]
    ld b, a
    ld a, OAMF_PAL0
    cp a, b
    jr z, .flipX
    ld [hl], a
    jr .endString
.flipX:
    or OAMF_XFLIP
    ld [hl], a
.endString:

    ;
    ; Check collision
    ;
    ldh a, [hGlobalTimer]
    and PORCUPINE_COLLISION_TIME
    ret nz ; jp nz, .endCollision ; Just return because end of update
    ldh a, [hBossFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .bossDamaged
    ; === testing ===
; .checkHitBullet:
    ; ld bc, wPlayerBulletOAM
    ; ld hl, wOAM
    ; ldh a, [hBossOAM]
    ; ADD_A_TO_HL
    ; ld d, 32
    ; ld e, 32
    ; call CollisionCheck
    ; jr nz, .bossDamaged
    ; ===============
.checkHitPlayer:
    SETUP_COLLIDER wColliderA, [hBossY], [hBossX], PORCUPINE_COLLISION_Y, PORCUPINE_COLLISION_HEIGHT, PORCUPINE_COLLISION_X, PORCUPINE_COLLISION_WIDTH
    call CollisionCheckPlayerBalloon
    jr z, .checkHitCactus
    jp CollisionWithPlayer ; Just jp because end of update
.checkHitCactus:
    ; SETUP_COLLIDER wColliderA, [hBossY], [hBossX], 0, 32, 2, 24
    call CollisionCheckPlayerCactus
    ret z ; Just return because end of update
    jp StunPlayer ; Just jp because end of update
.bossDamaged:
    ; Points
    ld a, PORCUPINE_POINTS
    call AddPoints
    ld a, PORCUPINE_POINTS
    call AddPoints
    ld a, PORCUPINE_POINTS
    call AddPoints
    ; Sound
    call OwVoiceSound
    call HitSound
    ; Stop speed
    xor a ; ld a, 0
    ldh [hBossSpeed], a
    ; Stop enemy hit and decrease life
    ldh a, [hBossFlags]
    res ENEMY_FLAG_HIT_ENEMY_BIT, a
    res PORCUPINE_FLAG_TRIGGER_SPAWN_BIT, a
    ld b, a
    and PORCUPINE_FLAG_HEALTH_MASK
    rlca
    rlca
    dec a
    rrca
    rrca
    ld c, a
    ld a, b
    and ENEMY_FLAG_ACTIVE_MASK | ENEMY_FLAG_ALIVE_MASK | ENEMY_FLAG_DYING_MASK | ENEMY_FLAG_DIRECTION_MASK | ENEMY_FLAG_HIT_ENEMY_MASK | PORCUPINE_FLAG_TRIGGER_SPAWN_MASK
    or c
    ldh [hBossFlags], a
    and PORCUPINE_FLAG_HEALTH_MASK
    jr nz, .bossDamagedAndAlive
.bossDamagedAndDead:
    ldh a, [hBossFlags]
    res ENEMY_FLAG_ALIVE_BIT, a
    set ENEMY_FLAG_DYING_BIT, a
    ldh [hBossFlags], a
.bossDamagedAndAlive:
    ld a, PORCUPINE_KNOCKED_OUT_TIME
    ldh [hBossKnockedOutTimer], a
    ld a, PORCUPINE_EXPRESSION_SCARED
    ldh [hBossAnimationFrame], a
    xor a ; ld a, 0
    ldh [hBossAnimationTimer], a
.endCollision:
    ret

SECTION "boss miscellaneous vars", WRAM0
wWaitBossTimer:: DB

SECTION "boss miscellaneous", ROMX

InitializeBossMiscellaneous::
    ld a, BOSS_KILLER_START_TIME
    ld [wWaitBossTimer], a
    ret

; *************************************************************
; UPDATE
; *************************************************************
WaitBossUpdate::
    ;
    ; Check if we can spawn balloon carrier
    ;
    ld a, [wWaitBossTimer]
    inc a
    ld [wWaitBossTimer], a
    and BOSS_KILLER_WAIT_TIME
    ret nz
    call FindBalloonCarrier
    ret nz

    ;
    ; Spawn balloon carrier
    ;
    ld a, BALLOON_CARRIER
    ldh [hEnemyNumber], a
    ld a, CARRIER_ANVIL_VARIANT
    ldh [hEnemyVariant], a
    ld a, -8
    ldh [hEnemyY], a
    ld a, 80
    ldh [hEnemyX], a
    jp SpawnBalloonCarrier