INCLUDE "hardware.inc"

SECTION "OAM DMA routine", ROM0

NUMBERS_TILE_OFFSET EQU $47
SCORE_INDEX_ONE_ADDRESS EQU $9C0B
LIVES_ADDRESS EQU $9C10

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
	ret

SetupPalettes::
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOCPD], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ret

RefreshScore::
	push af
	push hl
	ld hl, SCORE_INDEX_ONE_ADDRESS
	; First digit
	ld a, [score]
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Second digit
    ld a, [score]
    swap a
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Third digit
	ld a, [score+1]
    and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fourth digit
	ld a, [score+1]
	swap a
    and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fifth digit
	ld a, [score+2]
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Sixth digit
	ld a, [score+2]
	swap a
    and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	pop af
	pop hl
	ret

RefreshLives::
	push af
	ld a, [player_lives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_ADDRESS], a
	pop af
	ret