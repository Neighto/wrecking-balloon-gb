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