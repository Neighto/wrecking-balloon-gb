INCLUDE "hardware.inc"

SECTION "math", ROMX

MODULO::
    ; simple modulo formula
    ; takes 'a' argument as number being modded
    ; takes 'd' argument as mod number
    ; returns 'a' as remainder
    cp a, d
    ret c
.loop:
    sub a, d
    cp a, d
    jr nc, .loop
    ret

RANDOM::
    ; takes 'a' argument as range number
    ; uses 'd' as holder
    ; returns 'a' as random number => 0 to a - 1
    ; ex:
    ; ld a, 10
    ; call RANDOM
    ; [a is # 0-9]
    push de
    ld d, a
    ldh a, [rDIV]
    call MODULO
    pop de
    ret

DIVISION::
    ; simple division formula
    ; takes 'a' argument as number being divided
    ; takes 'd' argument as divider
    ; uses 'c' as counter
    ; returns 'a' as solution
    push bc
    ld c, 0
    cp a, d
    jr c, .end
.loop:
    sub a, d
    inc c
    cp a, d
    jr nc, .loop
.end:
    ld a, c
    pop bc
    ret

ToBCD::
    ; takes 'a' argument as non-BCD number
    ; uses 'b' 'c' as holder
    ; returns 'a' as BCD number
    push bc
    push de
    ld b, a ; save a
    ld d, 10
    call MODULO
    ld c, a ; 
    ld a, b ; refresh a
    ld d, 100
    call MODULO
    ld d, 10
    call DIVISION
    swap a
    or c
.end:
    pop de
    pop bc
    ret


MULTIPLY::
    ; simple multiply formula
    ; argument 'b'
    ; argument 'c'
    ; uses 'a' and 'd' as counter
    ; returns 'a' as solution
    push de
    xor a ; ld a, 0
    ld d, a
.loop:
    ld a, c
    cp a, 0
    jr z, .end
    ld a, b
    add a, d
    ld d, a
    dec c
    jr .loop
.end:
    ld a, d
    pop de
    ret