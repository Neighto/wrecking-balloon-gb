INCLUDE "hardware.inc"
INCLUDE "constants.inc"

COMMON_LCD_SETTINGS EQU LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_WIN9C00
ENABLE_LCD_SETTINGS_NO_WINDOW EQU COMMON_LCD_SETTINGS | LCDCF_OBJ16 | LCDCF_WINOFF
ENABLE_LCD_SETTINGS_NO_WINDOW_8_SPR_MODE EQU COMMON_LCD_SETTINGS | LCDCF_OBJ8 | LCDCF_WINOFF

ENABLE_LCD_SETTINGS EQU COMMON_LCD_SETTINGS | LCDCF_OBJ16 | LCDCF_WINON

SECTION "lcd", ROMX

; Some naming convention exceptions for function clarity

LCD_OFF::
    xor a ; ld a, 0
    ldh [rLCDC], a
    ret

LCD_ON::
    ld a, ENABLE_LCD_SETTINGS
    ldh [rLCDC], a
    ret

LCD_ON_NO_WINDOW::
    ld a, ENABLE_LCD_SETTINGS_NO_WINDOW
    ldh [rLCDC], a
    ret

LCD_ON_NO_WINDOW_8_SPR_MODE::
    ld a, ENABLE_LCD_SETTINGS_NO_WINDOW_8_SPR_MODE
    ldh [rLCDC], a
    ret

WaitVBlank::
    ld hl, wVBlankFlag
    xor a ; ld a, 0
.loop:
    halt 
    nop
    cp a, [hl]
    jr z, .loop
    ld [hl], a
    ret

WaitVRAMAccessible::
    ; Waits for VRAM to be in
    ; Mode 0 = H-Blank
    ; Mode 1 = V-Blank
    ; Mode 2 = Searching OAM
    ; If there is an untimely LCD interrupt, it is possible to enter Mode 3 before VRAM is accessed
    ld hl, rSTAT
.wait:
    bit 1, [hl]
    jr nz, .wait
    ret

; WaitOAMAccessible::
;     ; Waits for OAM to be in
;     ; Mode 0 = H-Blank
;     ; Mode 1 = V-Blank
;     ; OAM can also be accessed any time with DMA function
;     ld hl, rSTAT
; .wait1:
;     bit 1, [hl]
;     jr nz, .wait1
; .wait2:
;     bit 1, [hl]
;     jr nz, .wait2
;     ret

ToggleWindow::
	ld hl, rLCDC
	bit 5, [hl]
	jr z, .winon
.winoff::
	ld hl, rLCDC ; Must be set for .winoff to be called on its own
	res 5, [hl]
	ret
.winon::
	ld hl, rLCDC ; Must be set for .winon to be called on its own
	set 5, [hl]
    ret