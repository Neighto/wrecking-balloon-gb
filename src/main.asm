INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

Start::
	di
	ld sp, $FFFE
	call SetBaseInterrupts
	call WaitVBlank
	call LCD_OFF
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearAllTiles
	call ResetScroll
	call LoadMenuData
	ld hl, menuTheme
	call hUGE_init
	call SetupPalettes
	call CopyDMARoutine
	call InitializeGameVars
	call SpawnMenuCursor
	call LCD_ON_BG_ONLY
	; Comment out MenuLoop to skip menu
; MenuLoop:
; 	call WaitVBlank
; 	call OAMDMA
; 	call _hUGE_dosound
; 	call UpdateMenu
; 	call UpdateGlobalTimer
; 	jp MenuLoop

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
	call SetClassicMapStartPoint
	call SpawnHandWave
	call SetupWindow
	call InitializeScore
	call LoadClassicGameData
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePlayer
	call InitializePointBalloon
	call InitializeBalloonCactus
	call InitializePorcupine
	call InitializeBird
	call InitializeBomb
	call InitializeClassicVars
	call LCD_ON_BG_ONLY
	; Comment out ParkLoop to skip park cutscene
; ParkLoop:
; 	call WaitVBlank
; 	call OAMDMA
; 	call UpdatePark
; 	call UpdateGlobalTimer
; 	jp ParkLoop

PreGameLoop::
	call StartedClassic
	call SetClassicInterrupts
	call ResetScroll
	call ClearOAM
	call ClearRAM
	ld hl, angryTheme
	call hUGE_init
	call InitializePlayer
	call SpawnCountdown
	call SetupPalettes
	call LCD_ON
GameLoopCountdown:
	call WaitVBlank
	call OAMDMA
	call UpdateClassicCountdown
	call UpdateGlobalTimer
	jp GameLoopCountdown
GameLoop::
	call WaitVBlank
	call OAMDMA
	call UpdateClassic
	call UpdateGlobalTimer
	jp GameLoop