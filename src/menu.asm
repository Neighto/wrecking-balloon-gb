INCLUDE "constants.inc"
INCLUDE "macro.inc"

SECTION "menu", ROMX

MENU_MODES EQU 2

SpawnMenuCursor::
	ld b, 1 ; need 1 sprite for cursor
	call RequestOAMSpaceOffset
	ld [wOAMGeneral1], a
	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
	ld a, 104 ; y
	ld [hli], a
	ld a, 56 ; x
	ld [hli], a
	ld [hl], $80
	inc l
	ld [hl], %00000000
	ret

BlinkMenuCursor::
	; Check timer
	ld a, [global_timer]
	and %00011111
	jr z, .blink
	ret
.blink:
	; Check what tile and flip it
	SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
	ld a, [hl]
	cp a, $00
	jr nz, .empty
.show:
	ld a, $80
	ld [hl], a
	ret
.empty:
	ld a, $00
	ld [hl], a
	ret

MoveCursor:
	; call CollectSound
	ld a, [selected_mode]
	inc a
	ld d, MENU_MODES
	call MODULO
	ld [selected_mode], a
	cp a, 0
	jr nz, .storyMode
.classicMode:
	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
	ld a, 104
	ld [hl], a
	ret
.storyMode:
	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
	ld a, 120
	ld [hl], a
	ret

SelectMode:
	ld a, [selected_mode]
	cp a, 0
	jr nz, .storyMode
.classicMode:
	call CollectSound
	ld hl, classic_mode_stage
	ld [hl], STAGE_CLASSIC_SELECTED
	; call StartClassic
	ret
.storyMode:
	; call StartStory
	ret

MenuInput:
	ld a, [global_timer]
	and %00000011
	jr nz, .end
	call ReadInput	
.moveSelected:
	; ld a, [joypad_pressed]
	; call JOY_SELECT
	; call nz, MoveCursor
.selectMode:
	ld a, [joypad_down]
	call JOY_START
	call nz, SelectMode
.end:
	ret

UpdateMenu::
	call BlinkMenuCursor
	ld a, [classic_mode_stage]
	cp a, STAGE_CLASSIC_SELECTED
	jr z, .fadeOut
	call MenuInput
	ret
.fadeOut:
	call HasFadedOut
	cp a, 0
	jr nz, .hasFadedOut
	call FadeOutPalettes
	ret
.hasFadedOut:
	call StartClassic
	ret