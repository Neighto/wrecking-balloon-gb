INCLUDE "hardware.inc"

SECTION "OAM DMA routine", ROM0

; Move DMA routine to HRAM
CopyDMARoutine::
	ld  hl, DMARoutine
	ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
	ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
	ld  a, [hli]
	ldh [c], a
	inc c
	dec b
	jr  nz, .copy
	ret
DMARoutine:
	ldh [rDMA], a
	
	ld  a, 40
.wait
	dec a
	jr  nz, .wait
	ret
DMARoutineEnd:

OAMDMA::
  	; Call DMA subroutine to copy the bytes to OAM for sprites begin to draw
	ld a, HIGH($C100)
	call hOAMDMA
	ret

SECTION "OAM DMA", HRAM
hOAMDMA:: ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

SECTION "graphics", ROM0

; Load tiles, draw sprites and draw tilemap
LoadGameData::
	; Copy the sprite tiles
	ld bc, CactusTiles
	ld hl, $8800
	ld de, CactusTilesEnd - CactusTiles
	call MEMCPY
 	; Copy the background tiles
	ld bc, BackgroundTiles
	ld hl, $9000
	ld de, BackgroundTilesEnd - BackgroundTiles
	call MEMCPY
	; Copy the tilemap
	ld bc, BackgroundMap
	ld hl, $9800
	ld de, BackgroundMapEnd - BackgroundMap
	call MEMCPY
	; Initialize
	call InitializePlayer
	call InitializePointBalloon
	ret

SetupPalettes::
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOCPD], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ret