INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "controller vars", WRAM0
	wControllerDown:: DB
	wControllerPressed:: DB
	wPaused:: DB

SECTION "controller", ROM0

InitializeController::
	xor a ; ld a, 0
	ld [wPaused], a
	ld [wControllerDown], a
	ld [wControllerPressed], a
	ret

ReadController::
.dPad:
	ld a, P1F_GET_DPAD
	; Recommended to read multiple times
	ld [_IO], a
	ld a, [_IO]
	ld a, [_IO]
	cpl
	and HIGH_HALF_BYTE_MASK
	swap a
	ld b, a ; DPad info stored in b low bits
.buttons:
	ld a, P1F_GET_BTN
	; Recommended to read multiple times
	ld [_IO], a  
	ld a, [_IO]
	ld a, [_IO]
	cpl
	and HIGH_HALF_BYTE_MASK
	or b 
	ld b, a ; Button info stored in b high bits
.setControllerVars:
	ld a, [wControllerDown]
	cpl
	and b
	ld [wControllerPressed], a
	ld a, b
	ld [wControllerDown], a
	ret