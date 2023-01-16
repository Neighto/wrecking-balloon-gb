INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

SECTION "graphics", ROM0

ClearVRAM8000::
	ld hl, _VRAM8000
	ld bc, _VRAM8800 - _VRAM8000
	jp ResetHLInRange

ClearVRAM8800::
	ld hl, _VRAM8800
	ld bc, _VRAM9000 - _VRAM8800
	jp ResetHLInRange

ClearVRAM9000::
	ld hl, _VRAM9000
	ld bc, _SCRN0 - _VRAM9000
	jp ResetHLInRange

ClearMap::
	ld hl, _SCRN0
	ld bc, SCRN0_SIZE
	jp ResetHLInRange

ClearWindow::
	ld hl, _SCRN1
	ld bc, SCRN1_SIZE
	jp ResetHLInRange