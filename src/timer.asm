SECTION "timer", ROMX

UpdateGlobalTimer::
	ld a, [global_timer]
	inc	a
	ld [global_timer], a
	ret
