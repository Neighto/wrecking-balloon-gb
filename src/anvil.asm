INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

ANVIL_OAM_SPRITES EQU 2
ANVIL_OAM_BYTES EQU ANVIL_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
ANVIL_MOVE_TIME EQU %00000001
ANVIL_COLLISION_TIME EQU %00000001

CACTUS_SCREAMING_TILE EQU $16

SECTION "anvil", ROMX

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
    ldh a, [hEnemyAnimationTimer]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Enemy Speed
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hl], a
    ret

SpawnAnvil::
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
.availableSpace:
    ld b, ANVIL_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    ret z
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ldh [hEnemyOAM], a
    LD_BC_DE
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    ldh [hEnemyFlags], a

.variantSpeed:
    ldh a, [hEnemyVariant]
.cactusSpeed:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .anvilSpeed
    ld a, 1
    jr .endVariantSpeed
.anvilSpeed:
    ld a, 4
.endVariantSpeed:
    ldh [hEnemyParam1], a

    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
.variantVisualLeft:
    ldh a, [hEnemyVariant]
.cactusVisual:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .anvilVisualLeft
    ld d, CACTUS_SCREAMING_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisualLeft
.anvilVisualLeft:
    ld d, ANVIL_TILE_1
    ld e, OAMF_PAL0
.endVariantVisualLeft:

.anvilLeftOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ld a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a

.variantVisualRight:
    ldh a, [hEnemyVariant]
.cactusVisualRight:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .anvilVisualRight
    ld d, CACTUS_SCREAMING_TILE
    ld e, OAMF_PAL0 | OAMF_XFLIP
    jr .endVariantVisualRight
.anvilVisualRight:
    ld d, ANVIL_TILE_2
    ld e, OAMF_PAL0
.endVariantVisualRight:

.anvilRightOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetStruct
    ret

AnvilUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyAnimationTimer], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hl]
    ldh [hEnemyVariant], a

.checkDying:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DYING_MASK
    jr z, .endCheckDying
    ldh a, [hEnemyAnimationTimer]
    inc a
    ldh [hEnemyAnimationTimer], a
    cp a, 40
    jr c, .animateDying
.clear:
    ld bc, ANVIL_OAM_BYTES
    call ClearEnemy
    jp .setStruct
.animateDying:
    and %00000111
    jp nz, .setStruct
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM ; Tile
    ld a, [hl]
    cp a, EMPTY_TILE
    jr z, .blinkOn
.blinkOff:
    ld a, EMPTY_TILE
    ld [hli], a
    inc hl
    inc hl
    inc hl
    ld [hli], a
    jp .setStruct
.blinkOn:
.variantBlinkOn:
    ldh a, [hEnemyVariant]
.variantCactus:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .variantAnvil
    ld d, CACTUS_SCREAMING_TILE
    ld e, CACTUS_SCREAMING_TILE
    jr .endVariantBlinkOn
.variantAnvil:
    ld d, ANVIL_TILE_1
    ld e, ANVIL_TILE_2
.endVariantBlinkOn:
    ld a, d
    ld [hli], a
    inc hl
    inc hl
    inc hl
    ld a, e
    ld [hli], a
    jp .setStruct
.endCheckDying:

.fallingSpeed:
    ldh a, [hGlobalTimer]
    and ANVIL_MOVE_TIME
    jr nz, .endFallingSpeed
    ldh a, [hEnemyParam1]
    inc a 
    ldh [hEnemyParam1], a
    ld b, 3
    call DIVISION
    ld b, a
    ldh a, [hEnemyY]
    add a, b
    ldh [hEnemyY], a
.anvilLeftOAM:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ldh a, [hEnemyY]
    ld [hli], a
    inc l
    inc l
    inc l
.anvilRightOAM:
    ldh a, [hEnemyY]
    ld [hl], a
.endFallingSpeed:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	ANVIL_COLLISION_TIME
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
.checkHitAnotherEnemy:
    call EnemyInterCollision
    jr nz, .hitEnemy
.checkHitBoss:
    ldh a, [hEnemyVariant]
    cp a, ANVIL_NORMAL_VARIANT
    jr nz, .endCollision
    SET_HL_TO_ADDRESS wOAM, hBossOAM
    SET_BC_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 32
    ld e, 24
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call CollisionWithBoss
.hitEnemy:
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
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
    ld bc, ANVIL_OAM_BYTES
    call ClearEnemy
.endOffscreen:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret