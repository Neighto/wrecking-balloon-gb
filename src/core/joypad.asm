INCLUDE "hardware.inc"

SECTION "joypad", ROM0

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
	and %00001111
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
	and %00001111
	or b
	; Check if input reads the same
	ld b, a
	ld a, [joypad_down]
	cpl
	and b
	ld [joypad_pressed], a
	ld a, b
	ld [joypad_down], a
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