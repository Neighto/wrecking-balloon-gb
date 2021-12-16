INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

Start::
	di
	ld sp, $FFFE
	ld a, IEF_STAT | IEF_VBLANK ; Enable LCD and VBLANK interrupts
	ldh [rIE], a
	ld a, STATF_LYC
	ldh [rSTAT], a
	call WaitVBlank
	; call AUDIO_OFF
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
; MenuLoop:
; 	call WaitVBlank
; 	call OAMDMA
; 	call _hUGE_dosound
; 	call UpdateMenu
; 	call UpdateGlobalTimer
; 	jp MenuLoop

StartClassic::
	call ParkEnteredClassic
	call SetParkLYC
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
	call LoadGameData
	call InitializePlayer
	call InitializePointBalloon
	call InitializeEnemy
	call InitializeEnemy2
	call InitializePropellerCactus
	call InitializeBird
	call InitializeBomb
	call InitializeClassicVars
	call RefreshLives
	call LCD_ON_BG_ONLY
; ParkLoop:
; 	call WaitVBlank
; 	call OAMDMA
; 	call UpdatePark
; 	call UpdateGlobalTimer
; 	jp ParkLoop

PregameLoop::
	call StartedClassic
	call SetClassicLYC
	call ResetScroll
	call ClearOAM
	call ClearRAM
	ld hl, angryTheme
	call hUGE_init
	call InitializePlayer
	call SpawnCountdown
	call SetupPalettes
	call LCD_ON
GameLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateClassic
	call UpdateGlobalTimer
.end:
	jp GameLoop