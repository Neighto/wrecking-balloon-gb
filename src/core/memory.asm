INCLUDE "hardware.inc"

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
    ld hl, _OAMRAM
    ld bc, $A0
.clear_oam_loop
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .clear_oam_loop
    ret

ClearRAM::
    ld hl, $C100
    ld bc, $A0
.clear_ram_loop
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .clear_ram_loop
    ret

; [deprecated, for now]
; CLEAR_SPRITES::
;     ;; Clear what's in "Shadow OAM"
; 	ld hl, wShadowOAM
; .clear_sprites
;     ld a, $0
;     ld [hl], a
;     inc l
;     ld a, l
;     cp $0
;     jp nz, .clear_sprites
;     ret