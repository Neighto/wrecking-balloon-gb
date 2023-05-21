; *************************************************************
; GENERAL MACROS
; *************************************************************

; Arg: 1 = Range
; Ret: A = 0 - (range - 1)
MACRO RANDOM
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
    add a, l
    ld l, a
    ld a, h
    adc a, 0
    ld h, a
ENDM

; Arg: 1 = Value to add to HL (8 bit)
MACRO ADD_TO_HL
    ld a, \1
    ADD_A_TO_HL
ENDM

; Arg: 1 = Value to add to HL (16 bit)
MACRO ADD_TO_HL_16
    ld a, l
    add a, LOW(\1)
    ld l, a
    ld a, h
    adc a, HIGH(\1)
    ld h, a
ENDM

; Arg: 1 = Value to sub from HL (16 bit)
MACRO SUB_FROM_HL_16
    ld a, l
    sub a, LOW(\1)
    ld l, a
    ld a, h
    sbc a, HIGH(\1)
    ld h, a
ENDM

MACRO ADD_A_TO_BC
    add a, c
    ld c, a
    ld a, b
    adc a, 0
    ld b, a
ENDM

; Arg: 1 = Value to add to BC (8 bit)
MACRO ADD_TO_BC
    ld a, \1
    ADD_A_TO_BC
ENDM

; Arg: 1 = High value r16
; Arg: 2 = Low value r16
; Arg: 3 = Value
MACRO SUB_FROM_R16
    ld a, \2
    sub \3
    ld \2, a
    sbc a
    add \1
    ld \1, a
ENDM

; Arg: 1 = Distance
; Ret: C/NC = Carry / no carry
; Ret: Z/NZ = Zero / not zero
MACRO CP_BC_HL
    xor a ; ld a, 0
    ld d, a ; Will cause zero
    ld e, a
.loop\@:
    ld a, e
    cp a, \1
    jr nz, .compare\@
    ; End
    ld a, 2
    cp a, d
    jr .done\@
.compare\@:
    inc e
    ld a, [bc]
    inc bc
    cp a, [hl]
    inc hl
    jr z, .loop\@
    jr nc, .bigger\@
    ; Smaller
    ld d, 3 ; Will cause carry
    jr .loop\@
.bigger\@:
    ld d, 1 ; Will cause no carry
    jr .loop\@
.done\@:
ENDM

; *************************************************************
; ENEMY MACROS
; *************************************************************

; Arg: 1 = # sprites horizontal
; Arg: 2 = # sprites vertical
; Arg: 3 = X position
; Arg: 4 = Y position
; Arg: 5 = Y offset (where 1 = 16 pixels down, 2 = 32 pixels down, etc)
MACRO UPDATE_OAM_POSITION_HRAM
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

; Arg: 1 = # sprites horizontal
; Arg: 2 = # sprites vertical
MACRO UPDATE_OAM_POSITION_ENEMY
    UPDATE_OAM_POSITION_HRAM \1, \2, [hEnemyX], [hEnemyY], 0
ENDM

; Arg: 1 = # sprites horizontal
; Arg: 2 = # sprites vertical
; Arg: 3 = Y offset
MACRO UPDATE_OAM_POSITION_ENEMY_WITH_OFFSET
    UPDATE_OAM_POSITION_HRAM \1, \2, [hEnemyX], [hEnemyY], \3
ENDM

; *************************************************************
; LEVEL MACROS
; *************************************************************

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

; Arg: 1 = Enemy number
; Arg: 2 = Variant
; Arg: 3 = X
MACRO LVL__SPAWN_BOTTOM
    DB LEVEL_SPAWN_BOTTOM_KEY, \3, (\1 << 4) | \2
ENDM

; Arg: 1 = Enemy number
; Arg: 2 = Variant
; Arg: 3 = Y
MACRO LVL__SPAWN_RIGHT
    DB LEVEL_SPAWN_RIGHT_KEY, \3, (\1 << 4) | \2
ENDM

; Arg: 1 = Enemy number
; Arg: 2 = Variant
; Arg: 3 = Y
MACRO LVL__SPAWN_LEFT
    DB LEVEL_SPAWN_LEFT_KEY, \3, (\1 << 4) | \2
ENDM

; Arg: 1 = Enemy number
; Arg: 2 = Variant
; Arg: 3 = X
MACRO LVL__SPAWN_TOP
    DB LEVEL_SPAWN_TOP_KEY, \3, (\1 << 4) | \2
ENDM

; Arg: 1 = Enemy number
; Arg: 2 = Variant
; Arg: 3 = Y1
; Arg: 4 = X1
; Arg: 5 = Y2 (Must be > Y1)
; Arg: 6 = X2 (Must be > X1)
MACRO LVL__SPAWN_RANDOM
    DB LEVEL_SPAWN_RANDOM_KEY, \3, \4, \5, \6, (\1 << 4) | \2
