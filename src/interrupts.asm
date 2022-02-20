INCLUDE "hardware.inc"
INCLUDE "constants.inc"

MENU_LCD_SCROLL_FAR EQU 111
MENU_LCD_SCROLL_CLOSE EQU 119
MENU_LCD_SCROLL_RESET EQU 127

OPENING_CUTSCENE_HIDE EQU 0
OPENING_CUTSCENE_SHOW EQU 23

GAME_CITY_LCD_SCROLL_FAR EQU 47
GAME_CITY_LCD_SCROLL_MIDDLE EQU 102
GAME_CITY_LCD_SCROLL_CLOSE EQU 110
GAME_CITY_LCD_SCROLL_RESET EQU 128

GAME_DESERT_LCD_SCROLL_FAR EQU 57
GAME_DESERT_LCD_SCROLL_MIDDLE EQU 97
GAME_DESERT_LCD_SCROLL_CLOSE EQU 111
GAME_DESERT_LCD_SCROLL_RESET EQU 128

GAME_SHOWDOWN_LCD_SCROLL_CLOSE EQU 0
GAME_SHOWDOWN_LCD_SCROLL_MIDDLE EQU 16
GAME_SHOWDOWN_LCD_SCROLL_RAIN EQU 23
GAME_SHOWDOWN_LCD_SCROLL_RESET EQU 128

SECTION "interrupts vars", WRAM0
    wVBlankFlag:: DB
    wLCDInterrupt:: DS 2

SECTION "interrupts", ROM0

InitializeInterrupts::
	xor a ; ld a, 0
	ld [wVBlankFlag], a

    ld hl, wLCDInterrupt
    ld a, LOW(LCDInterruptEnd)
    ld [hli], a
    ld a, HIGH(LCDInterruptEnd)
    ld [hl], a

    ld a, IEF_STAT | IEF_VBLANK ; Enable LCD and VBLANK interrupts
	ldh [rIE], a
	ld a, STATF_LYC
	ldh [rSTAT], a
    ret

VBlankInterrupt::
    push hl
    push af
    ld hl, wVBlankFlag
    ld [hl], 1
    ldh a, [rLCDC]
    or LCDCF_OBJON
    ldh [rLCDC], a
    pop af
    pop hl
    reti

LCDInterrupt::
    push af
    push bc
    push hl
	ld hl, wLCDInterrupt
	ld a, [hli]
	ld h, [hl]
	ld l, a
    jp hl

LCDInterruptEnd:
    pop hl
    pop bc
    pop af
    reti

MenuLCDInterrupt:
    ld a, [rLYC]
    cp a, MENU_LCD_SCROLL_RESET
    jr z, .reset
	cp a, MENU_LCD_SCROLL_FAR
    jr z, .far
    cp a, MENU_LCD_SCROLL_CLOSE
    jr z, .close
    jr .end
.reset:
    ld a, MENU_LCD_SCROLL_FAR
	ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCX], a
    jr .end
.far:
    ld a, MENU_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ld a, [wParallaxFar]
	ldh [rSCX], a
    jr .end
.close:
    ld a, MENU_LCD_SCROLL_RESET
	ldh [rLYC], a
    ld a, [wParallaxClose]
	ldh [rSCX], a
.end:
    jp LCDInterruptEnd

SetMenuInterrupts::
    ld a, MENU_LCD_SCROLL_FAR
	ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(MenuLCDInterrupt)
    ld [hli], a
    ld a, HIGH(MenuLCDInterrupt)
    ld [hl], a
    ret 

OpeningCutsceneLCDInterrupt:
    ld a, [rLYC]
    cp a, OPENING_CUTSCENE_HIDE
    jr z, .hide
	cp a, OPENING_CUTSCENE_SHOW
    jr z, .show
    jr .end
.hide:
    ld a, OPENING_CUTSCENE_SHOW
	ldh [rLYC], a
    ld hl, rLCDC
    res 1, [hl]
    jr .end
.show:
    ld a, OPENING_CUTSCENE_HIDE
    ldh [rLYC], a
    ld hl, rLCDC
    set 1, [hl]
.end:
    jp LCDInterruptEnd

SetOpeningCutsceneInterrupts::
    ld a, OPENING_CUTSCENE_HIDE
	ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(OpeningCutsceneLCDInterrupt)
    ld [hli], a
    ld a, HIGH(OpeningCutsceneLCDInterrupt)
    ld [hl], a
    ret 

