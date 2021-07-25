INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

START::
	ei

	; Enable Vblank Interrupt
	ld sp, $FFFE
	ld a, IEF_VBLANK
	ld [rIE], a

	call TurnOffAudio

	call WaitVBlank
	call LCD_OFF

	call SetupPalettes

	call ClearMap
	call ClearOAM
	call ClearRAM

	call LoadGameData
	call CopyDMARoutine

	call LCD_ON

GAMELOOP:
	call WaitVBlank
	call VBlankHScroll
	call CollisionCheck
	call UpdateGlobalTimer
	call PlayerUpdate
	call PointBalloonUpdate
	call OAMDMA
	jp GAMELOOP

SECTION "audio", ROM0

TurnOffAudio:
	ld a, 0
	ld [rNR52], a
	ret

SECTION "timer", ROM0 

UpdateGlobalTimer:
	ld a, [movement_timer]
	inc	a
	ld [movement_timer], a
	ret