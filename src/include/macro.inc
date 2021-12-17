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

MACRO RESET_IN_RANGE
    ; argument hl is starting address
    ; argument bc is distance
    ; uses a
    ld hl, \1
    ld bc, \2
.loop\@:
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop\@
ENDM

MACRO SET_HL_TO_ADDRESS
    ; argument hl is starting address
    ; argument bc is offset
    ; uses a
    ld hl, \1
    ld bc, \2
    push af
    ld a, [bc]
    add a, l ; might cause issues if no carry to h?
    ld l, a
    pop af
ENDM