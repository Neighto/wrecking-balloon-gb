INCLUDE "macro.inc"
INCLUDE "playerConstants.inc"
INCLUDE "constants.inc"

SEQUENCE_UPDATE_REFRESH_TIME EQU %00000001

SECTION "sequence vars", HRAM
hSequenceWaitCounter:: DB
hSequenceDataAddress:: DS 2
hSequencePhase:: DB
hSequencePlaySong:: DB
hSequenceWaitUntilCheck:: DB

SECTION "sequence", ROMX

InitializeSequence::
    xor a ; ld a, 0
    ldh [hSequenceWaitCounter], a
    ldh [hSequencePhase], a
    ldh [hSequencePlaySong], a
    ldh [hSequenceWaitUntilCheck], a
    ; Must initialize hSequenceDataAddress elsewhere
    ret

; *************************************************************
; UPDATE
; *************************************************************
SequenceDataUpdate::
    ; Frequency we read 
    ldh a, [hGlobalTimer]
    and SEQUENCE_UPDATE_REFRESH_TIME
    ret nz

    ; Read next sequence instruction
    ldh a, [hSequenceDataAddress]
    ld l, a
    ldh a, [hSequenceDataAddress+1]
    ld h, a
    ld a, [hl]

    ; Interpret
    cp a, SEQUENCE_WAIT_KEY
    jr z, .wait
    cp a, SEQUENCE_WAIT_UNTIL_KEY
    jr z, .waitUntil
    cp a, SEQUENCE_PALETTE_FADE_IN_KEY
    jr z, .fadeInPalette
    cp a, SEQUENCE_PALETTE_FADE_OUT_KEY
    jr z, .fadeOutPalette
    cp a, SEQUENCE_HIDE_PALETTE_KEY
    jr z, .hidePalette
    cp a, SEQUENCE_SHOW_PALETTE_KEY
    jr z, .showPalette
    cp a, SEQUENCE_SHOW_PALETTE_2_KEY
    jr z, .showPalette2
    cp a, SEQUENCE_INCREASE_PHASE_KEY
    jr z, .increasePhase
    cp a, SEQUENCE_PLAY_SONG_KEY
    jr z, .playSong
    cp a, SEQUENCE_END_KEY
    jr z, .end
    ret
.wait:
    ; Next instruction: amount to wait
    inc hl
    ldh a, [hSequenceWaitCounter]
    cp a, [hl]
    jr nc, .waitEnd
    inc a
    ldh [hSequenceWaitCounter], a
    ret
.waitEnd:
    xor a ; ld a, 0
    ldh [hSequenceWaitCounter], a
    jr .updateSequenceDataCounter
.waitUntil:
    ldh a, [hSequenceWaitUntilCheck]
    cp a, 0
    ret z
.waitUntilEnd:
    xor a ; ld a, 0
    ldh [hSequenceWaitUntilCheck], a
    jr .updateSequenceDataCounter
.hidePalette:
    call InitializeEmptyPalettes
    jr .updateSequenceDataCounter
.showPalette:
    call InitializePalettes
    jr .updateSequenceDataCounter
.showPalette2:
    call InitializeStageClearPalettes
    jr .updateSequenceDataCounter
.fadeInPalette:
    call FadeInPalettes
    jr nz, .updateSequenceDataCounter
    ret
.fadeOutPalette:
    call FadeOutPalettes
    jr nz, .updateSequenceDataCounter
    ret
.playSong:
    ld a, 1
    ldh [hSequencePlaySong], a
    jr .updateSequenceDataCounter
.increasePhase:
    ldh a, [hSequencePhase]
    inc a
    ldh [hSequencePhase], a
    ; jr .updateSequenceDataCounter
.updateSequenceDataCounter:
    inc hl
    ld a, l
    ldh [hSequenceDataAddress], a
    ld a, h
    ldh [hSequenceDataAddress+1], a
    ret
.end:
    ; Next instructions: jump to address
    inc hl
    ld b, [hl]
    inc hl
    ld c, [hl]
    LD_HL_BC
    jp hl