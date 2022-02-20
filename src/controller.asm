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
	ret

ReadInput::
	; Select DPAD
	ld a, %00100000
	; Read multiple for accurate reading
	ld [_IO], a
	ld a, [_IO]
	ld a, [_IO]
	ld a, [_IO]
	ld a, [_IO]
	; Upper bits are DPAD (1 = pressed)
	cpl
	and HIGH_HALF_BYTE_MASK
	swap a
	ld b, a
	; Select Buttons
	ld a, %00010000
	; Read multiple for accurate reading
	ld [_IO], a  
	ld a, [_IO]
	ld a, [_IO]
	ld a, [_IO]
	ld a, [_IO]
	; Lower bits are Buttons (1 = pressed)
	cpl
	and HIGH_HALF_BYTE_MASK
	or b
	; Check if input reads the same
	ld b, a
	ld a, [wControllerDown]
	cpl
	and b
	ld [wControllerPressed], a
	ld a, b
	ld [wControllerDown], a
	ret

JOY_RIGHT::
	and %00010000
	jp z, JOY_FALSE
	ld a, $1
	ret
JOY_LEFT::
	and %00100000
	jp z, JOY_FALSE
	ld a, $1
	ret
JOY_UP::
	and %01000000
	jp z, JOY_FALSE
	ld a, $1
	ret
JOY_DOWN::
	and %10000000
	jp z, JOY_FALSE
	ld a, $1
	ret
JOY_A::
	and %00000001
	jp z, JOY_FALSE
	ld a, $1
	ret
JOY_B::
	and %00000010
	jp z, JOY_FALSE
	ld a, $1
	ret
JOY_SELECT::
	and %00000100
	jp z, JOY_FALSE
	ld a, $1
	ret
JOY_START::
	and %00001000
	jp z, JOY_FALSE
	ld a, $1
	ret
JOY_FALSE:
	ld a, $0
	ret