INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "hardware.inc"

MENU_CURSOR_TILE EQU $6A
MODES_ADDRESS EQU $9926

MENU_SPRITE_CLASSIC_Y EQU 88
MENU_SPRITE_ENDLESS_Y EQU 104
MENU_SPRITE_X EQU 48
MENU_SPRITE_BLINK_TIMER EQU %00011111

TITLE_ADDRESS EQU $9860
TITLE_ADDRESS_OFFSET EQU TITLE_ADDRESS - _SCRN0
TITLE_DISTANCE_FROM_TOP_IN_TILES EQU 4
TITLE_HEIGHT_IN_TILES EQU 5

SECTION "menu vars", WRAM0
	wMenuFrame:: DB
	wSelectedMode:: DB
	wMenuCursorOAM:: DB
	wMenuCursorTimer:: DB

SECTION "menu", ROMX

InitializeMenu::
	xor a ; ld a, 0
	ld [wMenuFrame], a
	ld [wSelectedMode], a
	ld [wMenuCursorTimer], a
	ld a, 140
	ld [rSCY], a
	ret

LoadMenuOpeningGraphics::
.tiles:
	ld bc, MenuTiles
	ld hl, _VRAM9000
	ld de, MenuTilesEnd - MenuTiles
	call MEMCPY
.tilemap:
	; Add WRECKING BALLOON title
	ld bc, TitleMap
	ld hl, TITLE_ADDRESS
	ld d, TITLE_HEIGHT_IN_TILES
	ld e, SCRN_X_B
	call MEMCPY_SINGLE_SCREEN
	ret

LoadMenuGraphics::
.tiles:
	ld bc, MenuTiles
	ld hl, _VRAM9000
	ld de, MenuTilesEnd - MenuTiles
	call MEMCPY
.tilemap:
	; Add WRECKING BALLOON title
	ld bc, TitleMap
	ld hl, TITLE_ADDRESS
	ld d, TITLE_HEIGHT_IN_TILES
	ld e, SCRN_X_B
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
	ld bc, ModesMap
	ld hl, MODES_ADDRESS
	ld de, 7
	ld a, $51
	call MEMCPY_WITH_OFFSET
	ld hl, MODES_ADDRESS + $40
	ld de, 7
	call MEMCPY_WITH_OFFSET
	ld bc, NameMap
	ld hl, $9A0B
	ld de, NameMapEnd - NameMap
	ld a, $4D
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
	ld a, MENU_SPRITE_CLASSIC_Y
	ld [hli], a
	ld a, MENU_SPRITE_X
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
.startSound:
	cp a, 0
	jr nz, .scrollUpTitle
	call RisingSound
	jr .endFrame
.scrollUpTitle:
	cp a, 1
	jr nz, .endSound
	ldh a, [rSCY]
	cp a, 0
	jr z, .endFrame
	ldh a, [rSCY]
    inc a
    ldh [rSCY], a
	ret
.endSound:
	cp a, 2
	jr nz, .scrollDownTitle
	call StopSweepSound
	jr .endFrame
.scrollDownTitle:
	cp a, 3
	jr nz, .scrollUpTitle2
	ldh a, [rSCY]
	cp a, 252
	jr z, .endFrame
	ldh a, [rSCY]
	dec a
    ldh [rSCY], a
	ret
.scrollUpTitle2:
	cp a, 4
	jr nz, .fadeOut
	ld a, [rSCY]
	cp a, 0
	jr z, .endFrame
	ldh a, [rSCY]
    inc a
    ldh [rSCY], a
	ret
.fadeOut:
	cp a, 5
	jr nz, .startMenu
	call FadeOutPalettes
	ret z
	jr .endFrame
.startMenu:
	jp StartMenu
.endFrame:
	ld a, [wMenuFrame]
	inc a 
	ld [wMenuFrame], a
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
	ld a, [wMenuCursorTimer]
	inc a
	ld [wMenuCursorTimer], a
	and MENU_SPRITE_BLINK_TIMER
	jr nz, .blinkMenuCursorEnd
.blink:
	ld hl, wOAM+2
	ld a, [wMenuCursorOAM]
	call AddToHL
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
.checkSelect:
	ldh a, [hControllerPressed]
	and PADF_SELECT | PADF_UP | PADF_DOWN
	jr z, .checkStart
.select:
	xor a ; ld a, 0
	ld [wMenuCursorTimer], a
	ld hl, wOAM+2
	ld a, [wMenuCursorOAM]
	call AddToHL
	ld a, MENU_CURSOR_TILE
	ld [hld], a
	dec hl ; Now pointing to Y
	ld a, [wSelectedMode]
	cp a, 0
	jr z, .selectEndless
.selectClassic:
	xor a ; ld a, 0
	ld [wSelectedMode], a
	ld a, MENU_SPRITE_CLASSIC_Y
	ld [hl], a
	ret
.selectEndless:
	ld a, 1
	ld [wSelectedMode], a
	ld a, MENU_SPRITE_ENDLESS_Y
	ld [hl], a
	ret
.checkStart:
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