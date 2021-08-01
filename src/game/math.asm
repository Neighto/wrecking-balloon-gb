INCLUDE "hardware.inc"

SECTION "math", ROMX

MODULO::
    ; simple modulo formula
    ; takes 'a' argument as number being modded
    ; takes 'b' argument as mod number
    ; returns 'a' as remainder
    cp a, b
    ret c
.loop:
    sub a, b
    cp a, b
    jr nc, .loop
    ret

RANDOM::
    ; takes 'a' argument as range number
    ; returns 'a' as random number => 0 to a - 1
    ; ex:
    ; ld a, 10
    ; call RANDOM
    ; [a is # 0-9]
    ld b, a
    ldh a, [rDIV]
    call MODULO
    ret

DIVISION::
    ; simple division formula
    ; takes 'a' argument as number being divided
    ; takes 'b' argument as divider
    ; uses 'c' as counter
    ; returns 'a' as solution
    ld c, 0
    cp a, b
    jr c, .end
.loop:
    sub a, b
    inc c
    cp a, b
    jr nc, .loop
.end:
    ld a, c
    ret