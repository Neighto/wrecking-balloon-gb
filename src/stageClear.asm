INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

STAGE_CLEAR_UPDATE_TIME EQU %00000010
STAGE_CLEAR_PAUSE_LENGTH EQU 40

PLUS_TILE EQU $FF
SCORE_SC_INDEX_ONE_ADDRESS EQU $98CF
TOTAL_SC_INDEX_ONE_ADDRESS EQU $990F
LIVES_SC_ADDRESS EQU $994C
LIVES_TO_ADD_SC_ADDRESS EQU $994E
STAGE_NUMBER_ADDRESS EQU $9889

SECTION "stage clear vars", WRAM0
    wStageClearTimer:: DB
    wStageClearFrame:: DB
    wLivesToAdd:: DB
    wPointSound:: DB
    wStageNumberOAM:: DB

SECTION "stage clear", ROMX

InitializeStageClear::
    ld a, STAGE_CLEAR_PAUSE_LENGTH
    ld [wStageClearTimer], a
    xor a ; ld a, 0
    ld [wStageClearFrame], a
    ld [wLivesToAdd], a
    ld [wPointSound], a
    ld [wStageNumberOAM], a
    call RefreshStageClear
    ret

LoadStageClearGraphics::
	ld bc, StageEndTiles
	ld hl, _VRAM9000
	ld de, StageEndTilesEnd - StageEndTiles
	call MEMCPY
	ld bc, StageEndMap
	ld hl, _SCRN0
    ld d, SCRN_Y_B
	call MEMCPY_SINGLE_SCREEN
	ret

SpawnStageNumber::
	ld b, 1
	call RequestOAMSpace
	jr z, .end
.availableSpace:
	ld a, b
	ld [wStageNumberOAM], a
	SET_HL_TO_ADDRESS wOAM, wStageNumberOAM
	ld a, 48 ; y
	ld [hli], a
	ld a, 84 ; x
	ld [hli], a
    ld a, [wLevel]
    dec a
    add NUMBERS_TILE_OFFSET
	ld [hli], a
	ld [hl], OAMF_PAL0
.end:
	ret

RefreshAddLives::
	ld a, [wLivesToAdd]
	cp a, 0
	jr nz, .hasLivesToAdd
	ld a, DARK_GREY_BKG_TILE
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

	ldh a, [hPlayerLives]
	add NUMBERS_TILE_OFFSET
	ld [LIVES_SC_ADDRESS], a

    ; ld a, [wLevel]
    ; dec a
    ; add NUMBERS_TILE_OFFSET
	; ld [STAGE_NUMBER_ADDRESS], a

	call RefreshAddLives
	ret

PointSound::
	ld a, [wPointSound]
	cp a, 0
	jr nz, .soundB
.soundA:
	ld a, 1
	ld [wPointSound], a
	call BassSoundA
	jr .endPointSound
.soundB:
	ld a, 0
	ld [wPointSound], a
	call BassSoundB
.endPointSound:
    ret

UpdateStageClear::
    UPDATE_GLOBAL_TIMER
    call _hUGE_dosound
    call RefreshStageClear
.fadeIn:
    call FadeInPalettes
	ret z
.hasFadedIn:
    ldh a, [hGlobalTimer]
    and STAGE_CLEAR_UPDATE_TIME
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
.fadeOut:
    call FadeOutPalettes
    ret z
.hasFadedOut:
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
    and HIGH_HALF_BYTE_MASK
    ld d, a
    call AddTotal
    ld a, [wScore]
    and HIGH_HALF_BYTE_MASK
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
    call PointSound
    ret
.addGainedLives:
    ld a, [wLivesToAdd]
    cp a, 0
    jr z, .endFrame
    dec a
    ld [wLivesToAdd], a
    ldh a, [hPlayerLives]
    cp a, PLAYER_MAX_LIVES
    ret nc
    inc a
    ldh [hPlayerLives], a
    call CollectSound
    ret
.endFrame:
    ld a, [wStageClearFrame]
    inc a
    ld [wStageClearFrame], a
    ret