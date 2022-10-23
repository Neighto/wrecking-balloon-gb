INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "game over", ROMX

InitializeGameOver::
    jp AddScoreToTotal

UpdateGameOver::
    UPDATE_GLOBAL_TIMER
    call _hUGE_dosound_with_end
    call ReadController
    ldh a, [hControllerDown]
    and PADF_START | PADF_A
    jp nz, Start
    ret