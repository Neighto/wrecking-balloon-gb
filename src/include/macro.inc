; General Macros

MACRO INCREMENT_POS
    ; argument 1 is address
    ; argument 2 is amount
    ld hl, \1
    ld a, \2
    add [hl]
    ld [hl], a
ENDM

MACRO DECREMENT_POS
    ; argument 1 is address
    ; argument 2 is amount
    ld hl, \1
    ld a, \2
    cpl
    inc a
    add [hl]
    ld [hl], a
ENDM

; Use with caution: Overwrites hl and bc
MACRO RESET_AT_HL
    ; argument 1 is distance
    ld bc, \1
    push af
.loop\@:
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop\@
    pop af
ENDM

; Use with caution: Overwrites hl and bc
MACRO RESET_IN_RANGE
    ; argument 1 is starting address
    ; argument 2 is distance
    ld hl, \1
    RESET_AT_HL \2
ENDM

; Use with caution: Overwrites hl and bc, and d
MACRO SET_IN_RANGE
    ; argument 1 is starting address
    ; argument 2 is distance
    ; argument 3 is value
    ld hl, \1
    ld bc, \2
    ld d, \3
    push af
.loop\@:
    ld a, d
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop\@
    pop af
ENDM

MACRO LD_BC_HL
    ld b, h
    ld c, l
ENDM

MACRO LD_DE_HL
    ld d, h
    ld e, l
ENDM

MACRO LD_HL_BC
    ld h, b 
    ld l, c
ENDM

MACRO LD_HL_DE
    ld h, d
    ld l, e
ENDM

MACRO LD_BC_DE
    ld b, d
    ld c, e
ENDM

MACRO ADD_TO_HL
    ; argument 1 is value to add to HL (8 bit)
    ld a, \1 ; 2 cycles
    add a, l ; 1 cycle
    ld l, a ; 1 cycle
    ld a, h ; 1 cycle
    adc a, 0 ; 2 cycles
    ld h, a ; 1 cycle
ENDM

MACRO ADD_TO_HL_16
    ; argument 1 is value to add to HL (16 bit)
    ld a, l ; 1 cycle
    add a, LOW(\1) ; 2 cycles
    ld l, a ; 1 cycle
    ld a, h ; 1 cycle
    adc a, HIGH(\1) ; 2 cycles
    ld h, a ; 1 cycle
ENDM

MACRO SUB_FROM_HL_16
    ; argument 1 is value to sub from HL (16 bit)
    ld a, l
    sub a, LOW(\1)
    ld l, a
    ld a, h
    sbc a, HIGH(\1)
    ld h, a
ENDM

MACRO SET_HL_TO_ADDRESS
    ; argument 1 is starting address
    ; argument 2 is offset
    ld hl, \1
    ADD_TO_HL [\2]
ENDM

MACRO UPDATE_OAM_POSITION_HRAM
    ; argument 1 is # sprites horizontal
    ; argument 2 is # sprites vertical
    ; argument 3 is x position
    ; argument 4 is y position
    ; argument 5 is y offset (where 1 = 16 pixels down, 2 = 32 pixels down, etc)
REPT_NUMBER_X SET 0
REPT_NUMBER_Y SET \5
REPT \2
REPT \1
    ldh a, \4
IF REPT_NUMBER_Y != 0
    add 16 * REPT_NUMBER_Y
ENDC
    ld [hli], a
    ldh a, \3
IF REPT_NUMBER_X != 0
    add 8 * REPT_NUMBER_X
ENDC
    ld [hli], a
    inc l
    inc l
REPT_NUMBER_X SET REPT_NUMBER_X + 1
ENDR
REPT_NUMBER_X SET 0
REPT_NUMBER_Y SET REPT_NUMBER_Y + 1
ENDR
ENDM

MACRO UPDATE_OAM_POSITION_ENEMY
    ; argument 1 is # sprites horizontal
    ; argument 2 is # sprites vertical
    UPDATE_OAM_POSITION_HRAM \1, \2, [hEnemyX], [hEnemyY], 0
ENDM

MACRO UPDATE_OAM_POSITION_ENEMY2
    ; argument 1 is # sprites horizontal
    ; argument 2 is # sprites vertical
    UPDATE_OAM_POSITION_HRAM \1, \2, [hEnemyX2], [hEnemyY2], 0
ENDM

MACRO UPDATE_OAM_POSITION_ENEMY_WITH_OFFSET
    ; argument 1 is # sprites horizontal
    ; argument 2 is # sprites vertical
    ; argument 3 is y offset
    UPDATE_OAM_POSITION_HRAM \1, \2, [hEnemyX], [hEnemyY], \3
ENDM

; Level Macros

; Level Instructions
LEVEL_SPAWN_KEY EQU 0 
LEVEL_WAIT_KEY EQU 1
LEVEL_END_KEY EQU 2
GAME_WON_KEY EQU 3

MACRO LEVEL_SPAWN
    ; Enemy, Y, X, Difficulty
    DB LEVEL_SPAWN_KEY, \1, \2, \3, \4
ENDM

MACRO LEVEL_WAIT
    ; Amount of iterations to wait
    DB LEVEL_WAIT_KEY, \1
ENDM

MACRO LEVEL_END
    ; Stop reading
    DB LEVEL_END_KEY
ENDM

MACRO GAME_WON
    ; Jump to end cutscene
    DB GAME_WON_KEY
ENDM

; Timer

MACRO UPDATE_GLOBAL_TIMER
    ldh a, [hGlobalTimer]
    inc	a
    ldh [hGlobalTimer], a
ENDM