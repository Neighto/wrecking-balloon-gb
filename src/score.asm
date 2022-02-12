INCLUDE "playerConstants.inc"

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
    ld hl, wScore ; 1st byte of score
    ld a, d
    call ToBCD ; a is now BCD
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
    ld hl, wScore
    ld e, SCORE_SIZE
    ld a, d
    call ToBCD
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
    ld hl, wTotal
.saveFourthDigit:
    ld a, [wTotal+1]
    swap a
    and %00001111
    ld e, a
.toBCD:
    ld a, d
    call ToBCD
.carry:
    add a, [hl]
    daa
    ld [hl], a
    push af
.checkAddLife:
    ld a, [wTotal+1]
    swap a
    and %00001111
    cp a, e
    jr z, .checkLoop
.addLife:
    ld a, [wLivesToAdd]
    cp a, PLAYER_MAX_LIVES
    jr nc, .checkLoop
    inc a
    ld [wLivesToAdd], a
.checkLoop:
    pop af
    ret nc
    inc l
    ld a, 1
    jr .carry
    