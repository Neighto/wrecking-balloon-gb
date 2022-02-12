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
    ; takes 'd' argument as points to receive (must be 1 byte BCD [max 99])
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
    ; takes 'd' argument as points to remove (must be 1 byte BCD [max 99])
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
    ; takes 'd' argument as points to receive (must be 1 byte BCD [max 99])
    ld hl, wTotal
    ld a, d
    call ToBCD
.carry:
    add a, [hl]
    daa
    ld [hl], a
    ret nc
    inc l
    ld a, 1
    jr .carry
    