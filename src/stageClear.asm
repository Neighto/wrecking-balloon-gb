INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "tileConstants.inc"

STAGE_CLEAR_PAUSE_LENGTH EQU 20

PLUS_TILE EQU $FF
SCORE_SC_INDEX_ONE_ADDRESS EQU $992F
TOTAL_SC_INDEX_ONE_ADDRESS EQU $996F
LIVES_SC_ADDRESS EQU $99AC
LIVES_TO_ADD_SC_ADDRESS EQU $99AE

SECTION "stage clear vars", WRAM0
    wStageClearTimer:: DB
    wStageClearFrame:: DB
    wLivesToAdd:: DB

SECTION "stage clear", ROMX

InitializeStageClear::
    ld a, STAGE_CLEAR_PAUSE_LENGTH
    ld [wStageClearTimer], a
    xor a ; ld a, 0
    ld [wStageClearFrame], a
    ld [wLivesToAdd], a
    ret

LoadStageClearGraphics::
	call LoadWindow
	ld bc, StageClearTiles
	ld hl, _VRAM9000
	ld de, StageClearTilesEnd - StageClearTiles
	call MEMCPY
	ld bc, StageClearMap
	ld hl, _SCRN0
    ld d, SCRN_Y_B
	call MEMCPY_SINGLE_SCREEN
	ret

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

UpdateStageClear::
    call _hUGE_dosound
    call RefreshStageClear

    ld a, [wGlobalTimer]
    and %00000011
    cp a, 0
    ret nz
    ld a, [wStageClearFrame]
    cp a, 0
    jr z, .pause
    cp a, 1
    jr z, .copyFirstDigitToTotal
    cp a, 2
    jr z, .copyPointsToTotal
    cp a, 3
    jr z, .pause
    cp a, 4
    jr z, .addGainedLives
    cp a, 5
    jr z, .pause
    cp a, 6
    jr z, .pause
    ; Jump to next level!
    jp SetupNextLevel
.pause:
    ld a, [wStageClearTimer]
    dec a 
    ld [wStageClearTimer], a
    cp a, 0
    ret nz
    ld a, STAGE_CLEAR_PAUSE_LENGTH
    ld [wStageClearTimer], a
    jr .endFrame
.copyFirstDigitToTotal:
    ld a, [wScore]
    and %00001111
    ld d, a
    call AddTotal
    ld a, [wScore]
    and %00001111
    ld d, a
    call DecrementPoints
    jr .endFrame
.copyPointsToTotal:
    call IsScoreZero
    jr z, .endFrame
    ld d, 10
    call AddTotal
    ld d, 10
    call DecrementPoints
    ret
.addGainedLives:
    ld a, [wLivesToAdd]
    cp a, 0
    jr z, .endFrame
    dec a
    ld [wLivesToAdd], a
    ld a, [wPlayerLives]
    cp a, PLAYER_MAX_LIVES
    ret nc
    inc a
    ld [wPlayerLives], a
    ret
.endFrame:
    ld a, [wStageClearFrame]
    inc a
    ld [wStageClearFrame], a
    ret