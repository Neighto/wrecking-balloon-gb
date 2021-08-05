SECTION "score", ROMX

InitializeScore::
    xor a ; ld a, 0
    ld hl, score
	ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

ToBCD::
    ; a = argument non-BCD number
    ; a = return BCD number
    ld d, a ; save a
    ld b, 10
    call MODULO
    ld e, a
    ld a, d ; refresh a
    ld b, 100
    call MODULO
    ld b, 10
    call DIVISION ; dangerous, corrupts c
    swap a
    or e
.end:
    ret

AddPoints::
    ; b = points to receive (must be 1 byte BCD [max 99])
    ld a, [player_alive]
    and 1
    jr z, .end
    ; Alive we can add points
    ld hl, score ; 1st byte of score
    ld a, b
    call ToBCD
    ; Add to hl, if there's a carry, then add to hl+1
    add [hl]
    daa
    ld [hl], a 
    jr nc, .noCarry
    inc l ; 2nd byte of score
    ld a, 1 ; The carry value
    add [hl]
    daa
    ld [hl], a 
    jr nc, .noCarry
    inc l ; 3rd byte of score
    ld a, 1 ; The carry value
    add [hl]
    daa
    ld [hl], a
.noCarry:
    call RefreshScore
.end:
    ret

GetScoreFromIndex::
    ; a = index
    ; a = return score
    ld hl, score
    cp a, 0
    jr z, .firstNibble
    cp a, 1
    jr z, .secondNibble
    inc l ; next byte
    cp a, 2
    jr z, .firstNibble
    cp a, 3
    jr z, .secondNibble
    inc l ; next byte
    cp a, 4
    jr z, .firstNibble
    cp a, 5
    jr z, .secondNibble
    ret
.firstNibble:
    ld a, [hl]
    jr .end
.secondNibble:
    ld a, [hl]
    swap a
.end:
    and %00001111
    ret