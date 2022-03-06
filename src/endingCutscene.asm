INCLUDE "hardware.inc"

SECTION "ending cutscene", ROMX

InitializeEndingCutscene::
    ld a, 120
	ld [rSCY], a
    ret

LoadEndingCutsceneGraphics::
	ld bc, CutsceneTiles
	ld hl, _VRAM9000
	ld de, CutsceneTilesEnd - CutsceneTiles
	call MEMCPY
	ld bc, CutsceneMap
	ld hl, _SCRN0
    ld d, SCRN_VY_B
	call MEMCPY_SINGLE_SCREEN
	ret

UpdateEndingCutscene::

    ret