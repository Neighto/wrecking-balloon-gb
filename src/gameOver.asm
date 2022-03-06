INCLUDE "hardware.inc"

SECTION "game over", ROMX

TOTAL_SC_INDEX_ONE_ADDRESS EQU $998F

LoadGameOverGraphics::
	ld bc, GameOverTiles
	ld hl, _VRAM9000
	ld de, GameOverTilesEnd - GameOverTiles
	call MEMCPY
	ld bc, GameOverMap
	ld hl, _SCRN0
    ld d, SCRN_Y_B
	call MEMCPY_SINGLE_SCREEN
    ret

UpdateGameOver::
    ; call _hUGE_dosound
    ld hl, TOTAL_SC_INDEX_ONE_ADDRESS
	call RefreshTotal
    call ReadController
    ld a, [wControllerDown]
    and PADF_START | PADF_A
    jp nz, Start
    ret