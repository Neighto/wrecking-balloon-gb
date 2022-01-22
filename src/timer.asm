SECTION "timer vars", WRAM0
	wGlobalTimer:: DB

SECTION "timer", ROMX

UpdateGlobalTimer::
	ld a, [wGlobalTimer]
	inc	a
	ld [wGlobalTimer], a
	ret
