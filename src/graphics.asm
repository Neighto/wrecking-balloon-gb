INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"
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

LoadPlayerTiles::
	ld bc, PlayerSpriteTiles
	ld hl, _VRAM8000+$20 ; Offset first 2 tiles as empty
	ld de, PlayerSpriteTilesEnd - PlayerSpriteTiles
	call MEMCPY
	ret

LoadEnemyTiles::
	ld bc, EnemyTiles
	ld hl, _VRAM8000 + $20 + (PlayerSpriteTilesEnd - PlayerSpriteTiles)
	ld de, EnemyTilesEnd - EnemyTiles
	call MEMCPY
	ld bc, CountdownTiles ; Could erase these countdown tiles after use if needed
	ld hl, _VRAM8000 + $20 + (PlayerSpriteTilesEnd - PlayerSpriteTiles) + (EnemyTilesEnd - EnemyTiles)
	ld de, CountdownTilesEnd - CountdownTiles
	call MEMCPY

	ld bc, PorcupineTiles
	ld hl, _VRAM8800+$500
	ld de, PorcupineTilesEnd - PorcupineTiles
	call MEMCPY
	ret

ClearAllTiles::
	push hl
	push bc
	RESET_IN_RANGE _VRAM8000, _VRAM8800 - _VRAM8000
	RESET_IN_RANGE _VRAM8800, _VRAM9000 - _VRAM8800
	RESET_IN_RANGE _VRAM9000, _SCRN0 - _VRAM9000
	pop bc
	pop hl
    ret

ClearMap::
	RESET_IN_RANGE _SCRN0, $400
	ret

ClearWindow::
	RESET_IN_RANGE _SCRN1, $400
	ret