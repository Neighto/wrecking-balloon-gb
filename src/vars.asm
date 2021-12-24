SECTION "general RAM vars", WRAM0[$C000]
	vblank_flag:: DB
	score:: DS 3
	global_timer:: DB
	joypad_down:: DB
	joypad_pressed:: DB
	paused_game:: DB
	difficulty_level:: DB
	selected_mode:: DB
	hand_waving_frame:: DB
	countdown_frame:: DB
	cloud_scroll_offset:: DB
	classic_mode_stage:: DB
	fade_frame:: DB

	; General-use OAM offset
	wOAMGeneral1:: DB
	wOAMGeneral2:: DB

	; Set LCD interrupt behavior
	wLCDInterrupt:: DS 2

	; Updating tilemap
	wUpdateTilemapAddress:: DS 2
	wUpdateTilemapOffset:: DB
	wUpdateTilemapIndex:: DB
	wHasUpdatedNextTilemapAddress:: DB
	wLastUpdatedSCX:: DB

SECTION "general initialization", ROMX

InitializeGameVars::
	xor a ; ld a, 0
	ld [vblank_flag], a
	ld [paused_game], a
	ld [difficulty_level], a
	ld [selected_mode], a
	ld [hand_waving_frame], a
	ld [countdown_frame], a
	ld [cloud_scroll_offset], a
	ld [classic_mode_stage], a
	ld [fade_frame], a
	ld [wUpdateTilemapOffset], a
	ld [wUpdateTilemapIndex], a
	ld [wHasUpdatedNextTilemapAddress], a

	ld a, 255
	ld [wLastUpdatedSCX], a

	ld a, 2
	ld [player_lives], a
	ret