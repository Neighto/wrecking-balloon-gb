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
	call ClearWindow
	call ClearOAM
	call ClearRAM
	call ClearAllTiles
	call ResetScroll
	call CopyDMARoutine
	call LoadMenuOpeningGraphics
	call InitializeGeneralVars
	call InitializePalettes
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
	call LoadParkGraphics
	call ResetFading
	call InitializeOpeningCutscene
	call InitializeTotal
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePlayer
	call SpawnPlayer
	call SpawnHandWave
	call LCD_ON_NO_WINDOW
	; Comment out OpeningCutsceneLoop to skip cutscene
OpeningCutsceneLoop:
	call WaitVBlank
	call OAMDMA
	call UpdatePark
	call UpdateGlobalTimer
	jp OpeningCutsceneLoop

SetupNextLevel::
	call WaitVBlank
	call LCD_OFF
	call ResetScroll
	call ClearOAM
	call ClearRAM
	call ClearSound
	call SetGameInterrupts
	call SetupWindow
	call LoadGameGraphics
	call ResetFading
	call InitializeGame
	call InitializeScore
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

StageClear::
	call WaitVBlank
	call LCD_OFF
	call ResetScroll
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearAllTiles
	call ClearSound
	call InitializeInterrupts
	call LoadStageClearGraphics
	call InitializePalettes ; Warning cannot fade back in with this set this way
	call InitializeStageClear
	ld hl, menuTheme
	call hUGE_init
	call LCD_ON_NO_WINDOW
StageClearLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateStageClear
	call UpdateGlobalTimer
	jp StageClearLoop