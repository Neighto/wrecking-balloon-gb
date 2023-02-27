INCLUDE "hardware.inc"

POP_SOUND_TIMER EQU 40
EXPLOSION_SOUND_TIMER EQU 40
PROJECTILE_SOUND_TIMER EQU 20
BULLET_SOUND_TIMER EQU 20
BOOST_SOUND_TIMER EQU 40
HIT_SOUND_TIMER EQU 40

SECTION "sound vars", HRAM
  hStopMusic:: DB

SECTION "sound", ROM0

AUDIO_OFF::
  ldh a, [rNR52]
	res 7, a
	ldh [rNR52], a
	ret

AUDIO_ON::
  ldh a, [rNR52]
  set 7, a
	ldh [rNR52], a
	ret

InitializeSound::
  ; Master volume
  ld a, %11111111
  ldh [rNR50], a
  ldh [rNR51], a
  xor a ; ld a, 0
  ldh [hStopMusic], a
  ret

ClearSound::
  ; Handle obscure case toggling C3 DAC
  ; C3
  xor a ; ld a, 0
  ldh [rNR30], a
  cpl
  ldh [rNR30], a
  ; Silence channel
  ld a, $08
  ; C1
  ldh [rNR12], a
  ; C2
  ldh [rNR22], a
  ; C3
  ldh [rNR32], a
  ; C4
  ldh [rNR42], a
  ; Retrigger channel and reload NRx2
  ld a, $80
  ; C1
  ldh [rNR14], a
  ; C2
  ldh [rNR24], a
  ; C3
  ldh [rNR34], a
  ; C4
  ldh [rNR44], a
  ret

SetWaveRAMToSquareWave::
  xor a
  ldh [rNR30], a
  ld hl, _AUD3WAVERAM
  ld bc, $2
  ld d, 0
  call SetInRange
  ld bc, $D
  ld d, $FF
  call SetInRange
  ld a, %10000000
  ldh [rNR30], a
  ret

; *************************************************************
; Gameplay Sound Effects (CH1)
; Channel 1 is only used for this during a level
; *************************************************************

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

StopSweepSound::
  xor a ; ld a, 0
  ldh [rNR12], a
  ret

; *************************************************************
; Level Sound Effects (CH4)
; *************************************************************

PopSound::
  ; Volume envelope
  ld a, %11110001
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01101100
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

HitSound::
  ; Volume envelope
  ld a, 101110001
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01000100
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

ExplosionSound::
  ; Volume envelope
  ld a, %11110110
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01111100
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

FireworkSound::
  ; Volume envelope
  ld a, %10110110
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01110001
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

ProjectileSound::
  ; Sound length
  ld a, %00000010
  ldh [rNR41], a
  ; Volume envelope
  ld a, %10000101
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %00111111
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %11000000
  ldh [rNR44], a
  ret

BulletSound::
  ; Sound length
  ld a, %00000111
  ldh [rNR41], a
  ; Volume envelope
  ld a, %10100001
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01000010
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %11000000
  ldh [rNR44], a
  ret

BossNeedleSound::
  ; Sound length
  ld a, %000001111
  ldh [rNR41], a
  ; Volume envelope
  ld a, %10100001
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01010011
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %11000000
  ldh [rNR44], a
  ret

BoostSound::
  ; Volume envelope
  ld a, %10000011
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01010000
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
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

; *************************************************************
; Menu Sound Effects
; *************************************************************

TitleSplashSound::
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

CollectSound::
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

; *************************************************************
; Stage Clear Sound Effects
; *************************************************************

BassSoundA::
  ; Sound on/off
  xor a
  ldh [rNR30], a
  cpl
  ldh [rNR30], a
  ; Sound length
  ld a, %11110010
  ldh [rNR31], a
  ; Select output level
  ld a, %00100000
  ldh [rNR32], a
  ; Frequency's lower data
  ld a, %11111100
  ldh [rNR33], a
  ; Frequency's higher data
  ld a, %11000101
  ldh [rNR34], a
  ret

BassSoundB::
  ; Sound on/off
  xor a
  ldh [rNR30], a
  cpl
  ldh [rNR30], a
  ; Sound length
  ld a, %11110010
  ldh [rNR31], a
  ; Select output level
  ld a, %00100000
  ldh [rNR32], a
  ; Frequency's lower data
  ld a, %00000000
  ldh [rNR33], a
  ; Frequency's higher data
  ld a, %11000011
  ldh [rNR34], a
  ret