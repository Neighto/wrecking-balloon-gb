SECTION "RAM Vars",WRAM0[$C100]

	joypad_down::    DB
	joypad_pressed:: DB
	
	;player vars
	bullets_alive::DB
	player_ground::DB
	player_idle::  DB
	player_fset::  DB
	player_fcount::DB
	player_gcount::DB
	player_fstart::DB
	player_fend::  DB
	; player_y::     DB
	; player_x::     DB
	player_y_temp::DB
	player_x_temp::DB
	player_yvel::  DB
	player_frame:: DB
	player_tile::  DB
	player_flags:: DB
	player_hp::    DB

	;other
	arb_counter::  DB
	scroll_timer:: DB ; temp variable for slowing down scroll speed

	my_sprites:: DS 4*13

	GAME_MAP_DATA:: DB ;bad