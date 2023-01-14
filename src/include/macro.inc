; GENERAL MACROS ****

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

MACRO ADD_A_TO_BC
    add a, c ; 1 cycle
    ld c, a ; 1 cycle
    ld a, b ; 1 cycle
    adc a, 0 ; 2 cycles
    ld b, a ; 1 cycle
ENDM

MACRO ADD_TO_BC
    ; argument 1 is value to add to BC (8 bit)
    ld a, \1 ; 2 cycles
    ADD_A_TO_BC
ENDM

; ENEMY MACROS ****

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

; LEVEL MACROS ****

; Level Instructions
LEVEL_SPAWN_BOTTOM_KEY EQU 0
LEVEL_SPAWN_LEFT_KEY EQU 1
LEVEL_SPAWN_RIGHT_KEY EQU 2
LEVEL_SPAWN_TOP_KEY EQU 3
LEVEL_SPAWN_RANDOM_KEY EQU 4
LEVEL_WAIT_KEY EQU 5
LEVEL_WAIT_BOSS_KEY EQU 6
LEVEL_REPEAT_KEY EQU 7
LEVEL_VICTORY_SONG_KEY EQU 8
LEVEL_POINTS_FOR_LIVES_KEY EQU 9
LEVEL_END_KEY EQU 10
GAME_WON_KEY EQU 11

MACRO LVL__SPAWN_BOTTOM
    ; \1 = Enemy Number
    ; \2 = Variant
    ; \3 = X
    DB LEVEL_SPAWN_BOTTOM_KEY, \3, (\1 << 4) | \2
ENDM

MACRO LVL__SPAWN_RIGHT
    ; \1 = Enemy Number
    ; \2 = Variant
    ; \3 = Y
    DB LEVEL_SPAWN_RIGHT_KEY, \3, (\1 << 4) | \2
ENDM

MACRO LVL__SPAWN_LEFT
    ; \1 = Enemy Number
    ; \2 = Variant
    ; \3 = Y
    DB LEVEL_SPAWN_LEFT_KEY, \3, (\1 << 4) | \2
ENDM

MACRO LVL__SPAWN_TOP
    ; \1 = Enemy Number
    ; \2 = Variant
    ; \3 = X
    DB LEVEL_SPAWN_TOP_KEY, \3, (\1 << 4) | \2
ENDM

; Y2 and X2 must be larger than Y1 and X1 respectively
MACRO LVL__SPAWN_RANDOM
    ; \1 = Enemy
    ; \2 = Variant
    ; \3 = Y1
    ; \4 = X1
    ; \5 = Y2
    ; \6 = X2
    DB LEVEL_SPAWN_RANDOM_KEY, \3, \4, \5, \6, (\1 << 4) | \2
ENDM

; Level Point Balloon

MACRO LVL__POINT_BALLOON_EASY______________
    ; \1 = X
    LVL__SPAWN_BOTTOM POINT_BALLOON, BALLOON_EASY_VARIANT, \1
ENDM

MACRO LVL__POINT_BALLOON_MEDIUM____________
    ; \1 = X
    LVL__SPAWN_BOTTOM POINT_BALLOON, BALLOON_MEDIUM_VARIANT, \1
ENDM

MACRO LVL__POINT_BALLOON_HARD______________
    ; \1 = X
    LVL__SPAWN_BOTTOM POINT_BALLOON, BALLOON_HARD_VARIANT, \1
ENDM

; Level Balloon Carrier

MACRO LVL__BALLOON_CARRIER_NORMAL_LEFT_____
    ; \1 = Y
    LVL__SPAWN_LEFT BALLOON_CARRIER, CARRIER_NORMAL_VARIANT, \1
ENDM

MACRO LVL__BALLOON_CARRIER_NORMAL_RIGHT____
    ; \1 = Y
    LVL__SPAWN_RIGHT BALLOON_CARRIER, CARRIER_NORMAL_VARIANT, \1
ENDM

MACRO LVL__BALLOON_CARRIER_PROJECTILE_LEFT_
    ; \1 = Y
    LVL__SPAWN_LEFT BALLOON_CARRIER, CARRIER_PROJECTILE_VARIANT, \1
ENDM

MACRO LVL__BALLOON_CARRIER_PROJECTILE_RIGHT
    ; \1 = Y
    LVL__SPAWN_RIGHT BALLOON_CARRIER, CARRIER_PROJECTILE_VARIANT, \1
ENDM

MACRO LVL__BALLOON_CARRIER_FOLLOW_LEFT_____
    ; \1 = Y
    LVL__SPAWN_LEFT BALLOON_CARRIER, CARRIER_FOLLOW_VARIANT, \1
ENDM

MACRO LVL__BALLOON_CARRIER_FOLLOW_RIGHT____
    ; \1 = Y
    LVL__SPAWN_RIGHT BALLOON_CARRIER, CARRIER_FOLLOW_VARIANT, \1
ENDM

MACRO LVL__BALLOON_CARRIER_BOMB_LEFT_______
    ; \1 = Y
    LVL__SPAWN_LEFT BALLOON_CARRIER, CARRIER_BOMB_VARIANT, \1
ENDM

MACRO LVL__BALLOON_CARRIER_BOMB_RIGHT______
    ; \1 = Y
    LVL__SPAWN_RIGHT BALLOON_CARRIER, CARRIER_BOMB_VARIANT, \1
ENDM

; Level Bird

MACRO LVL__BIRD_EASY_LEFT__________________
    ; \1 = Y
    LVL__SPAWN_LEFT BIRD, BIRD_EASY_VARIANT, \1
ENDM

