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


RequestOAMSpace::
    ; b = sprite space needed
    ; returns a as start sprite # in wOAM
    xor a ; ld a, 0
    ld c, a ; c = how many sprites we've found free so far
    ld hl, wOAM
    ld d, OAM_COUNT
.loop:
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero
    ; FREE TO USE
    inc c
    ; DO WE HAVE ENOUGH SPACE
    ld a, b
    cp a, c
    jr nc, .notEnoughSprites
    ; YES WE DO WE ARE DONE
    ld a, OAM_COUNT
    sub a, d
    sub a, c
    inc a
    ret
.isNotZero:
    ; RESET FREE SPRITES SINCE IT WASNT CLEAR
    xor a ; ld a, 0
    ld c, a
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