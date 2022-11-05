INCLUDE "macro.inc"
INCLUDE "playerConstants.inc"
INCLUDE "constants.inc"

SEQUENCE_UPDATE_REFRESH_TIME EQU %00000001

SECTION "sequence vars", WRAM0
    wSequenceWaitCounter:: DB
    wSequenceDataAddress:: DS 2
    wSequencePhase:: DB
    wSequencePlaySong:: DB
    wSequenceWaitUntilCheck:: DB

SECTION "sequence", ROMX

InitializeSequence::
    xor a ; ld a, 0
    ld [wSequenceWaitCounter], a
    ld [wSequencePhase], a
    ld [wSequencePlaySong], a
    ld [wSequenceWaitUntilCheck], a
    ; Must initialize wSequenceDataAddress elsewhere
    ret

SequenceDataUpdate::
    ; Frequency we read 
    ldh a, [hGlobalTimer]
    and SEQUENCE_UPDATE_REFRESH_TIME
    ret nz

    ; Read next sequence instruction
    ld a, [wSequenceDataAddress]
    ld l, a
    ld a, [wSequenceDataAddress+1]
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
    ld a, [wSequenceWaitCounter]
    cp a, [hl]
    jr nc, .waitEnd
    inc a
    ld [wSequenceWaitCounter], a
    ret
.waitEnd:
    xor a ; ld a, 0
    ld [wSequenceWaitCounter], a
    jr .updateSequenceDataCounter
.waitUntil:
    ld a, [wSequenceWaitUntilCheck]
    cp a, 0
    ret z
.waitUntilEnd:
    xor a ; ld a, 0
    ld [wSequenceWaitUntilCheck], a
    jr .updateSequenceDataCounter
.hidePalette:
    call InitializeEmptyPalettes
    jr .updateSequenceDataCounter
.showPalette:
    call InitializePalettes
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
    ld [wSequencePlaySong], a
    jr .updateSequenceDataCounter
.increasePhase:
    ld a, [wSequencePhase]
    inc a
    ld [wSequencePhase], a
    ; jr .updateSequenceDataCounter
.updateSequenceDataCounter:
    inc hl
    ld a, l
    ld [wSequenceDataAddress], a
    ld a, h
    ld [wSequenceDataAddress+1], a
    ret
.end:
    ; Next instructions: jump to address
    inc hl
    ld b, [hl]
    inc hl
    ld c, [hl]
    LD_HL_BC
    jp hl