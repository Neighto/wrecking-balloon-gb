SECTION "score", ROM0

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
    jr nc, .end
    inc l ; next byte of score
    ld a, 1 ; The carry value
    jr .carry
.end:
    pop af
    pop hl
    ret