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
	; Copy the window tiles
	ld bc, WindowTiles
	ld hl, $9400
	ld de, WindowTilesEnd - WindowTiles
	call MEMCPY
	; Copy the tilemap
	ld bc, BackgroundMap
	ld hl, $9800
	ld de, BackgroundMapEnd - BackgroundMap
	call MEMCPY
	; ; Copy the window
	ld bc, WindowMap
	ld hl, $9C00
	ld de, WindowMapEnd - WindowMap
	call MEMCPY
	call RefreshWindowLayer
	; Initialize
	call InitializePlayer
	call InitializePointBalloon
	call InitializeEnemy
	ret

SetupPalettes::
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOCPD], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ret

RefreshWindowLayer:
	ld hl, score
	ld a, 5

	; example: 482
	; take first digit
	; ld a, 1
	; and a, [hl]
	add $47
	ld hl, $9C0B
	ld [hl], a

	ld a, [player_lives]
	add $47 ; Tile number for 0
	ld hl, $9C10
	ld [hl], a
	ret