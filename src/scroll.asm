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

SECTION "scroll", ROMX

InitializeScroll::
    xor a ; ld a, 0
    ldh [rSCX], a
    ldh [rSCY], a
	ldh [hParallaxClose], a
	ldh [hParallaxMiddle], a
	ldh [hParallaxFar], a
    ldh [hRain], a
    ret

IncrementScrollOffset::
    ldh a, [hGlobalTimer]
    ld b, a
    ; Close scroll
    and PARALLAX_CLOSE_WAIT_TIME
    jr nz, .endParallax
    ld hl, hParallaxClose
    inc [hl]
    ; Middle scroll
    ld a, b
    and PARALLAX_MIDDLE_WAIT_TIME
    jr nz, .endParallax
    ld hl, hParallaxMiddle
    inc [hl]
    ; Far scroll
    ld a, b
    and PARALLAX_FAR_WAIT_TIME
    jr nz, .endParallax
    ld hl, hParallaxFar
    inc [hl]
.endParallax:
    ; Rain scroll
    ldh a, [hRain]
    sub a, RAIN_SCROLL_SPEED
    ld l, SCRN_VY - SCRN_Y
    cp a, l
    jr c, .updateRain
    ld a, l
.updateRain:
    ldh [hRain], a
    ret