SECTION "score", ROMX

InitializeScore::
    xor a ; ld a, 0
    ld hl, score
	ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

AddPoints::
    ; takes 'd' argument as points to receive (must be 1 byte BCD [max 99])
    ; uses 'af' 'hl' as holder
    push af
    push hl
    ld a, [player_alive]
    and 1
    jr z, .end
    ; Alive so we can add points
    ld hl, score ; 1st byte of score
    ld a, d
    call ToBCD ; a is now BCD
    ; Now update hl and if there's a carry add to hl+1
.carry:
    add a, [hl]
    daa
    ld [hl], a
    jr nc, .noCarry
    inc l ; next byte of score
    ld a, 1 ; The carry value
    jr .carry
.noCarry:
    call RefreshScore
.end:
    pop af
    pop hl
    ret

GetScoreFromIndex::
    ; takes 'a' argument as index
    ; returns 'a' as score
    push hl
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
    pop hl
    ret
.firstNibble:
    ld a, [hl]
    jr .end
.secondNibble:
    ld a, [hl]
    swap a
.end:
    and %00001111
    pop hl
    ret