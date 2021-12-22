INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

Start::
	di
	ld sp, $FFFE
	call SetBaseInterrupts
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
	; Comment out MenuLoop to skip menu
MenuLoop:
	call WaitVBlank
	call OAMDMA
	call _hUGE_dosound
	call UpdateMenu
	call UpdateGlobalTimer
	jp MenuLoop

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
	; Comment out ParkLoop to skip park cutscene
ParkLoop:
	call WaitVBlank
	call OAMDMA
	call UpdatePark
	call UpdateGlobalTimer
	jp ParkLoop

PregameLoop::
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


GameLoop:
	call WaitVBlank
	call OAMDMA
	call UpdateClassic
	call UpdateGlobalTimer
.end:
	jp GameLoop


;; MOVE ME
MoveToNextTilemap::
	push hl
	push af
	; basic way: long timer that will set between the 2 ways!
	; when we see X flag set, then we set tilemap address
	; ld a, [global_timer]
	; and %00000111
	; jr nz, .end
	

	; should we update tilemap
	ld a, [rSCX]
	cp a, 7
	jr nc, .end

	ld a, [alreadyReadThis]
	cp a, 0
	jr nz, .end2
	ld a, 1
	ld [alreadyReadThis], a

	ld a, [wCanUpdateTilemap]
	cp a, 0
	jr z, .clouds2
	cp a, 1
	jr z, .clouds2

.clouds1:
	; Default loaded tilemap
	ld hl, wUpdateTilemapAddress
	ld a, LOW(BackgroundMap)
	ld [hli], a
	ld a, HIGH(BackgroundMap)
	ld [hl], a
	ld a, $0
	ld [wUpdateTilemapOffset], a
	ld a, 1
	ld [wCanUpdateTilemap], a
	jr .end2
.clouds2:
	ld hl, wUpdateTilemapAddress
	ld a, LOW(World2Map)
	ld [hli], a
	ld a, HIGH(World2Map)
	ld [hl], a
	ld a, $37
	ld [wUpdateTilemapOffset], a
	ld a, 2
	ld [wCanUpdateTilemap], a
	jr .end2
.end:
	; reset alreadyReadThis
	ld a, [rSCX]
	cp a, 14
	jr nc, .end2
	ld a, 0 
	ld [alreadyReadThis], a
.end2:
	pop af
	pop hl
	ret