MACRO LVL__BIRD_EASY_RIGHT_________________
    ; \1 = Y
    LVL__SPAWN_RIGHT BIRD, BIRD_EASY_VARIANT, \1
ENDM

MACRO LVL__BIRD_HARD_LEFT__________________
    ; \1 = Y
    LVL__SPAWN_LEFT BIRD, BIRD_HARD_VARIANT, \1
ENDM

MACRO LVL__BIRD_HARD_RIGHT_________________
    ; \1 = Y
    LVL__SPAWN_RIGHT BIRD, BIRD_HARD_VARIANT, \1
ENDM

; Level Bomb

MACRO LVL__BOMB_DIRECT_____________________
    ; \1 = X
    LVL__SPAWN_BOTTOM BOMB, BOMB_DIRECT_VARIANT, \1
ENDM

MACRO LVL__BOMB_FOLLOW_____________________
    ; \1 = X
    LVL__SPAWN_BOTTOM BOMB, BOMB_FOLLOW_VARIANT, \1
ENDM

; Level Anvil

MACRO LVL__ANVIL_NORMAL____________________
    ; \1 = X
    LVL__SPAWN_TOP ANVIL, ANVIL_NORMAL_VARIANT, \1
ENDM

MACRO LVL__ANVIL_CACTUS____________________
    ; \1 = X
    LVL__SPAWN_TOP ANVIL, ANVIL_CACTUS_VARIANT, \1
ENDM

MACRO LVL__ANVIL_WARNING___________________
    ; \1 = X
    LVL__SPAWN_TOP ANVIL, ANVIL_WARNING_VARIANT, \1
ENDM

; Level Explosion

; MACRO LVL__EXPLOSION_BOMB__________________
;     ; \1 = Y
;     ; \2 = X
;     LVL__SPAWN EXPLOSION, EXPLOSION_BOMB_VARIANT, \1, \2
; ENDM

; MACRO LVL__EXPLOSION_CONGRATULATIONS_______
;     ; \1 = Y
;     ; \2 = X
;     LVL__SPAWN EXPLOSION, EXPLOSION_CONGRATULATIONS_VARIANT, \1, \2
; ENDM

; Level Other

MACRO LVL__WAIT
    ; \1 = Amount of iterations to wait
    DB LEVEL_WAIT_KEY, \1
ENDM

MACRO LVL__WAIT_BOSS
    ; Wait until boss is defeated
    DB LEVEL_WAIT_BOSS_KEY
ENDM

; Iteration will break if you set address as anywhere other than earlier on in the level data
; Iteration will break if you use nested LVL__REPT
MACRO LVL__REPT
    ; \1 = Iterate this many times
    ; \2 = Jump to this address
    DB LEVEL_REPEAT_KEY, \1, LOW(\2), HIGH(\2)
ENDM

MACRO LVL__VICTORY_SONG
    ; Change level song to victory song
    DB LEVEL_VICTORY_SONG_KEY
ENDM

MACRO LVL__POINTS_FOR_LIVES
    ; Grant some points for remaining player lives
    DB LEVEL_POINTS_FOR_LIVES_KEY
ENDM

MACRO LVL__END
    ; Stop reading
    DB LEVEL_END_KEY
ENDM

MACRO LVL__GAME_WON
    ; Jump to end cutscene
    DB GAME_WON_KEY
ENDM

; CUTSCENE MACROS ****

; Sequence Instructions
SEQUENCE_WAIT_KEY EQU 0 
SEQUENCE_WAIT_UNTIL_KEY EQU 1
SEQUENCE_PALETTE_FADE_IN_KEY EQU 2
SEQUENCE_PALETTE_FADE_OUT_KEY EQU 3
SEQUENCE_HIDE_PALETTE_KEY EQU 4
SEQUENCE_SHOW_PALETTE_KEY EQU 5
SEQUENCE_INCREASE_PHASE_KEY EQU 6
SEQUENCE_PLAY_SONG_KEY EQU 7
SEQUENCE_END_KEY EQU 8

MACRO SEQUENCE_WAIT
    ; \1 = Amount of iterations to wait
    DB SEQUENCE_WAIT_KEY, \1
ENDM

MACRO SEQUENCE_WAIT_UNTIL
    DB SEQUENCE_WAIT_UNTIL_KEY
ENDM

MACRO SEQUENCE_HIDE_PALETTE
    DB SEQUENCE_HIDE_PALETTE_KEY
ENDM

MACRO SEQUENCE_SHOW_PALETTE
    DB SEQUENCE_SHOW_PALETTE_KEY
ENDM

MACRO SEQUENCE_END
    ; \1 = Jump to address
    DB SEQUENCE_END_KEY, HIGH(\1), LOW(\1)
ENDM

MACRO SEQUENCE_FADE_IN_PALETTE
    DB SEQUENCE_PALETTE_FADE_IN_KEY
ENDM

MACRO SEQUENCE_FADE_OUT_PALETTE
    DB SEQUENCE_PALETTE_FADE_OUT_KEY
ENDM

MACRO SEQUENCE_INCREASE_PHASE
    DB SEQUENCE_INCREASE_PHASE_KEY
ENDM

MACRO SEQUENCE_PLAY_SONG
    DB SEQUENCE_PLAY_SONG_KEY
ENDM

; TIMER MACROS ****

MACRO UPDATE_GLOBAL_TIMER
    ldh a, [hGlobalTimer]
    inc	a
    ldh [hGlobalTimer], a
ENDM

MACRO RESET_GLOBAL_TIMER
    xor a ; ld a, 0
    ldh [hGlobalTimer], a
ENDM