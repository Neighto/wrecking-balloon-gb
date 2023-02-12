INCLUDE "hardware.inc"
INCLUDE "header.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

SECTION "rom", ROM0

Common::
	call ClearMap
	call ClearOAM
	call ClearVRAM9000
	call ClearSound
	call ResetScroll
	RESET_GLOBAL_TIMER
	jp ResetFading

Start::
	di
	ld sp, $E000 ; Stack pointer to WRAM ; OLD: $FFFE
	call InitializeInterrupts
	call WaitVBlank
	call LCD_OFF
	call Common
	call ClearWindow
	call ClearHRAM
	call ClearVRAM8000
	call ClearVRAM8800
	call CopyDMARoutine
	call LoadMenuOpeningGraphics
	call LoadWindow
	call LoadGameSpriteAndMiscellaneousTiles
	call SetupWindow
	call InitializeParallaxScrolling
	call InitializeController
	call InitializeMenu
	call InitializeSound
	call InitializePalettes
	call InitializeTotal
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
	call StopSweepSound
	call SetMenuInterrupts
	call ResetFading
	call LoadMenuGraphics
	call SpawnMenuCursor
	call LCD_ON_NO_WINDOW_8_SPR_MODE
	; Comment out MenuLoop to skip menu
MenuLoop:
	; call WaitVBlank
	; call OAMDMA
	; call UpdateMenu
	; jp MenuLoop

StartGame::
	; === testing ===
	; ld a, ENDLESS_MODE
	; ld [wSelectedMode], a
	; ===============
	ld a, [wSelectedMode]
	cp a, CLASSIC_MODE
	jr z, .enteringClassic
.enteringEndless:
	call InitializeLivesEndless
	jr SetupNextLevel
.enteringClassic:
	call InitializeLivesClassic

OpeningCutscene:
	call WaitVBlank
	call LCD_OFF
	call Common
	call InitializeEnemies
	call SetCutsceneInterrupts
	call LoadOpeningCutsceneGraphics
	call InitializeSequence
	call InitializeOpeningCutscene
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePlayer
	call InitializeBullet
	call SpawnPlayer
	call SetPlayerPositionAndSpeedOpeningCutscene
	call SpawnHandWave
	call SpawnCartBalloons
	ld hl, menuTheme
	call hUGE_init_game_song
	ld b, 1 ; Channel 2
	ld c, 1 ; Mute
	call hUGE_mute_channel
	call LCD_ON_NO_WINDOW
	; Comment out OpeningCutsceneLoop to skip cutscene
OpeningCutsceneLoop:
	; call WaitVBlank
	; call OAMDMA
	; call UpdateOpeningCutscene
	; jp OpeningCutsceneLoop

	; SetupNextLevel
SetupNextLevel::
	call WaitVBlank
	call LCD_OFF
	call Common
	call InitializeEnemies
	call InitializePlayer
	call InitializeBullet
	call InitializePalettes
	call InitializeGame
	call InitializeEndless
	call InitializeScore
	call SpawnPlayer

	; === testing ===
	ld a, 2
	ldh [hLevel], a
	; ===============

.levelSelect:
	ldh a, [hLevel]
.level1:
	cp a, LEVEL_1
	jr nz, .level2
	call SetLevelCityInterrupts
	call LoadLevelCityGraphics
	ld hl, angryTheme
	call hUGE_init_game_song
	jp .endLevelSetup
.level2:
	cp a, LEVEL_2
	jr nz, .level3
	call SetLevelNightCityInterrupts
	call LoadLevelNightCityGraphics
	ld hl, cityNightTheme
	call hUGE_init_game_song
	jp .endLevelSetup
.level3:
	cp a, LEVEL_3
	jr nz, .level4
	call SetLevelDesertInterrupts
	call LoadLevelDesertGraphics
	ld hl, desertTheme
	call hUGE_init_game_song
	jr .endLevelSetup
.level4:
	cp a, LEVEL_4
	jr nz, .level5
	call SetLevelNightDesertInterrupts
	call LoadLevelNightDesertGraphics
	ld hl, desertNightTheme
	call hUGE_init_game_song
	call InitializeNightSpritePalettes
	jr .endLevelSetup
.level5:
	cp a, LEVEL_5
	jr nz, .level6
	call SetLevelNightShowdownInterrupts
	call LoadLevelShowdownGraphics
	ld hl, showdownTheme
	call hUGE_init_game_song
	jr .endLevelSetup
.level6:
	cp a, LEVEL_BOSS
	jr nz, .endless
	call SetLevelShowdownInterrupts
	call LoadLevelShowdownGraphics
	ld hl, bossTheme
	call hUGE_init_game_song
	call InitializeBoss
	call InitializeBossMiscellaneous
	call SpawnBoss
	call SetPlayerPositionBoss
	jr .endLevelSetup
.endless:
	; cp a, LEVEL_ENDLESS
	; jr nz, .endLevelSetup
	call SetEndlessInterrupts
	call LoadEndlessGraphics
	ld hl, angryTheme
	call hUGE_init_game_song
	; clean this
	ld a, [hEndlessLevelSwitchSkip]
	cp a, 0
	jr nz, .endLevelSetup
	call InitializeEmptyPalettes
	; jr .endLevelSetup
.endLevelSetup:
	call InitializeNewLevel
	call RefreshWindow
	call LCD_ON
	; Check flag to skip countdown for endless level switching
	ld a, [hEndlessLevelSwitchSkip]
	cp a, 0
	jr nz, GameLoop
	; Comment out GameCountdownLoop and SpawnCountdown to skip countdown
	call SpawnCountdown
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

	; SetupNextLevelEndless
SetupNextLevelEndless::
	call ClearSound
	call WaitVBlank
	call LCD_OFF
	call ClearMap
	call InitializePalettes
	call InitializeSound
	jp SetupNextLevel.levelSelect

StageClear::
	call WaitVBlank
	call LCD_OFF
	call Common
	call InitializeInterrupts
	call InitializeSound
	call SetWaveRAMToSquareWave
	call LoadStageClearGraphics
	call InitializeEmptyPalettes
	call InitializeSequence
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
	call ClearSound
	call ClearOAM
	call InitializeGameOver
	ld hl, gameOverTheme
	call hUGE_init
	call RefreshGameOverWindow
	call LCD_ON
GameOverLoop:
	call WaitVBlank
	call UpdateGameOver
	jp GameOverLoop

GameWon::
	call WaitVBlank
	call LCD_OFF
	call Common
	call InitializeEnemies
	call SetCutsceneInterrupts
	call LoadEndingCutsceneGraphics
	call InitializeSequence
	call InitializeEndingCutscene
	call InitializePlayer
	call SpawnPlayer
	call SetPlayerCactusHappy
	call SetPlayerPositionAndSpeedEndingCutscene
	call SpawnHandClap
	call SpawnCartBalloons
	ld hl, menuThemeShort
	call hUGE_init
	call LCD_ON_NO_WINDOW
GameWonLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateEndingCutscene
	jp GameWonLoop