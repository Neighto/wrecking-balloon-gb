INCLUDE "hardware.inc"
INCLUDE "constants.inc"

INTERRUPT_WINDOW EQU WINDOW_START_Y - 1
INTERRUPT_END_OF_SCREEN EQU SCRN_Y

MENU_LCD_SCROLL_FAR EQU 111
MENU_LCD_SCROLL_CLOSE EQU 119
MENU_LCD_SCROLL_RESET EQU 128

OPENING_CUTSCENE_HIDE EQU SCRN_Y
OPENING_CUTSCENE_SHOW EQU 23
OPENING_CUTSCENE_TOP EQU 39

GAME_CITY_LCD_SCROLL_FAR EQU 47
GAME_CITY_LCD_SCROLL_CLOSE EQU 102
GAME_CITY_LCD_SCROLL_MIDDLE EQU 110
GAME_NIGHT_CITY_LCD_SCROLL_CLOSE EQU 31

GAME_DESERT_LCD_SCROLL_FAR EQU 55
GAME_DESERT_LCD_SCROLL_MIDDLE EQU 95
GAME_DESERT_LCD_SCROLL_CLOSE EQU 111

GAME_SHOWDOWN_LCD_SCROLL_FAR EQU 32
GAME_SHOWDOWN_LCD_SCROLL_RAIN EQU 40
GAME_SHOWDOWN_LCD_SCROLL_FAR2 EQU 102
GAME_SHOWDOWN_LCD_SCROLL_CLOSE EQU 111
GAME_SHOWDOWN_LCD_SCROLL_MIDDLE EQU SCRN_Y

ENDLESS_LCD_SCROLL_FAR EQU 31
ENDLESS_LCD_SCROLL_MIDDLE EQU 39
ENDLESS_LCD_SCROLL_CLOSE EQU 111

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
    push af
    ld a, 1
    ld [wVBlankFlag], a
    ldh a, [rLCDC]
    or LCDCF_OBJON
    ldh [rLCDC], a
    pop af
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

WindowLCDInterrupt:
    call WaitVRAMAccessible
    ld a, MAIN_PAL0
    ldh [rBGP], a
.skipPaletteSetting:
    ld a, INTERRUPT_END_OF_SCREEN
	ldh [rLYC], a
    call WaitVRAMAccessible
    xor a ; ld a, 0
    ldh [rSCX], a
    ld a, 112
    ldh [rSCY], a
    ld hl, rLCDC
    res 1, [hl]
    jp LCDInterruptEnd

SetInterruptsCommon:
    ; a = Initial LYC
    ; bc = LCD Interrupt Address
    ldh [rLYC], a
    ld hl, wLCDInterrupt
    ld a, c
    ld [hli], a
    ld a, b
    ld [hl], a
    ret

; *************************************************************
; MENU
; *************************************************************

MenuLCDInterrupt:
    ldh a, [rLYC]
.reset:
    cp a, MENU_LCD_SCROLL_RESET
    jr nz, .far
    ld a, MENU_LCD_SCROLL_FAR
	ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCX], a
    jr .end
.far:
	cp a, MENU_LCD_SCROLL_FAR
    jr nz, .close
    ld a, MENU_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jr .end
.close:
    ; cp a, MENU_LCD_SCROLL_CLOSE
    ; jr nz, .end
    ld a, MENU_LCD_SCROLL_RESET
	ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    ; jr .end
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

; *************************************************************
; CUTSCENE
; *************************************************************

CutsceneLCDInterrupt:
    ldh a, [rLYC]
.hide:
    cp a, OPENING_CUTSCENE_HIDE
    jr nz, .show
    ld a, OPENING_CUTSCENE_SHOW
	ldh [rLYC], a
    ld hl, rLCDC
    res 1, [hl]
    jr .end
.show:
	cp a, OPENING_CUTSCENE_SHOW
    jr nz, .top
    ld a, OPENING_CUTSCENE_TOP
    ldh [rLYC], a
    ld hl, rLCDC
    set 1, [hl]
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jr .end
.top:
    ; cp a, OPENING_CUTSCENE_TOP
    ; jr nz, .end
    ld a, OPENING_CUTSCENE_HIDE
	ldh [rLYC], a
    xor a ; ld a, 0
	ldh [rSCX], a
    ; jr .end
