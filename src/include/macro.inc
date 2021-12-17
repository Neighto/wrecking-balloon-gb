MACRO INCREMENT_POS
    ; argument 1 is address
    ; argument 2 is amount
    ld hl, \1
    ld a, \2
    add [hl]
    ld [hl], a
ENDM

MACRO DECREMENT_POS
    ; argument 1 is address
    ; argument 2 is amount
    ld hl, \1
    ld a, \2
    cpl
    inc a
    add [hl]
    ld [hl], a
ENDM

; Use with caution: Overwrites hl and bc
MACRO RESET_IN_RANGE
    ; argument 1 is starting address
    ; argument 2 is distance
    ld hl, \1
    ld bc, \2
    push af
.loop\@:
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop\@
    pop af
ENDM

MACRO LD_BC_HL
    ld b, h
    ld c, l
ENDM

MACRO LD_DE_HL
    ld d, h
    ld e, l
ENDM

; Use with caution: Overwrites hl and de
MACRO SET_HL_TO_ADDRESS
    ; argument 1 is starting address
    ; argument 2 is offset
    ld hl, \1
    ld de, \2
    push af
    ld a, [de]
    add a, l ; might cause issues if no carry to h?
    ld l, a
    pop af
ENDM