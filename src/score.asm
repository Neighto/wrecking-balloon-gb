INCLUDE "playerConstants.inc"
INCLUDE "constants.inc"

SCORE_SIZE EQU 3

SECTION "score vars", WRAM0
wScore:: DS SCORE_SIZE
wTotal:: DS SCORE_SIZE

SECTION "score", ROM0

InitializeScore::
    xor a ; ld a, 0
    ld hl, wScore
	ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

InitializeTotal::
    xor a ; ld a, 0
    ld hl, wTotal
	ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

AddPoints::
    ; a = points to receive (must be 1 byte BCD [max 99])
    ; Warning no CAP at max points
    call ToBCD ; a is now BCD
    ld hl, wScore ; 1st byte of score
    ; Now update hl and if there's a carry add to hl+1
.carry:
    add a, [hl]
    daa
    ld [hl], a
    ret nc
    inc l ; next byte of score
    ld a, 1 ; The carry value
    jr .carry

DecrementPoints::
    ; a = points to remove (must be 1 byte BCD [max 99])
    call ToBCD
    ld hl, wScore
    ld e, SCORE_SIZE
.carry:
    dec e
    ld d, a
    ld a, [hl]
    sub a, d
    daa
    ld [hl], a
    ret nc
.checkCapAtZero:
    ld a, e
    cp a, 0
    jr nz, .noCap
    jp InitializeScore
.noCap:
    inc l
    ld a, 1
    jr .carry

IsScoreZero::
    ; z = zero
    ld hl, wScore
    ld a, [hli]
    cp a, 0
    ret nz
    ld a, [hli]
    cp a, 0
    ret nz
    ld a, [hli]
    cp a, 0
    ret

AddTotal::
    ; a = points to receive (must be 1 byte BCD [max 99])
    ; Warning no CAP at max points
    call ToBCD
    ld hl, wTotal
.carry:
    add a, [hl]
    daa
    ld [hl], a
    ret nc
    inc l
    ld a, 1
    jr .carry

IsTotalZero:
    ; z = zero
    ld hl, wTotal
    ld a, [hli]
    cp a, 0
    ret nz
    ld a, [hli]
    cp a, 0
    ret nz
    ld a, [hli]
    cp a, 0
    ret

AddScoreToTotal::
    call IsTotalZero
    jr nz, .isNotZeroTotal
.setScoreAsTotal:
    ld hl, wScore
    ld a, [hli]
    ld [wTotal], a
    ld a, [hli]
    ld [wTotal+1], a
    ld a, [hl]
    ld [wTotal+2], a
    ret
.isNotZeroTotal:
    ; TODO - this is super inefficient
    ld a, [wScore]
    and LOW_HALF_BYTE_MASK
    call AddTotal
    ld a, [wScore]
    and LOW_HALF_BYTE_MASK
    call DecrementPoints
.loop:
    call IsScoreZero
    ret z
    ld a, 10
    call AddTotal
    ld a, 10
    call DecrementPoints
    jr .loop