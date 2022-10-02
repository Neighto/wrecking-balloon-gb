INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "game over", ROMX

GAME_OVER_DISTANCE_FROM_TOP_IN_TILES EQU 2
TOTAL_SC_INDEX_ONE_ADDRESS EQU $98EF

LoadGameOverGraphics::
.loadTiles:
    ; Tiles should be loaded from window
.drawMap:
    ld bc, WindowMap + SCRN_X_B * GAME_OVER_DISTANCE_FROM_TOP_IN_TILES
	ld hl, _SCRN0 + $A0
	ld de, SCRN_X_B
    ld a, $D0
    call MEMCPY_WITH_OFFSET
	ld hl, _SCRN0 + $E0
	ld de, SCRN_X_B
    ld a, $D0
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