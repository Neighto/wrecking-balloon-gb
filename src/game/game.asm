INCLUDE "constants.inc"

SECTION "game", ROMX

SpawnMenuCursor::
	ld hl, player_cactus ; Borrow
	ld a, 104 ; y
	ld [hli], a
	ld a, 56 ; x
	ld [hli], a
	ld [hl], $8B
	inc l
	ld [hl], %00000000
	ret

MoveCursor::
	ld a, [selected_mode]
	inc a
	ld d, MENU_MODES
	call MODULO
	ld [selected_mode], a
	cp a, 0
	jr nz, .storyMode
.classicMode:
	ld a, 104
	ld [player_cactus], a
	ret
.storyMode:
	ld a, 112
	ld [player_cactus], a
	ret

SelectMode::
	ld a, [selected_mode]
	cp a, 0
	jr nz, .storyMode
.classicMode:
	call STARTGAME
	ret
.storyMode:
	; Empty for now
	ret

TryToUnpause::
	xor a ; ld a, 0
	ld hl, paused_game
	cp a, [hl]
	jr z, .end
	; Is paused
	call ReadInput
	ld a, [joypad_pressed]
	call JOY_START
	jr z, .end
	xor a ; ld a, 0
	ld [hl], a ; pause
.end:
	ret

UpdateGlobalTimer::
	ld a, [global_timer]
	inc	a
	ld [global_timer], a
	ret