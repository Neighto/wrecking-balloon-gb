INCLUDE "hardware.inc"
INCLUDE "constants.inc"

PARALLAX_CLOSE_WAIT_TIME EQU %0000011
PARALLAX_MIDDLE_WAIT_TIME EQU %0000111
PARALLAX_FAR_WAIT_TIME EQU %0011111
RAIN_SCROLL_SPEED EQU 2

SECTION "scroll vars", WRAM0
wParallaxClose:: DB
wParallaxMiddle:: DB
wParallaxFar:: DB
wRain:: DB

SECTION "scroll", ROM0

InitializeParallaxScrolling::
	xor a ; ld a, 0
	ld [wParallaxClose], a
	ld [wParallaxMiddle], a
	ld [wParallaxFar], a
    ld [wRain], a
    ret

IncrementScrollOffset::
    ; Parallax
    ldh a, [hGlobalTimer] ; 3
    ld b, a ; 1
.close:
    and PARALLAX_CLOSE_WAIT_TIME
    jr nz, .endParallax
    ld hl, wParallaxClose
    inc [hl]
.middle:
    ld a, b
    and PARALLAX_MIDDLE_WAIT_TIME
    jr nz, .endParallax
    ld hl, wParallaxMiddle
    inc [hl]
.far:
    ld a, b
    and PARALLAX_FAR_WAIT_TIME
    jr nz, .endParallax
    ld hl, wParallaxFar
    inc [hl]
.endParallax:
    ; Rain
.rain:
    ld a, [wRain]
    sub a, RAIN_SCROLL_SPEED
    cp a, SCRN_VY - SCRN_Y
    jr nc, .resetRain
    ld [wRain], a
    ret
.resetRain:
    ld a, SCRN_VY - SCRN_Y
    ld [wRain], a
    ret

ResetScroll::
    xor a ; ld a, 0
    ldh [rSCX], a
    ldh [rSCY], a
    ret