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