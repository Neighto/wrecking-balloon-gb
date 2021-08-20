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

	call LoadMenuData
	call InitializeGameVars
	call SpawnMenuCursor
	call CopyDMARoutine

	call LCD_ON_BG_ONLY

MENULOOP:
	call WaitVBlank
	call UpdateGlobalTimer
	call OAMDMA
	call MenuInput
.END:
	jp MENULOOP

STARTCLASSIC::

	; ld a, IEF_VBLANK | IEF_STAT ; Enable Vblank and LCD Interrupt
	; ld [rIE], a

	call WaitVBlank
	call LCD_OFF

	call SetupPalettes

	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearAllTiles

	call SetupWindow
	call InitializeScore

	call LoadGameData
	call InitializePlayer
	call InitializePointBalloon
	call InitializeEnemy
	call InitializeEnemy2
	call InitializeBird
	call RefreshLives
	call PlayMusic

	call LCD_ON

GAMELOOP:
	call WaitVBlank
	call TryToUnpause
	ld a, [paused_game]
	cp a, 1
	jr z, .END
	call VBlankHScroll
	call CollisionUpdate
	call UpdateGlobalTimer
	call PlayerUpdate
	call GameManager
	call RefreshScore ; Might want to move somewhere to call less frequently
	call OAMDMA
.END:
	jp GAMELOOP