ENDM

; Level Point Balloon

; Arg: 1 = X
MACRO LVL__POINT_BALLOON_EASY______________
    LVL__SPAWN_BOTTOM POINT_BALLOON, BALLOON_EASY_VARIANT, \1
ENDM

; Arg: 1 = X
MACRO LVL__POINT_BALLOON_MEDIUM____________
    LVL__SPAWN_BOTTOM POINT_BALLOON, BALLOON_MEDIUM_VARIANT, \1
ENDM

; Arg: 1 = X
MACRO LVL__POINT_BALLOON_HARD______________
    LVL__SPAWN_BOTTOM POINT_BALLOON, BALLOON_HARD_VARIANT, \1
ENDM

; Level Balloon Carrier

; Arg: 1 = Y
MACRO LVL__BALLOON_CARRIER_NORMAL_LEFT_____
    LVL__SPAWN_LEFT BALLOON_CARRIER, CARRIER_NORMAL_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BALLOON_CARRIER_NORMAL_RIGHT____
    LVL__SPAWN_RIGHT BALLOON_CARRIER, CARRIER_NORMAL_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BALLOON_CARRIER_PROJECTILE_LEFT_
    LVL__SPAWN_LEFT BALLOON_CARRIER, CARRIER_PROJECTILE_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BALLOON_CARRIER_PROJECTILE_RIGHT
    LVL__SPAWN_RIGHT BALLOON_CARRIER, CARRIER_PROJECTILE_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BALLOON_CARRIER_FOLLOW_LEFT_____
    LVL__SPAWN_LEFT BALLOON_CARRIER, CARRIER_FOLLOW_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BALLOON_CARRIER_FOLLOW_RIGHT____
    LVL__SPAWN_RIGHT BALLOON_CARRIER, CARRIER_FOLLOW_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BALLOON_CARRIER_BOMB_LEFT_______
    LVL__SPAWN_LEFT BALLOON_CARRIER, CARRIER_BOMB_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BALLOON_CARRIER_BOMB_RIGHT______
    LVL__SPAWN_RIGHT BALLOON_CARRIER, CARRIER_BOMB_VARIANT, \1
ENDM

; Level Bird

; Arg: 1 = Y
MACRO LVL__BIRD_EASY_LEFT__________________
    LVL__SPAWN_LEFT BIRD, BIRD_EASY_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BIRD_EASY_RIGHT_________________
    LVL__SPAWN_RIGHT BIRD, BIRD_EASY_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BIRD_HARD_LEFT__________________
    LVL__SPAWN_LEFT BIRD, BIRD_HARD_VARIANT, \1
ENDM

; Arg: 1 = Y
MACRO LVL__BIRD_HARD_RIGHT_________________
    LVL__SPAWN_RIGHT BIRD, BIRD_HARD_VARIANT, \1
ENDM

; Level Bomb

; Arg: 1 = X
MACRO LVL__BOMB_DIRECT_____________________
    LVL__SPAWN_BOTTOM BOMB, BOMB_DIRECT_VARIANT, \1
ENDM

; Arg: 1 = X
MACRO LVL__BOMB_FOLLOW_____________________
    LVL__SPAWN_BOTTOM BOMB, BOMB_FOLLOW_VARIANT, \1
ENDM

; Level Anvil

; Arg: 1 = X
MACRO LVL__ANVIL_NORMAL____________________
    LVL__SPAWN_TOP ANVIL, ANVIL_NORMAL_VARIANT, \1
ENDM

; Arg: 1 = X
MACRO LVL__ANVIL_CACTUS____________________
    LVL__SPAWN_TOP ANVIL, ANVIL_CACTUS_VARIANT, \1
ENDM

; Arg: 1 = X
MACRO LVL__ANVIL_WARNING___________________
    LVL__SPAWN_TOP ANVIL, ANVIL_WARNING_VARIANT, \1
ENDM

; Level Explosion

; Arg: 1 = Y
; Arg: 2 = X
MACRO LVL__EXPLOSION_BOMB__________________
    LVL__SPAWN EXPLOSION, EXPLOSION_BOMB_VARIANT, \1, \2
ENDM

; Arg: 1 = Y
; Arg: 2 = X
MACRO LVL__EXPLOSION_CONGRATULATIONS_______
    LVL__SPAWN EXPLOSION, EXPLOSION_CONGRATULATIONS_VARIANT, \1, \2
ENDM

; Level Other

; Arg: 1 = Amount of iterations to wait
MACRO LVL__WAIT
    DB LEVEL_WAIT_KEY, \1
ENDM

; Waits until boss is defeated
MACRO LVL__WAIT_BOSS
    DB LEVEL_WAIT_BOSS_KEY
ENDM

; Iteration will break if you set address as anywhere other than earlier on in the level data
; Iteration will break if you use nested LVL__REPT
; Arg: 1 = Iterate this many times
; Arg: 2 = Jump to this address
MACRO LVL__REPT
    DB LEVEL_REPEAT_KEY, \1, LOW(\2), HIGH(\2)
ENDM

; Change level song to victory song
MACRO LVL__VICTORY_SONG
    DB LEVEL_VICTORY_SONG_KEY
ENDM

; Grant some points for remaining player lives
MACRO LVL__POINTS_FOR_LIVES
    DB LEVEL_POINTS_FOR_LIVES_KEY
ENDM

; Stop reading
MACRO LVL__END
    DB LEVEL_END_KEY
ENDM

; Jump to end cutscene
MACRO LVL__GAME_WON
    DB GAME_WON_KEY
ENDM

; *************************************************************
; CUTSCENE MACROS
; *************************************************************

; Sequence Instructions
SEQUENCE_WAIT_KEY EQU 0 
SEQUENCE_WAIT_UNTIL_KEY EQU 1
SEQUENCE_PALETTE_FADE_IN_KEY EQU 2
SEQUENCE_PALETTE_FADE_OUT_KEY EQU 3
SEQUENCE_HIDE_PALETTE_KEY EQU 4
SEQUENCE_SHOW_PALETTE_KEY EQU 5
SEQUENCE_SHOW_PALETTE_2_KEY EQU 6
SEQUENCE_INCREASE_PHASE_KEY EQU 7
SEQUENCE_PLAY_SONG_KEY EQU 8
SEQUENCE_END_KEY EQU 9

; Arg: 1 = Amount of iterations to wait
MACRO SEQUENCE_WAIT
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

MACRO SEQUENCE_SHOW_PALETTE_2
    DB SEQUENCE_SHOW_PALETTE_2_KEY
ENDM

; Arg: 1 = Jump to address
MACRO SEQUENCE_END
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

; *************************************************************
; TIMER MACROS
; *************************************************************

MACRO UPDATE_GLOBAL_TIMER
    ldh a, [hGlobalTimer]
    inc	a
    ldh [hGlobalTimer], a
ENDM

MACRO RESET_GLOBAL_TIMER
    xor a ; ld a, 0
    ldh [hGlobalTimer], a
ENDM

; *************************************************************
; COLLISION MACROS
; *************************************************************


; Arg: 1 = Which collider
; Arg: 2 = Y Pos Var
; Arg: 3 = X Pos Var
; Arg: 4 = Y1
; Arg: 5 = Y2
; Arg: 6 = X1
; Arg: 7 = X2
MACRO SETUP_COLLIDER
    ld hl, \1
    ; Y1
    ld a, \2
IF \4 == 1
    inc a
ELIF \4 != 0
    add \4
ENDC
    ld [hli], a
    ; Y2
    add \5
    ld [hli], a
    ; X1
    ld a, \3
IF \6 == 1
    inc a
ELIF \6 != 0
    add \6
ENDC
    ld [hli], a
    ; X2
    add \7
    ld [hl], a
ENDM

; Arg: 1 = Y1
; Arg: 2 = Y2
; Arg: 3 = X1
; Arg: 4 = X2
MACRO SETUP_ENEMY_COLLIDER
    SETUP_COLLIDER wColliderA, [hEnemyY], [hEnemyX], \1, \2, \3, \4
ENDM

; Arg: 1 = Y1
; Arg: 2 = Y2
; Arg: 3 = X1
; Arg: 4 = X2
MACRO SETUP_PLAYER_BALLOON_COLLIDER
    SETUP_COLLIDER wColliderB, [hPlayerY], [hPlayerX], \1, \2, \3, \4
ENDM

; Arg: 1 = Y1
; Arg: 2 = Y2
; Arg: 3 = X1
; Arg: 4 = X2
MACRO SETUP_PLAYER_CACTUS_COLLIDER
    SETUP_COLLIDER wColliderB, [hPlayerY2], [hPlayerX2], \1, \2, \3, \4
ENDM

; Arg: 1 = Y1
; Arg: 2 = Y2
; Arg: 3 = X1
; Arg: 4 = X2
MACRO SETUP_BULLET_COLLIDER
    SETUP_COLLIDER wColliderB, [hPlayerBulletY], [hPlayerBulletX], \1, \2, \3, \4
ENDM

; Arg: 1 = Y1
; Arg: 2 = Y2
; Arg: 3 = X1
; Arg: 4 = X2
MACRO SETUP_BOSS_COLLIDER
    SETUP_COLLIDER wColliderB, [hBossY], [hBossX], \1, \2, \3, \4
ENDM