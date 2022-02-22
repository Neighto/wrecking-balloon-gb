INCLUDE "hardware.inc"
INCLUDE "balloonConstants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

PORCUPINE_OAM_SPRITES EQU 8
PORCUPINE_OAM_BYTES EQU PORCUPINE_OAM_SPRITES * 4
POINT_BALLOON_MOVE_TIME EQU %00000001
POINT_BALLOON_COLLISION_TIME EQU %00001000

PORCUPINE_TILE_1 EQU $42
PORCUPINE_TILE_2 EQU $44
PORCUPINE_TILE_3 EQU $46
PORCUPINE_TILE_4 EQU $48
PORCUPINE_TILE_5 EQU $4A
PORCUPINE_TILE_6 EQU $4C
PORCUPINE_TILE_7 EQU $4E

SECTION "porcupine", ROMX

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
    ld a, [wEnemyAlive]
    ld [hl], a
    ret

SpawnPorcupine::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    cp a, 0
    jp z, .end
.availableSpace:
    ld b, PORCUPINE_OAM_SPRITES
	call RequestOAMSpace ; b now contains OAM address
    cp a, 0
    jp z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ld [wEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyAlive], a
    ld a, PORCUPINE 
    ld [wEnemyNumber], a
.topLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], PORCUPINE_TILE_1
    inc l
    ld [hl], OAMF_PAL0
.topMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], PORCUPINE_TILE_3
    inc l
    ld [hl], OAMF_PAL0
.topMiddle2:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], PORCUPINE_TILE_5
    inc l
    ld [hl], OAMF_PAL0
.topRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], PORCUPINE_TILE_7
    inc l
    ld [hl], OAMF_PAL0
.bottomLeft:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], PORCUPINE_TILE_2
    inc l
    ld [hl], OAMF_PAL0
.bottomMiddle:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], PORCUPINE_TILE_4
    inc l
    ld [hl], OAMF_PAL0
.bottomMiddle2:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], PORCUPINE_TILE_6
    inc l
    ld [hl], OAMF_PAL0
.bottomRight:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], EMPTY_TILE
    inc l
    ld [hl], OAMF_PAL0
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

PorcupineUpdate::
    ; Get rest of struct
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, [hli]
    ld [wEnemyOAM], a
    ld a, [hli]
    ld [wEnemyAlive], a    
    ; Check alive
    ld a, [wEnemyAlive]
    cp a, 0
    jr z, .isDead
.isAlive:
    ; Do stuff
.offScreen:
    ; call Clear
    jr .checkLoop
.isDead:
    ; Do stuff
.checkLoop:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret