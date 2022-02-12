INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "tileConstants.inc"

NUMBERS_TILE_OFFSET EQU $F5
SCORE_INDEX_ONE_ADDRESS EQU $9C32
LIVES_ADDRESS EQU $9C0B
BAR_LEFT_EMPTY EQU $EF
BAR_LEFT_FULL EQU $F1
BAR_LEFT_HALF EQU $F3
BOOST_BAR_ADDRESS EQU $9C22
ATTACK_BAR_ADDRESS EQU $9C26
REFRESH_WINDOW_WAIT_TIME EQU %00000100

PLUS_TILE EQU $FF
SCORE_SC_INDEX_ONE_ADDRESS EQU $990F
TOTAL_SC_INDEX_ONE_ADDRESS EQU $994F
LIVES_SC_ADDRESS EQU $998C
LIVES_TO_ADD_SC_ADDRESS EQU $998E

SECTION "window", ROM0

RefreshScore:
	; Argument hl is index one address to update
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

RefreshTotal:
	; Argument hl is index one address to update
	; First digit
	ld a, [wTotal]
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Second digit
    ld a, [wTotal]
    swap a
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Third digit
	ld a, [wTotal+1]
    and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fourth digit
	ld a, [wTotal+1]
	swap a
    and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Fifth digit
	ld a, [wTotal+2]
	and %00001111
	add NUMBERS_TILE_OFFSET
	ld [hld], a
	; Sixth digit
	ld a, [wTotal+2]
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

LoadWindow::
.loadTiles:
    ld bc, WindowTiles
    ld hl, _VRAM8800+$600
    ld de, WindowTilesEnd - WindowTiles
    call MEMCPY
.drawMap:
    ld bc, WindowMap
    ld hl, _SCRN1
    ld de, SCRN_X_B
    ld a, $E0
    call MEMCPY_WITH_OFFSET
    ld hl, _SCRN1 + SCRN_VX_B
    ld de, SCRN_X_B
    ld a, $E0
    call MEMCPY_WITH_OFFSET
    ret

RefreshWindow::
	ld a, [wGlobalTimer]
	and REFRESH_WINDOW_WAIT_TIME
    ret nz
	ld hl, SCORE_INDEX_ONE_ADDRESS
	call RefreshScore
	call RefreshLives
	call RefreshBoostBar
	call RefreshAttackBar
	ret

; The following for STAGE CLEAR is ssentially all window tiles

RefreshAddLives::
	ld a, [wLivesToAdd]
	cp a, 0
	jr nz, .hasLivesToAdd
	ld a, EMPTY_TILE
	ld hl, LIVES_TO_ADD_SC_ADDRESS
	ld [hli], a
	ld [hl], a
	ret
.hasLivesToAdd:
	ld hl, LIVES_TO_ADD_SC_ADDRESS
	ld a, PLUS_TILE
	ld [hli], a
	ld a, [wLivesToAdd]
	add NUMBERS_TILE_OFFSET
	ld [hl], a
	ret

RefreshStageClear::
	ld hl, SCORE_SC_INDEX_ONE_ADDRESS
	call RefreshScore
	ld hl, TOTAL_SC_INDEX_ONE_ADDRESS
	call RefreshTotal

	ld a, [wPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_SC_ADDRESS], a

	call RefreshAddLives
	ret