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
	call InitializeLives
	call InitializeParallaxScrolling
	call InitializePalettes
	call InitializeController
	call InitializeMenu
	ld hl, menuTheme
	call hUGE_init
	call LCD_ON_NO_WINDOW
	; Comment out MenuLoopOpening to skip menu opening
MenuLoopOpening:
	; call WaitVBlank
	; call UpdateMenuOpening
	; jp MenuLoopOpening
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
	; call WaitVBlank
	; call OAMDMA
	; call UpdateMenu
	; jp MenuLoop

StartGame::
	call WaitVBlank
	call LCD_OFF
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound
	call ClearAllTiles
	call ResetScroll
	call SetOpeningCutsceneInterrupts
	call LoadGameSpriteTiles
	call LoadWindow
	call LoadOpeningCutsceneGraphics
	call ResetFading
	call InitializeOpeningCutscene
	call InitializeTotal
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePlayer
	call InitializeBullet
	call SpawnPlayer
	call SetPlayerPositionOpeningCutscene
	call SpawnHandWave
	ld hl, menuTheme
	call hUGE_init
	ld b, 0
	ld c, 1
	call hUGE_mute_channel
	ld b, 1
	ld c, 1
	call hUGE_mute_channel
	ld b, 3
	ld c, 1
	call hUGE_mute_channel
	call LCD_ON_NO_WINDOW
	; Comment out OpeningCutsceneLoop to skip cutscene
OpeningCutsceneLoop:
	; call WaitVBlank
	; call OAMDMA
	; call UpdateOpeningCutscene
	; jp OpeningCutsceneLoop

SetupNextLevel::
	call WaitVBlank
	call LCD_OFF
	call ResetScroll
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound

	ld a, [wLevel]
	cp a, 1
	jr z, .level1
	cp a, 2
	jr z, .level2
	cp a, 3
	jr z, .level3
	; Don't reach this point
.level1:
	; call SetLevel1Interrupts
	; call LoadLevel1Graphics
	; ld hl, angryTheme
	; call hUGE_init
	; jr .endLevelSetup
.level2:
	; call SetLevel2Interrupts
	; call LoadLevel2Graphics
	; ld hl, angryTheme
	; call hUGE_init
	; jr .endLevelSetup
.level3:
	call SetLevel3Interrupts
	call LoadLevel3Graphics
	call InitializeFlicker
	ld hl, angryTheme
	call hUGE_init
	jr .endLevelSetup
.level4:
.level5:
.level6:
.endLevelSetup:
	call SetupWindow
	call ResetFading
	call InitializeGame
	call InitializeScore
	call InitializeNewLevel
	call InitializeEnemies
	call InitializePlayer
	call InitializeBullet
	call SpawnPlayer
	call SpawnCountdown
	call LCD_ON

GameCountdownLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateGameCountdown
	jp GameCountdownLoop
GameLoop::
	call WaitVBlank
	call OAMDMA
	call UpdateGame
	jp GameLoop

StageClear::
	call WaitVBlank
	call LCD_OFF
	call ResetScroll
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound
	call InitializeInterrupts
	call LoadStageClearGraphics
	call ResetFading
	call InitializeStageClear
	ld hl, menuTheme
	call hUGE_init
	ld b, 3
	ld c, 1
	call hUGE_mute_channel
	ld b, 2
	ld c, 1
	call hUGE_mute_channel
	call LCD_ON_NO_WINDOW
StageClearLoop:
	call WaitVBlank
	call UpdateStageClear
	jp StageClearLoop

GameOver::
	call WaitVBlank
	call LCD_OFF
	call ResetScroll
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound
	call InitializeInterrupts
	call LoadGameOverGraphics
	call InitializePalettes
	call InitializeGameOver
	ld hl, gameOverTheme
	call hUGE_init
	call LCD_ON_NO_WINDOW
GameOverLoop:
	call WaitVBlank
	call UpdateGameOver
	jp GameOverLoop

GameWon::
	call WaitVBlank
	call LCD_OFF
	call ResetScroll
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound
	call InitializeInterrupts
	call LoadEndingCutsceneGraphics
	call InitializePalettes
	call InitializeEndingCutscene
	call InitializePlayer
	call SpawnPlayer
	call SetPlayerPositionEndingCutscene
	call SpawnHandClap
	ld hl, menuTheme
	call hUGE_init
	call LCD_ON_NO_WINDOW
GameWonLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateEndingCutscene
	jp GameWonLoop