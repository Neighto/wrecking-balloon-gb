INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "OAM vars", WRAM0[OAM_VAR_ADDRESS]
	; Player OAM is separate because we should not have to request it in case there's not enough space to spawn
wPlayerCactusOAM:: DS 2 * OAM_ATTRIBUTES_COUNT
wPlayerBalloonOAM:: DS 2 * OAM_ATTRIBUTES_COUNT
wPlayerBulletOAM:: DS 1 * OAM_ATTRIBUTES_COUNT
OAMVars::
wOAM:: DS 35 * OAM_ATTRIBUTES_COUNT ; 35 sprites with 4 bytes each of attributes
OAMVarsEnd::

SECTION "OAM DMA routine", ROM0

; Move DMA routine to HRAM
CopyDMARoutine::
	ld hl, hOAMDMA
	ld bc, DMARoutine
	ld de, DMARoutineEnd - DMARoutine
	jp MEMCPY
	
DMARoutine:
	; Arg: A = Address for DMA transfer source
	ldh [rDMA], a
	ld a, 40
.wait
	dec a
	jr nz, .wait
	ret
DMARoutineEnd:

OAMDMA::
  	; Call DMA subroutine to copy the bytes to OAM for sprites begin to draw
	ld a, HIGH(OAM_VAR_ADDRESS)
	jp hOAMDMA

SECTION "OAM DMA", HRAM
hOAMDMA:: DS DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to