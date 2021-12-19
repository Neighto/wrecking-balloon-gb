INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "interrupts", ROM0

VBlankInterrupt::
    push hl
    push af
    ld hl, vblank_flag
    ld [hl], 1
    ldh a, [rLCDC]
    or LCDCF_OBJON
    ldh [rLCDC], a
    pop af
    pop hl
    reti

LCDInterrupt::
    push af
    push bc
    push hl
	ld hl, wLCDInterrupt
	ld a, [hli]
	ld h, [hl]
	ld l, a
    jp hl

LCDInterruptEnd:
    pop hl
    pop bc
    pop af
    reti

SetBaseInterrupts::
	ld hl, wLCDInterrupt
    ld a, LOW(LCDInterruptEnd)
    ld [hli], a
    ld a, HIGH(LCDInterruptEnd)
    ld [hl], a

    ld a, IEF_STAT | IEF_VBLANK ; Enable LCD and VBLANK interrupts
	ldh [rIE], a
	ld a, STATF_LYC
	ldh [rSTAT], a
    ret

ParkLCDInterrupt:
    ld a, [rLYC]
	cp a, 0
    jr z, .clouds
    CP a, 72
    jr z, .ground
    jr .end
.clouds:
    ld a, 72
	ldh [rLYC], a
    ld a, [rSCX]
    ld hl, cloud_scroll_offset
    add a, [hl]
	ldh [rSCX], a
    jr .end
.ground:
    xor a ; ld a, 0
    ldh [rLYC], a
	ldh [rSCX], a
.end:
    jp LCDInterruptEnd

SetParkInterrupts::
    xor a ; ld a, 0
	ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(ParkLCDInterrupt)
    ld [hli], a
    ld a, HIGH(ParkLCDInterrupt)
    ld [hl], a
    ret 

ClassicLCDInterrupt:
    ; We call nop multiple times to delay hiding sprites so it happens on a new line read
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld hl, rLCDC
    res 1, [hl]
    jp LCDInterruptEnd

SetClassicInterrupts::
	ld a, WINDOW_START_Y-1
	ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(ClassicLCDInterrupt)
    ld [hli], a
    ld a, HIGH(ClassicLCDInterrupt)
    ld [hl], a
    ret