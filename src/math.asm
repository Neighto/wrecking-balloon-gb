INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "math", ROM0

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

DIVISION::
    ; simple division formula
    ; takes 'a' argument as number being divided
    ; takes 'b' argument as divider
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

ToBCD::
    ; takes 'a' argument as non-BCD number
    ; returns 'a' as BCD number
    ; Example: a = 32, 32 % 10 = 2, (32 % 100) / 10 = 3 => % 0011 0010 
    ld h, a ; save a
    ld d, 10
    call MODULO
    ld l, a ; 
    ld a, h ; refresh a
    ld d, 100
    call MODULO
    ld b, 10
    call DIVISION
    swap a
    or l
    ret

MULTIPLY::
    ; simple multiply formula
    ; argument 'b'
    ; argument 'c'
    ; returns 'a' as solution
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
    ret