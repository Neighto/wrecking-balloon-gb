INCLUDE "hardware.inc"
INCLUDE "constants.inc"

MENU_LCD_SCROLL_RESET EQU 128
MENU_LCD_SCROLL_FAR EQU 96
MENU_LCD_SCROLL_CLOSE EQU 113

GAME_LCD_SCROLL_RESET EQU 128
GAME_LCD_SCROLL_FAR EQU 47
GAME_LCD_SCROLL_CLOSE EQU 102

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
    ldh a, [rSCX]
    ld hl, wParallaxFar
    add a, [hl]
	ldh [rSCX], a
    jr .end
.close:
    ld a, MENU_LCD_SCROLL_RESET
	ldh [rLYC], a
    ldh a, [rSCX]
    ld hl, wParallaxClose
    add a, [hl]
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

ParkLCDInterrupt:
    ld a, [rLYC]
	cp a, 0
    jr z, .clouds
    CP a, 72
    jr z, .ground
    jr .end
.clouds:
    ld a, 72
	ldh [rLYC], a
    ldh a, [rSCX]
    ld hl, wParallaxClose
    add a, [hl]
	ldh [rSCX], a
    jr .end
.ground:
    xor a ; ld a, 0
    ldh [rLYC], a
	ldh [rSCX], a
.end:
    jp LCDInterruptEnd

SetParkInterrupts::
    xor a ; ld a, 0
	ldh [rLYC], a
    ret 

GameLCDInterrupt:
    ld a, [rLYC]
    cp a, GAME_LCD_SCROLL_RESET
    jr z, .reset
	cp a, GAME_LCD_SCROLL_FAR
    jr z, .far
    cp a, GAME_LCD_SCROLL_CLOSE
    jr z, .close
    jr .end
.reset:
    ld a, GAME_LCD_SCROLL_FAR
	ldh [rLYC], a
    xor a ; ld a, 0
    ldh [rSCX], a
    ld hl, rLCDC
    res 1, [hl]
    jr .end
.far:
    ld a, GAME_LCD_SCROLL_CLOSE
    ldh [rLYC], a
    ldh a, [rSCX]
    ld hl, wParallaxFar
    add a, [hl]
	ldh [rSCX], a
    jr .end
.close:
    ld a, GAME_LCD_SCROLL_RESET
	ldh [rLYC], a
    ldh a, [rSCX]
    ld hl, wParallaxClose
    add a, [hl]
	ldh [rSCX], a
.end:
    ; We call nop multiple times to delay hiding sprites so it happens on a new line read
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; nop
    ; ld hl, rLCDC
    ; res 1, [hl]
    jp LCDInterruptEnd

SetGameInterrupts::
    ; Can check level here to know how to set our interrupts for a level
    ld a, GAME_LCD_SCROLL_FAR
    ldh [rLYC], a

    ld hl, wLCDInterrupt
    ld a, LOW(GameLCDInterrupt)
    ld [hli], a
    ld a, HIGH(GameLCDInterrupt)
    ld [hl], a
    ret