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
    ; Volume envelope
    ld a, %10000001
    ld [rNR42], a
    ; Polynomial counter
    ld a, %01111011
    ld [rNR43], a
    ; Counter/consecutive initial
    ld a, %10000000
    ld [rNR44], a
    ; Master volume
    ld  a,%11111111
    ld  [rNR50],a
    ld  [rNR51],a
    ret

FallingSound::
  ;play boop on ch1
  ld  a,%10010110
  ld  [rNR10],a
  ld  a,%10000000
  ld  [rNR11],a
  ld  a,%01001001
  ld  [rNR12],a
  ld  a,%11111111
  ld  [rNR13],a
  ld  a,%10001101
  ld  [rNR14],a

    ; ; Sound on/off
    ; ld a, %10000000
    ; ld [rNR30], a
    ; ; Sound length
    ; ld a, %00000011
    ; ld [rNR31], a
    ; ; Select output level
    ; ld a, %00110000
    ; ld [rNR32], a
    ; ; Frequency's higher data
    ; ld a, %10100000
    ; ld [rNR34], a
    ; ; Master volume
    ; ld  a,%11111111
    ; ld  [rNR50],a
    ; ld  [rNR51],a
    ret