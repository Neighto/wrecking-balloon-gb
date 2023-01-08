INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SCORE_INDEX_ONE_ADDRESS EQU $9C32
LIVES_ADDRESS EQU $9C0B
BOOST_BAR_ADDRESS EQU $9C22
ATTACK_BAR_ADDRESS EQU $9C26
REFRESH_WINDOW_WAIT_TIME EQU %00000011
WINDOW_TILES_8800_OFFSET EQU $D0

GAME_OVER_DISTANCE_FROM_TOP_IN_TILES EQU 2

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
	ld [$9C21], a ; Boost
	ld [$9C25], a ; Attack
	ld a, BAR_RIGHT_EDGE
	ld [$9C24], a ; Boost
	ld [$9C28], a ; Attack
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
	ld hl, BOOST_BAR_ADDRESS
	ldh a, [hPlayerBoost]
	cp a, PLAYER_BOOST_FULL
	jr z, .isBoostReady
.isBoostCharging:
	cp a, PLAYER_BOOST_75_PERC
	jr c, .isBoost75Percent
	cp a, PLAYER_BOOST_50_PERC
	jr c, .isBoost50Percent
	cp a, PLAYER_BOOST_25_PERC
	jr c, .isBoost25Percent
.isBoostEmpty:
	ld a, BAR_0
	ld [hli], a
	ld [hl], a
	jr .refreshAttackBar
.isBoost25Percent:
	ld a, BAR_50
	ld [hli], a
	ld a, BAR_0
	ld [hl], a
	jr .refreshAttackBar
.isBoost50Percent:
	ld a, BAR_100
	ld [hli], a
	ld a, BAR_0
	ld [hl], a
	jr .refreshAttackBar
.isBoost75Percent:
	ld a, BAR_100
	ld [hli], a
	ld a, BAR_50
	ld [hl], a
	jr .refreshAttackBar
.isBoostReady:
	ld a, BAR_100
	ld [hli], a
	ld [hl], a
	; ATTACK
.refreshAttackBar:
	ld hl, ATTACK_BAR_ADDRESS
	ldh a, [hPlayerAttack]
	cp a, PLAYER_ATTACK_FULL
	jr z, .isAttackReady
.isAttackCharging:
	cp a, PLAYER_ATTACK_75_PERC
	jr c, .isAttack75Percent
	cp a, PLAYER_ATTACK_50_PERC
	jr c, .isAttack50Percent
	cp a, PLAYER_ATTACK_25_PERC
	jr c, .isAttack25Percent
.isAttackEmpty:
	ld a, BAR_0
	ld [hli], a
	ld [hl], a
	ret
.isAttack25Percent:
	ld a, BAR_50
	ld [hli], a
	ld a, BAR_0
	ld [hl], a
	ret
.isAttack50Percent:
	ld a, BAR_100
	ld [hli], a
	ld a, BAR_0
	ld [hl], a
	ret
.isAttack75Percent:
	ld a, BAR_100
	ld [hli], a
	ld a, BAR_50
	ld [hl], a
	ret
.isAttackReady:
	ld a, BAR_100
	ld [hli], a
	ld [hl], a
	ret

RefreshGameOverWindow::
	; Game over row
	ld bc, WindowMap + SCRN_X_B * GAME_OVER_DISTANCE_FROM_TOP_IN_TILES
    ld hl, _SCRN1
	ld de, SCRN_X_B
    ld a, $D0
    call MEMCPY_WITH_OFFSET
	; Total row
    ld hl, _SCRN1 + $20
	ld de, SCRN_X_B
    ld a, $D0
    call MEMCPY_WITH_OFFSET
	; Score
	ld hl, $9C2F
	jp RefreshTotal
