INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

Start::
	di
	ld sp, $FFFE
	call WaitVBlankNoWindow
	call LCD_OFF
	call ClearMap
	call ClearOAM
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
	call WaitVBlankNoWindow
	; call _hUGE_dosound
	call UpdateGlobalTimer
	call MenuBalloonUpdate
	call MenuInput
	call OAMDMA
	jp MenuLoop

StartClassic::
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
	call SetupClassicCutscenePalettes
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
CutsceneLoop:
	ei
	call WaitVBlankNoWindow
	di
	call IncrementScrollOffset
	call HandleCutsceneLoop
	call PlayerUpdate
	call HandWaveAnimation
	call UpdateGlobalTimer
	call OAMDMA
	jp CutsceneLoop

PregameLoop::
	call ResetScroll
	call SetupPalettes
	call LCD_ON
GameLoop:
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
	jp GameLoop