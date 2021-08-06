INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

START::
	di

	ld sp, $FFFE

	; Enable Vblank Interrupt
	ld a, IEF_VBLANK
	ld [rIE], a

	; Enable LCD Interrupt
	ld a, IEF_STAT
	ld [rIE], a

	; call AUDIO_OFF

	call WaitVBlank
	call LCD_OFF

	call SetupPalettes

	call ClearMap
	call ClearOAM
	call ClearRAM

	call SetupWindow
	call InitializeGameVars
	call InitializeScore

	call LoadGameData
	call RefreshLives
	call CopyDMARoutine

	call LCD_ON

GAMELOOP:
	call WaitVBlank
	call TryToUnpause
	ld a, [paused_game]
	cp a, 1
	jr z, .END
	call VBlankHScroll
	call CollisionUpdate
	call UpdateGlobalTimer
	call PlayerUpdate
	call PointBalloonUpdate
	call EnemyUpdate
	call Enemy2Update
	call OAMDMA
.END
	jp GAMELOOP

SECTION "timer", ROM0 

UpdateGlobalTimer:
	ld a, [movement_timer]
	inc	a
	ld [movement_timer], a
	ret