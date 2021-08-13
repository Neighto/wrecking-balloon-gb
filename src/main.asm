INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

START::
	di
	ld sp, $FFFE

	; ld a, IEF_VBLANK | IEF_STAT ; Enable Vblank and LCD Interrupt
	; ld [rIE], a

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
	call EnemiesUpdate
	call GameManager
	call RefreshScore ; Might want to move somewhere to call less frequently
	call OAMDMA
.END
	jp GAMELOOP

SECTION "timer", ROM0 

UpdateGlobalTimer:
	ld a, [global_timer]
	inc	a
	ld [global_timer], a
	ret