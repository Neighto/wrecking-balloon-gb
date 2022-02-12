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

; 	; Function where we REPLACE tilemap for a new one by transition
; ReplaceTilemapHorizontal::
; 	; Need to set wUpdateTilemapAddress before calling else crash
; 	push af
; 	push hl
; 	push de
; 	push bc
; 	; Can we update tilemap
; 	ld a, [wUpdateTilemapIndex]
; 	cp a, 0
; 	jr z, .end
; 	; Check if we have already checked this SCX value
; 	ld a, [wLastUpdatedSCX]
; 	ld b, a
; 	ldh a, [rSCX]
; 	cp a, b
; 	jr z, .end
; 	ld [wLastUpdatedSCX], a
; 	; Todo currently we check rSCX multiple times for the same column (but that helps reduce errors)
; 	; Get target tilemap
; 	ld hl, wUpdateTilemapAddress
; 	ld a, [hli]
; 	ld c, a
; 	ld a, [hl]
; 	ld b, a
; 	; Figure out column we want to update
; 	ldh a, [rSCX]
; 	ld d, 8
; 	call DIVISION
; 	cp a, 0
; 	jr nz, .handleZeroEnd
; .handleZero:
; 	ld a, SCRN_VX_B
; .handleZeroEnd:
; 	dec a
; 	; Set hl to the correct column
; 	ld d, a
; 	ld hl, _SCRN0
; 	add a, l
; 	ld l, a
; 	; Set bc to the correct column
; 	ld a, d
; 	add a, c
; 	ld c, a
; 	; Set screen height to load in	
; 	ld d, SCRN_Y_B-2
; .loop:
; 	; Update tile
; 	ld a, [bc]
; 	ld e, a
; 	ld a, [wUpdateTilemapOffset]
; 	add a, e
; 	ld [hl], a
; 	; Jump to next row
; 	ld a, c
; 	add a, $20
; 	ld c, a
; 	ld a, b
; 	adc a, 0 ; TODO use ADD_TO_HL
; 	ld b, a
; 	ld a, [bc]
; 	; Jump to next row
; 	ld a, l
; 	add a, $20
; 	ld l, a
; 	ld a, h
; 	adc a, 0
; 	ld h, a
; 	; Do we loop
; 	dec d
; 	ld a, d
; 	cp a, 0
; 	jr nz, .loop
; .end:
; 	pop bc
; 	pop de
; 	pop hl
; 	pop af
; 	ret

; MoveToNextTilemap::
; 	; Only set the next tilemap to load if we are between the 0th and 1st tile
; 	push hl
; 	push af
; 	; Should we update tilemap
; 	ld hl, wHasUpdatedNextTilemapAddress
; 	ldh a, [rSCX]
; 	cp a, BITS_IN_BYTE-1
; 	jr c, .canUpdateTilemap
; 	; Should we reset tilemap address
; 	cp a, 2*BITS_IN_BYTE-1
; 	jr nc, .end
; 	xor a ; ld a, 0 
; 	ld [hl], a
; 	jr .end
; .canUpdateTilemap:
; 	; Have we already updated tilemap address
; 	ld a, [hl]
; 	cp a, 0
; 	jr nz, .end
; 	; Update tilemap address
; 	ld a, 1
; 	ld [hl], a
; 	ld a, [wUpdateTilemapIndex]
; 	cp a, 0
; 	jr z, .clouds2
; 	cp a, 1
; 	jr z, .clouds2
; .clouds1:
; 	; Default loaded tilemap
; 	ld hl, wUpdateTilemapAddress
; 	ld a, LOW(Level1Map)
; 	ld [hli], a
; 	ld a, HIGH(Level1Map)
; 	ld [hl], a
; 	ld a, $0
; 	ld [wUpdateTilemapOffset], a
; 	ld a, 1
; 	ld [wUpdateTilemapIndex], a
; 	jr .end
; .clouds2:
; 	ld hl, wUpdateTilemapAddress
; 	ld a, LOW(Level2Map)
; 	ld [hli], a
; 	ld a, HIGH(Level2Map)
; 	ld [hl], a
; 	ld a, $37
; 	ld [wUpdateTilemapOffset], a
; 	ld a, 2
; 	ld [wUpdateTilemapIndex], a
; .end:
; 	pop af
; 	pop hl
; 	ret