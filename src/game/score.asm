SECTION "score", ROMX

InitializeScore::
    xor a ; ld a, 0
    ld hl, score
	ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

IncreaseDifficulty:
    ; TODO really not the best system
    ; ld hl, difficulty_level
    ; inc [hl]
    ; ld a, [hl]
    ld a, [difficulty_level]
    inc a
    ld [difficulty_level], a

    ; Increase level each time X happens
.scoreLow:
.scoreMid:
.scoreHigh:
    ret

AddPoints::
    ; takes 'd' argument as points to receive (must be 1 byte BCD [max 99])
    ; uses 'af' 'hl' as holder
    push af
    push hl
    call IncreaseDifficulty ;; TEMPORARY
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