Level1LCDInterrupt:
    ld a, [rLYC]
    cp a, GAME_CITY_LCD_SCROLL_RESET
    jr z, .reset
	cp a, GAME_CITY_LCD_SCROLL_FAR
    jr z, .far
    cp a, GAME_CITY_LCD_SCROLL_MIDDLE
    jr z, .middle
    cp a, GAME_CITY_LCD_SCROLL_CLOSE
    jr z, .close2
    jr .end
.reset:
    ld a, GAME_CITY_LCD_SCROLL_FAR
	ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    jr .end
.far:
    ld a, GAME_CITY_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    ld a, [wParallaxFar]
	ldh [rSCX], a
    jr .end
.middle:
    ld a, GAME_CITY_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ld a, [wParallaxMiddle]
	ldh [rSCX], a
    jr .end
.close2:
    ld a, GAME_CITY_LCD_SCROLL_RESET
	ldh [rLYC], a
    ld a, [wParallaxClose]
	ldh [rSCX], a
.end:
    jp LCDInterruptEnd

SetLevel1Interrupts::
    ld a, GAME_CITY_LCD_SCROLL_FAR
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(Level1LCDInterrupt)
    ld [hli], a
    ld a, HIGH(Level1LCDInterrupt)
    ld [hl], a
    ret

Level2LCDInterrupt:
    ld a, [rLYC]
    cp a, GAME_DESERT_LCD_SCROLL_RESET
    jr z, .reset
	cp a, GAME_DESERT_LCD_SCROLL_FAR
    jr z, .far
    cp a, GAME_DESERT_LCD_SCROLL_MIDDLE
    jr z, .middle
    cp a, GAME_DESERT_LCD_SCROLL_CLOSE
    jr z, .close
    jr .end
.reset:
    ld a, GAME_DESERT_LCD_SCROLL_FAR
	ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    jr .end
.far:
    ld a, GAME_DESERT_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    ld a, [wParallaxFar]
	ldh [rSCX], a
    jr .end
.middle:
    ld a, GAME_DESERT_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ld a, [wParallaxMiddle]
	ldh [rSCX], a
    jr .end
.close:
    ld a, GAME_DESERT_LCD_SCROLL_RESET
	ldh [rLYC], a
    ld a, [wParallaxClose]
	ldh [rSCX], a
.end:
    jp LCDInterruptEnd

SetLevel2Interrupts::
    ld a, GAME_DESERT_LCD_SCROLL_FAR
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(Level2LCDInterrupt)
    ld [hli], a
    ld a, HIGH(Level2LCDInterrupt)
    ld [hl], a
    ret

Level3LCDInterrupt:
    ld a, [rLYC]
    cp a, GAME_SHOWDOWN_LCD_SCROLL_RESET
    jr z, .reset
    cp a, GAME_SHOWDOWN_LCD_SCROLL_CLOSE
    jr z, .close
    cp a, GAME_SHOWDOWN_LCD_SCROLL_MIDDLE
    jr z, .middle
    cp a, GAME_SHOWDOWN_LCD_SCROLL_RAIN
    jr z, .rain
    jr .end
.reset:
    ld a, GAME_SHOWDOWN_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCY], a
    ld hl, rLCDC
    res 1, [hl]
    jr .end
.close:
    ld a, GAME_SHOWDOWN_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    ld a, [wParallaxClose]
	ldh [rSCX], a
    jr .end
.middle:
    ld a, GAME_SHOWDOWN_LCD_SCROLL_RAIN
    ldh [rLYC], a
    ld a, [wParallaxMiddle]
	ldh [rSCX], a
    jr .end
.rain:
    ld a, GAME_SHOWDOWN_LCD_SCROLL_RESET
    ldh [rLYC], a
    ld a, [wRain]    
    ldh [rSCY], a
    xor a ; ld a, 0
    ldh [rSCX], a
.end:
    jp LCDInterruptEnd

SetLevel3Interrupts::
    ld a, GAME_SHOWDOWN_LCD_SCROLL_CLOSE
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(Level3LCDInterrupt)
    ld [hli], a
    ld a, HIGH(Level3LCDInterrupt)
    ld [hl], a
    ret