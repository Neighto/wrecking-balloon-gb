INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "hardware.inc"

MENU_MODES EQU 2
MENU_CURSOR_TILE EQU $02

TITLE_ADDRESS EQU $9880
TITLE_ADDRESS_OFFSET EQU TITLE_ADDRESS - _SCRN0
TITLE_DISTANCE_FROM_TOP_IN_TILES EQU 4
TITLE_HEIGHT_IN_TILES EQU 5

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
.tiles:
	; Required for LoadMenuGraphics*
	ld bc, MenuTitleTiles
	ld hl, _VRAM9000
	ld de, MenuTitleTilesEnd - MenuTitleTiles
	call MEMCPY
.tilemap:
	; Add WRECKING BALLOON title
	ld bc, TitleMap
	ld hl, TITLE_ADDRESS
	ld d, TITLE_HEIGHT_IN_TILES
	call MEMCPY_SINGLE_SCREEN
	ret

LoadMenuGraphics::
.tiles:
	ld bc, MenuTiles
	ld hl, _VRAM8000 + $20
	ld de, MenuTilesEnd - MenuTiles
	call MEMCPY
	ld bc, DarkCloudsTiles
	ld hl, _VRAM8800
	ld de, DarkCloudsTilesEnd - DarkCloudsTiles
	call MEMCPY
	ld bc, LightCloudsTiles
	ld hl, _VRAM8800 + $40
	ld de, LightCloudsTilesEnd - LightCloudsTiles
	call MEMCPY
.tilemap:
	; Add WRECKING BALLOON title
	ld bc, TitleMap
	ld hl, TITLE_ADDRESS
	ld d, TITLE_HEIGHT_IN_TILES
	call MEMCPY_SINGLE_SCREEN
	; Add scrolling dark clouds
	ld bc, DarkCloudsMap
	ld hl, $99E0
	ld de, DarkCloudsMapEnd - DarkCloudsMap
	ld a, $80
	call MEMCPY_WITH_OFFSET
	; Add scrolling light clouds
	ld bc, LightCloudsMap
	ld hl, $99C0
	ld de, LightCloudsMapEnd - LightCloudsMap
	ld a, $84
	call MEMCPY_WITH_OFFSET
	; Fill in dark clouds space
	ld hl, $9A00
    ld bc, $40
    ld d, $81
    call SetInRange
	; Add texts
	ld bc, StartMap
	ld hl, $9968
	ld de, StartMapEnd - StartMap
	ld a, $4D
	call MEMCPY_WITH_OFFSET
	ld bc, NameMap
	ld hl, $9A0B
	ld de, NameMapEnd - NameMap
	ld a, $51
	call MEMCPY_WITH_OFFSET 
	ld hl, $9A04
	ld a, 2 + NUMBERS_TILE_OFFSET
	ld [hli], a
	ld a, 0 + NUMBERS_TILE_OFFSET
	ld [hli], a
	ld a, 2 + NUMBERS_TILE_OFFSET
	ld [hli], a
	ld [hl], a
	ret

SpawnMenuCursor::
	ld b, 1 ; need 1 sprite for cursor
	call RequestOAMSpace
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
	ld b, 0
	ld c, 1
	call hUGE_mute_channel
	call CollectSound
	ret
.fadeOut:
	call FadeOutPalettes
	jp nz, StartGame
	ret