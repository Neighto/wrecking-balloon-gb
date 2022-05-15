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
	call ResetGlobalTimer
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
	call ResetGlobalTimer
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
	call ResetGlobalTimer
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
	call ResetGlobalTimer
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound

	; testing
	ld a, 3
	ld [wLevel], a
	; ^^^

	ld a, [wLevel]
.level1:
	cp a, 1
	jr nz, .level2
	call SetLevelCityInterrupts
	call LoadLevelCityGraphics
	ld hl, angryTheme
	call hUGE_init
	jr .endLevelSetup
.level2:
	cp a, 2
	jr nz, .level3
	call SetLevelNightCityInterrupts
	call LoadLevelCityGraphics
	ld hl, angryTheme
	call hUGE_init
	call InitializePalettes
	jr .endLevelSetup
.level3:
	cp a, 3
	jr nz, .level4
	call SetLevelShowdownInterrupts
	call LoadLevelShowdownGraphics
	ld hl, bossTheme
	call hUGE_init
	jr .endLevelSetup
.level4:
	cp a, 4
	jr nz, .level5
	call SetLevelDesertInterrupts
	call LoadLevelDesertGraphics
	call InitializeFlicker
	ld hl, angryTheme
	call hUGE_init
	jr .endLevelSetup
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
	; call WaitVBlank
	; call OAMDMA
	; call UpdateGameCountdown
	; jp GameCountdownLoop
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
	call ResetGlobalTimer
	call InitializeFadedPalettes
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
	call ResetGlobalTimer
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
	call ResetGlobalTimer
	call ClearMap
	call ClearOAM
	call ClearRAM
	call ClearSound
	call SetEndingCutsceneInterrupts
	call LoadEndingCutsceneGraphics
	call InitializePalettes
	call InitializeEndingCutscene
	call InitializePlayer
	call SpawnPlayer
	call SetPlayerCactusHappy
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