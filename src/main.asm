INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

Common::
	call ClearMap
	call ClearOAM
	call ClearVRAM9000
	call ResetGlobalTimer
	call ResetScroll
	call ClearSound
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
	call LoadGameSpriteTiles
	call LoadGameMiscellaneousTiles
	call SetupWindow
	call InitializeLives
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
	call LCD_ON_NO_WINDOW
	; Comment out MenuLoop to skip menu
MenuLoop:
	; call WaitVBlank
	; call OAMDMA
	; call UpdateMenu
	; jp MenuLoop

StartGame::
	ld a, [wSelectedMode]
	cp a, 0
	jr nz, SetupNextLevel
OpeningCutscene:
	call WaitVBlank
	call LCD_OFF
	call Common
	call InitializeEnemies
	call SetOpeningCutsceneInterrupts
	call LoadOpeningCutsceneGraphics
	call InitializeSequence
	call InitializeOpeningCutscene
	call InitializeLevelVars
	call InitializeEnemyStructVars
	call InitializePlayer
	call InitializeBullet
	call SpawnPlayer
	call SetPlayerPositionOpeningCutscene
	call SetPlayerSpeedSlow
	call SpawnHandWave
	call SpawnCartBalloons
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
	call Common
	call InitializeEnemies
	call InitializePlayer
	call InitializeBullet
	call InitializePalettes
	call InitializeBossMiscellaneous
	call SpawnPlayer
	call SpawnCountdown

	; ; testing
	ld a, 6
	ld [wLevel], a
	; ld a, 1
	; ld [wSelectedMode], a
	; ; ^^^
	ld a, [wSelectedMode]
	cp a, 0
	jp nz, .endless
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
	call SetLevelDesertInterrupts
	call LoadLevelDesertGraphics
	ld hl, funkMachineTheme
	call hUGE_init
	jr .endLevelSetup
.level4:
	cp a, 4
	jr nz, .level5
	call SetLevelNightDesertInterrupts
	call LoadLevelNightDesertGraphics
	ld hl, funkMachineTheme
	call hUGE_init
	call InitializeNightSpritePalettes
	jr .endLevelSetup
.level5:
	cp a, 5
	jr nz, .level6
	call SetLevelShowdownInterrupts
	call LoadLevelShowdownGraphics
	ld hl, funkMachineTheme
	call hUGE_init
	jr .endLevelSetup
.level6:
	; cp a, 6
	; jr nz, .level7
	call SetLevelShowdownInterrupts
	call LoadLevelShowdownGraphics
	ld hl, bossTheme
	call hUGE_init
	call InitializeBoss
	call SpawnBoss
	call SetPlayerPositionBoss
	jr .endLevelSetup
.endless:
	call SetEndlessInterrupts
	call LoadEndlessGraphics
	ld hl, angryTheme
	call hUGE_init
.endLevelSetup:
	call InitializeGame
	call InitializeEndless
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
PreGameLoop::
	call ClearCountdown
GameLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateGame
	jp GameLoop

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
	call ResetGlobalTimer
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
	call SetEndingCutsceneInterrupts
	call LoadEndingCutsceneGraphics
	call InitializeSequence
	call InitializeEndingCutscene
	call InitializePlayer
	call SpawnPlayer
	call SetPlayerCactusHappy
	call SetPlayerPositionEndingCutscene
	call SetPlayerSpeedSlow
	call SpawnHandClap
	call SpawnCartBalloons
	ld hl, menuTheme
	call hUGE_init
	ld b, 2 ; Channel 3
	ld c, 1 ; Mute
	call hUGE_mute_channel
	ld b, 3 ; Channel 4
	ld c, 1 ; Mute
	call hUGE_mute_channel
	call LCD_ON_NO_WINDOW
GameWonLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateEndingCutscene
	jp GameWonLoop