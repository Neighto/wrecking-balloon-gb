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
	ld hl, menuTheme
	call hUGE_init
	call SetupPalettes
	call CopyDMARoutine
	call InitializeGameVars
	call InitializeGame
	call InitializeController
	call InitializeMenu
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

StartClassic::
	call ParkEnteredClassic
	call SetParkInterrupts
	call WaitVBlank
	call LCD_OFF
	call SetupParkPalettes
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound
	call ClearAllTiles
	call ResetScroll
	call SetGameMapStartPoint
	call SpawnHandWave
	call SetupWindow
	call InitializeScore
	call LoadParkData
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePointBalloon
	call InitializeBalloonCactus
	call InitializePorcupine
	call InitializeBird
	call InitializeBomb
	call InitializePlayer
	call SpawnPlayer
	call ResetFading
	call LCD_ON_NO_WINDOW
	; Comment out ParkLoop to skip park cutscene
ParkLoop:
	; call WaitVBlank
	; call OAMDMA
	; call UpdatePark
	; call UpdateGlobalTimer
	; jp ParkLoop

PreGameLoop::
	call WaitVBlank
	call LCD_OFF
	call StartedClassic
	call SetGameInterrupts
	call ResetScroll
	call ClearOAM
	call ClearRAM
	ld hl, angryTheme
	call hUGE_init
	call LoadGameData
	call InitializePlayer
	call SpawnPlayer
	call SpawnCountdown
	call SetupPalettes
	call LCD_ON
GameLoopCountdown:
	call WaitVBlank
	call OAMDMA
	call UpdateGameCountdown
	call UpdateGlobalTimer
	jp GameLoopCountdown
GameLoop::
	call WaitVBlank
	call OAMDMA
	call UpdateGame
	call UpdateGlobalTimer
	jp GameLoop