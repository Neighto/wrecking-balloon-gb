INCLUDE "balloonConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

ANVIL_OAM_SPRITES EQU 2
ANVIL_MOVE_TIME EQU %00000001
ANVIL_COLLISION_TIME EQU %00001000

ANVIL_TILE_1 EQU $5E
ANVIL_TILE_2 EQU $60

SECTION "anvil", ROMX

SetStruct:
    ; Argument hl = start of free enemy struct
    ld a, [wEnemyActive]
    ld [hli], a
    ld a, [wEnemyNumber]
    ld [hli], a
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld a, [wEnemyOAM]
    ld [hli], a
    ld a, [wEnemyFallingSpeed]
    ld [hli], a
    ld a, [wEnemyFallingTimer]
    ld [hli], a
    ld a, [wEnemyDelayFallingTimer]
    ld [hl], a
    ret

SpawnAnvil::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    cp a, 0
    jr z, .end
.availableSpace:
    ld b, ANVIL_OAM_SPRITES
	call RequestOAMSpace ; b now contains OAM address
    cp a, 0
    jr z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ld [wEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyFallingSpeed], a
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM

.anvilLeftOAM:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld a, ANVIL_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.anvilRightOAM:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld a, ANVIL_TILE_2
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

Clear:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    call InitializeEnemyStructVars
    ret

AnvilUpdate::
    ; Get rest of struct
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, [hli]
    ld [wEnemyOAM], a
    ld a, [hli]
    ld [wEnemyFallingSpeed], a
    ld a, [hli]
    ld [wEnemyFallingTimer], a
    ld a, [hl]
    ld [wEnemyDelayFallingTimer], a

.fallingSpeed:
    ld hl, wEnemyFallingTimer
    inc [hl]
    ld a, [hl]
    and CACTUS_FALLING_TIME
    jr nz, .endFallingSpeed
.canFall:
    ld hl, wEnemyDelayFallingTimer
    inc [hl]
    ld a, [hl]
    cp a, CACTUS_DELAY_FALLING_TIME
    jr c, .skipAcceleration
.accelerate:
    xor a ; ld a, 0
    ld [wEnemyDelayFallingTimer], a
    ld a, [wEnemyFallingSpeed]
    add a, a
    ld [wEnemyFallingSpeed], a
.skipAcceleration:
    INCREMENT_POS wEnemyY, [wEnemyFallingSpeed]
.anvilLeftOAM:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    inc l
    inc l
    inc l
.anvilRightOAM:
    ld a, [wEnemyY]
    ld [hl], a
.endFallingSpeed:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	ANVIL_COLLISION_TIME
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerBalloonOAM ; Cactus too?
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld d, 16
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet
.endCollision:

.checkOffscreen:
    ld a, [wEnemyY]
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