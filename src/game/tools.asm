SECTION "tools", ROM0

IncrementPosition::
    ; takes 'hl' argument as address
    ; takes 'a' argument as amount
    add [hl]
    ld [hl], a
    ret
  
DecrementPosition::
    ; takes 'hl' argument as address
    ; takes 'a' argument as amount
    cpl 
    inc a
    add [hl]
    ld [hl], a
    ret