INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

NUMBERS_TILE_OFFSET EQU $E9
SCORE_INDEX_ONE_ADDRESS EQU $9C2C
LIVES_ADDRESS EQU $9C32
WORLD_ADDRESS EQU $9C01
LEVEL_ADDRESS EQU $9C03
REFRESH_WINDOW_WAIT_TIME EQU %00000100

; For updating tileset and tilemap

SECTION "graphics", ROM0

LoadClassicGameData::
	push hl
	push bc
	push de
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
	ld hl, _VRAM8800+$300
	ld de, ClassicParkTilesEnd - ClassicParkTiles
	call MEMCPY
	; Copy the countdown tiles
	ld bc, CountdownTiles
	ld hl, _VRAM8800+$400
	ld de, CountdownTilesEnd - CountdownTiles
	call MEMCPY
	; Copy the boss tiles
	ld bc, PorcupineTiles
	ld hl, _VRAM8800+$500
	ld de, PorcupineTilesEnd - PorcupineTiles
	call MEMCPY
	; Copy the window tiles
	ld bc, WindowTiles
	ld hl, _VRAM8800+$600
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
	pop de
	pop bc
	pop hl
	ret

LoadMenuData::
	push hl
	push bc
	push de
	ld bc, MenuTiles
	ld hl, _VRAM8000
	ld de, MenuTilesEnd - MenuTiles
	call MEMCPY
	ld bc, MenuTitleTiles
	ld hl, _VRAM9000
	ld de, _SCRN0 - _VRAM9000;MenuTitleTilesEnd - MenuTitleTiles
	call MEMCPY
	ld bc, MenuTitleTiles + (_SCRN0 - _VRAM9000)
	ld hl, _VRAM8800
	ld de, $8FF0 - $8800;MenuTitleTilesEnd - MenuTitleTiles
	call MEMCPY

	; Load Empty
	SET_IN_RANGE _SCRN0, _SCRN1 - _SCRN0, $0E ; Set whole screen to empty tile

	; ld bc, MenuMap
	; ld hl, _SCRN0
	; ld de, MenuMapEnd - MenuMap
	; call MEMCPY
	ld bc, MenuMap+$80
	ld hl, _SCRN0+$80
	ld de, $A0
	call MEMCPY
	pop de
	pop bc
	pop hl
	ret

RefreshScore:
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

RefreshLives:
	push af
	ld a, [wPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_ADDRESS], a
	pop af
	ret

RefreshLevel:
	push af
	ld a, [wWorld]
	add NUMBERS_TILE_OFFSET
	ld [WORLD_ADDRESS], a
	ld a, [wLevel]
	add NUMBERS_TILE_OFFSET
	ld [LEVEL_ADDRESS], a
	pop af
	ret

RefreshWindow::
	ld a, [global_timer]
	and REFRESH_WINDOW_WAIT_TIME
	jr nz, .end
	call RefreshScore
	call RefreshLives
	call RefreshLevel
.end:
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
	push hl
	push bc
	RESET_IN_RANGE _SCRN0, $400
	pop bc
	pop hl
	ret

	; Function where we REPLACE tilemap for a new one by transition
ReplaceTilemapHorizontal::
	; Need to set wUpdateTilemapAddress before calling else crash
	push af
	push hl
	push de
	push bc
	; Can we update tilemap
	ld a, [wUpdateTilemapIndex]
	cp a, 0
	jr z, .end
	; Check if we have already checked this SCX value
	ld a, [wLastUpdatedSCX]
	ld b, a
	ldh a, [rSCX]
	cp a, b
	jr z, .end
	ld [wLastUpdatedSCX], a
	; Todo currently we check rSCX multiple times for the same column (but that helps reduce errors)
	; Get target tilemap
	ld hl, wUpdateTilemapAddress
	ld a, [hli]
	ld c, a
	ld a, [hl]
	ld b, a
	; Figure out column we want to update
	ldh a, [rSCX]
	ld d, 8
	call DIVISION
	cp a, 0
	jr nz, .handleZeroEnd
.handleZero:
	ld a, SCRN_VX_B
.handleZeroEnd:
	dec a
	; Set hl to the correct column
	ld d, a
	ld hl, _SCRN0
	add a, l
	ld l, a
	; Set bc to the correct column
	ld a, d
	add a, c
	ld c, a
	; Set screen height to load in	
	ld d, SCRN_Y_B-2
.loop:
	; Update tile
	ld a, [bc]
	ld e, a
	ld a, [wUpdateTilemapOffset]
	add a, e
	ld [hl], a
	; Jump to next row
	ld a, c
	add a, $20
	ld c, a
	ld a, b
	adc a, 0 ; TODO use ADD_TO_HL
	ld b, a
	ld a, [bc]
	; Jump to next row
	ld a, l
	add a, $20
	ld l, a
	ld a, h
	adc a, 0
	ld h, a
	; Do we loop
	dec d
	ld a, d
	cp a, 0
	jr nz, .loop
.end:
	pop bc
	pop de
	pop hl
	pop af
	ret

MoveToNextTilemap::
	; Only set the next tilemap to load if we are between the 0th and 1st tile
	push hl
	push af
	; Should we update tilemap
	ld hl, wHasUpdatedNextTilemapAddress
	ldh a, [rSCX]
	cp a, BITS_IN_BYTE-1
	jr c, .canUpdateTilemap
	; Should we reset tilemap address
	cp a, 2*BITS_IN_BYTE-1
	jr nc, .end
	xor a ; ld a, 0 
	ld [hl], a
	jr .end
.canUpdateTilemap:
	; Have we already updated tilemap address
	ld a, [hl]
	cp a, 0
	jr nz, .end
	; Update tilemap address
	ld a, 1
	ld [hl], a
	ld a, [wUpdateTilemapIndex]
	cp a, 0
	jr z, .clouds2
	cp a, 1
	jr z, .clouds2
.clouds1:
	; Default loaded tilemap
	ld hl, wUpdateTilemapAddress
	ld a, LOW(BackgroundMap)
	ld [hli], a
	ld a, HIGH(BackgroundMap)
	ld [hl], a
	ld a, $0
	ld [wUpdateTilemapOffset], a
	ld a, 1
	ld [wUpdateTilemapIndex], a
	jr .end
.clouds2:
	ld hl, wUpdateTilemapAddress
	ld a, LOW(World2Map)
	ld [hli], a
	ld a, HIGH(World2Map)
	ld [hl], a
	ld a, $37
	ld [wUpdateTilemapOffset], a
	ld a, 2
	ld [wUpdateTilemapIndex], a
.end:
	pop af
	pop hl
	ret