INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "math", ROM0

; Arg: A = Number being modded
; Arg: D = Mod number
; Ret: A = Remainder
MODULO::
    cp a, d
    ret c
.loop:
    sub a, d
    cp a, d
    jr nc, .loop
    ret

; Arg: A = Number being divided
; Arg: B = Divider
; Ret: A = Solution
DIVISION::
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

; Arg: A = Non-BCD number
; Ret: A = BCD number
; Example: a = 32, 32 % 10 = 2, (32 % 100) / 10 = 3 => % 0011 0010
ToBCD::
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

; Arg: B = Operand 1
; Arg: C = Operand 2
; Ret: A = Result
MULTIPLY::
    ld d, 0
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