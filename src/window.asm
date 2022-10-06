INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SCORE_INDEX_ONE_ADDRESS EQU $9C32
LIVES_ADDRESS EQU $9C0B
BAR_LEFT_EMPTY EQU $DF
BAR_LEFT_FULL EQU $E1
BAR_LEFT_HALF EQU $E3
BOOST_BAR_ADDRESS EQU $9C22
ATTACK_BAR_ADDRESS EQU $9C26
REFRESH_WINDOW_WAIT_TIME EQU %00000011

SECTION "window", ROMX

RefreshScore::
	; Argument hl is index one address to update
	ld bc, wScore
	; First digit
	ld a, [bc]
	and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Second digit
    ld a, [bc]
    swap a
	and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Third digit
	inc bc ; Move up score
	ld a, [bc]
    and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fourth digit
	ld a, [bc]
	swap a
    and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fifth digit
	inc bc ; Move up score
	ld a, [bc]
	and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Sixth digit
	ld a, [bc]
	swap a
    and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	ret

RefreshTotal::
	; Argument hl is index one address to update
	ld bc, wTotal
	; First digit
	ld a, [bc]
	and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Second digit
    ld a, [wTotal]
    swap a
	and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Third digit
	inc bc ; Move up total
	ld a, [bc]
    and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fourth digit
	ld a, [bc]
	swap a
    and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fifth digit
	inc bc ; Move up total
	ld a, [bc]
	and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Sixth digit
	ld a, [bc]
	swap a
    and HIGH_HALF_BYTE_MASK
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	ret

LoadWindow::
.loadTiles:
    ld bc, WindowTiles
    ld hl, _VRAM8800+$500
    ld de, WindowTilesEnd - WindowTiles
    call MEMCPY
.drawMap:
    ld bc, WindowMap
    ld hl, _SCRN1
    ld de, SCRN_X_B
    ld a, $D0
    call MEMCPY_WITH_OFFSET
    ld hl, _SCRN1 + SCRN_VX_B
    ld de, SCRN_X_B
    ld a, $D0
    call MEMCPY_WITH_OFFSET
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
	ld a, BAR_LEFT_EMPTY
	ld [hli], a
	inc a
	ld [hl], a
	jr .refreshAttackBar
.isBoost25Percent:
	ld a, BAR_LEFT_HALF
	ld [hli], a
	ld a, BAR_LEFT_EMPTY+1
	ld [hl], a
	jr .refreshAttackBar
.isBoost50Percent:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	ld a, BAR_LEFT_EMPTY+1
	ld [hl], a
	jr .refreshAttackBar
.isBoost75Percent:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	ld a, BAR_LEFT_HALF+1
	ld [hl], a
	jr .refreshAttackBar
.isBoostReady:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	inc a
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
	ld a, BAR_LEFT_EMPTY
	ld [hli], a
	inc a
	ld [hl], a
	ret
.isAttack25Percent:
	ld a, BAR_LEFT_HALF
	ld [hli], a
	ld a, BAR_LEFT_EMPTY+1
	ld [hl], a
	ret
.isAttack50Percent:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	ld a, BAR_LEFT_EMPTY+1
	ld [hl], a
	ret
.isAttack75Percent:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	ld a, BAR_LEFT_HALF+1
	ld [hl], a
	ret
.isAttackReady:
	ld a, BAR_LEFT_FULL
	ld [hli], a
	inc a
	ld [hl], a
	ret