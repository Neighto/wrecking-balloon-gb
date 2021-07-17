INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

START::
	ei

	; Enable Vblank Interrupt
	; ld sp, $FFFE
	; ld a, IEF_VBLANK
	; ld [rIE], a

	call TurnOffAudio

	call WAIT_VBLANK
	call LCD_OFF

	call SetupPalettes

	call ClearMap
	call ClearOAM
	call ClearRAM

	call LoadGameData
	call CopyDMARoutine

	call LCD_ON

GAMELOOP:
	call WAIT_VBLANK
	; call VBlankHScroll
	call CollisionCheck
	call PlayerUpdate
	call PointBalloonMovement
	call OAMDMA
	jp GAMELOOP

SECTION "otherfornow", ROM0

TurnOffAudio:
	ld a, 0
	ld [rNR52], a
	ret