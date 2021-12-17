INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "memory", ROMX

MEMCPY::
    ; de = block size
    ; bc = source address
    ; hl = destination address
.memcpy_loop:
    ld a, [bc]
    ld [hli], a
    inc bc
    dec de
.memcpy_check_limit:
	ld a, d
	or a, e
	jp nz, .memcpy_loop
    ret

ClearOAM::
    RESET_IN_RANGE _OAMRAM, $A0
    ret

ClearRAM::
    RESET_IN_RANGE $C100, $A0
    ret

RequestOAMSpace:
    ; b = sprite space needed
    ; returns a as start sprite # in wOAM
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
    ; FREE TO USE
    inc c
    ; DO WE HAVE ENOUGH SPACE
    ld a, b
    cp a, c
    jr nz, .notEnoughSprites
    ; YES WE DO WE ARE DONE
    ld a, OAMVarsEnd - OAMVars
    sub a, d
    sub a, c
    inc a
    ret
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
    ; RETURN -1
    ld a, -1
    ret

RequestOAMSpaceOffset::
    ; b = sprite space needed
    ; returns a as start sprite offset in wOAM
    call RequestOAMSpace
    ld b, a
    ld c, 4
    call MULTIPLY
    ret