.end:
    jp LCDInterruptEnd

SetCutsceneInterrupts::
    ld a, OPENING_CUTSCENE_HIDE
	ldh [rLYC], a
    ld hl, wLCDInterrupt
    ld a, LOW(CutsceneLCDInterrupt)
    ld [hli], a
    ld a, HIGH(CutsceneLCDInterrupt)
    ld [hl], a
    ret 

; *************************************************************
; CITY (Level 1)
; *************************************************************

LevelCityLCDInterrupt:
    ldh a, [rLYC]
.far:
	cp a, GAME_CITY_LCD_SCROLL_FAR
    jr nz, .close
    ld a, GAME_CITY_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_CITY_LCD_SCROLL_CLOSE
    jr nz, .middle
    ld a, GAME_CITY_LCD_SCROLL_MIDDLE
	ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.middle:
    cp a, GAME_CITY_LCD_SCROLL_MIDDLE
    jr nz, .close2
    ld a, INTERRUPT_WINDOW
	ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close2:
    cp a, INTERRUPT_END_OF_SCREEN
    jp nz, WindowLCDInterrupt
    ld a, GAME_CITY_LCD_SCROLL_FAR
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    xor a ; ld a, 0
    ldh [rSCY], a
    jp LCDInterruptEnd

SetLevelCityInterrupts::
    ld a, GAME_CITY_LCD_SCROLL_FAR
    ld bc, LevelCityLCDInterrupt
    jp SetInterruptsCommon

; *************************************************************
; NIGHT CITY (Level 2)
; *************************************************************

LevelNightCityLCDInterrupt:
    ldh a, [rLYC]
.closeNight:
    cp a, GAME_NIGHT_CITY_LCD_SCROLL_CLOSE
    jr nz, .far
    ld a, GAME_CITY_LCD_SCROLL_FAR
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
    cpl
	ldh [rSCX], a
    jp LCDInterruptEnd
.far:
	cp a, GAME_CITY_LCD_SCROLL_FAR
    jr nz, .close
    ld a, GAME_CITY_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_CITY_LCD_SCROLL_CLOSE
    jr nz, .middle
    ld a, GAME_CITY_LCD_SCROLL_MIDDLE
	ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.middle:
    cp a, GAME_CITY_LCD_SCROLL_MIDDLE
    jr nz, .bottom
    ld a, INTERRUPT_WINDOW
    ldh [rLYC], a
    ld a, %11100100
	ldh [rBGP], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    jp LCDInterruptEnd
.bottom:
    cp a, INTERRUPT_END_OF_SCREEN
    jp nz, WindowLCDInterrupt
    ld a, GAME_NIGHT_CITY_LCD_SCROLL_CLOSE
	ldh [rLYC], a
    ld a, %11100001
	ldh [rBGP], a
    xor a ; ld a, 0
    ldh [rSCY], a
    jp LCDInterruptEnd

SetLevelNightCityInterrupts::
    ld a, GAME_CITY_LCD_SCROLL_FAR
    ld bc, LevelNightCityLCDInterrupt
    jp SetInterruptsCommon

; *************************************************************
; DESERT (Level 3)
; *************************************************************

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
    jp nz, .bottom
    ld a, INTERRUPT_WINDOW
	ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.bottom:
    cp a, INTERRUPT_END_OF_SCREEN
    jp nz, WindowLCDInterrupt
    ld a, GAME_DESERT_LCD_SCROLL_FAR
	ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCY], a
    jp LCDInterruptEnd

SetLevelDesertInterrupts::
    ld a, GAME_DESERT_LCD_SCROLL_FAR
    ld bc, LevelDesertLCDInterrupt
    jp SetInterruptsCommon

