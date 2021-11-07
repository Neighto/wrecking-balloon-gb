MACRO INCREMENT_POS
    ; takes 'hl' argument as address
    ; takes 'a' argument as amount
    ld hl, \1
    ld a, \2
    add [hl]
    ld [hl], a
ENDM

MACRO DECREMENT_POS
    ; takes 'hl' argument as address
    ; takes 'a' argument as amount
    ld hl, \1
    ld a, \2
    cpl
    inc a
    add [hl]
    ld [hl], a
ENDM