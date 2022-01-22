SECTION "general RAM vars", WRAM0[$C000]
	; Fading
	wFadeInFrame:: DB
	wFadeOutFrame:: DB

	; General-use OAM offset
	wOAMGeneral1:: DB
	wOAMGeneral2:: DB

	; Parallax scroll offset
	wParallaxClose:: DB
	wParallaxFar:: DB

	; Updating tilemap
	wUpdateTilemapAddress:: DS 2
	wUpdateTilemapOffset:: DB
	wUpdateTilemapIndex:: DB
	wHasUpdatedNextTilemapAddress:: DB
	wLastUpdatedSCX:: DB

SECTION "general initialization", ROMX

InitializeGameVars::
	xor a ; ld a, 0
	ld [wParallaxClose], a
	ld [wParallaxFar], a
	ld [wFadeInFrame], a
	ld [wFadeOutFrame], a
	ld [wUpdateTilemapOffset], a
	ld [wUpdateTilemapIndex], a
	ld [wHasUpdatedNextTilemapAddress], a

	ld a, 255
	ld [wLastUpdatedSCX], a

	ld a, 2
	ld [wPlayerLives], a
	ret