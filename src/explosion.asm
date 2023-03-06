INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "tileConstants.inc"

EXPLOSION_OAM_SPRITES EQU 3
EXPLOSION_OAM_BYTES EQU EXPLOSION_OAM_SPRITES * 4
EXPLOSION_WAIT_TIME EQU %00000011
EXPLOSION_BLINK_TIME EQU %00000001
EXPLOSION_DURATION EQU 9

; hEnemyParam1 = Animation Frame

SECTION "explosion", ROMX

; *************************************************************
; SPAWN
; *************************************************************
SpawnExplosion::
    ld b, EXPLOSION_OAM_SPRITES
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
    ; Get hl pointing to OAM address
    ;
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ;
    ; Get variant visual
    ;
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
    ;
    ; Explosion OAM
    ;
    ; Left
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ; Middle
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, e
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    ; Right
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    ld [hl], a
    ;
    ; Set struct
    ;
    LD_HL_BC
    call SetEnemyStruct
.variantSound:
    ldh a, [hEnemyVariant]
    cp a, EXPLOSION_BOMB_VARIANT
    jp nz, FireworkSound
    jp ExplosionSound

; *************************************************************
; UPDATE
; *************************************************************
ExplosionUpdate::

    ;
    ; Animate explosion
    ;
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and EXPLOSION_WAIT_TIME
    jr nz, .endAnimateExplosion
    ; Can update explosion
    ldh a, [hEnemyParam1]
    inc a
    ldh [hEnemyParam1], a
    cp a, EXPLOSION_DURATION
    jr nc, .clear
    ; Still exploding
    ld hl, wOAM+2
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ldh a, [hEnemyParam1]
    and EXPLOSION_BLINK_TIME
    jr z, .hideExplosion

    ; Show explosion
.showExplosion:
    ; Update palette
    LD_DE_HL
    inc l
    ld a, [hl]
    ld b, OAMF_PAL0
    cp a, b
    jr nz, .paletteCommon
.palette1:
    ld b, OAMF_PAL1
.paletteCommon:
    ld a, b
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
    LD_HL_DE
    ; Update visual
    ldh a, [hEnemyVariant]
.bombVisual:
    cp a, EXPLOSION_BOMB_VARIANT
    jr nz, .congratulationsVisual
    ld b, EXPLOSION_BOMB_TILE_1
    ld c, EXPLOSION_BOMB_TILE_2
    jr .endVariantVisual
.congratulationsVisual:
    ; cp a, EXPLOSION_CONGRATULATIONS_VARIANT
    ; jr nz, .endVariantVisual
    ld b, EXPLOSION_CONGRATULATIONS_TILE_1
    ld c, EXPLOSION_CONGRATULATIONS_TILE_2
.endVariantVisual:
    jr .updateExplosion

    ; Hide explosion
.hideExplosion:
    ld b, WHITE_SPR_TILE
    ld c, b

    ; Update explosion
.updateExplosion:
    ld a, b
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, c
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, b
    ld [hl], a
    jr .endAnimateExplosion
.clear:
    ld bc, EXPLOSION_OAM_BYTES
    call ClearEnemy
    ; jr .setStruct
.endAnimateExplosion:

    ;
    ; Set struct
    ;
.setStruct:
    ld hl, wEnemies
    ldh a, [hEnemyOffset]
    ADD_A_TO_HL
    jp SetEnemyStruct