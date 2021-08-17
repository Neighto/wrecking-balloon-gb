SECTION "RAM vars", WRAM0[$C000]
	score:: DS 3
	global_timer:: DB
	joypad_down:: DB
	joypad_pressed:: DB
	paused_game:: DB
	difficulty_level:: DB

	song_timer:: DB
	song_index:: DB

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

SECTION "general initialization", ROM0 
InitializeGameVars::
	xor a
	ld [paused_game], a
	ld [difficulty_level], a
	; Should be set in player, but need to separate inits from spawning!
  	ld [player_invincible], a
	ld [song_timer], a
	ld [song_index], a

	ld a, 2
	ld [player_lives], a
	ret

SECTION "OAM vars", WRAM0[$C100]
	player_cactus:: DS 4*2
	player_balloon:: DS 4*2
	point_balloon:: DS 4*2
	enemy_cactus:: DS 4*2
	enemy_balloon:: DS 4*2
	enemy2_cactus:: DS 4*2
	enemy2_balloon:: DS 4*2
	bird:: DS 4*3