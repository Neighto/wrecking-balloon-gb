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
	; ld hl, song_descriptor
	; call hUGE_init
	call SetupPalettes
	call CopyDMARoutine
	call InitializeGameVars
	call InitializePointBalloon
	call SpawnMenuCursor
	call LCD_ON_BG_ONLY
MenuLoop:
	call WaitVBlank
	; call _hUGE_dosound
	call UpdateGlobalTimer
	call MenuBalloonUpdate
	call MenuInput
	call OAMDMA
	jp MenuLoop

StartClassic::
	call SetParkLYC
	call WaitVBlank
	call LCD_OFF
	call SetupParkPalettes
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
	call LCD_ON_BG_ONLY
ParkLoop:
	call WaitVBlank
	call IncrementScrollOffset
	call HandleParkLoop
	call PlayerUpdate
	call HandWaveAnimation
	call UpdateGlobalTimer
	call OAMDMA
	jp ParkLoop

PregameLoop::
	call StartedClassic
	call SetClassicLYC
	call ResetScroll
	call ClearOAM
	call ClearRAM
	call InitializePlayer
	call SetupPalettes
	call LCD_ON
GameLoop:
	call WaitVBlank
	call TryToUnpause
	ld a, [paused_game]
	cp a, 1
	jr z, .end
	call HorizontalScroll
	call CollisionUpdate
	call UpdateGlobalTimer
	call PlayerUpdate
	call ClassicGameManager
	call RefreshScore ; Might want to move somewhere to call less frequently
	call OAMDMA
.end:
	jp GameLoop