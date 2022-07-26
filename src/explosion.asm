INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

EXPLOSION_OAM_SPRITES EQU 3
EXPLOSION_OAM_BYTES EQU EXPLOSION_OAM_SPRITES * 4

EXPLOSION_BOMB_TILE_1 EQU $24
EXPLOSION_BOMB_TILE_2 EQU $26

EXPLOSION_CONGRATULATIONS_TILE_1 EQU $66
EXPLOSION_CONGRATULATIONS_TILE_2 EQU $68

EXPLOSION_TIME EQU 10
EXPLOSION_WAIT_TIME EQU %00000011

SECTION "explosion", ROM0

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
    ldh a, [hEnemyAnimationFrame]
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hl], a
    ret

SpawnExplosion::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jr z, .end
.availableSpace:
    ld b, EXPLOSION_OAM_SPRITES
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
    call SetStruct
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
.end:
    pop hl
    ret

ExplosionUpdate::
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
    ldh [hEnemyVariant], a
    ld a, [hl]

.animateExplosion:
    ldh a, [hGlobalTimer]
    and EXPLOSION_WAIT_TIME
    jr nz, .endAnimateExplosion
    ldh a, [hEnemyAnimationFrame]
    inc a
    ldh [hEnemyAnimationFrame], a
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
    inc hl
    inc hl
    inc hl
    ld [hli], a
    inc hl
    inc hl
    inc hl
    or OAMF_XFLIP
    ld [hl], a
    jr .endAnimateExplosion
.clear:
    ld bc, EXPLOSION_OAM_BYTES
    call ClearEnemy
.endAnimateExplosion:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret