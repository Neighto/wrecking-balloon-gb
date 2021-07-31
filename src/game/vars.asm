SECTION "RAM vars", WRAM0[$C000]
	scroll_timer:: DB
	movement_timer:: DB
	collision_timer:: DB
	joypad_down:: DB
	joypad_pressed:: DB

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

	point_balloon_x:: DB
	point_balloon_y:: DB
	point_balloon_alive:: DB
	point_balloon_popping:: DB
	point_balloon_popping_frame:: DB
	balloon_pop_timer:: DB
	point_balloon_respawn_timer:: DB

	enemy_x:: DB
	enemy_y:: DB
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

SECTION "OAM vars", WRAM0[$C100]
	player_cactus:: DS 4*2
	player_balloon:: DS 4*2
	point_balloon:: DS 4*2
	enemy_cactus:: DS 4*2
	enemy_balloon:: DS 4*2