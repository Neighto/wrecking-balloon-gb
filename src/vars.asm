SECTION "RAM vars", WRAM0[$C000]
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

	player_x:: DB
	player_y:: DB
	player_cactus_x:: DB 
	player_cactus_y:: DB
	player_alive:: DB
	player_popping:: DB
	player_popping_frame:: DB
	player_falling:: DB
	player_fall_speed:: DB
	player_falling_timer:: DB
	player_pop_timer:: DB
	player_delay_falling_timer:: DB
	player_respawn_timer:: DB
	player_speed:: DB
	player_lives:: DB
	player_invincible:: DB ; Operates like a timer, when set, invincible immediately
	player_cant_move:: DB

	point_balloon_x:: DB
	point_balloon_y:: DB
	point_balloon_alive:: DB
	point_balloon_popping:: DB
	point_balloon_popping_frame:: DB
	point_balloon_pop_timer:: DB
	point_balloon_respawn_timer:: DB

	; Enemy 1
	enemy_balloon_x:: DB
	enemy_balloon_y:: DB
	enemy_cactus_x:: DB 
	enemy_cactus_y:: DB
	enemy_alive:: DB
	enemy_popping:: DB
	enemy_popping_frame:: DB
	enemy_falling:: DB
	enemy_fall_speed:: DB
	enemy_falling_timer:: DB
	enemy_pop_timer:: DB
	enemy_delay_falling_timer:: DB
	enemy_respawn_timer:: DB

	; Enemy 2
	enemy2_balloon_x:: DB
	enemy2_balloon_y:: DB
	enemy2_cactus_x:: DB 
	enemy2_cactus_y:: DB
	enemy2_alive:: DB
	enemy2_popping:: DB
	enemy2_popping_frame:: DB
	enemy2_falling:: DB
	enemy2_fall_speed:: DB
	enemy2_falling_timer:: DB
	enemy2_pop_timer:: DB
	enemy2_delay_falling_timer:: DB
	enemy2_respawn_timer:: DB

	; Bird
	bird_x:: DB
	bird_y:: DB
	bird_flapping_frame:: DB
	bird_respawn_timer:: DB
	bird_alive:: DB
	bird_spawn_right:: DB
	bird_speed:: DB

	; Bomb
	bomb_x:: DB
	bomb_y:: DB
	bomb_respawn_timer:: DB
	bomb_alive:: DB
	bomb_speed:: DB
	bomb_popping:: DB
	bomb_popping_frame:: DB
	bomb_pop_timer:: DB

SECTION "general initialization", ROMX
InitializeGameVars::
	xor a
	ld [vblank_flag], a
	ld [paused_game], a
	ld [difficulty_level], a
	ld [selected_mode], a
	ld [hand_waving_frame], a
	ld [countdown_frame], a
	ld [cloud_scroll_offset], a
	ld [classic_mode_stage], a
	ld [fade_frame], a

	ld a, 2
	ld [player_lives], a
	ret

SECTION "OAM vars", WRAM0[$C100]
	wPlayerCactus:: DS 4*2
	wPlayerBalloon:: DS 4*2
	wPointBalloon:: DS 4*2
	wEnemyCactus:: DS 4*2
	wEnemyBalloon:: DS 4*2
	wEnemy2Cactus:: DS 4*2
	wEnemy2Balloon:: DS 4*2
	wBird:: DS 4*3
	wBomb:: DS 4*3
	wPropellerCactus:: DS 4*8