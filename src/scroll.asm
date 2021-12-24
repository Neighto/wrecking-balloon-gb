INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "scroll", ROM0

HorizontalScroll::
    push af
    ld a, [global_timer]
    and	BACKGROUND_HSCROLL_SPEED
    jr nz, .end
    ldh a, [rSCX]
    inc a
    ldh [rSCX], a
.end:
    pop af
    ret

ResetScroll::
    xor a ; ld a, 0
    ldh [rSCX], a
    ldh [rSCY], a
    ret