; *************************************************************
; NIGHT DESERT (Level 4)
; *************************************************************

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
    jr nz, .bottom
    ld a, INTERRUPT_WINDOW
	ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.bottom:
    cp a, INTERRUPT_END_OF_SCREEN
    jp nz, WindowLCDInterrupt
    ld a, GAME_DESERT_LCD_SCROLL_FAR
	ldh [rLYC], a
    ld a, %11100111
	ldh [rBGP], a
    xor a
    ldh [rSCY], a
    jp LCDInterruptEnd

SetLevelNightDesertInterrupts::
    ld a, GAME_DESERT_LCD_SCROLL_FAR
    ld bc, LevelNightDesertLCDInterrupt
    jp SetInterruptsCommon

; *************************************************************
; SHOWDOWN (Level 5) (Level 6)
; *************************************************************

LevelShowdownLCDInterrupt:
    ldh a, [rLYC]
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
    call WaitVRAMAccessible
    xor a ; ld a, 0
    ldh [rSCX], a
    ldh a, [hRain]  
    ldh [rSCY], a
    jp LCDInterruptEnd
.far2:
    cp a, GAME_SHOWDOWN_LCD_SCROLL_FAR2
    jr nz, .close
    ld a, GAME_SHOWDOWN_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ld a, 112
    ldh [rSCY], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close:
    cp a, GAME_SHOWDOWN_LCD_SCROLL_CLOSE
    jr nz, .window
    ld a, INTERRUPT_WINDOW
    ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    ldh a, [hLevel]
    cp a, LEVEL_BOSS
    jp z, LCDInterruptEnd
    ld a, MAIN_PAL0 ; Night showdown
	ldh [rBGP], a ; Night showdown
    jp LCDInterruptEnd
.window:
    cp a, INTERRUPT_WINDOW
    jr nz, .bottom
    ldh a, [hLevel]
    cp a, LEVEL_BOSS
    jp nz, WindowLCDInterrupt ; Night showdown
    jp WindowLCDInterrupt.skipPaletteSetting
.bottom:
    ld a, GAME_SHOWDOWN_LCD_SCROLL_FAR
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    xor a ; ld a, 0
    ldh [rSCY], a
    ldh a, [hLevel]
    cp a, LEVEL_BOSS
    jp z, LCDInterruptEnd
    ld a, %11100001 ; Night showdown
	ldh [rBGP], a ; Night showdown
    jp LCDInterruptEnd

SetLevelShowdownInterrupts::
    ld a, GAME_SHOWDOWN_LCD_SCROLL_FAR
    ld bc, LevelShowdownLCDInterrupt
    jp SetInterruptsCommon

; *************************************************************
; ENDLESS
; *************************************************************

EndlessLCDInterrupt:
    ldh a, [rLYC]
.far:
    cp a, ENDLESS_LCD_SCROLL_FAR
    jr nz, .middle 
    ld a, ENDLESS_LCD_SCROLL_MIDDLE
    ldh [rLYC], a
    ldh a, [hParallaxFar]
	ldh [rSCX], a
    jp LCDInterruptEnd
.middle:
    cp a, ENDLESS_LCD_SCROLL_MIDDLE
    jr nz, .close 
    ld a, ENDLESS_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    jp LCDInterruptEnd
.close:
    cp a, ENDLESS_LCD_SCROLL_CLOSE
    jr nz, .bottom 
    ld a, INTERRUPT_WINDOW
    ldh [rLYC], a
    ldh a, [hParallaxClose]
	ldh [rSCX], a
    jp LCDInterruptEnd
.bottom:
    cp a, INTERRUPT_END_OF_SCREEN
    jp nz, WindowLCDInterrupt.skipPaletteSetting
    ld a, ENDLESS_LCD_SCROLL_FAR
	ldh [rLYC], a
    ldh a, [hParallaxMiddle]
	ldh [rSCX], a
    xor a ; ld a, 0
    ldh [rSCY], a
    jp LCDInterruptEnd

SetEndlessInterrupts::
    ld a, ENDLESS_LCD_SCROLL_FAR
	ldh [rLYC], a
    ld hl, wLCDInterrupt
    ld a, LOW(EndlessLCDInterrupt)
    ld [hli], a
    ld a, HIGH(EndlessLCDInterrupt)
    ld [hl], a
    ret 