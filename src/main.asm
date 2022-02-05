INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

Start::
	di
	ld sp, $FFFE
	call InitializeInterrupts
	call WaitVBlank
	call LCD_OFF
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearAllTiles
	call ResetScroll
	call CopyDMARoutine
	call LoadMenuOpeningGraphics
	call InitializeGeneralVars
	call InitializePalettes
	call InitializeGame
	call InitializeController
	call InitializeMenu
	ld hl, menuTheme
	call hUGE_init
	call LCD_ON_NO_WINDOW
	; Comment out MenuLoopOpening to skip menu opening
MenuLoopOpening:
	call WaitVBlank
	call UpdateMenuOpening
	call UpdateGlobalTimer
	jp MenuLoopOpening
StartMenu::
	call LCD_OFF
	call WaveSound
	call ResetScroll
	call SetMenuInterrupts
	call ResetFading
	call LoadMenuGraphics
	call SpawnMenuCursor
	call LCD_ON_NO_WINDOW
	; Comment out MenuLoop to skip menu
MenuLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateMenu
	call UpdateGlobalTimer
	jp MenuLoop

StartGame::
	call WaitVBlank
	call LCD_OFF
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound
	call ClearAllTiles
	call ResetScroll
	call SetParkInterrupts
	call SetupWindow
	call LoadParkGraphics
	call ResetFading
	call InitializeScore
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePlayer
	call SpawnPlayer
	call SpawnHandWave
	call LCD_ON_NO_WINDOW
	; Comment out ParkLoop to skip park cutscene
ParkLoop:
	call WaitVBlank
	call OAMDMA
	call UpdatePark
	call UpdateGlobalTimer
	jp ParkLoop

SetupNextLevel::
	call WaitVBlank
	call LCD_OFF
	call ResetScroll
	call ClearOAM
	call ClearRAM
	call ClearSound
	call SetGameInterrupts
	call LoadGameGraphics
	call ResetFading
	call InitializeGame
	call InitializeNewLevel
	call InitializePointBalloon
	call InitializeBalloonCactus
	call InitializePorcupine
	call InitializeBird
	call InitializeBomb
	call InitializePlayer
	call SpawnPlayer
	call SpawnCountdown
	ld hl, angryTheme
	call hUGE_init
	call LCD_ON

GameCountdownLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateGameCountdown
	call UpdateGlobalTimer
	jp GameCountdownLoop
GameLoop::
	call WaitVBlank
	call OAMDMA
	call UpdateGame
	call UpdateGlobalTimer
	jp GameLoop