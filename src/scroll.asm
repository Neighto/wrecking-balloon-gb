INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "scroll", ROM0

HorizontalScroll::
    push af
    ld a, [wGlobalTimer]
    and	BACKGROUND_HSCROLL_SPEED
    jr nz, .end
    ldh a, [rSCX]
    inc a
    ldh [rSCX], a
.end:
    pop af
    ret

VerticalScroll::
    push af
    ld a, [wGlobalTimer]
    and	BACKGROUND_VSCROLL_SPEED
    jr nz, .end
    ldh a, [rSCY]
    inc a
    ldh [rSCY], a
.end:
    pop af
    ret

ResetScroll::
    xor a ; ld a, 0
    ldh [rSCX], a
    ldh [rSCY], a
    ret