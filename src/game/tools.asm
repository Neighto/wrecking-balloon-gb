SECTION "tools", ROM0

IncrementPosition::
    ; hl = address
    ; a = amount
    add [hl]
    ld [hl], a
    ret
  
DecrementPosition::
    ; hl = address
    ; a = amount
    cpl 
    inc a
    add [hl]
    ld [hl], a
    ret

AddPoints::
    ; b = points to receive
    ld a, [player_alive]
    and 1
    jr z, .end
    ; Alive we can add points
    ld hl, score
    ld a, b
    add [hl]
    ld [hl], a
    call RefreshScore
.end:
    ret