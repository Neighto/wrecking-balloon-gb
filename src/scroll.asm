INCLUDE "hardware.inc"
INCLUDE "constants.inc"

PARALLAX_CLOSE_WAIT_TIME EQU %0000011
PARALLAX_MIDDLE_WAIT_TIME EQU %0000111
PARALLAX_FAR_WAIT_TIME EQU %0011111
RAIN_SCROLL_SPEED EQU 2

SECTION "scroll vars", HRAM
    hParallaxClose:: DB
    hParallaxMiddle:: DB
    hParallaxFar:: DB
    hRain:: DB

SECTION "scroll", ROM0

InitializeParallaxScrolling::
	xor a ; ld a, 0
	ldh [hParallaxClose], a
	ldh [hParallaxMiddle], a
	ldh [hParallaxFar], a
    ldh [hRain], a
    ret

IncrementScrollOffset::
    ; Parallax
    ldh a, [hGlobalTimer] ; 3
    ld b, a ; 1
.close:
    and PARALLAX_CLOSE_WAIT_TIME
    jr nz, .endParallax
    ldh a, [hParallaxClose]
    inc a
    ldh [hParallaxClose], a
.middle:
    ld a, b
    and PARALLAX_MIDDLE_WAIT_TIME
    jr nz, .endParallax
    ldh a, [hParallaxMiddle]
    inc a
    ldh [hParallaxMiddle], a
.far:
    ld a, b
    and PARALLAX_FAR_WAIT_TIME
    jr nz, .endParallax
    ldh a, [hParallaxFar]
    inc a
    ldh [hParallaxFar], a
.endParallax:
    ; Rain
.rain:
    ldh a, [hRain]
    sub a, RAIN_SCROLL_SPEED
    ld c, SCRN_VY - SCRN_Y
    cp a, c
    jr nc, .resetRain
    ldh [hRain], a
    ret
.resetRain:
    ld a, c
    ldh [hRain], a
    ret

ResetScroll::
    xor a ; ld a, 0
    ldh [rSCX], a
    ldh [rSCY], a
    ret