INCLUDE "balloonConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

ANVIL_OAM_SPRITES EQU 2
ANVIL_OAM_BYTES EQU ANVIL_OAM_SPRITES * 4
ANVIL_MOVE_TIME EQU %00000001
ANVIL_COLLISION_TIME EQU %00001000

CACTUS_SCREAMING_TILE EQU $16

ANVIL_TILE_1 EQU $48
ANVIL_TILE_2 EQU $4A

SECTION "anvil", ROMX

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
    ldh a, [hEnemySpeed]
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hl], a
    ret

SpawnAnvil::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jr z, .end
.availableSpace:
    ld b, ANVIL_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    jr z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ldh [hEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ldh [hEnemyActive], a

.variantSpeed:
    ldh a, [hEnemyVariant]
.cactusSpeed:
    cp a, CACTUS_VARIANT
    jr nz, .anvilSpeed
    ld a, 1
    jr .endVariantSpeed
.anvilSpeed:
    ld a, 4
.endVariantSpeed:
    ldh [hEnemySpeed], a

    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
.variantVisualLeft:
    ldh a, [hEnemyVariant]
.cactusVisual:
    cp a, CACTUS_VARIANT
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
    cp a, CACTUS_VARIANT
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
.end:
    pop hl
    ret

Clear:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld bc, ANVIL_OAM_BYTES
    call ResetHLInRange
    call InitializeEnemyStructVars
    ret

AnvilUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ldh [hEnemyOAM], a
    ld a, [hli]
    ldh [hEnemySpeed], a
    ld a, [hl]
    ldh [hEnemyVariant], a

.fallingSpeed:
    ldh a, [hGlobalTimer]
    and ANVIL_MOVE_TIME
    jr nz, .endFallingSpeed
    ldh a, [hEnemySpeed]
    inc a 
    ldh [hEnemySpeed], a
    ld b, 2
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
    jr z, .endCollision
.hitEnemy:
    ; mark to blink instead
    call Clear
    jr .setStruct
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
    call Clear
.endOffscreen:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret