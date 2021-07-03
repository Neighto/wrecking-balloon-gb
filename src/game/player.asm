INCLUDE "hardware.inc"

SECTION "player", ROMX

PLAYER_START_X EQU (160 / 2 - 20)
PLAYER_START_Y EQU (144 / 2 + 16)
PLAYER_MAX_VEL EQU $04

player_sprite_init::
    ; Set variables
    ld [HL], $00
    ld HL, player_x
    ld [HL], PLAYER_START_X
    ld HL, player_y
    ld [HL], PLAYER_START_Y
    ; Enable sprite
    ld HL, rLCDC
    set 1, [HL]
    ; Set Palette
    ; ld HL, OBJ0_PAL
    ; ld [HL], %11100100
    ; ld HL, OBJ1_PAL
    ; ld [HL], %11010000
    ; Set Attributes
    ; Top left
    ld HL, $FE00
    ld [HL], PLAYER_START_Y
    inc L
    ld [HL], PLAYER_START_X
    inc L
    ld [HL], $80
    inc L
    set 4, [HL]
    ; Top right
    ld HL, $FE04
    ld [HL], PLAYER_START_Y
    inc L
    ld [HL], PLAYER_START_X + 8
    inc L
    ld [HL], $81
    inc L
    set 4, [HL]
    ; Bottom right
    ld HL, $FE08
    ld [HL], PLAYER_START_Y + 8
    inc L
    ld [HL], PLAYER_START_X + 8
    inc L
    ld [HL], $82
    inc L
    set 4, [HL]
    ; Bottom left
    ld HL, $FE0C
    ld [HL], PLAYER_START_Y + 8
    inc L
    ld [HL], PLAYER_START_X
    inc L
    ld [HL], $83
    inc L
    set 4, [HL]
    ret

; player_update::
;     ; update animation
;     ld HL, player_frame_index
;     ld A, [HL]
;     ld HL, player_frames
;     ld L, A
;     ld A, [HL] ; Got frame
;     ld HL, $FE0E
;     ld [HL], A
;     ld HL, player_frame_index
;     inc [HL]
;     ld A, [HL]
;     cp 27
;     jr nz, .player_update_continue_00
;     ld [HL], $00
; .player_update_continue_00:
;     ld HL, player_dead
;     ld A, [HL]
;     cp $00
;     jr nz, .player_update_no_input
;     ; Check if Button A 
;     ; was pressed
;     ld HL, IO_P15
;     bit BUTTON_A, [HL]
;     jr nz, .player_update_no_input
;     ld HL, IO_P15_OLD
;     bit BUTTON_A, [HL]
;     jr z, .player_update_no_input
    
;     ; Set the player to active
;     ld HL, player_active
;     ld [HL], $01

;     ; if button A was pressed
;     ; we apply jump
; .player_update_jump:
;     ld HL, player_vel_y
;     ld A, [HL]
;     ld A, -(PLAYER_MAX_VEL * 2)
;     ld [HL], A
; .player_update_no_input:
;     ld HL, player_active
;     ld A, [HL]
;     cp $00
;     jr nz, .player_update_apply_accel_y

; player_update_end:
;     ret

player_set_position::
    xor A
    ld HL, player_y
    ld B, [HL]
    ld HL, player_x
    ld C, [HL]
    ; Top left
    ld HL, $FE00
    ld [HL], B
    inc L
    ld [HL], C
    ; Top right
    ld HL, $FE04
    ld E, C
    ld A, C
    adc A, 8
    ld C, A
    ld [HL], B
    inc L
    ld [HL], C
    ; Bottom left
    ld HL, $FE0C
    ld A, B
    adc A, 8
    ld B, A
    ld [HL], B
    inc L
    ld [HL], E
    ; Bottom right
    ld HL, $FE08
    ld [HL], B
    inc L
    ld [HL], C
    
    ret

SECTION "player_vars", WRAM0
player_x:: DS 1
player_y:: DS 1