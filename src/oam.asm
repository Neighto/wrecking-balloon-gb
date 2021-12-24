INCLUDE "hardware.inc"

SECTION "OAM DMA routine", ROM0

; Move DMA routine to HRAM
CopyDMARoutine::
	ld hl, DMARoutine
	ld b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
	ld c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .copy
	ret
DMARoutine:
	ldh [rDMA], a
	ld a, 40
.wait
	dec a
	jr nz, .wait
	ret
DMARoutineEnd:

OAMDMA::
  	; Call DMA subroutine to copy the bytes to OAM for sprites begin to draw
	push af
	ld a, HIGH($C100)
	call hOAMDMA
	pop af
	ret

SECTION "OAM DMA", HRAM
hOAMDMA:: ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to