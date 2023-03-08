INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"

SECTION "memory vars", WRAM0 
wMemcpyTileOffset:: DB

SECTION "memory", ROM0

; Arg: DE = Block size
; Arg: BC = Source address
; Arg: HL = Destination address
MEMCPY::
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

; Arg: DE = Block size
; Arg: BC = Source address
; Arg: HL = Destination address
; Arg: A = Offset
MEMCPY_WITH_OFFSET::
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

; Arg: D = Block size (byte)
; Arg: E = Pattern size (byte)
; Arg: BC = Source address
; Arg: HL = Destination address
; Set wMemcpyTileOffset too if tile offset used
MEMCPY_SIMPLE_PATTERN::
    xor a ; ld a, 0
    ld [wMemcpyTileOffset], a
MEMCPY_SIMPLE_PATTERN_WITH_OFFSET::
    ld a, e
    push af
.loop:
    ; Have we visited all blocks?
    ld a, d
    cp a, 0
    jr z, .end
    ; Copy
    ld a, [bc]
    inc bc
    push hl
    ld hl, wMemcpyTileOffset
    add a, [hl]
    pop hl
    ld [hli], a
    ; Reduce blocks to copy
    dec d
    ; Reset to pattern start if its over
    dec e
    ld a, e
    cp a, 0
    jr nz, .loop
.resetPattern:
    pop af
    ld e, a
    push af
    ld a, e
    SUB_FROM_R16 b, c, e
    jr .loop
.end:
    pop af
    ret

; Arg: HL = Destination address
; Arg: BC = Source address
MEMCPY_PATTERN_CLOUDS::
	ld d, SCRN_VX_B
	ld e, CLOUDS_TILE_AMOUNT
	ld a, CLOUDS_TILE_OFFSET
	ld [wMemcpyTileOffset], a
	jp MEMCPY_SIMPLE_PATTERN_WITH_OFFSET

; Arg: BC = Source address
; Arg: HL = Destination address
; Arg: D = Y counter (set to SCRN_Y_B if you want the entire screen height 144)
; Arg: E = X counter (set to SCRN_X_B if you want the entire screen width 160)
MEMCPY_SINGLE_SCREEN::
    xor a ; ld a, 0
    ld [wMemcpyTileOffset], a
MEMCPY_SINGLE_SCREEN_WITH_OFFSET::
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

; Arg: BC = Distance
ResetHLInRange::
.loop:
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop
    ret

; Arg: HL = Starting address
; Arg: BC = Distance
; Arg: D = Value
SetInRange::
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
    ld hl, OAM_VAR_ADDRESS
    ld bc, OAM_COUNT * OAM_ATTRIBUTES_COUNT
    jp ResetHLInRange

; ClearRAM::
;     ld hl, _RAM
;     ld bc, _OAMRAM - _RAM
;     jp ResetHLInRange

ClearHRAM::
    ld hl, _HRAM
    ld bc, $FFFC - _HRAM
    jp ResetHLInRange

; Arg: B = Sprite space needed (4 bytes each)
; Ret: Z/NZ = Failed / succeeded respectively
; Ret: B = Start sprite # in wOAM
RequestOAMSpace::
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

; Arg: HL = Data address
; Arg: D = Struct amount
; Arg: E = Struct size
; Ret: Z/NZ = Failed / succeeded respectively
; Ret: HL = Address of free space
RequestRAMSpace::
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

; Arg: B = Sprites needed
; Arg: HL = OAM offset var
; Ret: HL = Address of free space
; Ret: Z/NZ = Failed / succeeded respectively
RequestOAMAndSetOAMOffset::
    push hl
	call RequestOAMSpace
    pop hl
	ret z
	; Has available space
	ld a, b
	ld [hl], a
	ld hl, wOAM
	ADD_A_TO_HL
    or a, 1 ; Force return nz
    ret