INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "hardware.inc"
INCLUDE "tileConstants.inc"

MENU_MODES EQU 2
MENU_CURSOR_TILE EQU $02

TITLE_ADDRESS EQU $9880
TITLE_ADDRESS_OFFSET EQU TITLE_ADDRESS - _SCRN0
TITLE_DISTANCE_FROM_TOP_IN_TILES EQU 4
TITLE_HEIGHT_IN_TILES EQU 6

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
	ld [hl], MENU_CURSOR_TILE
	inc l
	ld [hl], OAMF_PAL0
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
	cp a, EMPTY_TILE
	jr nz, .empty
.show:
	ld a, MENU_CURSOR_TILE
	ld [hl], a
	ret
.empty:
	ld a, EMPTY_TILE
	ld [hl], a
	ret

SelectMode:
	call CollectSound
	ld a, 1 
	ld [wTriggerFadeOut], a
	ret

MenuInput:
	ld a, [wGlobalTimer]
	and %00000011
	jr nz, .end
	call ReadInput	
.moveSelected:
	ld a, [wControllerPressed]
	call JOY_SELECT
	; call nz, MoveCursor
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
	ret z
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
	call _hUGE_dosound
	ld a, [wTriggerFadeOut]
	cp a, 0
	jr nz, .fadeOut
	call MenuInput
	call IncrementScrollOffset
	ret
.fadeOut:
	call FadeOutPalettes
	cp a, 0
	jp nz, StartGame
	ret