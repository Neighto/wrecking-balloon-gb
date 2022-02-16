INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "memory", ROMX

MEMCPY::
    ; de = block size
    ; bc = source address
    ; hl = destination address
.loop:
    ld a, [bc]
    ld [hli], a
    inc bc
    dec de
.checkLoop:
	ld a, d
	or a, e
	jr nz, .loop
    ret

MEMCPY_WITH_OFFSET::
    ; de = block size
    ; bc = source address
    ; hl = destination address
    ; a = offset
    push af
.loop:
    pop af

    push de
    ld d, a
    ld a, [bc]
    add a, d
    ld [hli], a
    ld a, d
    pop de
    push af
    inc bc
    dec de
.checkLoop:
	ld a, d
	or a, e
	jr nz, .loop
    pop af
    ret

MEMCPY_SINGLE_SCREEN::
    ; Assumes source is 160x144
    ; bc = source address
    ; hl = destination address
    ; d = Y counter (set to SCRN_Y_B if you want the entire screen)
    ld e, SCRN_X_B ; X counter
.loop:
    ld a, [bc]
    ld [hli], a
    inc bc
    dec e
    ld a, e
    cp a, 0
    jr nz, .checkLoop
    dec d
    ld e, SCRN_X_B
    ADD_TO_HL SCRN_VX_B - SCRN_X_B
.checkLoop:
	ld a, d
    cp a, 0
	jr nz, .loop
    ret

ClearOAM::
    RESET_IN_RANGE _OAMRAM, $A0
    ret

ClearRAM::
    RESET_IN_RANGE $C100, $A0 ; should probably be at C000
    ret

RequestOAMSpace::
    push hl
    push de
    ; Argument b = sprite space needed (4 bytes each)
    ; Returns a as 0 or 1 where 0 is failed and 1 is succeeded
    ; Returns b as start sprite # in wOAM

    ld c, 0 ; c = how many sprites we've found free so far
    ld hl, wOAM
    ld d, OAMVarsEnd - OAMVars
.loop:
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero4
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero3
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero2
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero1
.availableSpace:
    inc c
    ; DO WE HAVE ENOUGH SPACE
    ld a, b
    cp a, c
    jr nz, .notEnoughSprites
.sufficientSpace:
    ld a, OAMVarsEnd - OAMVars
    sub a, d
    sub a, c
    inc a
    ld b, a
    ld c, 4
    call MULTIPLY
    ld b, a
    ld a, 1
    jr .end
.isNotZero4:
    inc l
.isNotZero3:
    inc l
.isNotZero2:
    inc l
.isNotZero1:
    ; RESET FREE SPRITES SINCE IT WASNT CLEAR
    ld c, 0
.notEnoughSprites:
    ; LOOP TO NEXT SPRITE
    inc l
    dec d
    ld a, d
	cp a, 0
    jr nz, .loop
    ; No space
    xor a ; ld a, 0
.end:
    pop de
    pop hl
    ret

RequestRAMSpace::
    ; Argument hl as data address
    ; Argument d as struct amount
    ; Argument e as struct size
    ; Returns a as 0 or 1 where 0 is failed and 1 is succeeded
    ; Returns hl as address of free space
.loop:
    ld a, [hl] ; Active
    cp a, 0
    jr nz, .checkLoop
.availableSpace:
    ld a, 1
    jr .end
.checkLoop:
    ADD_TO_HL e
    dec d
    ld a, d 
    cp a, 0
    jr nz, .loop
.noFreeSpace:
    xor a ; ld a, 0
.end:
    ret