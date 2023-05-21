INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "game over", ROMX

; *************************************************************
; UPDATEGAMEOVER
; *************************************************************
UpdateGameOver::
    UPDATE_GLOBAL_TIMER
    call _hUGE_dosound
    call ReadController
    ldh a, [hControllerDown]
    and PADF_START | PADF_A
    jp nz, Restart
    ret