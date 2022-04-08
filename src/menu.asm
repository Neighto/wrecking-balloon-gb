INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "hardware.inc"

MENU_MODES EQU 2
MENU_CURSOR_TILE EQU $02

TITLE_ADDRESS EQU $9880
TITLE_ADDRESS_OFFSET EQU TITLE_ADDRESS - _SCRN0
TITLE_DISTANCE_FROM_TOP_IN_TILES EQU 4
TITLE_HEIGHT_IN_TILES EQU 6

SECTION "menu vars", WRAM0
	wMenuFrame:: DB
	wSelectedMode:: DB
	wMenuCursorOAM:: DB

SECTION "menu", ROMX

InitializeMenu::
	xor a ; ld a, 0
	ld [wMenuFrame], a
	ld [wSelectedMode], a
	ld a, 140
	ld [rSCY], a
	ret

LoadMenuOpeningGraphics::
	ld bc, MenuTitleTiles
	ld hl, _VRAM9000
	ld de, MenuTitleTilesEnd - MenuTitleTiles
	call MEMCPY
	ld bc, MenuMap + SCRN_X_B * TITLE_DISTANCE_FROM_TOP_IN_TILES
	ld hl, TITLE_ADDRESS
	ld d, TITLE_HEIGHT_IN_TILES
	call MEMCPY_SINGLE_SCREEN
	ret

LoadMenuGraphics::
	ld bc, MenuTiles
	ld hl, _VRAM8000 + $20
	ld de, MenuTilesEnd - MenuTiles
	call MEMCPY
	ld bc, MenuMap
	ld hl, _SCRN0
	ld d, SCRN_Y_B
	call MEMCPY_SINGLE_SCREEN

	ld bc, CloudsTiles
	ld hl, _VRAM8800
	ld de, CloudsTilesEnd - CloudsTiles
	call MEMCPY

	ld bc, CloudsMap
	ld hl, $99C0
	ld de, CloudsMapEnd - CloudsMap
	ld a, $80
	call MEMCPY_WITH_OFFSET
	ret

SpawnMenuCursor::
	ld b, 1 ; need 1 sprite for cursor
	call RequestOAMSpace
	cp a, 0
	jr z, .end
.availableSpace:
	ld a, b
	ld [wMenuCursorOAM], a
	SET_HL_TO_ADDRESS wOAM, wMenuCursorOAM
	ld a, 104 ; y
	ld [hli], a
	ld a, 56 ; x
	ld [hli], a
	ld [hl], MENU_CURSOR_TILE
	inc l
	ld [hl], OAMF_PAL0
.end:
	ret

UpdateMenuOpening::
	UPDATE_GLOBAL_TIMER
.checkSkip:
	call ReadController
	ldh a, [hControllerDown]
    and PADF_START | PADF_A
	jr z, .endSkip
	call StopSweepSound
	ld a, 5
	ld [wMenuFrame], a
.endSkip:

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
	jp StartMenu
.startSound:
	call RisingSound
	jr .endFrame
.scrollUpTitle:
	ldh a, [rSCY]
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
	ldh a, [rSCY]
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
	ret z
.endFrame:
	ld a, [wMenuFrame]
	inc a 
	ld [wMenuFrame], a
.end:
	ret

UpdateMenu::
	UPDATE_GLOBAL_TIMER

.fadeIn:
	call FadeInPalettes
	ret z
.hasFadedIn:
	call _hUGE_dosound
	call IncrementScrollOffset
	ld a, [wTriggerFadeOut]
	cp a, 0
	jr nz, .fadeOut

.blinkMenuCursor:
	ldh a, [hGlobalTimer]
	and %00011111
	jr nz, .blinkMenuCursorEnd
.blink:
	SET_HL_TO_ADDRESS wOAM+2, wMenuCursorOAM
	ld a, [hl]
	cp a, EMPTY_TILE
	jr nz, .empty
.show:
	ld a, MENU_CURSOR_TILE
	ld [hl], a
	jr .blinkMenuCursorEnd
.empty:
	ld a, EMPTY_TILE
	ld [hl], a
.blinkMenuCursorEnd:

.menuInput:
	call ReadController
	ldh a, [hControllerDown]
	and PADF_START | PADF_A
	ret z
.start:
	ld a, 1 
	ld [wTriggerFadeOut], a
	call CollectSound
	ret
.fadeOut:
	call FadeOutPalettes
	jp nz, StartGame
	ret