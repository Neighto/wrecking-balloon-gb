INCLUDE "hardware.inc"
INCLUDE "balloonConstants.inc"
INCLUDE "macro.inc"

PORCUPINE_STRUCT_SIZE EQU 5
PORCUPINE_STRUCT_AMOUNT EQU 1
PORCUPINE_DATA_SIZE EQU PORCUPINE_STRUCT_SIZE * PORCUPINE_STRUCT_AMOUNT
PORCUPINE_OAM_SPRITES EQU 8
PORCUPINE_OAM_BYTES EQU PORCUPINE_OAM_SPRITES * 4
POINT_BALLOON_MOVE_TIME EQU %00000001
POINT_BALLOON_COLLISION_TIME EQU %00001000

SECTION "porcupine vars", WRAM0
    porcupine:: DS PORCUPINE_DATA_SIZE

SECTION "porcupine", ROMX

InitializePorcupine::
    push hl
    push bc
    RESET_IN_RANGE porcupine, PORCUPINE_DATA_SIZE
    pop bc
    pop hl
    ret

SetStruct:
    ; Argument hl = start of free enemy struct
    ld a, [wEnemyActive]
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
    push af
    push hl
    push de
    push bc
    ld hl, porcupine
    ld d, PORCUPINE_STRUCT_AMOUNT
    ld e, PORCUPINE_STRUCT_SIZE
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
.topLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], $D0
    inc l
    ld [hl], OAMF_PAL0
.topMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], $D4
    inc l
    ld [hl], OAMF_PAL0
.topMiddle2:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], $D8
    inc l
    ld [hl], OAMF_PAL0
.topRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 24
    ld [hli], a
    ld [hl], $DC
    inc l
    ld [hl], OAMF_PAL0
.bottomLeft:
    inc l
    ld a, [wEnemyY]
    add 16
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], $D2
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
    ld [hl], $D6
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
    ld [hl], $DA
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
    ld [hl], $DE
    inc l
    ld [hl], OAMF_PAL0
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop bc
    pop de
    pop hl
    pop af
    ret

PorcupineUpdate::
    ld bc, PORCUPINE_STRUCT_AMOUNT
    xor a ; ld a, 0
    ld [wEnemyOffset], a
.loop:
    ; Get active state
    SET_HL_TO_ADDRESS porcupine, wEnemyOffset
    ld a, [hli]
    ld [wEnemyActive], a
    ; Check active
    ld a, [wEnemyActive]
    cp a, 0
    jr z, .checkLoopSkipSet
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
    SET_HL_TO_ADDRESS porcupine, wEnemyOffset
    call SetStruct
.checkLoopSkipSet:
    ld a, [wEnemyOffset]
    add a, PORCUPINE_STRUCT_SIZE
    ld [wEnemyOffset], a    
    dec bc
    ld a, b
    or a, c
    jr nz, .loop
    ret