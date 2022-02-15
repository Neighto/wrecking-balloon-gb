INCLUDE "hardware.inc"
INCLUDE "constants.inc"

PARALLAX_CLOSE_WAIT_TIME EQU %0000111
PARALLAX_MIDDLE_WAIT_TIME EQU %0001111
PARALLAX_FAR_WAIT_TIME EQU %0011111

SECTION "scroll vars", WRAM0
wParallaxClose:: DB
wParallaxMiddle:: DB
wParallaxFar:: DB

SECTION "scroll", ROM0

InitializeParallaxScrolling::
	xor a ; ld a, 0
	ld [wParallaxClose], a
	ld [wParallaxMiddle], a
	ld [wParallaxFar], a
    ret

IncrementScrollOffset::
.close:
    ld a, [wGlobalTimer]
    and PARALLAX_CLOSE_WAIT_TIME
    jr nz, .middle
    ld a, [wParallaxClose]
    inc a
    ld [wParallaxClose], a
.middle:
    ld a, [wGlobalTimer]
    and PARALLAX_MIDDLE_WAIT_TIME
    jr nz, .far
    ld a, [wParallaxMiddle]
    inc a
    ld [wParallaxMiddle], a
.far:
    ld a, [wGlobalTimer]
    and PARALLAX_FAR_WAIT_TIME
    jr nz, .end
    ld a, [wParallaxFar]
    inc a
    ld [wParallaxFar], a
.end:
    ret

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