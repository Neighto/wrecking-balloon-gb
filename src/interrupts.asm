INCLUDE "hardware.inc"
INCLUDE "constants.inc"

MENU_LCD_SCROLL_FAR EQU 111
MENU_LCD_SCROLL_CLOSE EQU 119
MENU_LCD_SCROLL_RESET EQU WINDOW_START_Y - 1

OPENING_CUTSCENE_HIDE EQU SCRN_Y
OPENING_CUTSCENE_SHOW EQU 23

GAME_CITY_LCD_SCROLL_FAR EQU 47
GAME_CITY_LCD_SCROLL_MIDDLE EQU 102
GAME_CITY_LCD_SCROLL_CLOSE EQU 110
GAME_CITY_LCD_SCROLL_RESET EQU WINDOW_START_Y

GAME_DESERT_LCD_SCROLL_FAR EQU 55
GAME_DESERT_LCD_SCROLL_MIDDLE EQU 96
GAME_DESERT_LCD_SCROLL_CLOSE EQU 110
GAME_DESERT_LCD_SCROLL_RESET EQU WINDOW_START_Y

GAME_SHOWDOWN_LCD_SCROLL_CLOSE EQU 0
GAME_SHOWDOWN_LCD_SCROLL_MIDDLE EQU 24
GAME_SHOWDOWN_LCD_SCROLL_RAIN EQU 32
GAME_SHOWDOWN_LCD_SCROLL_RESET EQU WINDOW_START_Y

ENDING_CUTSCENE_SCROLL_FAR EQU 103
ENDING_CUTSCENE_SCROLL_CLOSE EQU 111
ENDING_CUTSCENE_SCROLL_RESET EQU 119

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
    push hl
    push af
	ld hl, wLCDInterrupt
	ld a, [hli]
	ld h, [hl]
	ld l, a
    jp hl

LCDInterruptEnd:
    pop af
    pop hl
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
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jr .end
.close:
    ld a, MENU_LCD_SCROLL_RESET
	ldh [rLYC], a
    ldh a, [hParallaxClose]
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

LevelCityLCDInterrupt:
    ldh a, [rLYC]
.far:
	cp a, GAME_CITY_LCD_SCROLL_FAR
    jr nz, .middle
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    ld a, GAME_CITY_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    jp LCDInterruptEnd
.middle:
    cp a, GAME_CITY_LCD_SCROLL_MIDDLE
    jr nz, .close
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    ld a, GAME_CITY_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_CITY_LCD_SCROLL_CLOSE
    jr nz, .window
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    ld a, GAME_CITY_LCD_SCROLL_RESET
	ldh [rLYC], a
    jp LCDInterruptEnd
.window:
    cp a, GAME_CITY_LCD_SCROLL_RESET
    jp nz, LCDInterruptEnd
    xor a ; ld a, 0
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    ld a, GAME_CITY_LCD_SCROLL_FAR
	ldh [rLYC], a
    jp LCDInterruptEnd

SetLevelCityInterrupts::
    ld a, GAME_CITY_LCD_SCROLL_FAR
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(LevelCityLCDInterrupt)
    ld [hli], a
    ld a, HIGH(LevelCityLCDInterrupt)
    ld [hl], a
    ret

LevelNightCityLCDInterrupt:
    ldh a, [rLYC]
.far:
	cp a, GAME_CITY_LCD_SCROLL_FAR
    jr nz, .middle
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    ld a, GAME_CITY_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    jp LCDInterruptEnd
.middle:
    cp a, GAME_CITY_LCD_SCROLL_MIDDLE
    jr nz, .close
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    ld a, GAME_CITY_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_CITY_LCD_SCROLL_CLOSE
    jr nz, .preWindow
    ld a, %11010100
	ldh [rBGP], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    ld a, GAME_CITY_LCD_SCROLL_RESET - 1
	ldh [rLYC], a
    jp LCDInterruptEnd
.preWindow:
    cp a, GAME_CITY_LCD_SCROLL_RESET - 1
    jr nz, .window
    ld a, MAIN_PALETTE
    ldh [rBGP], a
    ld a, GAME_CITY_LCD_SCROLL_RESET
	ldh [rLYC], a
    jp LCDInterruptEnd
.window:
    cp a, GAME_CITY_LCD_SCROLL_RESET
    jr nz, .bottom
    xor a ; ld a, 0
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    ld a, SCRN_Y
	ldh [rLYC], a
    jp LCDInterruptEnd
.bottom:
    cp a, SCRN_Y
    jp nz, LCDInterruptEnd
    ld a, %11010010
	ldh [rBGP], a
    ld a, GAME_CITY_LCD_SCROLL_FAR
	ldh [rLYC], a
    jp LCDInterruptEnd

SetLevelNightCityInterrupts::
    ld a, GAME_CITY_LCD_SCROLL_FAR
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(LevelNightCityLCDInterrupt)
    ld [hli], a
    ld a, HIGH(LevelNightCityLCDInterrupt)
    ld [hl], a
    ret

Level2LCDInterrupt:
    ldh a, [rLYC]
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
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jr .end
.middle:
    ld a, GAME_DESERT_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    jr .end
.close:
    ld a, GAME_DESERT_LCD_SCROLL_RESET
	ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
.end:
    jp LCDInterruptEnd

SetLevelDesertInterrupts::
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
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jr .end
.middle:
    ld a, GAME_SHOWDOWN_LCD_SCROLL_RAIN
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    jr .end
.rain:
    ld a, GAME_SHOWDOWN_LCD_SCROLL_RESET
    ldh [rLYC], a
    ldh a, [hRain]    
    ldh [rSCY], a
    xor a ; ld a, 0
    ldh [rSCX], a
.end:
    jp LCDInterruptEnd

SetLevelShowdownInterrupts::
    ld a, GAME_SHOWDOWN_LCD_SCROLL_CLOSE
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(Level3LCDInterrupt)
    ld [hli], a
    ld a, HIGH(Level3LCDInterrupt)
    ld [hl], a
    ret

SetEndingCutsceneInterrupts::
    ld a, ENDING_CUTSCENE_SCROLL_FAR
	ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(LCDInterruptEnd)
    ld [hli], a
    ld a, HIGH(LCDInterruptEnd)
    ld [hl], a
    ret 