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

PAUSE_TOGGLE_TIME EQU %00111111
PAUSE_WINDOW_ADDRESS EQU $9BC0

GAME_OVER_DISTANCE_FROM_TOP_IN_TILES EQU 2
PAUSE_DISTANCE_FROM_TOP_IN_TILES EQU 6
TOTAL_GAME_OVER_INDEX_ONE_ADDRESS EQU $9C2F

TOP_TEXT_ADDRESS EQU $9C04
TOP_SCORE_INDEX_ONE_ADDRESS EQU $9C0F

SECTION "window", ROM0

SetupWindow::
    ld a, WINDOW_START_Y
	ldh [rWY], a
	ld a, 7
	ldh [rWX], a
    ret

; Arg: BC = Score address
; Arg: HL = Index one address to update
RefreshScoreCommon:
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

; Arg: HL = Index one address to update
RefreshScore::
	ld bc, wScore
	jp RefreshScoreCommon

; Arg: HL = Index one address to update
RefreshTotal::
	ld bc, wTotal
	jp RefreshScoreCommon

; Arg: HL = Index one address to update
RefreshTopClassic::
	ld bc, wTopClassic
	jp RefreshScoreCommon

; Arg: HL = Index one address to update
RefreshTopEndless::
	ld bc, wTopEndless
	jp RefreshScoreCommon

LoadWindowTiles::
	; TILES
    ld bc, WindowTiles
    ld hl, _VRAM8800 + ((WINDOW_TILES_8800_OFFSET - $80) * $10)
    ld de, WindowTilesEnd - WindowTiles
    jp MEMCPY

LoadWindow::
	; TILEMAP
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
	jp RefreshWindow

; Arg: HL = Bar address
; Arg: A = Bar meter
RefreshBar:
	ld b, a

	; BLOCK 1 (LEFT)
.special_1_100:
	cp a, PLAYER_SPECIAL_BLOCK_1_100
	jr nc, .special_1_75
	ld a, BAR_100
	jr .endBlock1
.special_1_75:
	cp a, PLAYER_SPECIAL_BLOCK_1_75
	jr nc, .special_1_50
	ld a, BAR_75
	jr .endBlock1
.special_1_50:
	cp a, PLAYER_SPECIAL_BLOCK_1_50
	jr nc, .special_1_25
	ld a, BAR_50
	jr .endBlock1
.special_1_25:
	cp a, PLAYER_SPECIAL_BLOCK_1_25
	jr nc, .special_1_0
	ld a, BAR_25
	jr .endBlock1
.special_1_0:
	; cp a, PLAYER_SPECIAL_EMPTY
	; jr nc, .endBlock1
	ld a, BAR_0
	; jr .endBlock1
.endBlock1:
	ld [hli], a
	ld a, b

	; BLOCK 2 (RIGHT)
.special_2_100:
	cp a, PLAYER_SPECIAL_BLOCK_2_100
	jr nz, .special_2_75
	ld a, BAR_100
	jr .endBlock2
.special_2_75:
	cp a, PLAYER_SPECIAL_BLOCK_2_75
	jr nc, .special_2_50
	ld a, BAR_75
	jr .endBlock2
.special_2_50:
	cp a, PLAYER_SPECIAL_BLOCK_2_50
	jr nc, .special_2_25
	ld a, BAR_50
	jr .endBlock2
.special_2_25:
	cp a, PLAYER_SPECIAL_BLOCK_2_25
	jr nc, .special_2_0
	ld a, BAR_25
	jr .endBlock2
.special_2_0:
	; cp a, PLAYER_SPECIAL_EMPTY
	; jr nc, .endBlock2
	ld a, BAR_0
	; jr .endBlock2
.endBlock2:
	ld [hl], a
	ret 

; *************************************************************
; REFRESHWINDOW
; *************************************************************
RefreshWindow::
	ldh a, [hGlobalTimer]
	and REFRESH_WINDOW_WAIT_TIME
    ret nz
	; SCORE
	ld hl, SCORE_INDEX_ONE_ADDRESS
	call RefreshScore
	; LIVES
	ldh a, [hPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_ADDRESS], a
	; BOOST
	ld hl, BOOST_BAR_ADDRESS + 1
	ldh a, [hPlayerBoost]
	call RefreshBar
	; ATTACK
	ld hl, ATTACK_BAR_ADDRESS + 1
	ldh a, [hPlayerAttack]
	jp RefreshBar

; *************************************************************
; REFRESHGAMEOVERWINDOW
; *************************************************************
RefreshGameOverWindow::
	; Game over row
	ld bc, WindowMap + SCRN_X_B * GAME_OVER_DISTANCE_FROM_TOP_IN_TILES
    ld hl, _SCRN1
	ld de, SCRN_X_B
    ld a, WINDOW_TILES_8800_OFFSET
    call MEMCPY_WITH_OFFSET
	; Total row
    ld hl, _SCRN1 + SCRN_VX_B
	ld de, SCRN_X_B
    ld a, WINDOW_TILES_8800_OFFSET
    call MEMCPY_WITH_OFFSET
	; Score
	ld hl, TOTAL_GAME_OVER_INDEX_ONE_ADDRESS
	jp RefreshTotal

; *************************************************************
; REFRESHTOPSCOREWINDOW
; *************************************************************
LoadTopScoreWindow::
	; Fill in dark grey
	ld hl, _SCRN1
	ld bc, SCRN_VX_B * 2
	ld d, DARK_GREY_BKG_TILE
	call SetInRange
	; Top text
	ld bc, TopTextMap
	ld hl, TOP_TEXT_ADDRESS
	ld de, TopTextMapEnd - TopTextMap
	call MEMCPY
	; Top score
.refresh::
	call WaitVRAMAccessible
	ld hl, TOP_SCORE_INDEX_ONE_ADDRESS
	ld a, [wSelectedMode]
	cp a, CLASSIC_MODE
	jp z, RefreshTopClassic
	jp RefreshTopEndless

; *************************************************************
; PAUSEWINDOW
; *************************************************************

ShowPauseWindow::
    ld a, PAUSE_TOGGLE_TIME
    ldh [hPausedTimer], a
.skipResetTimer::
    ; Check if we can toggle
	ldh a, [hPausedTimer]
    inc	a
    ldh [hPausedTimer], a
    and PAUSE_TOGGLE_TIME
    ret nz
	jp ToggleWindow

LoadPauseWindow::
	; Except we actually load it on background layer not window
	; So we can toggle between the two with ease
	ld hl, PAUSE_WINDOW_ADDRESS
	ld bc, WindowMap + SCRN_X_B * PAUSE_DISTANCE_FROM_TOP_IN_TILES
	ld de, SCRN_X_B
	ld a, WINDOW_TILES_8800_OFFSET
	call MEMCPY_WITH_OFFSET
	; Fill in dark grey
	ld hl, PAUSE_WINDOW_ADDRESS + SCRN_VX_B
	ld bc, SCRN_X_B
	ld d, DARK_GREY_BKG_TILE
	jp SetInRange