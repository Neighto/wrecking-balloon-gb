INCLUDE "hardware.inc"

SECTION "math", ROMX

RANDOM::
    ; takes 'a' argument as mod number
    ; ex:
    ; ld a, 10
    ; call RANDOM
    ; [a is # 0-9]
    ld b, a
.seed:
    ldh a, [rDIV]
.loop:
    sub a, b
    ; If a < b continue
    cp a, b
    jr nc, .loop
    ret