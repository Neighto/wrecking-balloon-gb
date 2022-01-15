INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "hardware.inc"

MENU_MODES EQU 2

SECTION "menu vars", WRAM0
	wMenuFrame:: DB

SECTION "menu", ROMX

InitializeMenu::
	xor a ; ld a, 0
	ld [wMenuFrame], a
	ld a, 120
	ld [rSCY], a
	ret

SpawnMenuCursor::
	ld b, 1 ; need 1 sprite for cursor
	call RequestOAMSpace
	cp a, 0
	jr z, .end
.availableSpace:
	ld a, b
	ld [wOAMGeneral1], a
	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
	ld a, 104 ; y
	ld [hli], a
	ld a, 56 ; x
	ld [hli], a
	ld [hl], $80
	inc l
	ld [hl], %00000000
.end:
	ret

BlinkMenuCursor::
	; Check timer
	ld a, [global_timer]
	and %00011111
	jr z, .blink
	ret
.blink:
	; Check what tile and flip it
	SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
	ld a, [hl]
	cp a, $00
	jr nz, .empty
.show:
	ld a, $80
	ld [hl], a
	ret
.empty:
	ld a, $00
	ld [hl], a
	ret

MoveCursor:
; 	; call CollectSound
; 	ld a, [selected_mode]
; 	inc a
; 	ld d, MENU_MODES
; 	call MODULO
; 	ld [selected_mode], a
; 	cp a, 0
; 	jr nz, .storyMode
; .classicMode:
; 	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
; 	ld a, 104
; 	ld [hl], a
; 	ret
; .storyMode:
; 	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
; 	ld a, 120
; 	ld [hl], a
	ret

SelectMode:
	ld a, [selected_mode]
	cp a, 0
	jr nz, .storyMode
.classicMode:
	call CollectSound
	ld hl, classic_mode_stage
	ld [hl], STAGE_CLASSIC_SELECTED
	; call StartClassic
	ret
.storyMode:
	; call StartStory
	ret

MenuInput:
	ld a, [global_timer]
	and %00000011
	jr nz, .end
	call ReadInput	
.moveSelected:
	ld a, [joypad_pressed]
	call JOY_SELECT
	call nz, MoveCursor
.selectMode:
	ld a, [joypad_down]
	call JOY_START
	call nz, SelectMode
.end:
	ret

ScrollTitleUp:
	ld a, [wMenuFrame]
	cp a, 0
	jr z, .scrollUpTitle
	cp a, 1
	jr z, .fadeOut
	cp a, 2
	jr z, .fadeIn
	jr .end
.scrollUpTitle:
	ld a, [rSCY]
	cp a, 0
	jr z, .endFrame
	call VerticalScroll
	jr .end
.fadeOut:
	call HasFadedOut
	cp a, 0
	jr nz, .loadFullMenu
	call FadeOutPalettes
	jr .end
.loadFullMenu:
	call LCD_OFF
	ld bc, MenuMap
	ld hl, _SCRN0
	ld de, MenuMapEnd - MenuMap
	call MEMCPY
	call LCD_ON_NO_WINDOW
	jr .endFrame
.fadeIn:
	call HasFadedIn
	cp a, 0
	jr nz, .endFrame
	call FadeInPalettes
	jr .end
.endFrame:
	ld a, [wMenuFrame]
	inc a 
	ld [wMenuFrame], a
.end:
	ret

UpdateMenu::
	call BlinkMenuCursor
	ld a, [classic_mode_stage]
	cp a, STAGE_CLASSIC_SELECTED
	jr z, .fadeOut
	call MenuInput
	call ScrollTitleUp
	ret
.fadeOut:
	call HasFadedOut
	cp a, 0
	jr nz, .hasFadedOut
	call FadeOutPalettes
	ret
.hasFadedOut:
	call StartClassic
	ret