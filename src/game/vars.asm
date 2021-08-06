SECTION "RAM vars", WRAM0[$C000]
	score:: DS 3
	scroll_timer:: DB
	movement_timer:: DB
	collision_timer:: DB
	joypad_down:: DB
	joypad_pressed:: DB
	paused_game:: DB

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
	player_bobbed_up:: DB
	player_speed:: DB
	player_bob_timer:: DB
	player_drift_timer_x:: DB
	player_drift_timer_y:: DB
	player_lives:: DB

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

SECTION "general initialization", ROM0 
InitializeGameVars::
	xor a
	ld [hl], paused_game
	ld hl, player_lives
	ld [hl], 2
	ret

SECTION "OAM vars", WRAM0[$C100]
	player_cactus:: DS 4*2
	player_balloon:: DS 4*2
	point_balloon:: DS 4*2
	enemy_cactus:: DS 4*2
	enemy_balloon:: DS 4*2
	enemy2_cactus:: DS 4*2
	enemy2_balloon:: DS 4*2