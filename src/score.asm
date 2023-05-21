INCLUDE "playerConstants.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

SCORE_SIZE EQU 3
SCORE_MOVE_POINTS EQU 10

SECTION "score vars", WRAM0
wScore:: DS SCORE_SIZE
wTotal:: DS SCORE_SIZE
wTopClassic:: DS SCORE_SIZE
wTopEndless:: DS SCORE_SIZE

SECTION "score", ROM0

InitializeScore::
    ld bc, SCORE_SIZE
    ld hl, wScore
    jp ResetHLInRange

InitializeTotal::
    ld bc, SCORE_SIZE
    ld hl, wTotal
    jp ResetHLInRange

InitializeTopScores::
    ld bc, SCORE_SIZE
    ld hl, wTopClassic
    call ResetHLInRange
    ld bc, SCORE_SIZE
    ld hl, wTopEndless
    jp ResetHLInRange

; Arg: A = Points to receive (must be 1 byte BCD [max 99])
; Warning: will loop if we reach max points
AddPoints::
    call ToBCD
    ld hl, wScore
    ld e, SCORE_SIZE
    ; Now update hl and if there's a carry add to hl+1
.carry:
    add a, [hl]
    daa
    ld [hl], a
    ret nc
    ; Check if we reached end of score size
    dec e
    ld a, e
    cp a, 0
    ret z
    ; Continue
    inc l ; next byte of score
    ld a, 1 ; The carry value
    jr .carry

; Arg: A = Points to remove (must be 1 byte BCD [max 99])
DecrementPoints::
    call ToBCD
    ld hl, wScore
    ld e, SCORE_SIZE
.carry:
    ld d, a
    ld a, [hl]
    sub a, d
    daa
    ld [hl], a
    ret nc
    ; Check if we reached the end of score size
    dec e
    ld a, e
    cp a, 0
    jp z, InitializeScore
    ; Continue
    inc l
    ld a, 1
    jr .carry

AddTotal::
    ; a = points to receive (must be 1 byte BCD [max 99])
    ; Warning no restriction for hl going off rails but it never should
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

; Arg: HL = Score address
; Ret: Z/NZ = Score zero / not zero respectively
IsScoreZeroCommon:
    ld a, [hli]
    cp a, 0
    ret nz
    ld a, [hli]
    cp a, 0
    ret nz
    ld a, [hli]
    cp a, 0
    ret

; Ret: Z/NZ = Score zero / not zero respectively
IsScoreZero::
    ld hl, wScore
    jp IsScoreZeroCommon

; Ret: Z/NZ = Total zero / not zero respectively
IsTotalZero:
    ld hl, wTotal
    jp IsScoreZeroCommon

AddScoreToTotal::
    call IsTotalZero
    jr nz, .isNotZeroTotal
    ; Set score as total (just copy)
    ld hl, wScore
    ld a, [hli]
    ld [wTotal], a
    ld a, [hli]
    ld [wTotal + 1], a
    ld a, [hl]
    ld [wTotal + 2], a
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
    ld a, SCORE_MOVE_POINTS
    call AddTotal
    ld a, SCORE_MOVE_POINTS
    call DecrementPoints
    jr .loop

SetTopScore::
    ld a, [wSelectedMode]
    cp a, CLASSIC_MODE
	jr z, .setTopClassic
.setTopEndless:
    ld bc, wTopEndless
    jr .setTop
.setTopClassic:
    ld bc, wTopClassic
.setTop:
    ; Check if new score is greater
    LD_HL_BC
    push bc
    LD_BC_HL
    ld hl, wTotal
    CP_BC_HL SCORE_SIZE
    pop bc
    ret nc
    ; Update top score
    ld hl, wTotal
    ld a, [hli]
    ld [bc], a
    inc bc
    ld a, [hli]
    ld [bc], a
    inc bc
    ld a, [hl]
    ld [bc], a   
    ret