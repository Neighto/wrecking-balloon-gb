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
    ldh a, [hEnemyParam1] ; Enemy Falling Timer
    ld [hli], a
    ldh a, [hEnemyParam2] ; Enemy Delay Falling Timer
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
    ldh [hEnemySpeed], a
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.anvilLeftOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ld a, [hEnemyX]
    ld [hli], a
    ld a, ANVIL_TILE_1
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
.anvilRightOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
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
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
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
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ldh [hEnemyOAM], a
    ld a, [hli]
    ldh [hEnemySpeed], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hl]
    ldh [hEnemyParam2], a

.fallingSpeed:
    ldh a, [hEnemyParam1]
    inc a
    ldh [hEnemyParam1], a
    and CACTUS_FALLING_TIME
    jr nz, .endFallingSpeed
.canFall:
    ldh a, [hEnemyParam2]
    inc a
    ldh [hEnemyParam2], a
    cp a, CACTUS_DELAY_FALLING_TIME
    jr c, .skipAcceleration
.accelerate:
    xor a ; ld a, 0
    ldh [hEnemyParam2], a
    ldh a, [hEnemySpeed]
    add a, a
    ldh [hEnemySpeed], a
.skipAcceleration:
    INCREMENT_POS hEnemyY, [hEnemySpeed]
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
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
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