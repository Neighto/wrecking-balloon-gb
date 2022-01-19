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
	call InitializeMenu
	call LCD_ON_NO_WINDOW
	; Comment out MenuLoop and MenuLoopOpening to skip menu
; MenuLoopOpening:
; 	call WaitVBlank
; 	call UpdateMenuOpening
; 	call UpdateGlobalTimer
; 	jp MenuLoopOpening
MenuLoop::
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
	call LoadClassicData
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePlayer
	call InitializePointBalloon
	call InitializeBalloonCactus
	call InitializePorcupine
	call InitializeBird
	call InitializeBomb
	call InitializeClassicVars
	call LCD_ON_NO_WINDOW
	; Comment out ParkLoop to skip park cutscene
ParkLoop:
	; call WaitVBlank
	; call OAMDMA
	; call UpdatePark
	; call UpdateGlobalTimer
	; jp ParkLoop

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