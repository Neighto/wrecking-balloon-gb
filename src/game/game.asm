SECTION "game", ROMX

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