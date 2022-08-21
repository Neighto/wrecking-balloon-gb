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

GAME_SHOWDOWN_LCD_SCROLL_MIDDLE EQU 0
GAME_SHOWDOWN_LCD_SCROLL_FAR EQU 32
GAME_SHOWDOWN_LCD_SCROLL_RAIN EQU 40
GAME_SHOWDOWN_LCD_SCROLL_FAR2 EQU 102
GAME_SHOWDOWN_LCD_SCROLL_CLOSE EQU 110
GAME_SHOWDOWN_LCD_SCROLL_RESET EQU WINDOW_START_Y

GAME_BOSS_LCD_SCROLL_FAR EQU 95
; GAME_BOSS_LCD_SCROLL_MIDDLE EQU 111
GAME_BOSS_LCD_SCROLL_CLOSE EQU 111
GAME_BOSS_LCD_SCROLL_RESET EQU WINDOW_START_Y

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
    ldh a, [rLYC]
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
    ldh a, [rLYC]
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
    ld a, %11101100
	ldh [rBGP], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    ld a, GAME_CITY_LCD_SCROLL_RESET - 1
	ldh [rLYC], a
    jp LCDInterruptEnd
.preWindow:
    cp a, GAME_CITY_LCD_SCROLL_RESET - 1
    jr nz, .window
    ld a, MAIN_PAL0
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
    ld a, %11100001
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

LevelDesertLCDInterrupt::
    ldh a, [rLYC]
.far:
    cp a, GAME_DESERT_LCD_SCROLL_FAR
    jr nz, .middle
    ld a, GAME_DESERT_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.middle:
    cp a, GAME_DESERT_LCD_SCROLL_MIDDLE
    jr nz, .close
    ld a, GAME_DESERT_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_DESERT_LCD_SCROLL_CLOSE
    jr nz, .window
    ld a, GAME_DESERT_LCD_SCROLL_RESET
	ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.window:
    cp a, GAME_DESERT_LCD_SCROLL_RESET
    jp nz, LCDInterruptEnd
    ld a, GAME_DESERT_LCD_SCROLL_FAR
	ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    jp LCDInterruptEnd

SetLevelDesertInterrupts::
    ld a, GAME_DESERT_LCD_SCROLL_FAR
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(LevelDesertLCDInterrupt)
    ld [hli], a
    ld a, HIGH(LevelDesertLCDInterrupt)
    ld [hl], a
    ret

LevelNightDesertLCDInterrupt::
    ldh a, [rLYC]
.far:
    cp a, GAME_DESERT_LCD_SCROLL_FAR
    jr nz, .middle
    ld a, GAME_DESERT_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.middle:
    cp a, GAME_DESERT_LCD_SCROLL_MIDDLE
    jr nz, .close
    ld a, GAME_DESERT_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_DESERT_LCD_SCROLL_CLOSE
    jr nz, .preWindow
    ld a, GAME_DESERT_LCD_SCROLL_RESET - 1
	ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.preWindow:
    cp a, GAME_DESERT_LCD_SCROLL_RESET - 1
    jr nz, .window
    ld a, MAIN_PAL0
    ldh [rBGP], a
    ld a, GAME_DESERT_LCD_SCROLL_RESET
	ldh [rLYC], a
    jp LCDInterruptEnd
.window:
    cp a, GAME_DESERT_LCD_SCROLL_RESET
    jr nz, .bottom
    ld a, SCRN_Y
	ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    jp LCDInterruptEnd
.bottom:
    cp a, SCRN_Y
    jp nz, LCDInterruptEnd
    ld a, %11100111
	ldh [rBGP], a
    ld a, GAME_DESERT_LCD_SCROLL_FAR
	ldh [rLYC], a
    jp LCDInterruptEnd

SetLevelNightDesertInterrupts::
    ld a, GAME_DESERT_LCD_SCROLL_FAR
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(LevelNightDesertLCDInterrupt)
    ld [hli], a
    ld a, HIGH(LevelNightDesertLCDInterrupt)
    ld [hl], a
    ret

LevelShowdownLCDInterrupt:
    ldh a, [rLYC]
.middle:
    cp a, GAME_SHOWDOWN_LCD_SCROLL_MIDDLE
    jr nz, .far
    ld a, GAME_SHOWDOWN_LCD_SCROLL_FAR
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    jp LCDInterruptEnd
.far:
    cp a, GAME_SHOWDOWN_LCD_SCROLL_FAR
    jr nz, .rain
    ld a, GAME_SHOWDOWN_LCD_SCROLL_RAIN
    ldh [rLYC], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.rain:
    cp a, GAME_SHOWDOWN_LCD_SCROLL_RAIN
    jr nz, .far2
    ld a, GAME_SHOWDOWN_LCD_SCROLL_FAR2
    ldh [rLYC], a
    ldh a, [hRain]    
    ldh [rSCY], a
    xor a ; ld a, 0
    ldh [rSCX], a
    jp LCDInterruptEnd
.far2:
    cp a, GAME_SHOWDOWN_LCD_SCROLL_FAR2
    jr nz, .close
    ld a, GAME_SHOWDOWN_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ld a, 128
    ldh [rSCY], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_SHOWDOWN_LCD_SCROLL_CLOSE
    jr nz, .window
    ld a, GAME_SHOWDOWN_LCD_SCROLL_RESET
    ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.window:
    cp a, GAME_SHOWDOWN_LCD_SCROLL_RESET
    jp nz, LCDInterruptEnd
    ld a, GAME_SHOWDOWN_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCY], a
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    jp LCDInterruptEnd

SetLevelShowdownInterrupts::
    ld a, GAME_SHOWDOWN_LCD_SCROLL_MIDDLE
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(LevelShowdownLCDInterrupt)
    ld [hli], a
    ld a, HIGH(LevelShowdownLCDInterrupt)
    ld [hl], a
    ret

LevelBossLCDInterrupt:
    ldh a, [rLYC]
.far:
    cp a, GAME_BOSS_LCD_SCROLL_FAR
    jr nz, .close 
    ld a, GAME_BOSS_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_BOSS_LCD_SCROLL_CLOSE
    jr nz, .window 
    ld a, GAME_BOSS_LCD_SCROLL_RESET
    ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.window:
    cp a, GAME_BOSS_LCD_SCROLL_RESET
    jp nz, LCDInterruptEnd
    ld a, GAME_BOSS_LCD_SCROLL_FAR
    ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    jp LCDInterruptEnd

SetLevelBossInterrupts::
    ld a, GAME_BOSS_LCD_SCROLL_FAR
	ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(LevelBossLCDInterrupt)
    ld [hli], a
    ld a, HIGH(LevelBossLCDInterrupt)
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