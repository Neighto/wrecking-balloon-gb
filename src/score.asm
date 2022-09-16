INCLUDE "playerConstants.inc"
INCLUDE "constants.inc"

SCORE_SIZE EQU 3

SECTION "score vars", WRAM0
wScore:: DS SCORE_SIZE
wTotal:: DS SCORE_SIZE

SECTION "score", ROMX

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
    ; d = points to receive (must be 1 byte BCD [max 99])
    ; Warning no CAP at max points
    ld a, d
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
    ; d = points to remove (must be 1 byte BCD [max 99])
    ld a, d
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
    call InitializeScore
    ret
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
    ; d = points to receive (must be 1 byte BCD [max 99])
.saveFourthDigit:
    ld a, [wTotal+1]
    swap a
    and HIGH_HALF_BYTE_MASK
    ld e, a
.toBCD:
    ld a, d
    call ToBCD
    ld hl, wTotal
.carry:
    add a, [hl]
    daa
    ld [hl], a
    push af
.checkAddLife:
    ld a, [wTotal+1]
    swap a
    and HIGH_HALF_BYTE_MASK
    cp a, e
    jr z, .checkLoop
.addLife:
    ld a, [wLivesToAdd]
    cp a, PLAYER_MAX_LIVES
    jr nc, .checkLoop
    inc a
    ld [wLivesToAdd], a
    call PopSound
.checkLoop:
    pop af
    ret nc
    inc l
    ld a, 1
    jr .carry
    
SetScoreAsTotal::
    ld hl, wScore
    ld a, [hli]
    ld [wTotal], a
    ld a, [hli]
    ld [wTotal+1], a
    ld a, [hl]
    ld [wTotal+2], a
    ret