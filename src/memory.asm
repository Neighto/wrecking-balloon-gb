INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "constants.inc"

SECTION "memory vars", WRAM0 
    wMemcpyTileOffset:: DB

SECTION "memory", ROM0

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
    xor a ; ld a, 0
    ld [wMemcpyTileOffset], a
MEMCPY_SINGLE_SCREEN_WITH_OFFSET::
    ; bc = source address
    ; hl = destination address
    ; d = Y counter (set to SCRN_Y_B if you want the entire screen height 144)
    ; e = X counter (set to SCRN_X_B if you want the entire screen width 166)
    ld a, e
    push af
.loop:
    ld a, [bc]
    push hl
    ld hl, wMemcpyTileOffset
    add a, [hl]
    pop hl
    ld [hli], a
    inc bc
    dec e
    ld a, e
    cp a, 0
    jr nz, .checkLoop
    dec d
    pop af
    ld e, a
    push af
    ld a, SCRN_VX_B
    sub e
    ADD_TO_HL a
.checkLoop:
	ld a, d
    cp a, 0
	jr nz, .loop
    pop af
    ret

ResetHLInRange::
    ; bc = distance
.loop:
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop
    ret

SetInRange::
    ; hl = starting address
    ; bc = distance
    ; d = value
.loop:
    ld a, d
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop
    ret

ClearOAM::
    ld hl, _OAMRAM
    ld bc, OAM_COUNT * OAM_ATTRIBUTES_COUNT
    call ResetHLInRange
    ld hl, $C100
    ld bc, OAM_COUNT * OAM_ATTRIBUTES_COUNT
    jp ResetHLInRange

ClearRAM::
    ld hl, _RAM
    ld bc, _OAMRAM - _RAM
    jp ResetHLInRange

ClearHRAM::
    ld hl, _HRAM
    ld bc, $FFFC - _HRAM
    jp ResetHLInRange

RequestOAMSpace::
    ; Argument b = sprite space needed (4 bytes each)
    ; Returns z flag as failed / nz flag as succeeded
    ; Returns b as start sprite # in wOAM

    ld c, 0 ; c = how many sprites we've found free so far
    ld hl, wOAM
    ld d, OAMVarsEnd - OAMVars
.loop:
    ; Check sprite attribute: Y
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero4
    ; Check sprite attribute: X
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero3
    ; Check sprite attribute: Tile
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero2
    ; Check sprite attribute: Flag
    inc l
    ld a, [hl]
    cp a, 0
    jr nz, .isNotZero1
.freeSpriteSpace:
    inc c
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
.availableSpace:
    ; Set the nz
    or a, 1
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
.noFreeSpace:
    ; z already set
    ret

RequestRAMSpace::
    ; Argument hl as data address
    ; Argument d as struct amount
    ; Argument e as struct size
    ; Returns z flag as failed / nz flag as succeeded
    ; Returns hl as address of free space
.loop:
    ld a, [hl] ; Active
    cp a, 0
    jr nz, .checkLoop
.availableSpace:
    or a, 1
    ret
.checkLoop:
    ADD_TO_HL e
    dec d
    ld a, d 
    cp a, 0
    jr nz, .loop
.noFreeSpace:
    xor a ; ld a, 0
    ret