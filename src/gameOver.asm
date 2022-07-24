INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "game over", ROMX

GAME_OVER_DISTANCE_FROM_TOP_IN_TILES EQU 18
TOTAL_SC_INDEX_ONE_ADDRESS EQU $98EF

LoadGameOverTiles::
    ld bc, GameOverTiles
	ld hl, _VRAM8000 + $D00
	ld de, GameOverTilesEnd - GameOverTiles
	call MEMCPY
    ret

LoadGameOverGraphics::
    ld bc, GameOverMap
	ld hl, _SCRN0 + $A0
	ld de, GameOverMapEnd - GameOverMap
    ld a, $D0
    call MEMCPY_WITH_OFFSET
    ld bc, GameOverTotalMap
	ld hl, _SCRN0 + $E0
	ld de, GameOverTotalMapEnd - GameOverTotalMap
    ld a, $D9
    call MEMCPY_WITH_OFFSET
    ret

InitializeGameOver::
    call AddScoreToTotal
    ld hl, TOTAL_SC_INDEX_ONE_ADDRESS
	call RefreshTotal
    ret

UpdateGameOver::
    UPDATE_GLOBAL_TIMER
    call _hUGE_dosound_with_end
    call ReadController
    ldh a, [hControllerDown]
    and PADF_START | PADF_A
    jp nz, Start
    ret