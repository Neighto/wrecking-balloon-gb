INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "tileConstants.inc"

POINT_BALLOON_OAM_SPRITES EQU 3
POINT_BALLOON_OAM_BYTES EQU POINT_BALLOON_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
POINT_BALLOON_COLLISION_TIME EQU %00000011
POINT_BALLOON_STRING_X_OFFSET EQU 4
POINT_BALLOON_STRING_Y_OFFSET EQU 14

POINT_BALLOON_COLLISION_Y EQU 1
POINT_BALLOON_COLLISION_X EQU 1
POINT_BALLOON_COLLISION_HEIGHT EQU 12
POINT_BALLOON_COLLISION_WIDTH EQU 14

; hEnemyParam1 = Animation Frame
; hEnemyParam2 = Animation Timer

SECTION "point balloon", ROMX

; *************************************************************
; SPAWN
; *************************************************************
SpawnPointBalloon::
    ld b, POINT_BALLOON_OAM_SPRITES
    call FindRAMAndOAMForEnemy ; hl = RAM space, b = OAM offset
    ret z
    ;
    ; Initialize
    ;
    call InitializeEnemyStructVars
    ld a, b
    ldh [hEnemyOAM], a
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    set ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a
    ;
    ; Get hl pointing to OAM address
    ;
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
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
    ld e, OAMF_PAL1
    jr .endVariantVisual
.hardVisual:
    cp a, BALLOON_HARD_VARIANT
    jr nz, .extraLifeVisual
    ld d, POINT_BALLOON_HARD_TILE
    ld e, OAMF_PAL1
    jr .endVariantVisual
.extraLifeVisual:
    ; cp a, BALLOON_STAGE_CLEAR_VARIANT
    ; jr nz, .endVariantVisual
    ld d, EXTRA_LIFE_BALLOON_TILE
    ld e, OAMF_PAL1
    ; jr .endVariantVisual
.endVariantVisual:
    ;
    ; Balloon left OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
    ;
    ; Balloon right OAM
    ;
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
    ;
    ; String OAM
    ;
    ldh a, [hEnemyY]
    add POINT_BALLOON_STRING_Y_OFFSET
    ld [hli], a
    ldh a, [hEnemyX]
    add POINT_BALLOON_STRING_X_OFFSET
    ld [hli], a
    ld a, STRING_TILE
    ld [hli], a
    ld [hl], OAMF_PAL0
    ;
    ; Set struct
    ;
    LD_HL_BC
    jp SetEnemyStructWithHL

; *************************************************************
; UPDATE
; *************************************************************
PointBalloonUpdate::

    ;
    ; Check alive
    ;
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jr nz, .isAlive
    ; Is popped
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DYING_MASK
    jr z, .clear
    ; Animating
    call PopBalloonAnimation
    jp SetEnemyStruct
    ; Clear
.clear:
    ld bc, POINT_BALLOON_OAM_BYTES
    call ClearEnemy
    jp SetEnemyStruct
.isAlive:

    ;
    ; Check move
    ;
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
    jr nz, .endMove
    dec [hl]
    dec [hl]
    dec [hl]
    ; jr .setOAM
.setOAM:
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    UPDATE_OAM_POSITION_ENEMY 2, 1
.stringOAM:
    ldh a, [hEnemyY]
    add POINT_BALLOON_STRING_Y_OFFSET
    ld [hli], a
.endMove:

    ;
    ; Check string
    ;
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and STRING_MOVE_TIME
    jr nz, .endString
    ld hl, wOAM + 11
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
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

    ;
    ; Check collision
    ;
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	POINT_BALLOON_COLLISION_TIME
    jr nz, .endCollision
    ; Hit by enemy
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .deathOfPointBalloon
    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .checkHitByBullet
    ; Check hit player cactus
    SETUP_ENEMY_COLLIDER POINT_BALLOON_COLLISION_Y, POINT_BALLOON_COLLISION_HEIGHT, POINT_BALLOON_COLLISION_X, POINT_BALLOON_COLLISION_WIDTH
    call CollisionCheckPlayerCactus
    jr nz, .deathOfPointBalloon
    ; Check hit bullet
.checkHitByBullet:
    call EnemyHitBullet
    jr z, .endCollision
.deathOfPointBalloon:
    ; Points
.variantPoints:
    ldh a, [hEnemyVariant]
.easyPoints:
    cp a, BALLOON_EASY_VARIANT
    jr nz, .mediumPoints
    ld a, POINT_BALLOON_EASY_POINTS
    jr .updatePoints
.mediumPoints:
    cp a, BALLOON_MEDIUM_VARIANT
    jr nz, .hardPoints
    ld a, POINT_BALLOON_MEDIUM_POINTS
    jr .updatePoints
.hardPoints:
    cp a, BALLOON_HARD_VARIANT
    jr nz, .endVariantPoints
    ld a, POINT_BALLOON_HARD_POINTS
    ; jr .updatePoints
.updatePoints:
    call AddPoints
.endVariantPoints:
    ; Flags
    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_ALIVE_BIT, a
    set ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ; Sound
    call PopSound
.endCollision:

    ;
    ; Check offscreen
    ;
    ld bc, POINT_BALLOON_OAM_BYTES
    call HandleEnemyOffscreenVertical
    ; Enemy may be cleared, must do setStruct next

    ;
    ; Set struct
    ;
    jp SetEnemyStruct