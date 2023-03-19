INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "hardware.inc"
INCLUDE "tileConstants.inc"

MODES_ADDRESS EQU $9926
MENU_SPRITE_CLASSIC_Y EQU 88
MENU_SPRITE_ENDLESS_Y EQU 104
MENU_SPRITE_X EQU 48
MENU_SPRITE_BLINK_TIMER EQU %00011111
MENU_SPRITE_SPRITES EQU 1

TITLE_ADDRESS EQU $9860
TITLE_ADDRESS_OFFSET EQU TITLE_ADDRESS - _SCRN0
TITLE_DISTANCE_FROM_TOP_IN_TILES EQU 4
TITLE_HEIGHT_IN_TILES EQU 5

MODES_OFFSET EQU $4D
YEAR_NAME_DISTANCE_FROM_TOP_IN_TILES EQU 4
YEAR_NAME_ADDRESS EQU $9A00

SUNGLASSES_ADDRESS EQU $9811
SUNGLASSES_SPRITES EQU 2

SECTION "menu vars", WRAM0
wMenuFrame:: DB
wSelectedMode:: DB
wMenuCursorOAM:: DB
wMenuCursorTimer:: DB
wSunglassesOAM:: DB
wSecret:: DB

SECTION "menu", ROMX

InitializeMenu::
	xor a ; ld a, 0
	ld [wMenuFrame], a
	ld [wSelectedMode], a
	ld [wMenuCursorTimer], a
	ld [wSecret], a
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
	jp MEMCPY_SINGLE_SCREEN

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
	; Add scrolling light clouds
	ld bc, CloudsMap + CLOUDS_LIGHT_OFFSET
	ld hl, $99C0
	call MEMCPY_PATTERN_CLOUDS
	; Add scrolling dark clouds
	ld bc, CloudsMap + CLOUDS_DARK_OFFSET
	call MEMCPY_PATTERN_CLOUDS
	; Fill in dark clouds space
	ld hl, $9A00
    ld bc, $40
    ld d, DARK_GREY_BKG_TILE
    call SetInRange
	; Add texts
	ld bc, ModesMap
	ld hl, MODES_ADDRESS
	ld de, 7
	ld a, MODES_OFFSET
	call MEMCPY_WITH_OFFSET
	ld hl, MODES_ADDRESS + $40
	ld de, 7
	call MEMCPY_WITH_OFFSET
	; Year + name row
	ld bc, WindowMap + SCRN_X_B * YEAR_NAME_DISTANCE_FROM_TOP_IN_TILES
	ld hl, YEAR_NAME_ADDRESS
	ld de, SCRN_X_B
	ld a, WINDOW_TILES_8800_OFFSET
	jp MEMCPY_WITH_OFFSET

SpawnMenuCursor::
	ld b, MENU_SPRITE_SPRITES
	ld hl, wMenuCursorOAM
	call RequestOAMAndSetOAMOffset
	ret z
	; Has available space
	ld a, MENU_SPRITE_CLASSIC_Y
	ld [hli], a
	ld a, MENU_SPRITE_X
	ld [hli], a
	ld a, MENU_CURSOR_TILE
	ld [hli], a
	ld a, OAMF_PAL0
	ld [hl], a
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
	jp nz, .fadeOut

.blinkMenuCursor:
	ld a, [wMenuCursorTimer]
	inc a
	ld [wMenuCursorTimer], a
	and MENU_SPRITE_BLINK_TIMER
	jr nz, .blinkMenuCursorEnd
.blink:
	ld hl, wOAM+2
	ADD_A_TO_HL [wMenuCursorOAM]
	ld a, [hl]
	cp a, WHITE_SPR_TILE
	jr nz, .empty
.show:
	ld a, MENU_CURSOR_TILE
	ld [hl], a
	jr .blinkMenuCursorEnd
.empty:
	ld a, WHITE_SPR_TILE
	ld [hl], a
.blinkMenuCursorEnd:

.menuInput:
	call ReadController

.checkSunglasses:
	ldh a, [hControllerPressed]
	and PADF_SELECT
	jr z, .checkSelect
	; SUNGLASSES
	call BoostSound
	ld hl, SUNGLASSES_ADDRESS
	ld a, [wSecret]
	cp a, 0 
	jr nz, .sunglassesModeOff
.sunglassesModeOn:
	ld a, 1 
	ld [wSecret], a
	ld a, SUNGLASSES_TILE
	jr .updateSunglassesMode
.sunglassesModeOff:
	xor a ; ld a, 0
	ld [wSecret], a
	ld a, WHITE_SPR_TILE
	; jr .updateSunglassesMode
.updateSunglassesMode:
	LD_BC_HL
	call WaitVRAMAccessible
	LD_HL_BC
	ld [hli], a
	ld [hl], a
	ret
.checkSelect:
	ldh a, [hControllerPressed]
	and PADF_UP | PADF_DOWN
	jr z, .checkStart
	; SELECT
	call BulletSound
	; Reset cursor blink
	xor a ; ld a, 0
	ld [wMenuCursorTimer], a
	; Move cursor and select mode
	ld hl, wOAM+2
	ADD_TO_HL [wMenuCursorOAM]
	ld a, MENU_CURSOR_TILE
	ld [hld], a
	dec hl ; Now pointing to Y
	ld a, [wSelectedMode]
	cp a, CLASSIC_MODE
	jr z, .selectEndless
.selectClassic:
	ld a, CLASSIC_MODE
	ld [wSelectedMode], a
	ld a, MENU_SPRITE_CLASSIC_Y
	ld [hl], a
	ret
.selectEndless:
	ld a, ENDLESS_MODE
	ld [wSelectedMode], a
	ld a, MENU_SPRITE_ENDLESS_Y
	ld [hl], a
	ret
.checkStart:
	ldh a, [hControllerDown]
	and PADF_START | PADF_A
	ret z
	; START
	ld a, 1 
	ld [wTriggerFadeOut], a
	ld b, 0 ; Channel 1
	ld c, 1 ; Mute
	call hUGE_mute_channel
	jp LifeUpSound
.fadeOut:
	call FadeOutPalettes
	jp nz, StartGame
	ret