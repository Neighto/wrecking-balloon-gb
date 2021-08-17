INCLUDE "hardware.inc"
INCLUDE "constants.inc"

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
  ; Sweep register
  ld a, %01111111
  ld [rNR10], a
  ; Sound length / wave pattern duty
  ld a, %11000000
  ld [rNR11], a
  ; Volume envelope
  ld a, %00111000
  ld [rNR12], a
  ; Frequency lo
  ld a,%11111111
  ld [rNR13], a
  ; Frequency hi
  ld a,%10001101
  ld [rNR14], a
  ret

StopFallingSound::
  ld a, %00000000
  ld [rNR12], a
  ret

CollectSound::
  ; Borrowed sound / more like collected item
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
  ret

WrongAnswerSound::
  ; Sound on/off
  ld a, %10000000
  ld [rNR30], a
  ; Sound length
  ld a, %11000001
  ld [rNR31], a
  ; Select output level
  ld a, %00100000 ; 100% volume
  ld [rNR32], a
  ; Frequency's higher data
  ld a, %11000010
  ld [rNR34], a
  ; Master volume
  ld  a,%11111111
  ld  [rNR50],a
  ld  [rNR51],a
  ret

Percussion::
  ; Volume envelope
  ld a, %10000001
  ld [rNR42], a
  ; Polynomial counter
  ld a, %00111111
  ld [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ld [rNR44], a
  ret

Percussion2::
  ; Volume envelope
  ld a, %10000001
  ld [rNR42], a
  ; Polynomial counter
  ld a, %00111011
  ld [rNR43], a
  ; Counter/consecutive initial
  ld a, %10000000
  ld [rNR44], a
  ret

Bass::
  ; Sound on/off
  ld a, %10000000
  ld [rNR30], a
  ; Sound length
  ld a, %11110000
  ld [rNR31], a
  ; Select output level
  ld a, %00100000 ; 100% volume
  ld [rNR32], a
  ; Frequency's higher data
  ld a, %11000011
  ld [rNR34], a
  ret

Song1:
  ; DW Percussion, Bass, Percussion2

PlayMusic::
  ; ld a, [global_timer]
  ; and TEMPO
  ; jr nz, .end

  ; ld a, [song_timer]
  ; inc a
  ; ld [song_timer], a
  ; ld c, a

  ; Read Song 1
  ; ld hl, Song1
  ; ld a, [song_index]
  ; ld c, a
  ; ld b, 0
  ; ; inc c ; possibly issue is here, can we deduce inc is successfully causing subsequent line to be read?
  ; ; inc c
  ; add hl, bc
  ; jp hl
.end:
  ret