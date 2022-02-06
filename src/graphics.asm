INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "macro.inc"

NUMBERS_TILE_OFFSET EQU $F5
SCORE_INDEX_ONE_ADDRESS EQU $9C32
LIVES_ADDRESS EQU $9C0B
BAR_LEFT_EMPTY EQU $EF
BAR_LEFT_FULL EQU $F1
BAR_LEFT_HALF EQU $F3
BOOST_BAR_ADDRESS EQU $9C22
ATTACK_BAR_ADDRESS EQU $9C26
REFRESH_WINDOW_WAIT_TIME EQU %00000100
TITLE_ADDRESS EQU $9880
TITLE_ADDRESS_OFFSET EQU TITLE_ADDRESS - _SCRN0
TITLE_SIZE EQU $9920 - TITLE_ADDRESS

; For updating tileset and tilemap

SECTION "graphics", ROM0

AddBGTiles8800Method:
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

LoadPlayerTiles:
	ld bc, PlayerSpriteTiles
	ld hl, _VRAM8000+$20 ; Offset first 2 tiles as empty
	ld de, PlayerSpriteTilesEnd - PlayerSpriteTiles
	call MEMCPY
	ret

LoadWindow:
.loadTiles:
	ld bc, WindowTiles
	ld hl, _VRAM8800+$600
	ld de, WindowTilesEnd - WindowTiles
	call MEMCPY
.loadMap:
	ld bc, WindowMap
	ld hl, _SCRN1
	ld de, WindowMapEnd - WindowMap
	ld a, $E0
	call MEMCPY_WITH_OFFSET
	ret

LoadEnemyTiles:
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

LoadParkGraphics::
	call LoadPlayerTiles
	call LoadWindow
	ld bc, OpeningCutsceneSpriteTiles
	ld hl, _VRAM8000 + $20 + (PlayerSpriteTilesEnd - PlayerSpriteTiles) + (EnemyTilesEnd - EnemyTiles) + (CountdownTilesEnd - CountdownTiles)
	ld de, OpeningCutsceneSpriteTilesEnd - OpeningCutsceneSpriteTiles
	call MEMCPY
	ld bc, OpeningCutsceneTiles
	ld hl, _VRAM9000
	ld de, OpeningCutsceneTilesEnd - OpeningCutsceneTiles
	call MEMCPY
	ld bc, OpeningCutsceneMap
	ld hl, _SCRN0
	ld de, OpeningCutsceneMapEnd - OpeningCutsceneMap
	call MEMCPY
	ret

LoadGameGraphics::
	; ld a, [wLevel]
	; cp a, 1
	; jr z, .level1
	; cp a, 2
	; jr z, .level2
	; cp a, 3
	; jr z, .level3
	; ret
.level1:
	call LoadEnemyTiles

	ld bc, Level1Tiles
	ld hl, _VRAM9000
	ld de, Level1TilesEnd - Level1Tiles
	call MEMCPY
	ld bc, Level1Map
	ld hl, _SCRN0
	ld de, Level1MapEnd - Level1Map
	call MEMCPY
	ret
.level2:
	; call LoadEnemyTiles ; Later might want to change loaded enemies

	; ld bc, Level2Tiles
	; ld hl, _VRAM9000
	; ld de, Level2TilesEnd - Level2Tiles
	; call MEMCPY
	; ld bc, Level2Map
	; ld hl, _SCRN0
	; ld de, Level2MapEnd - Level2Map
	; call MEMCPY
	ret
.level3:
	ret

LoadMenuOpeningGraphics::
	ld bc, MenuTitleTiles
	ld de, MenuTitleTilesEnd - MenuTitleTiles
	call AddBGTiles8800Method
	ld bc, MenuMap + TITLE_ADDRESS_OFFSET
	ld hl, _SCRN0 + TITLE_ADDRESS_OFFSET
	ld de, $A0
	call MEMCPY
	ret

