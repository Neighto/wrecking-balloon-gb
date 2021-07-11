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

DMA_COPY::
    ld  de,$FF80
    rst $28
    DB  $00,$0D
    DB  $F5, $3E, $C1, $EA, $46, $FF, $3E, $28, $3D, $20, $FD, $F1, $D9
    ret