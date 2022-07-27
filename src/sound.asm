INCLUDE "hardware.inc"

POP_SOUND_TIMER EQU 40
EXPLOSION_SOUND_TIMER EQU 40
PROJECTILE_SOUND_TIMER EQU 20
BULLET_SOUND_TIMER EQU 20
BOOST_SOUND_TIMER EQU 40
HIT_SOUND_TIMER EQU 40

SECTION "sound vars", WRAM0
  wChannel4SoundTimer:: DB

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
  xor a ; ld a, 0
  ld [wChannel4SoundTimer], a
  ret

StopSweepSound::
  xor a ; ld a, 0
  ldh [rNR12], a
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
  ret

SetWaveRAMToSquareWave::
  ld a, %00000000
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

SoundUpdate::
.channel4Sound:
  ld a, [wChannel4SoundTimer]
  cp a, 0
  ret z
  cp a, 1
  jr nz, .updateChannel4SoundTimer
.unmuteChannel4:
  ld b, 3 ; Channel 4
	ld c, 0 ; Unmute
	call hUGE_mute_channel
.updateChannel4SoundTimer:
  dec a
  ld [wChannel4SoundTimer], a
  ret

; Gameplay Sound Effects (CH1)
; Channel 1 is only used for this during a level

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

; Level Sound Effects (CH4)

PopSound::
  ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
  ld a, POP_SOUND_TIMER
  ld [wChannel4SoundTimer], a
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
  ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
  ld a, HIT_SOUND_TIMER
  ld [wChannel4SoundTimer], a
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
  ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
  ld a, EXPLOSION_SOUND_TIMER
  ld [wChannel4SoundTimer], a
  ; Volume envelope
  ld a, %11100110
  ldh [rNR42], a
  ; Polynomial counter
  ld a, %01111100
  ldh [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ldh [rNR44], a
  ret

FireworkSound::
  ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
  ld a, EXPLOSION_SOUND_TIMER
  ld [wChannel4SoundTimer], a
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
  ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
  ld a, PROJECTILE_SOUND_TIMER
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
  ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
  ld a, BULLET_SOUND_TIMER
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
  ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
  ld a, BULLET_SOUND_TIMER
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
  ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
  ld a, BOOST_SOUND_TIMER
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

; Menu Sound Effects

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

; Stage Clear Sound Effects

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
  ld a, %11111100
  ldh [rNR33], a
  ; Frequency's higher data
  ld a, %11000101
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
  ld a, %00000000
  ldh [rNR33], a
  ; Frequency's higher data
  ld a, %11000011
  ldh [rNR34], a
  ret