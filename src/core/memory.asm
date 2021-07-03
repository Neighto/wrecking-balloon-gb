SECTION "memory", ROMX

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