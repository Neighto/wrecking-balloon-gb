INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "hardware.inc"

MENU_MODES EQU 2

SECTION "menu vars", WRAM0
	wMenuFrame:: DB
	wSelectedMode:: DB

SECTION "menu", ROMX

InitializeMenu::
	xor a ; ld a, 0
	ld [wMenuFrame], a
	ld [wSelectedMode], a
	ld a, 140
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
	ld [hl], $00
	inc l
	ld [hl], %00000000
.end:
	ret

BlinkMenuCursor::
	; Check timer
	ld a, [wGlobalTimer]
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
	ld a, $02
	ld [hl], a
	ret
.empty:
	ld a, $00
	ld [hl], a
	ret

MoveCursor:
; 	; call CollectSound
; 	ld a, [wSelectedMode]
; 	inc a
; 	ld d, MENU_MODES
; 	call MODULO
; 	ld [wSelectedMode], a
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
	ld a, [wSelectedMode]
	cp a, 0
	jr nz, .storyMode
.classicMode:
	call CollectSound
	ld hl, wClassicModeStage
	ld [hl], STAGE_CLASSIC_SELECTED
	; call StartClassic
	ret
.storyMode:
	; call StartStory
	ret

MenuInput:
	ld a, [wGlobalTimer]
	and %00000011
	jr nz, .end
	call ReadInput	
.moveSelected:
	ld a, [wControllerPressed]
	call JOY_SELECT
	call nz, MoveCursor
.selectMode:
	ld a, [wControllerDown]
	call JOY_START
	call nz, SelectMode
.end:
	ret

UpdateMenuOpening::
	ld a, [wMenuFrame]
	cp a, 0
	jr z, .startSound
	cp a, 1
	jr z, .scrollUpTitle
	cp a, 2
	jr z, .endSound
	cp a, 3
	jr z, .scrollDownTitle
	cp a, 4
	jr z, .scrollUpTitle2
	cp a, 5
	jr z, .fadeOut
	ret
.startSound:
	call RisingSound
	jr .endFrame
.scrollUpTitle:
	ld a, [rSCY]
	cp a, 0
	jr z, .endFrame
	ldh a, [rSCY]
    inc a
    ldh [rSCY], a
	ret
.endSound:
	call StopSweepSound
	jr .endFrame
.scrollDownTitle:
	ld a, [rSCY]
	cp a, 252
	jr z, .endFrame
	ldh a, [rSCY]
	dec a
    ldh [rSCY], a
	ret
.scrollUpTitle2:
	ld a, [rSCY]
	cp a, 0
	jr z, .endFrame
	ldh a, [rSCY]
    inc a
    ldh [rSCY], a
	ret
.fadeOut:
	call FadeOutPalettes
	cp a, 0
	jr nz, .next
	ret
.next:
	jp StartMenu
	ret
.endFrame:
	ld a, [wMenuFrame]
	inc a 
	ld [wMenuFrame], a
.end:
	ret

UpdateMenu::
.fadeIn:
	call FadeInPalettes
	cp a, 0
	ret z
.hasFadedIn:
	call BlinkMenuCursor
	ld a, [wClassicModeStage]
	cp a, STAGE_CLASSIC_SELECTED
	jr z, .fadeOut
	call MenuInput
	call IncrementScrollOffset
	ret
.fadeOut:
	call FadeOutPalettes
	cp a, 0
	jp nz, StartClassic
	ret