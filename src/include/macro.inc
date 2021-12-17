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
    ; argument bc is starting address
    ; argument de is offset
    ; uses de and hl
    ld bc, \1
    ld de, \2
    ld h, b
    ld l, c
    ld a, [de]
    add a, l ; might cause issues if no carry to h?
    ld l, a
ENDM

MACRO NEW_AND_SIMPLE
    ld bc, \1 ; wPlayerCactus
    ld l, \2 ; offset
    ld h, $C1
    ld a, [bc]
    add l
    ld l, a
ENDM