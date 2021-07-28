SECTION "RAM vars", WRAM0[$C000]
	scroll_timer:: 	 DB
	movement_timer:: DB
	collision_timer:: DB
	balloon_pop_timer:: DB
	player_bob_timer:: DB
	player_drift_timer:: DB
	point_balloon_respawn_timer:: DB
	player_bobbed_up:: DB
	joypad_down::    DB
	joypad_pressed:: DB
	player_speed:: 	 DB
	player_x:: DB
	player_y:: DB
	player_cactus_x:: DB 
	player_cactus_y:: DB
	point_balloon_alive:: DB
	point_balloon_popping:: DB
	point_balloon_popping_frame:: DB
	point_balloon_x:: DB
	point_balloon_y:: DB

SECTION "OAM vars", WRAM0[$C100]
	player_balloon:: DS 4*2
	player_cactus:: DS 4*2
	point_balloon:: DS 4
	balloon_pop:: DS 4*4