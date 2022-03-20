INCLUDE "hardware.inc"

SECTION "game over", ROMX

GAME_OVER_DISTANCE_FROM_TOP_IN_TILES EQU 18
TOTAL_SC_INDEX_ONE_ADDRESS EQU $994F

LoadGameOverGraphics::
	ld bc, StageEndTiles
	ld hl, _VRAM9000
	ld de, StageEndTilesEnd - StageEndTiles
	call MEMCPY
	ld bc, StageEndMap + SCRN_X_B * GAME_OVER_DISTANCE_FROM_TOP_IN_TILES
	ld hl, _SCRN0
    ld d, SCRN_Y_B
	call MEMCPY_SINGLE_SCREEN
    ret

InitializeGameOver::
    call AddScoreToTotal
    ret

UpdateGameOver::
    call _hUGE_dosound_with_end
    ld hl, TOTAL_SC_INDEX_ONE_ADDRESS
	call RefreshTotal
    call ReadController
    ld a, [wControllerDown]
    and PADF_START | PADF_A
    jp nz, Start
    ret