LoadMenuGraphics::
	ld bc, MenuTiles
	ld hl, _VRAM8000 + $20
	ld de, MenuTilesEnd - MenuTiles
	call MEMCPY
	ld bc, MenuMap
	ld hl, _SCRN0
	ld de, MenuMapEnd - MenuMap
	call MEMCPY
	ret

RefreshScore:
	ld hl, SCORE_INDEX_ONE_ADDRESS
	; First digit
	ld a, [wScore]
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Second digit
    ld a, [wScore]
    swap a
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Third digit
	ld a, [wScore+1]
    and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fourth digit
	ld a, [wScore+1]
	swap a
    and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fifth digit
	ld a, [wScore+2]
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Sixth digit
	ld a, [wScore+2]
	swap a
    and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	ret

RefreshLives:
	ld a, [wPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_ADDRESS], a
	ret

RefreshBoostBar:
	ld hl, BOOST_BAR_ADDRESS
	ld a, [wPlayerBoost]
	cp a, PLAYER_BOOST_FULL
	jr z, .isReady
.isCharging:
	cp a, PLAYER_BOOST_75_PERC
	jr c, .is75Percent
	cp a, PLAYER_BOOST_50_PERC
	jr c, .is50Percent
	cp a, PLAYER_BOOST_25_PERC
	jr c, .is25Percent
.isEmpty:
	ld a, BAR_LEFT_EMPTY
	ld [hli], a
	inc a
	ld [hl], a
	ret
.is25Percent:
	ld a, BAR_LEFT_HALF
	ld [hli], a
	ld a, BAR_LEFT_EMPTY+1
	ld [hl], a
	ret
.is50Percent:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	ld a, BAR_LEFT_EMPTY+1
	ld [hl], a
	ret
.is75Percent:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	ld a, BAR_LEFT_HALF+1
	ld [hl], a
	ret
.isReady:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	inc a
	ld [hl], a
	ret 

RefreshAttackBar:
	ld hl, ATTACK_BAR_ADDRESS
	ld a, [wPlayerAttack]
	cp a, PLAYER_ATTACK_FULL
	jr z, .isReady
.isCharging:
	cp a, PLAYER_ATTACK_75_PERC
	jr c, .is75Percent
	cp a, PLAYER_ATTACK_50_PERC
	jr c, .is50Percent
	cp a, PLAYER_ATTACK_25_PERC
	jr c, .is25Percent
.isEmpty:
	ld a, BAR_LEFT_EMPTY
	ld [hli], a
	inc a
	ld [hl], a
	ret
.is25Percent:
	ld a, BAR_LEFT_HALF
	ld [hli], a
	ld a, BAR_LEFT_EMPTY+1
	ld [hl], a
	ret
.is50Percent:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	ld a, BAR_LEFT_EMPTY+1
	ld [hl], a
	ret
.is75Percent:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	ld a, BAR_LEFT_HALF+1
	ld [hl], a
	ret
.isReady:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	inc a
	ld [hl], a
	ret 

RefreshWindow::
	ld a, [wGlobalTimer]
	and REFRESH_WINDOW_WAIT_TIME
	jr nz, .end
	call RefreshScore
	call RefreshLives
	call RefreshBoostBar
	call RefreshAttackBar
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
	ld a, LOW(Level1Map)
	ld [hli], a
	ld a, HIGH(Level1Map)
	ld [hl], a
	ld a, $0
	ld [wUpdateTilemapOffset], a
	ld a, 1
	ld [wUpdateTilemapIndex], a
	jr .end
.clouds2:
	ld hl, wUpdateTilemapAddress
	ld a, LOW(Level2Map)
	ld [hli], a
	ld a, HIGH(Level2Map)
	ld [hl], a
	ld a, $37
	ld [wUpdateTilemapOffset], a
	ld a, 2
	ld [wUpdateTilemapIndex], a
.end:
	pop af
	pop hl
	ret