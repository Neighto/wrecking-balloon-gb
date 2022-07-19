INCLUDE "hardware.inc"

SECTION "sound", ROMX

AUDIO_OFF::
	xor a ; ld a, 0
	ldh [rNR52], a
	ret

AUDIO_ON::
  ld a, %10001111
	ldh [rNR52], a
	ret

InitializeSound::
  ; Master volume
  ld a, %11111111
  ldh [rNR50], a
  ldh [rNR51], a
  ret

PopSound::
  ; Volume envelope
  ld a, %11110001
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01101011
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

ExplosionSound::
  ; Volume envelope
  ld a, %10110111
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01110001
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

WaveSound::
  ; Volume envelope
  ld a, %10110111
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01110000
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

FallingSound::
  ; Sweep register
  ld a, %01111111
  ldh [rNR10], a
  ; Sound length / wave pattern duty
  ld a, %11000000
  ldh [rNR11], a
  ; Volume envelope
  ld a, %11111000
  ldh [rNR12], a
  ; Frequency lo
  ld a,%11111111
  ldh [rNR13], a
  ; Frequency hi
  ld a,%10000101
  ldh [rNR14], a
  ret

RisingSound::
  ; Sweep register
  ld a, %01110111
  ldh [rNR10], a
  ; Sound length / wave pattern duty
  ld a, %11000000
  ldh [rNR11], a
  ; Volume envelope
  ld a, %11111000
  ldh [rNR12], a
  ; Frequency lo
  ld a,%10111111
  ldh [rNR13], a
  ; Frequency hi
  ld a,%10000100
  ldh [rNR14], a
  ret

StopSweepSound::
  xor a ; ld a, 0
  ldh [rNR12], a
  ret

CollectSound::

  ; TODO add in relevant areas
  ; ld b, 0
	; ld c, 1
	; call hUGE_mute_channel


  ; Sweep register
  ld a, %11110110
  ldh [rNR10], a
  ; Sound length / wave pattern duty
  ld a, %11000000
  ldh [rNR11], a
  ; Volume envelope
  ld a, %11110010
  ldh [rNR12], a
  ; Frequency lo
  ld a, %11111111
  ldh [rNR13], a
  ; Frequency hi
  ld a, %10000110
  ldh [rNR14], a
  ret

CountdownSound::
  ; Volume envelope
  ld a, %10000001
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %00111111
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

BassSoundA::
  ; Sound on/off
  ld a, %10000000
  ldh [rNR30], a
  ; Sound length
  ld a, %11110010
  ldh [rNR31], a
  ; Select output level
  ld a, %00100000
  ldh [rNR32], a
  ; Frequency's lower data
  ld a, %01011000 ; 0110 1000
  ldh [rNR33], a
  ; Frequency's higher data
  ld a, %11000100
  ldh [rNR34], a
  ret

BassSoundB::
  ; Sound on/off
  ld a, %10000000
  ldh [rNR30], a
  ; Sound length
  ld a, %11110010
  ldh [rNR31], a
  ; Select output level
  ld a, %00100000
  ldh [rNR32], a
  ; Frequency's lower data
  ld a, %01101000
  ldh [rNR33], a
  ; Frequency's higher data
  ld a, %11000100
  ldh [rNR34], a
  ret

ClearSound::
  xor a ; ld a, 0
  ; C1
  ldh [rNR12], a
  ; C2
  ldh [rNR22], a
  ; C3
  ldh [rNR30], a
  ; C4
  ldh [rNR42], a

  ld hl, _AUD3WAVERAM
  ld bc, $F
  call ResetHLInRange
  ret