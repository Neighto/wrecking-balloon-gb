INCLUDE "constants.inc"
INCLUDE "hardware.inc"

HAND_WAVE_START_X EQU 120
HAND_WAVE_START_Y EQU 112

SECTION "classic", ROMX

HandleCutsceneLoop::
	; Can we end loop
	ld a, [rSCY]
	inc a
	ld b, a
	call OffScreenY
	cp a, 0
	call nz, PREGAMELOOP
	; Can we scroll into the sky
	ld a, [start_scroll]
	cp a, 0
	call nz, ScrollIntoSky
	; Can we start scrolling into the sky
	call ReadInput
	ld a, [joypad_down]
	call JOY_UP
	jr z, .end
	ld a, 1
	ld [start_scroll], a
.end:
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

IncrementScrollOffset::
	ld a, [global_timer]
	and %00011111
	jr nz, .end
	
	ld a, [scroll_offset]
	inc a
	ld [scroll_offset], a
.end:
	ret

ScrollIntoSky:
    push af
    ld a, [global_timer]
    and	2
    jr nz, .end
    ld a, [cutscene_timer]
.slowScroll2:
    cp a, 140
    jr c, .fastScroll
    ldh a, [rSCY]
    sub 1
    ldh [rSCY], a
    jr .end
.fastScroll:
    cp a, 50
    jr c, .slowScroll
    ldh a, [rSCY]
    sub 2
    ldh [rSCY], a
    jr .end
.slowScroll:
    cp a, 30
    jr c, .end
    ldh a, [rSCY]
    sub 1
    ldh [rSCY], a
.end:
    ld a, [cutscene_timer]
    inc a
    ld [cutscene_timer], a
    pop af
    ret

SetClassicMapStartPoint::
    ld a, BACKGROUND_VSCROLL_START
    ldh [rSCY], a
    ret

ClassicGameManager::
    call PointBalloonUpdate

    ld a, [difficulty_level]
    cp a, 3
    jr nc, .levelThree
    cp a, 2
    jr nc, .levelTwo
    cp a, 1
    jr nc, .levelOne
    ret
.levelThree:
    call Enemy2Update
.levelTwo:
    call BirdUpdate
.levelOne:
	call EnemyUpdate
.end:
    ret