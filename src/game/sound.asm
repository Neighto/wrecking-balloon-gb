INCLUDE "hardware.inc"

SECTION "sound", ROMX

AUDIO_OFF::
	xor a ; ld a, 0
	ld [rNR52], a
	ret

AUDIO_ON::
    ld a, 1
	ld [rNR52], a
	ret

PopSound::
    ; Sound length
    ld a, %00011110
    ld [rNR41], a
    ; Volume envelope
    ld a, %10000001
    ld [rNR42], a
    ; Polynomial counter
    ld a, %01111011
    ld [rNR43], a
    ; Counter/consecutive Initial
    ld a, %10000000
    ld [rNR44], a
    ; Master volume
    ld  a,%11111111
    ld  [rNR50],a
    ld  [rNR51],a
    ret

FallingSound::
    ret