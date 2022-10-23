INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"
INCLUDE "playerConstants.inc"

ANVIL_OAM_SPRITES EQU 2
ANVIL_OAM_BYTES EQU ANVIL_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
ANVIL_DEAD_BLINKING_TIME EQU %00000011
ANVIL_DEAD_BLINKING_DURATION EQU 20

ANVIL_FALLING_SPEED_DELAY EQU 3

ANVIL_INITIAL_SPEED EQU 4
CACTUS_INITIAL_SPEED EQU 1

CACTUS_SCREAMING_TILE EQU $2E

; hEnemyParam1 = Speed
; hEnemyParam2 = Animation Timer

SECTION "anvil", ROMX

; SPAWN
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
    ; Initialize
    call InitializeEnemyStructVars
    ld a, b
    ldh [hEnemyOAM], a
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    ldh [hEnemyFlags], a
.variantSpeed:
    ldh a, [hEnemyVariant]
.cactusSpeed:
    cp a, ANVIL_CACTUS_VARIANT
    jr nz, .anvilSpeed
    ld a, CACTUS_INITIAL_SPEED
    jr .endVariantSpeed
.anvilSpeed:
    ld a, ANVIL_INITIAL_SPEED
.endVariantSpeed:
    ldh [hEnemyParam1], a
    ; Get hl pointing to OAM address
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
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
    jp SetEnemyStruct

; UPDATE
AnvilUpdate::

.checkDying:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DYING_MASK
    jr z, .endCheckDying
    ldh a, [hEnemyParam2]
    inc a
    ldh [hEnemyParam2], a
    cp a, ANVIL_DEAD_BLINKING_DURATION
    jr c, .animateDying
.clear:
    ld bc, ANVIL_OAM_BYTES
    call ClearEnemy
    jp .setStruct
.animateDying:
    and ANVIL_DEAD_BLINKING_TIME
    jp nz, .setStruct
    ld hl, wOAM+2
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld a, [hl]
    cp a, EMPTY_TILE
    jr z, .blinkOn
.blinkOff:
    ld a, EMPTY_TILE
    ld [hli], a
    inc l
    inc l
    inc l
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
    inc l
    inc l
    inc l
    ld a, e
    ld [hli], a
    jp .setStruct
.endCheckDying:

.checkMove:
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
.setOAM:
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    UPDATE_OAM_POSITION_ENEMY 2, 1
.endMove:

.checkCollision:
    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .checkHitAnotherEnemy
.checkHit:
    ld bc, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_BC
    ld hl, wPlayerBalloonOAM
    ld d, PLAYER_BALLOON_WIDTH
    ld e, PLAYER_BALLOON_HEIGHT
    call CollisionCheck
    jr z, .checkHitAnotherEnemy
    call CollisionWithPlayer
    jr .hitSomething
.checkHitAnotherEnemy:
    call EnemyInterCollision
    jr nz, .hitSomething
.checkHitBoss:
    ld a, [wLevel]
    cp a, BOSS_LEVEL
    jr nz, .endCollision
    ldh a, [hEnemyVariant]
    cp a, ANVIL_NORMAL_VARIANT
    jr nz, .endCollision
    ld hl, wOAM
    LD_BC_HL ; ld bc, wOAM
    ldh a, [hBossOAM]
    ADD_A_TO_HL
    ldh a, [hEnemyOAM]
    ADD_A_TO_BC
    ld d, 32
    ld e, 24
    call CollisionCheck
    jr z, .endCollision
    call CollisionWithBoss
.hitSomething:
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
.endCollision:

.checkOffscreen:
    ld bc, ANVIL_OAM_BYTES
    call HandleEnemyOffscreenVertical
    ; Enemy may be cleared, must do setStruct next
.endOffscreen:

.setStruct:
    ld hl, wEnemies
    ADD_TO_HL [wEnemyOffset]
    jp SetEnemyStruct