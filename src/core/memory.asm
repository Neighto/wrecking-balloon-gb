SECTION "memory", ROMX

INCLUDE "hardware.inc"

memcpy::
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


CLEAR_OAM::
    ld  hl,_OAMRAM
    ld  bc,$A0
.clear_oam_loop
    ld  a, $0
    ld  [hli], a
    dec bc
    ld  a, b
    or  c
    jr  nz,.clear_oam_loop
    ret


CLEAR_RAM::
    ld  hl,$C100
    ld  bc,$A0
.clear_ram_loop
    ld  a,$0
    ld  [hli],a
    dec bc
    ld  a,b
    or  c
    jr  nz,.clear_ram_loop
    ret


CLEAR_SPRITES::
	ld hl, wShadowOAM
.clear_sprites
    ld a,$FF
    ld [hl],a
    inc l
    ld a,l
    cp $FF
    jp nz, .clear_sprites
    ret