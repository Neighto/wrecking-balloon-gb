INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

SECTION "graphics", ROM0

AddBGTiles8800Method::
	; bc = source tile address
	; de = size of source
	push hl
	push af
	ld hl, _VRAM9000

	; Does size exceed block size
	ld a, LOW(de)
	cp a, LOW(TILE_BLOCK_SIZE)
	jr nc, .tilesExceedBlock
.tilesFitBlock:
	call MEMCPY
	jr .end
.tilesExceedBlock:
	push de
	ld de, TILE_BLOCK_SIZE
	call MEMCPY ; bc has now moved de from MEMCPY
	pop de
	LD_HL_DE
	SUB_FROM_HL_16 TILE_BLOCK_SIZE
	LD_DE_HL
	ld hl, _VRAM8800
	call MEMCPY
.end:
	pop af
	pop hl
	ret

ClearAllTiles::
	push hl
	push bc
	ld hl, _VRAM8000
	ld bc, _VRAM8800 - _VRAM8000
	call ResetHLInRange
	ld hl, _VRAM8800
	ld bc, _VRAM9000 - _VRAM8800
	call ResetHLInRange
	ld hl, _VRAM9000
	ld bc, _SCRN0 - _VRAM9000
	call ResetHLInRange
	pop bc
	pop hl
    ret

ClearMap::
	ld hl, _SCRN0
	ld bc, SCRN0_SIZE
	call ResetHLInRange
	ret

ClearWindow::
	ld hl, _SCRN1
	ld bc, SCRN1_SIZE
	call ResetHLInRange
	ret