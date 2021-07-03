SECTION "joypad", ROMX

INCLUDE "hardware.inc"

read_joypad::
    ; Read P14
    ld HL, rP1
    ld A, $20
    ld [HL], A
    ld A, [HL]
    ld HL, IO_P14
    ld B, [HL]
    ld [HL], A
    ld HL, IO_P14_OLD
    ld [HL], B

    ; Read P15
    ld HL, rP1
    ld A, $10
    ld [HL], A
    ld A, [HL]
    ld HL, IO_P15
    ld B, [HL]
    ld [HL], A
    ld HL, IO_P15_OLD
    ld [HL], B
    
    ; Reset
    ld HL, rP1
    ld A, $FF
    ld [HL], A
    ret

clear_joypad::
    ld HL, IO_P14
    ld [HL], $EF
    ld HL, IO_P15
    ld [HL], $DF
    ld HL, IO_P14_OLD
    ld [HL], $EF
    ld HL, IO_P15_OLD
    ld [HL], $DF
    ret

SECTION "joypad_vars", WRAM0
IO_P14:: DS 1
IO_P15:: DS 1
IO_P14_OLD:: DS 1
IO_P15_OLD:: DS 1