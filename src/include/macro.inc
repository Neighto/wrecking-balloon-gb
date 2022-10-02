; General Macros

MACRO RANDOM
    ; argument 1 is range
    ; returns a as # 0-(range-1)
    ld d, \1
    ldh a, [rDIV]
    call MODULO
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

MACRO LD_DE_BC
    ld d, b
    ld e, c
ENDM

MACRO ADD_A_TO_HL
    add a, l ; 1 cycle
    ld l, a ; 1 cycle
    ld a, h ; 1 cycle
    adc a, 0 ; 2 cycles
    ld h, a ; 1 cycle
ENDM

MACRO ADD_TO_HL
    ; argument 1 is value to add to HL (8 bit)
    ld a, \1 ; 2 cycles
    ADD_A_TO_HL
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

MACRO ADD_TO_BC
    ; argument 1 is value to add to BC (8 bit)
    ld a, \1 ; 2 cycles
    add a, c ; 1 cycle
    ld c, a ; 1 cycle
    ld a, b ; 1 cycle
    adc a, 0 ; 2 cycles
    ld b, a ; 1 cycle
ENDM

MACRO SET_BC_TO_ADDRESS
    ; argument 1 is starting address
    ; argument 2 is offset
    ld bc, \1
    ADD_TO_BC [\2]
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

MACRO UPDATE_OAM_POSITION_ENEMY_WITH_OFFSET
    ; argument 1 is # sprites horizontal
    ; argument 2 is # sprites vertical
    ; argument 3 is y offset
    UPDATE_OAM_POSITION_HRAM \1, \2, [hEnemyX], [hEnemyY], \3
ENDM

MACRO IF_HRAM_Z
    ; argument 1 is hram var
    ; argument 2 is compare value
    ; argument 3 is label for zero path
    ldh a, [\1]
    cp a, \2
    jr z, \3
ENDM

MACRO IF_WRAM_Z
    ; argument 1 is wram var
    ; argument 2 is compare value
    ; argument 3 is label for zero path
    ld a, [\1]
    cp a, \2
    jr z, \3
ENDM

; Level Macros

; Level Instructions
LEVEL_SPAWN_KEY EQU 0 
LEVEL_WAIT_KEY EQU 1
LEVEL_WAIT_BOSS_KEY EQU 2
LEVEL_END_KEY EQU 3
GAME_WON_KEY EQU 4
LEVEL_VICTORY_SONG_KEY EQU 5
ENDLESS_KEY EQU 6

MACRO LEVEL_SPAWN
    ; Enemy, Y, X, Variant
    DB LEVEL_SPAWN_KEY, \1, \2, \3, \4
ENDM

MACRO LEVEL_WAIT
    ; Amount of iterations to wait
    DB LEVEL_WAIT_KEY, \1
ENDM

MACRO LEVEL_WAIT_BOSS
    ; Wait until boss is defeated
    DB LEVEL_WAIT_BOSS_KEY
ENDM

MACRO LEVEL_VICTORY_SONG
    ; Change level song to victory song
    DB LEVEL_VICTORY_SONG_KEY
ENDM

MACRO LEVEL_END
    ; Stop reading
    DB LEVEL_END_KEY
ENDM

MACRO GAME_WON
    ; Jump to end cutscene
    DB GAME_WON_KEY
ENDM

; Stage Clear Macros

; Sequence Instructions
SEQUENCE_WAIT_KEY EQU 0 
SEQUENCE_HIDE_PALETTE_KEY EQU 1
SEQUENCE_SHOW_PALETTE_KEY EQU 2
SEQUENCE_END_KEY EQU 3
SEQUENCE_COPY_SCORE_TO_TOTAL_1_KEY EQU 4
SEQUENCE_COPY_SCORE_TO_TOTAL_2_KEY EQU 5
SEQUENCE_ADD_SCORE_LIVES_KEY EQU 6

MACRO SEQUENCE_WAIT
    ; Amount of iterations to wait
    DB SEQUENCE_WAIT_KEY, \1
ENDM

MACRO SEQUENCE_HIDE_PALETTE
    DB SEQUENCE_HIDE_PALETTE_KEY
ENDM

MACRO SEQUENCE_SHOW_PALETTE
    DB SEQUENCE_SHOW_PALETTE_KEY
ENDM

MACRO SEQUENCE_END
    DB SEQUENCE_END_KEY
ENDM

MACRO SEQUENCE_COPY_SCORE_TO_TOTAL_1
    DB SEQUENCE_COPY_SCORE_TO_TOTAL_1_KEY
ENDM

MACRO SEQUENCE_COPY_SCORE_TO_TOTAL_2
    DB SEQUENCE_COPY_SCORE_TO_TOTAL_2_KEY
ENDM

MACRO SEQUENCE_ADD_SCORE_LIVES
    DB SEQUENCE_ADD_SCORE_LIVES_KEY
ENDM

; Timer

MACRO UPDATE_GLOBAL_TIMER
    ldh a, [hGlobalTimer]
    inc	a
    ldh [hGlobalTimer], a
ENDM

MACRO RESET_GLOBAL_TIMER
    xor a ; ld a, 0
    ldh [hGlobalTimer], a
ENDM