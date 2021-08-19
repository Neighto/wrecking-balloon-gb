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

ResetInRange::
    ; argument hl is starting address
    ; argument bc is distance
    xor a ; ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, ResetInRange
    ret