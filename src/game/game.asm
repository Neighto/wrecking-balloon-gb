INCLUDE "constants.inc"
INCLUDE "hardware.inc"

HAND_WAVE_START_X EQU 120
HAND_WAVE_START_Y EQU 112

SECTION "game", ROMX

SpawnMenuCursor::
	ld hl, player_cactus ; Borrow
	ld a, 104 ; y
	ld [hli], a
	ld a, 56 ; x
	ld [hli], a
	ld [hl], $80
	inc l
	ld [hl], %00000000
	ret

MoveCursor:
	call CollectSound
	ld a, [selected_mode]
	inc a
	ld d, MENU_MODES
	call MODULO
	ld [selected_mode], a
	cp a, 0
	jr nz, .storyMode
.classicMode:
	ld a, 104
	ld [player_cactus], a
	ret
.storyMode:
	ld a, 120
	ld [player_cactus], a
	ret

SelectMode:
	ld a, [selected_mode]
	cp a, 0
	jr nz, .storyMode
.classicMode:
	call STARTCLASSIC
	ret
.storyMode:
	; call STARTSTORY
	ret

MenuInput::
	ld a, [global_timer]
	and %00000011
	jr nz, .end
	call ReadInput	
.moveSelected:
	ld a, [joypad_pressed]
	call JOY_SELECT
	call nz, MoveCursor
.selectMode:
	ld a, [joypad_down]
	call JOY_START
	call nz, SelectMode
.end:
	ret

CheckCutsceneOver::
	; TODO could cause issues when < 0
	ld a, [rSCY]
	inc a
	ld b, a
	call OffScreenY
	cp a, 0
	call nz, PREGAMELOOP
	ret

TryToUnpause::
	xor a ; ld a, 0
	ld hl, paused_game
	cp a, [hl]
	jr z, .end
	; Is paused
	call ReadInput
	ld a, [joypad_pressed]
	call JOY_START
	jr z, .end
	xor a ; ld a, 0
	ld [hl], a ; pause
.end:
	ret

SpawnHandWave::
	; Totally dumb for now... But we just take another enemy sprite slot
    ld hl, enemy2_balloon
    ld a, HAND_WAVE_START_Y
    ld [hli], a
    ld a, HAND_WAVE_START_X
    ld [hli], a
    ld [hl], $A0
    inc l
    ld [hl], %00000000
	ret

; NOTE if ram becomes a problem I could probably use modulo off global timer for frames
HandWaveAnimation::
	; Here we move the sprite as the screen moves
	ldh a, [rSCY]
	ld b, a
	ld a, BACKGROUND_VSCROLL_START
	sub a, b
	add a, HAND_WAVE_START_Y
	ld [enemy2_balloon], a

	; Here we animate
    ld a, [hand_waving_frame]
    cp a, 0
    jr nz, .frame1
.frame0:
    ld a, [global_timer]
    and 15
    jp nz, .end
    ld hl, enemy2_balloon+2
    ld [hl], $A2
    ld hl, hand_waving_frame
    ld [hl], 1
    ret
.frame1:
    ld a, [global_timer]
    and 15
    jp nz, .end
    ld hl, enemy2_balloon+2
    ld [hl], $A0
    ld hl, hand_waving_frame
    ld [hl], 0
.end:
	ret

UpdateGlobalTimer::
	ld a, [global_timer]
	inc	a
	ld [global_timer], a
	ret