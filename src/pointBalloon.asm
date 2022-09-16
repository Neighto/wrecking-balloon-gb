INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

POINT_BALLOON_OAM_SPRITES EQU 3
POINT_BALLOON_OAM_BYTES EQU POINT_BALLOON_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
POINT_BALLOON_MOVE_TIME EQU %00000001
POINT_BALLOON_COLLISION_TIME EQU %00000111
POINT_BALLOON_STRING_X_OFFSET EQU 4
POINT_BALLOON_STRING_Y_OFFSET EQU 14

POINT_BALLOON_EASY_TILE EQU $3A
POINT_BALLOON_EASY_POINTS EQU 25

POINT_BALLOON_MEDIUM_TILE EQU $40
POINT_BALLOON_MEDIUM_POINTS EQU 50

POINT_BALLOON_HARD_TILE EQU $3A
POINT_BALLOON_HARD_POINTS EQU 80


SECTION "point balloon", ROMX

SetStruct:
    ; Argument hl = start of free enemy struct
    ldh a, [hEnemyFlags]
    ld [hli], a
    ldh a, [hEnemyNumber]
    ld [hli], a
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ldh a, [hEnemyOAM]
    ld [hli], a
    ldh a, [hEnemyAnimationFrame]
    ld [hli], a
    ldh a, [hEnemyAnimationTimer]
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hl], a
    ret

SpawnPointBalloon::
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
.availableSpace:
    ld b, POINT_BALLOON_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    ret z
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ld [hEnemyOAM], a
    LD_BC_DE
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    set ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.variantVisual:
    ldh a, [hEnemyVariant]
.easyVisual:
    cp a, BALLOON_EASY_VARIANT
    jr nz, .mediumVisual
    ld d, POINT_BALLOON_EASY_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisual
.mediumVisual:
    cp a, BALLOON_MEDIUM_VARIANT
    jr nz, .hardVisual
    ld d, POINT_BALLOON_MEDIUM_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisual
.hardVisual:
    cp a, BALLOON_HARD_VARIANT
    jr nz, .endVariantVisual
    ld d, POINT_BALLOON_HARD_TILE
    ld e, OAMF_PAL1
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
    ld [hli], a
.stringOAM:
    ldh a, [hEnemyY]
    add POINT_BALLOON_STRING_Y_OFFSET
    ld [hli], a
    ldh a, [hEnemyX]
    add POINT_BALLOON_STRING_X_OFFSET
    ld [hli], a
    ld a, STRING_TILE
    ld [hli], a
    ld [hl], OAMF_PAL0
.setStruct:
    LD_HL_BC
    call SetStruct
    ret

PointBalloonUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ldh [hEnemyOAM], a
    ld a, [hli]
    ldh [hEnemyAnimationFrame], a
    ld a, [hli]
    ldh [hEnemyAnimationTimer], a
    ld a, [hl]
    ldh [hEnemyVariant], a

.checkAlive:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jp z, .popped
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	POINT_BALLOON_MOVE_TIME
    jr nz, .endMove
.canMove:
    ld hl, hEnemyY
    ldh a, [hEnemyVariant]
.moveEasy:
    cp a, BALLOON_EASY_VARIANT
    jr nz, .moveMedium
    dec [hl]
    jr .setOAM
.moveMedium:
    cp a, BALLOON_MEDIUM_VARIANT
    jr nz, .moveHard
    dec [hl]
    dec [hl]
    jr .setOAM
.moveHard:
    cp a, BALLOON_HARD_VARIANT
    jr nz, .setOAM
    dec [hl]
    dec [hl]
    dec [hl]
.setOAM:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    UPDATE_OAM_POSITION_ENEMY 2, 1
.stringOAM:
    ldh a, [hEnemyY]
    add POINT_BALLOON_STRING_Y_OFFSET
    ld [hli], a
.endMove:

.checkString:
    ldh a, [hGlobalTimer]
    and STRING_MOVE_TIME
    jr nz, .endString
    SET_HL_TO_ADDRESS wOAM+11, hEnemyOAM
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
    and	POINT_BALLOON_COLLISION_TIME
    jr nz, .endCollision
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .deathOfPointBalloon
.checkHit:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    LD_BC_HL
    ld hl, wPlayerCactusOAM
    ld d, 16
    ld e, 13
    call CollisionCheck
    cp a, 0
    jr nz, .deathOfPointBalloon
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
.deathOfPointBalloon:
    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a
    ; Points
.variantPoints:
    ldh a, [hEnemyVariant]
.easyPoints:
    cp a, BALLOON_EASY_VARIANT
    jr nz, .mediumPoints
    ld d, POINT_BALLOON_EASY_POINTS
    jr .endVariantPoints
.mediumPoints:
    cp a, BALLOON_MEDIUM_VARIANT
    jr nz, .hardPoints
    ld d, POINT_BALLOON_MEDIUM_POINTS
    jr .endVariantPoints
.hardPoints:
    cp a, BALLOON_HARD_VARIANT
    jr nz, .endVariantPoints
    ld d, POINT_BALLOON_HARD_POINTS
.endVariantPoints:
    call AddPoints
    ; Animation trigger
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ; Sound
    call PopSound
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
    ld bc, POINT_BALLOON_OAM_BYTES
    call ClearEnemy
    jr .setStruct
.endOffscreen:
    jr .setStruct

.popped:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DYING_MASK
    jr z, .clear
.animating:
    call PopBalloonAnimation
    jr .setStruct
.clear:
    ld bc, POINT_BALLOON_OAM_BYTES
    call ClearEnemy
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret