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
	jp MENULOOP

STARTCLASSIC::
	di
	ld a, IEF_STAT ; Enable LCD Interrupt
	ldh [rIE], a
	ld a, 0
	ldh [rLYC], a
	ld a, STATF_LYC
	ldh [rSTAT], a
	ei

	call WaitVBlank
	call LCD_OFF
	call SetupPalettes
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearAllTiles
	call ResetScroll
	call SetClassicMapStartPoint
	call SpawnHandWave
	call SetupWindow
	call InitializeScore
	call LoadGameData
	call InitializePlayer
	call InitializePointBalloon
	call InitializeEnemy
	call InitializeEnemy2
	call InitializeBird
	call RefreshLives
	; call ClearBottom ; TESTING
	call LCD_ON_BG_ONLY
CUTSCENELOOP:
	; ei
	call WaitVBlankNoWindow
	; call LCD_OFF
	; di
	call UpScrollOffset
	; call CheckCutsceneOver
	call PlayerUpdate
	; call VerticalScrollGradual
	call HandWaveAnimation
	call UpdateGlobalTimer
	; di
	call OAMDMA
	; call LCD_ON_BG_ONLY
	; ei
	jp CUTSCENELOOP

PREGAMELOOP::
	call ResetScroll
	call LCD_ON
GAMELOOP:
	call WaitVBlank
	call TryToUnpause
	ld a, [paused_game]
	cp a, 1
	jr z, .END
	call HorizontalScroll
	call CollisionUpdate
	call UpdateGlobalTimer
	call PlayerUpdate
	call ClassicGameManager
	call RefreshScore ; Might want to move somewhere to call less frequently
	call OAMDMA
.END:
	jp GAMELOOP