INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"
INCLUDE "playerConstants.inc"

ANVIL_OAM_SPRITES EQU 2
ANVIL_OAM_BYTES EQU ANVIL_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
ANVIL_DEAD_BLINKING_TIME EQU %00000011
ANVIL_DEAD_BLINKING_DURATION EQU 20
ANVIL_WARNING_DURATION EQU 15
ANVIL_FALLING_SPEED_DELAY EQU 3
ANVIL_INITIAL_SPEED EQU 4
CACTUS_INITIAL_SPEED EQU 1
ANVIL_WAIT_TO_KILL_DURATION EQU 6

ANVIL_COLLISION_Y EQU 0
ANVIL_COLLISION_X EQU 1
ANVIL_COLLISION_HEIGHT EQU 16
ANVIL_COLLISION_WIDTH EQU 14

; hEnemyParam1 = Speed
; hEnemyParam2 = Can Kill Timer / Animation Timer
; hEnemyParam3 = Warning Timer

SECTION "anvil", ROMX

; *************************************************************
; SPAWN
; *************************************************************
SpawnAnvil::
    ld b, ANVIL_OAM_SPRITES
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
    ldh [hEnemyFlags], a
    ;
    ; Variant speed
    ;
    ldh a, [hEnemyVariant]
.cactusSpeed:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .anvilSpeed
    ld a, CACTUS_INITIAL_SPEED
    jr .updateVariantSpeed
.anvilSpeed:
    ; cp a, ANVIL_NORMAL_VARIANT or ANVIL_WARNING_VARIANT
    ; jr nz, .endVariantSpeed
    ld a, ANVIL_INITIAL_SPEED
    ; jr .updateVariantSpeed
.updateVariantSpeed:
    ldh [hEnemyParam1], a
    ;
    ; Get hl pointing to OAM address
    ;
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ;
    ; Variant visual left
    ;
    ldh a, [hEnemyVariant]
.cactusVisual:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .anvilVisualLeft
    ld d, CACTUS_SCREAMING_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisualLeft
.anvilVisualLeft:
    ; cp a, ANVIL_NORMAL_VARIANT or ANVIL_WARNING_VARIANT
    ; jr nz, .endVariantVisualLeft
    ld d, ANVIL_TILE_1
    ld e, OAMF_PAL0
    ; jr .endVariantVisualLeft
.endVariantVisualLeft:
    ;
    ; Anvil left OAM
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
    ; Variant visual right
    ;
    ldh a, [hEnemyVariant]
.cactusVisualRight:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .anvilVisualRight
    ld d, CACTUS_SCREAMING_TILE
    ld e, OAMF_PAL0 | OAMF_XFLIP
    jr .endVariantVisualRight
.anvilVisualRight:
    ; cp a, ANVIL_NORMAL_VARIANT or ANVIL_WARNING_VARIANT
    ; jr nz, .endVariantVisualRight
    ld d, ANVIL_TILE_2
    ld e, OAMF_PAL0
    ; jr .endVariantVisualRight
.endVariantVisualRight:
    ;
    ; Anvil right OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hl], a
    ;
    ; Set struct
    ;
    LD_HL_BC
    jp SetEnemyStructWithHL

; *************************************************************
; UPDATE
; *************************************************************
AnvilUpdate::

    ;
    ; Check warning variant
    ;
    ldh a, [hEnemyVariant]
    cp a, ANVIL_WARNING_VARIANT
    jr nz, .endCheckWarningVariant
    ; Wait before falling to warn player
    ldh a, [hEnemyParam3]
    cp a, ANVIL_WARNING_DURATION
    jr nc, .endCheckWarningVariant
    inc a
    ldh [hEnemyParam3], a
    jp SetEnemyStruct
.endCheckWarningVariant:

    ;
    ; Check dying
    ;
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DYING_MASK
    jr z, .endCheckDying
    ldh a, [hEnemyParam2]
    inc a
    ldh [hEnemyParam2], a
    cp a, ANVIL_DEAD_BLINKING_DURATION
    jr c, .animateDying
    ; Clear
    ld bc, ANVIL_OAM_BYTES
    call ClearEnemy
    jp SetEnemyStruct
    ; Animate dying
