INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"

SCORE_INDEX_ONE_ADDRESS EQU $9C32
LIVES_ADDRESS EQU $9C0B
BOOST_BAR_ADDRESS EQU $9C21
ATTACK_BAR_ADDRESS EQU $9C25
BAR_TILES EQU 4
REFRESH_WINDOW_WAIT_TIME EQU %00000011

GAME_OVER_DISTANCE_FROM_TOP_IN_TILES EQU 2
TOTAL_GAME_OVER_INDEX_ONE_ADDRESS EQU $9C2F

SECTION "window", ROM0

RefreshScore::
	; Argument hl is index one address to update
	ld bc, wScore
	; First digit
	ld a, [bc]
	and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Second digit
    ld a, [bc]
    swap a
	and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Third digit
	inc bc ; Move up score
	ld a, [bc]
    and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fourth digit
	ld a, [bc]
	swap a
    and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fifth digit
	inc bc ; Move up score
	ld a, [bc]
	and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Sixth digit
	ld a, [bc]
	swap a
    and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	ret

RefreshTotal::
	; Argument hl is index one address to update
	ld bc, wTotal
	; First digit
	ld a, [bc]
	and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Second digit
    ld a, [wTotal]
    swap a
	and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Third digit
	inc bc ; Move up total
	ld a, [bc]
    and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fourth digit
	ld a, [bc]
	swap a
    and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fifth digit
	inc bc ; Move up total
	ld a, [bc]
	and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Sixth digit
	ld a, [bc]
	swap a
    and LOW_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	ret

LoadWindow::
.loadTiles:
    ld bc, WindowTiles
    ld hl, _VRAM8800 + ((WINDOW_TILES_8800_OFFSET - $80) * $10)
    ld de, WindowTilesEnd - WindowTiles
    call MEMCPY
.drawMap:
	; Draw first row
    ld bc, WindowMap
    ld hl, _SCRN1
    ld de, SCRN_X_B
    ld a, WINDOW_TILES_8800_OFFSET
    call MEMCPY_WITH_OFFSET
	; Fill in dark grey
	ld hl, _SCRN1 + SCRN_VX_B
	ld bc, SCRN_X_B
	ld d, DARK_GREY_BKG_TILE
	call SetInRange
	; Draw boost and attack meter ends
	ld a, BAR_LEFT_EDGE
	ld [BOOST_BAR_ADDRESS], a ; Boost
	ld [ATTACK_BAR_ADDRESS], a ; Attack
	ld a, BAR_RIGHT_EDGE
	ld [BOOST_BAR_ADDRESS + BAR_TILES - 1], a ; Boost
	ld [ATTACK_BAR_ADDRESS + BAR_TILES - 1], a ; Attack
	ret

RefreshBar:
	; hl = bar address
	; a = bar meter

	; Check if special is charging
	cp a, PLAYER_SPECIAL_FULL
	jr z, .special100
	cp a, PLAYER_SPECIAL_75_PERC
	jr c, .special75
	cp a, PLAYER_SPECIAL_50_PERC
	jr c, .special50
	cp a, PLAYER_SPECIAL_25_PERC
	jr c, .special25
.specialEmpty:
	ld a, BAR_0
	ld [hli], a
	ld [hl], a
	ret
.special25:
	ld a, BAR_50
	ld [hli], a
	ld a, BAR_0
	ld [hl], a
	ret
.special50:
	ld a, BAR_100
	ld [hli], a
	ld a, BAR_0
	ld [hl], a
	ret
.special75:
	ld a, BAR_100
	ld [hli], a
	ld a, BAR_50
	ld [hl], a
	ret
.special100:
	ld a, BAR_100
	ld [hli], a
	ld [hl], a
	ret 

RefreshWindow::
	ldh a, [hGlobalTimer]
	and REFRESH_WINDOW_WAIT_TIME
    ret nz
	; SCORE
.refreshScore:
	ld hl, SCORE_INDEX_ONE_ADDRESS
	call RefreshScore
	; LIVES
.refreshLives:
	ldh a, [hPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_ADDRESS], a
	; BOOST
.refreshBoostBar:
	ld hl, BOOST_BAR_ADDRESS + 1
	ldh a, [hPlayerBoost]
	call RefreshBar
	; ATTACK
.refreshAttackBar:
	ld hl, ATTACK_BAR_ADDRESS + 1
	ldh a, [hPlayerAttack]
	jp RefreshBar

RefreshGameOverWindow::
	; Game over row
	ld bc, WindowMap + SCRN_X_B * GAME_OVER_DISTANCE_FROM_TOP_IN_TILES
    ld hl, _SCRN1
	ld de, SCRN_X_B
    ld a, WINDOW_TILES_8800_OFFSET
    call MEMCPY_WITH_OFFSET
	; Total row
    ld hl, _SCRN1 + $20
	ld de, SCRN_X_B
    ld a, WINDOW_TILES_8800_OFFSET
    call MEMCPY_WITH_OFFSET
	; Score
	ld hl, TOTAL_GAME_OVER_INDEX_ONE_ADDRESS
	jp RefreshTotal
