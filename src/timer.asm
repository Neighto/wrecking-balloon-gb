SECTION "timer vars", HRAM
	hGlobalTimer:: DB

SECTION "timer", ROMX

UpdateGlobalTimer::
	ldh a, [hGlobalTimer]
	inc	a
	ldh [hGlobalTimer], a
	ret
