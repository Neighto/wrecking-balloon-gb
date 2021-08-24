INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

START::
	di
	ld sp, $FFFE
	call WaitVBlankNoWindow
	call LCD_OFF
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearAllTiles
	call ResetScroll
	call LoadMenuData
	call SetupPalettes
	call CopyDMARoutine
	call InitializeGameVars
	call InitializePointBalloon
	call SpawnMenuCursor
	call LCD_ON_BG_ONLY
MENULOOP:
	call WaitVBlankNoWindow
	call UpdateGlobalTimer
	call MenuBalloonUpdate
	call MenuInput
	call OAMDMA
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
	call ResetScroll
	call SetupWindow
	call InitializeScore
	call LoadGameData
	call InitializePlayer
	call InitializePointBalloon
	call InitializeEnemy
	call InitializeEnemy2
	call InitializeBird
	call RefreshLives
	call PlayMusic ; Remove
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