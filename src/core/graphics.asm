INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "OAM DMA routine", ROM0

NUMBERS_TILE_OFFSET EQU $47
SCORE_INDEX_ONE_ADDRESS EQU $9C0B
LIVES_ADDRESS EQU $9C10

PARK_WAVE_PALETTE EQU %11100001

FADE_SPEED EQU %00000011
FADE_PALETTE_1 EQU %11100100
FADE_PALETTE_2 EQU %10000100
FADE_PALETTE_3 EQU %01000000
FADE_PALETTE_4 EQU %00000000

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
	ld hl, _VRAM8800
	ld de, CactusTilesEnd - CactusTiles
	call MEMCPY
 	; Copy the background tiles
	ld bc, BackgroundTiles
	ld hl, _VRAM9000
	ld de, BackgroundTilesEnd - BackgroundTiles
	call MEMCPY
	; Copy the classic park tiles
	ld bc, ClassicParkTiles
	ld hl, _VRAM8800+$0200
	ld de, ClassicParkTilesEnd - ClassicParkTiles
	call MEMCPY
	; Copy the countdown tiles
	ld bc, CountdownTiles
	ld hl, _VRAM8800+$0300
	ld de, CountdownTilesEnd - CountdownTiles
	call MEMCPY
	; Copy the window tiles
	ld bc, WindowTiles
	ld hl, $9400
	ld de, WindowTilesEnd - WindowTiles
	call MEMCPY
	; Copy the tilemap
	ld bc, BackgroundMap
	ld hl, _SCRN0
	ld de, BackgroundMapEnd - BackgroundMap
	call MEMCPY
	; ; Copy the window
	ld bc, WindowMap
	ld hl, _SCRN1
	ld de, WindowMapEnd - WindowMap
	call MEMCPY
	ret

	; Function where we REPLACE tilemap for a new one
ReplaceTilemapHorizontal::
	; takes b as index of tilemap we want to replace (0= first 8 cols, 1= second 8 cols, etc [0-3])
	; Replace 8 previous tile columns once we are past them
	ld hl, $9800
	ld bc, $07
	; once we hit $07, then we add $20 to hl
.loop:

	ret

LoadMenuData::
	ld bc, MenuTitleTiles
	ld hl, _VRAM9000
	ld de, MenuTitleTilesEnd - MenuTitleTiles
	call MEMCPY
	ld bc, MenuTiles
	ld hl, _VRAM8800
	ld de, MenuTilesEnd - MenuTiles
	call MEMCPY
	ld bc, MenuMap
	ld hl, _SCRN0
	ld de, MenuMapEnd - MenuMap
	call MEMCPY
	ret

SetAllPalettes:
	; B = argument
	push af
	ld a, b
	ldh [rBGP], a
    ldh [rOCPD], a
	ldh [rOBP1], a
	ldh [rOBP0], a
	pop af
    ret

SetupPalettes::
	push bc
    ld b, MAIN_PALETTE
    call SetAllPalettes
	pop bc
    ret

SetupParkPalettes::
	ld a, MAIN_PALETTE
    ldh [rBGP], a
    ldh [rOCPD], a
	ldh [rOBP1], a
	ld a, PARK_WAVE_PALETTE
	ldh [rOBP0], a
    ret

FadeOutPalettes::
	ld a, [global_timer]
	and FADE_SPEED
	jr z, .fadeOut
	ret
.fadeOut:
	ld a, [fade_frame]
	cp a, 0
	jr z, .fade1
	cp a, 1
	jr z, .fade2
	cp a, 2
	jr z, .fade3
	cp a, 3
	jr z, .fade4
	ret
.fade1:
    ld b, FADE_PALETTE_1
	jr .end
.fade2:
	ld b, FADE_PALETTE_2
	jr .end
.fade3:
	ld b, FADE_PALETTE_3
	jr .end
.fade4:
	ld b, FADE_PALETTE_4
.end:
	call SetAllPalettes
	ld a, [fade_frame]
	inc a
	ld [fade_frame], a
	ret

HasFadedOut::
	; => A as 1 or 0
	ld a, [rBGP]
	cp a, FADE_PALETTE_4
	jr z, .true
.false:
	xor a ; ld a, 0
	ret
.true:
	ld a, 1
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

ClearAllTiles::
    ld hl, _VRAM8000
    ld bc, _VRAM8800 - _VRAM8000
    call ResetInRange
    ld hl, _VRAM8800
    ld bc, _VRAM9000 - _VRAM8800
    call ResetInRange
    ld hl, _VRAM9000
    ld bc, _SCRN0 - _VRAM9000
    call ResetInRange
    ret

ClearMap::
    ld hl, _SCRN0
    ld bc, $400
    push hl
.clear_map_loop
    ;wait for hblank
    ld  hl, rSTAT
    bit 1, [hl]
    jr nz, .clear_map_loop
    pop hl
    xor a ; ld a, 0
    ld [hli], a
    push hl
    dec bc
    ld a, b
    or c
    jr nz, .clear_map_loop
    pop hl
    ret