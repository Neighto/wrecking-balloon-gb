INCLUDE "macro.inc"
INCLUDE "playerConstants.inc"
INCLUDE "constants.inc"

SEQUENCE_UPDATE_REFRESH_TIME EQU %00000001

SECTION "sequence vars", WRAM0
    wSequenceWaitCounter:: DB
    wSequenceDataAddress:: DS 2
    wPhase:: DB

SECTION "sequence", ROMX

InitializeSequence::
    xor a ; ld a, 0
    ld [wSequenceWaitCounter], a
    ld [wPhase], a
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
    cp a, SEQUENCE_HIDE_PALETTE_KEY
    jr z, .hidePalette
    cp a, SEQUENCE_SHOW_PALETTE_KEY
    jr z, .showPalette
    cp a, SEQUENCE_COPY_SCORE_TO_TOTAL_1_KEY
    jr z, .copyFirstDigitScoreToTotal
    cp a, SEQUENCE_COPY_SCORE_TO_TOTAL_2_KEY
    jr z, .copyScoreToTotal
    cp a, SEQUENCE_ADD_SCORE_LIVES_KEY
    jr z, .addGainedLives
    cp a, SEQUENCE_END_KEY
    jp z, .end
    cp a, SEQUENCE_PALETTE_FADE_IN_KEY
    jr z, .fadeInPalette
    cp a, SEQUENCE_PALETTE_FADE_OUT_KEY
    jr z, .fadeOutPalette
    cp a, SEQUENCE_INCREASE_PHASE_KEY
    jr z, .increasePhase
    cp a, SEQUENCE_WAIT_FOREVER_KEY
    ; ret z
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
.hidePalette:
    call InitializeEmptyPalettes
    jr .updateSequenceDataCounter
.showPalette:
    call InitializePalettes
    jr .updateSequenceDataCounter
.copyFirstDigitScoreToTotal:
    push hl
    ld a, [wScore]
    and HIGH_HALF_BYTE_MASK
    ld d, a
    call AddTotal
    ld a, [wScore]
    and HIGH_HALF_BYTE_MASK
    ld d, a
    call DecrementPoints
    pop hl
    jr .updateSequenceDataCounter
.copyScoreToTotal:
    push hl
    call IsScoreZero
    pop hl
    jr z, .updateSequenceDataCounter
    ld d, 10
    call AddTotal
    ld d, 10
    call DecrementPoints
    call PointSound
    ret
.addGainedLives:
    ld a, [wLivesToAdd]
    cp a, 0
    jr z, .updateSequenceDataCounter
    dec a
    ld [wLivesToAdd], a
    ldh a, [hPlayerLives]
    cp a, PLAYER_MAX_LIVES
    ret nc
    inc a
    ldh [hPlayerLives], a
    call CollectSound
    ret
.fadeInPalette:
    call FadeInPalettes
    jr nz, .updateSequenceDataCounter
    ret
.fadeOutPalette:
    call FadeOutPalettes
    jr nz, .updateSequenceDataCounter
    ret
.increasePhase:
    ld a, [wPhase]
    inc a
    ld [wPhase], a
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