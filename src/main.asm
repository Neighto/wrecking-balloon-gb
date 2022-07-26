INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

Start::
	di
	ld sp, $E000 ; Stack pointer to WRAM ; OLD: $FFFE
	call InitializeInterrupts
	call WaitVBlank
	call LCD_OFF
	call ClearMap
	call ClearWindow
	call ClearOAM
	; call ClearRAM
	call ClearHRAM
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
	call InitializeEndlessVars
	call InitializeSound
	call AUDIO_ON ; Not actually required
	ld hl, menuTheme
	call hUGE_init
	call LCD_ON_NO_WINDOW_8_SPR_MODE
	; Comment out MenuLoopOpening to skip menu opening
MenuLoopOpening:
	; call WaitVBlank
	; call UpdateMenuOpening
	; jp MenuLoopOpening
StartMenu::
	call LCD_OFF
	call TitleSplashSound
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
	call ClearSound
	call ClearAllTiles
	call ResetScroll
	call ResetGlobalTimer
	call SetOpeningCutsceneInterrupts
	call LoadGameSpriteTiles
	call LoadGameOverTiles
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
	ld b, 0 ; Channel 1
	ld c, 1 ; Mute
	call hUGE_mute_channel
	ld b, 1 ; Channel 2
	ld c, 1 ; Mute
	call hUGE_mute_channel
	ld b, 3 ; Channel 4
	ld c, 1 ; Mute
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
	call ClearSound
	call SetupWindow
	call ResetFading
	call InitializeEnemies
	call InitializePlayer
	call InitializeBullet
	call InitializePalettes
	call SpawnPlayer
	call SpawnCountdown

	; ; testing
	; ld a, 1
	; ld [wLevel], a
	; ; ^^^

	ld a, [wLevel]
.level1:
	cp a, 1
	jr nz, .level2
	call SetLevelCityInterrupts
	call LoadLevelCityGraphics
	ld hl, angryTheme
	call hUGE_init
	jp .endLevelSetup
.level2:
	cp a, 2
	jr nz, .level3
	call SetLevelNightCityInterrupts
	call LoadLevelNightCityGraphics
	ld hl, angryTheme
	call hUGE_init
	jp .endLevelSetup
.level3:
	cp a, 3
	jr nz, .level4
	call SetLevelBossInterrupts
	call LoadLevelBossGraphics
	ld hl, bossTheme
	call hUGE_init
	call SpawnBossNotInLevelData
	call SetPlayerPositionBoss
	jr .endLevelSetup
.level4:
	cp a, 4
	jr nz, .level5
	call SetLevelDesertInterrupts
	call LoadLevelDesertGraphics
	ld hl, angryTheme
	call hUGE_init
	jr .endLevelSetup
.level5:
	cp a, 5
	jr nz, .level6
	call SetLevelNightDesertInterrupts
	call LoadLevelNightDesertGraphics
	ld hl, angryTheme
	call hUGE_init
	call InitializeNightSpritePalettes
	jr .endLevelSetup
.level6:
	cp a, 6
	jr nz, .level7
	call SetLevelBossInterrupts
	call LoadLevelBossGraphics
	ld hl, bossTheme
	call hUGE_init
	call SpawnBossNotInLevelData
	call SetPlayerPositionBoss
	jr .endLevelSetup
.level7:
	cp a, 7
	jr nz, .level8
	call SetLevelShowdownInterrupts
	call LoadLevelShowdownGraphics
	ld hl, angryTheme
	call hUGE_init
	jr .endLevelSetup
.level8:
	cp a, 8
	jr nz, .level9
	call SetLevelShowdownInterrupts
	call LoadLevelShowdownGraphics
	ld hl, angryTheme
	call hUGE_init
	jr .endLevelSetup
.level9:
	call SetLevelBossInterrupts
	call LoadLevelBossGraphics
	ld hl, bossTheme
	call hUGE_init
	call SpawnBossNotInLevelData
	call SetPlayerPositionBoss
.endLevelSetup:
	call InitializeGame
	call InitializeScore
	call InitializeNewLevel
	call RefreshWindow
	call LCD_ON
	; Comment out GameCountdownLoop to skip countdown
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
	call ClearSound
	call InitializeInterrupts
	call InitializeSound
	call SetWaveRAMToSquareWave
	call LoadStageClearGraphics
	call ResetFading
	call ResetGlobalTimer
	call InitializeFadedPalettes
	call InitializeStageClear
	call SpawnStageNumber
	call LCD_ON_NO_WINDOW_8_SPR_MODE
StageClearLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateStageClear
	jp StageClearLoop

GameOver::
	call WaitVBlank
	call LCD_OFF
	call ResetGlobalTimer
	call ClearOAM
	call ClearSound
	call InitializeInterrupts
	call LoadGameOverGraphics
	call InitializePalettes
	call InitializeGameOver
	ld hl, gameOverTheme
	call hUGE_init
	call LCD_ON
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