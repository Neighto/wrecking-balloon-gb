INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

EXPLOSION_OAM_SPRITES EQU 3
EXPLOSION_OAM_BYTES EQU EXPLOSION_OAM_SPRITES * 4

EXPLOSION_BOMB_TILE_1 EQU $48
EXPLOSION_BOMB_TILE_2 EQU $4A

EXPLOSION_CONGRATULATIONS_TILE_1 EQU $44
EXPLOSION_CONGRATULATIONS_TILE_2 EQU $46

EXPLOSION_TIME EQU 15
EXPLOSION_WAIT_TIME EQU %00000001

; hEnemyParam1 = Animation Frame

SECTION "explosion", ROM0

SpawnExplosion::
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
.availableSpace:
    ld b, EXPLOSION_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    ret z
.availableOAMSpace:
    call InitializeEnemyStructVars
    ld a, b
    ldh [hEnemyOAM], a
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    ldh [hEnemyFlags], a
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.variantVisual:
    ldh a, [hEnemyVariant]
.bombVisual:
    cp a, EXPLOSION_BOMB_VARIANT
    jr nz, .congratulationsVisual
    ld d, EXPLOSION_BOMB_TILE_1
    ld e, EXPLOSION_BOMB_TILE_2
    jr .endVariantVisual
.congratulationsVisual:
    ; cp a, EXPLOSION_CONGRATULATIONS_VARIANT
    ; jr nz, .endVariantVisual
    ld d, EXPLOSION_CONGRATULATIONS_TILE_1
    ld e, EXPLOSION_CONGRATULATIONS_TILE_2
.endVariantVisual:

.explosionLeftOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.explosionMiddleOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, e
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.explosionRightOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetEnemyStruct
.variantSound:
    ldh a, [hEnemyVariant]
.bombSound:
    cp a, EXPLOSION_BOMB_VARIANT
    jr nz, .congratulationsSound
    call ExplosionSound
    jr .endVariantSound
.congratulationsSound:
    call FireworkSound
.endVariantSound:
    ret

ExplosionUpdate::

.animateExplosion:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and EXPLOSION_WAIT_TIME
    jr nz, .endAnimateExplosion
    ldh a, [hEnemyParam1]
    inc a
    ldh [hEnemyParam1], a
    cp a, EXPLOSION_TIME
    jr nc, .clear
    and %00000001
    jr z, .palette1
.palette0:
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
    ld a, OAMF_PAL0
    jr .paletteEnd
.palette1:
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
    ld a, OAMF_PAL1
.paletteEnd:
    ld [hli], a
    inc l
    inc l
    inc l
    ld [hli], a
    inc l
    inc l
    inc l
    or OAMF_XFLIP
    ld [hl], a
    jr .endAnimateExplosion
.clear:
    ld bc, EXPLOSION_OAM_BYTES
    call ClearEnemy
.endAnimateExplosion:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    jp SetEnemyStruct