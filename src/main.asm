INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

START::
	di
	ld sp, $FFFE

	call WaitVBlank
	call LCD_OFF

	call SetupPalettes

	call ClearMap
	call ClearOAM
	call ClearRAM

	; Copy the menu tiles
	ld bc, MenuTiles
	ld hl, $9000
	ld de, MenuTilesEnd - MenuTiles
	call MEMCPY
	ld bc, MenuTilesLetters
	ld hl, $8800
	ld de, MenuTilesLettersEnd - MenuTilesLetters
	call MEMCPY

	; Copy the menu tilemap
	ld bc, MenuMap
	ld hl, $9800
	ld de, MenuMapEnd - MenuMap
	call MEMCPY

	call InitializeGameVars
	call SpawnMenuCursor
	call CopyDMARoutine

	call LCD_ON_BG_ONLY

MENULOOP:
	call WaitVBlank
	call UpdateGlobalTimer
	call OAMDMA
	; Menu Controls TODO move logic elsewhere 
	ld a, [global_timer]
	and %00000011
	jr nz, .END
	call ReadInput	
.moveSelected:
	ld a, [joypad_pressed]
	call JOY_SELECT
	jr z, .selectMode
	call MoveCursor
.selectMode:
	ld a, [joypad_down]
	call JOY_START
	call nz, SelectMode
.END:
	jp MENULOOP

STARTGAME::
	di
	ld sp, $FFFE

	; ld a, IEF_VBLANK | IEF_STAT ; Enable Vblank and LCD Interrupt
	; ld [rIE], a

	; call AUDIO_OFF

	call WaitVBlank
	call LCD_OFF

	call SetupPalettes

	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearAllTiles

	call SetupWindow
	; call InitializeGameVars
	call InitializeScore

	call LoadGameData
	call InitializePlayer
	call InitializePointBalloon
	call InitializeEnemy
	call InitializeEnemy2
	call InitializeBird
	call RefreshLives
	; call CopyDMARoutine
	call PlayMusic

	call LCD_ON

GAMELOOP:
	call WaitVBlank
	call TryToUnpause
	ld a, [paused_game]
	cp a, 1
	jr z, .END
	; call PlayMusic
	call VBlankHScroll
	call CollisionUpdate
	call UpdateGlobalTimer
	call PlayerUpdate
	call GameManager
	call RefreshScore ; Might want to move somewhere to call less frequently
	call OAMDMA
.END:
	jp GAMELOOP