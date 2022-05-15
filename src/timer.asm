SECTION "timer vars", HRAM
	hGlobalTimer:: DB

SECTION "timer", ROM0

ResetGlobalTimer::
	xor a ; ld a, 0
	ldh [hGlobalTimer], a
	ret