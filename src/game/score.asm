SECTION "score", ROMX

InitializeScore::
    xor a ; ld a, 0
    ld hl, score
	ld [hl], a
    inc l
    ld [hl], a
    ret

AddPoints::
    ; b = points to receive (must be 8-bit)
    ld a, [player_alive]
    and 1
    jr z, .end
    ; Alive we can add points
    ld hl, score ; 1st byte of score
    ld a, b
    ; Add to hl, if there's a carry, then add to hl+1
    add [hl]
    ld [hl], a 
    jr nc, .noCarry
    inc l ; 2nd byte of score
    inc [hl]
.noCarry:
    call RefreshScore
.end:
    ret

GetScore::
    ; returns hl = score
    ld a, [score]
    ld l, a
    ld a, [score+1]
    ld h, a
    ret

GetScoreFromIndex::
    ; a = index
    ; a = return score

    cp a, 0
    jr z, .firstDigit
    cp a, 1
    jr z, .secondDigit
    cp a, 2
    jr z, .thirdDigit
    ; ...

.firstDigit:
    call GetScore
	ld a, l ; get score 1st byte
	ld b, 10
	call MODULO
    ret
.secondDigit:
    call GetScore
	ld a, l ; get score 1st byte
	ld b, 100
	call MODULO
	ld b, 2
	call DIVISION ; should be able to do a bit shift...
	ld b, 5
	call DIVISION
    ret
.thirdDigit:
	call GetScore
	ld a, l ; get score 1st byte
	ld b, 1000
	call MODULO
	ld b, 20
	call DIVISION ; should be able to do a bit shift...
	ld b, 5
	call DIVISION
    ret