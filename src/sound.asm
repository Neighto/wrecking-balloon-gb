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

; AUDIO_OFF::
;     ldh a, [rNR52]
;     res 7, a
;     ldh [rNR52], a
;     ret

; AUDIO_ON::
;     ldh a, [rNR52]
;     set 7, a
;     ldh [rNR52], a
;     ret

InitializeSound::
    ; Master volume
    ld a, %11111111
    ldh [rNR50], a
    ldh [rNR51], a
    xor a ; ld a, 0
    ldh [hStopMusic], a
    ret

; Mute or unmute all channels' DACs
; Arg: D = Mute (1) or Unmute (0)
ChDACs::
.unmute::
    ld d, 0
    jr .toggle
.mute::
    ld d, 1
.toggle:
    ld b, 0 ; Channel 1
    ld c, d
    call hUGE_mute_channel
    ld b, 1 ; Channel 2
    ld c, d
    call hUGE_mute_channel
    ld b, 2 ; Channel 3
    ld c, d
    call hUGE_mute_channel
    ld b, 3 ; Channel 4
    ld c, d
    jp hUGE_mute_channel

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

FastBulletSound::
    ld a, %01011100
    ldh [rNR10], a ; Sweep register
    ld a, %01000000
    ldh [rNR11], a ; Sound length / wave pattern duty
    ld a, %11110010
    ldh [rNR12], a ; Volume envelope
    ld a, %11101111
    ldh [rNR13], a ; Frequency lo
    ld a, %11000101
    ldh [rNR14], a ; Frequency hi
    ret

OwVoiceSound::
    ld a, %00011101
    ldh [rNR10], a ; Sweep register
    ld a, %00000000
    ldh [rNR11], a ; Sound length / wave pattern duty
    ld a, %11110110
    ldh [rNR12], a ; Volume envelope
    ld a, %00111111
    ldh [rNR13], a ; Frequency lo
    ld a, %11000101
    ldh [rNR14], a ; Frequency hi
    ret

HelpVoiceSound::
    ld a, %00010101
    ldh [rNR10], a ; Sweep register
    ld a, %00000000
    ldh [rNR11], a ; Sound length / wave pattern duty
    ld a, %11110010
    ldh [rNR12], a ; Volume envelope
    ld a, %11111111
    ldh [rNR13], a ; Frequency lo
    ld a, %11000001
    ldh [rNR14], a ; Frequency hi
    ret

LifeUpSound::
    ld a, %00010101
    ldh [rNR10], a ; Sweep register
    ld a, %10000000
    ldh [rNR11], a ; Sound length / wave pattern duty
    ld a, %11110010
    ldh [rNR12], a ; Volume envelope
    ld a, %00111111
    ldh [rNR13], a ; Frequency lo
    ld a, %11000101
    ldh [rNR14], a ; Frequency hi
    ret

FallingSound::
    ld a, %01111111
    ldh [rNR10], a ; Sweep register
    ld a, %11000000
    ldh [rNR11], a ; Sound length / wave pattern duty
    ld a, %11111000
    ldh [rNR12], a ; Volume envelope
    ld a,%11111111
    ldh [rNR13], a ; Frequency lo
    ld a,%10000101
    ldh [rNR14], a ; Frequency hi
    ret

StopSweepSound::
    xor a ; ld a, 0
    ldh [rNR12], a
    ret

; *************************************************************
; Level Sound Effects (CH4)
; *************************************************************

PopSound::
    ld a, %11110001
    ldh [rNR42], a ; Volume envelope
    ld a, %01101100
    ldh [rNR43], a ; Polynomial counter
    ld a, %10000000
    ldh [rNR44], a ; Counter/consecutive initial
    ret

HitSound::
    ld a, 101110001
    ldh [rNR42], a ; Volume envelope
    ld a, %01000100
    ldh [rNR43], a ; Polynomial counter
    ld a, %10000000
    ldh [rNR44], a ; Counter/consecutive initial
    ret

ExplosionSound::
    ld a, %11110110
    ldh [rNR42], a ; Volume envelope
    ld a, %01111100
    ldh [rNR43], a ; Polynomial counter
    ld a, %10000000
    ldh [rNR44], a ; Counter/consecutive initial
    ret

FireworkSound::
    ld a, %10110110
    ldh [rNR42], a ; Volume envelope
    ld a, %01110001
    ldh [rNR43], a ; Polynomial counter
    ld a, %10000000
    ldh [rNR44], a ; Counter/consecutive initial
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
    ld a, %00000111
    ldh [rNR41], a ; Sound length
    ld a, %10100001
    ldh [rNR42], a ; Volume envelope
    ld a, %01000010
    ldh [rNR43], a ; Polynomial counter
    ld a, %11000000
    ldh [rNR44], a ; Counter/consecutive initial
    ret

BossNeedleSound::
    ld a, %000001111
    ldh [rNR41], a ; Sound length
    ld a, %10100001
    ldh [rNR42], a ; Volume envelope
    ld a, %01010011
    ldh [rNR43], a ; Polynomial counter
    ld a, %11000000
    ldh [rNR44], a ; Counter/consecutive initial
    ret

BoostSound::
    ld a, %10000011
    ldh [rNR42], a ; Volume envelope
    ld a, %01010000
    ldh [rNR43], a ; Polynomial counter
    ld a, %10000000
    ldh [rNR44], a ; Counter/consecutive initial
    ret

CountdownSound::
    ld a, %10000001
    ldh [rNR42], a ; Volume envelope
    ld a, %00111111
    ldh [rNR43], a ; Polynomial counter
    ld a, %10000000
    ldh [rNR44], a ; Counter/consecutive initial
    ret

; *************************************************************
; Menu Sound Effects
; *************************************************************

TitleSplashSound::
    ld a, %10110111
    ldh [rNR42], a ; Volume envelope
    ld a, %01110000
    ldh [rNR43], a ; Polynomial counter
    ld a, %10000000
    ldh [rNR44], a ; Counter/consecutive initial
    ret

RisingSound::
    ld a, %01110111
    ldh [rNR10], a ; Sweep register
    ld a, %11000000
    ldh [rNR11], a ; Sound length / wave pattern duty
    ld a, %11111000
    ldh [rNR12], a ; Volume envelope
    ld a,%10111111
    ldh [rNR13], a ; Frequency lo
    ld a,%10000100
    ldh [rNR14], a ; Frequency hi
    ret

; *************************************************************
; Stage Clear Sound Effects
; *************************************************************

; Arg: B = Frequency lower data
; Arg: C = Frequency higher data
BassSoundCommon:
    xor a
    ldh [rNR30], a ; Sound off
    cpl
    ldh [rNR30], a ; Sound on
    ld a, %11110010
    ldh [rNR31], a ; Sound length
    ld a, %00100000
    ldh [rNR32], a ; Select output level
    ld a, b
    ldh [rNR33], a ; Frequency lo
    ld a, c
    ldh [rNR34], a ; Frequency hi
    ret

BassSoundA::
    ld b, %11111100
    ld c, %11000101
    jp BassSoundCommon

BassSoundB::
    ld b, %00000000
    ld c, %11000011
    jp BassSoundCommon