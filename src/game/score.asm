SECTION "score", ROMX

InitializeScore::
    xor a ; ld a, 0
    ld hl, score
	ld [hl], a
    inc l
    ld [hl], a
    inc l
    ld [hl], a
    ret

ToBCD::
    ; a = argument non-BCD number
    ; a = return BCD number
    ; double dabble
    ld b, 0
    ld c, 0 ;not use right now

    ld d, 7 ;maybe 8
.loop:
    ; if BCD digit (and 00001111) is >= 5 (0101), then increment by 3 (0011) at that BCD digit
    ; left shift one bit

    ld e, a ; hold me

    ld a, b ; grab the BCDs
    and %00001111
    cp a, 4
    jr nc, .next
    ; b >= 5
    add %00000011 ;inc b by 3
    ; TODO: now I have to re-add it to b
    
.next:

    ; if b lower is >= 5
    ;   increment it by 3
    ;
    

    sla a ;if carry add it to b after shift!
    jr c, .noCarry
    sla b
    inc b
    jr .after
.noCarry:
    sla b
.after:
    dec d
    jr nz, .loop
    ; cp a, 9
    ; jr c, .end 
    ; add 6
    ; TODO: NEED TO MAKE IT BCD-FRIENDLY IF BIG!!!
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
    jr z, .firstDigit
    cp a, 1
    jr z, .secondDigit
    inc l ; next byte
    cp a, 2
    jr z, .thirdDigit
    cp a, 3
    jr z, .fourthDigit
    inc l ; next byte
    cp a, 4
    jr z, .fifthDigit
    cp a, 5
    jr z, .sixthDigit
    ret
.firstDigit:
    ld a, [hl]
    and %00001111
    ret
.secondDigit:
    ld a, [hl]
    swap a
    and %00001111
    ret
.thirdDigit:
    ld a, [hl]
    and %00001111
    ret
.fourthDigit:
    ld a, [hl]
    swap a
    and %00001111
    ret
.fifthDigit:
    ld a, [hl]
    and %00001111
    ret
.sixthDigit:
    ld a, [hl]
    swap a
    and %00001111
    ret