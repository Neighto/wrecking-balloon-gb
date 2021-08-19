SECTION "game", ROMX

MoveMenu::
	ld a, [global_timer] ; if we even need a delay
	and $00000011
	jr nz, .end
	; Is paused
	call ReadInput	
.moveSelected:
	ld a, [joypad_down]
	call JOY_SELECT
	jr z, .selectMode
	
	;move
.selectMode:
	ld a, [joypad_down]
	call JOY_START
	jr z, .end
	call STARTGAME
	;select game
.end:
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