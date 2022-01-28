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
	call LoadMenuOpeningData
	call SetupPalettes
	call CopyDMARoutine
	call InitializeGameVars
	call InitializeGame
	call InitializeController
	call InitializeMenu
	ld hl, menuTheme
	call hUGE_init
	call LCD_ON_NO_WINDOW
	; Comment out MenuLoopOpening to skip menu opening
MenuLoopOpening:
	; call WaitVBlank
	; call UpdateMenuOpening
	; call UpdateGlobalTimer
	; jp MenuLoopOpening
StartMenu::
	call LCD_OFF
	call WaveSound
	call SetMenuInterrupts
	call SpawnMenuCursor
	call LoadMenuData
	call ResetScroll
	call ResetFading
	call LCD_ON_NO_WINDOW
	; Comment out MenuLoop to skip menu
MenuLoop:
	; call WaitVBlank
	; call OAMDMA
	; call UpdateMenu
	; call UpdateGlobalTimer
	; call _hUGE_dosound
	; jp MenuLoop

StartGame::
	call ParkEnteredClassic
	call WaitVBlank
	call LCD_OFF
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound
	call ClearAllTiles
	call ResetScroll
	call SetParkInterrupts
	call SetupParkPalettes
	call SetGameMapStartPoint
	call SpawnHandWave
	call SetupWindow
	call InitializeScore
	call LoadParkData
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePlayer
	call SpawnPlayer
	call ResetFading
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
	call SetGameInterrupts
	call SetupPalettes
	call LoadGameData
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