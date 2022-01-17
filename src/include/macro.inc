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

; Use with caution: Overwrites hl and bc, and d
MACRO SET_IN_RANGE
    ; argument 1 is starting address
    ; argument 2 is distance
    ; argument 3 is value
    ld hl, \1
    ld bc, \2
    ld d, \3
    push af
.loop\@:
    ld a, d
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

MACRO LD_HL_BC
    ld h, b 
    ld l, c
ENDM

MACRO LD_HL_DE
    ld h, d
    ld l, e
ENDM

MACRO LD_BC_DE
    ld b, d
    ld c, e
ENDM

MACRO ADD_TO_HL
    ; argument 1 is value to add to HL (8 bit)
    push af
    ld a, l
    add a, \1
    ld l, a
    ld a, h
    adc a, 0
    ld h, a
    pop af
ENDM

; Use with caution: Overwrites de
MACRO SUB_FROM_HL_16
    ; argument 1 is value to sub from HL (16 bit)
    ld de, \1
    push af
    ld a, l
    sub a, e
    ld l, a
    ld a, h
    sbc a, d
    ld h, a
    pop af
ENDM

; Use with caution: Overwrites hl and de
MACRO SET_HL_TO_ADDRESS
    ; argument 1 is starting address
    ; argument 2 is offset
    ld hl, \1 ; 3 cycles
    ld de, \2 ; 3 cycles
    push af ; 4 cycles
    ld a, [de] ; 2 cycles
    add a, l ; 1 cycle
    ld l, a ; 1 cycle
    pop af ; 3 cycles
ENDM

; Use with caution: Overwrites hl and bc
MACRO SET_HL_TO_ADDRESS_WITH_BC
    ; argument 1 is starting address
    ; argument 2 is offset
    ld hl, \1
    ld bc, \2
    push af
    ld a, [bc]
    add a, l ; might cause issues if no carry to h?
    ld l, a
    pop af
ENDM