.animateDying:
    and ANVIL_DEAD_BLINKING_TIME
    jp nz, SetEnemyStruct
    ld hl, wOAM + 2
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld a, [hl]
    cp a, WHITE_SPR_TILE
    jr z, .blinkOn
.blinkOff:
    ld a, WHITE_SPR_TILE
    ld [hli], a
    inc l
    inc l
    inc l
    ld [hli], a
    jp SetEnemyStruct
.blinkOn:
.variantBlinkOn:
    ldh a, [hEnemyVariant]
.variantCactus:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .variantAnvil
    ld d, CACTUS_SCREAMING_TILE
    ld e, d
    jr .endVariantBlinkOn
.variantAnvil:
    ; cp a, ANVIL_NORMAL_VARIANT or ANVIL_WARNING_VARIANT
    ; jr nz, .endVariantBlinkOn
    ld d, ANVIL_TILE_1
    ld e, ANVIL_TILE_2
    ; jr .endVariantBlinkOn
.endVariantBlinkOn:
    ld a, d
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, e
    ld [hli], a
    jp SetEnemyStruct
.endCheckDying:

    ;
    ; Check move
    ;
    ; Fall faster
    ldh a, [hEnemyParam1]
    inc a
    ldh [hEnemyParam1], a
    ld b, ANVIL_FALLING_SPEED_DELAY
    call DIVISION
    ld b, a
    ldh a, [hEnemyY]
    add a, b
    ldh [hEnemyY], a
    ; Set OAM
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    UPDATE_OAM_POSITION_ENEMY 2, 1

    ;
    ; Check collision
    ;
    ; Has been alive long enough (prevent hit immediately after spawning)
    ldh a, [hEnemyParam2]
    cp a, ANVIL_WAIT_TO_KILL_DURATION
    jr nc, .checkCollisionContinue
    inc a
    ldh [hEnemyParam2], a
    jr .endCollision
.checkCollisionContinue:
    SETUP_ENEMY_COLLIDER ANVIL_COLLISION_Y, ANVIL_COLLISION_HEIGHT, ANVIL_COLLISION_X, ANVIL_COLLISION_WIDTH
    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .checkHitAnotherEnemy
    ; Check hit player balloon
    ; SETUP_ENEMY_COLLIDER ANVIL_COLLISION_Y, ANVIL_COLLISION_HEIGHT, ANVIL_COLLISION_X, ANVIL_COLLISION_WIDTH
    call CollisionCheckPlayerBalloon
    jr z, .checkHitAnotherEnemy
    call CollisionWithPlayer
    jr .hitSomething
    ; Check hit another enemy
.checkHitAnotherEnemy:
    ; SETUP_ENEMY_COLLIDER ANVIL_COLLISION_Y, ANVIL_COLLISION_HEIGHT, ANVIL_COLLISION_X, ANVIL_COLLISION_WIDTH
    call EnemyInterCollision
    jr nz, .hitSomething
    ; Check hit boss
    ; Is boss alive
    ldh a, [hBossFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jr z, .endCollision
    ; Is normal variant
    ldh a, [hEnemyVariant]
    cp a, ANVIL_NORMAL_VARIANT
    jr nz, .endCollision
    ; Check
    ; SETUP_ENEMY_COLLIDER ANVIL_COLLISION_Y, ANVIL_COLLISION_HEIGHT, ANVIL_COLLISION_X, ANVIL_COLLISION_WIDTH
    call CollisionCheckBoss
    jr z, .endCollision
    call CollisionWithBoss
.hitSomething:
    ; Set our dying flag
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ; Reset our shared var hEnemyParam2
    xor a ; ld a, 0
    ldh [hEnemyParam2], a
.endCollision:

    ;
    ; Check offscreen
    ;
    ld bc, ANVIL_OAM_BYTES
    call HandleEnemyOffscreenVertical
    ; Enemy may be cleared, must do setStruct next

    ;
    ; Set struct
    ;
    jp SetEnemyStruct