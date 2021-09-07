INCLUDE "constants.inc"
INCLUDE "hardware.inc"

HAND_WAVE_START_X EQU 120
HAND_WAVE_START_Y EQU 112

SECTION "classic", ROMX

HandleCutsceneLoop::
    ; Are we done moving into the sky
    ld a, [player_y]
    add 16
    ld b, a
    call OffScreenY
    call nz, PregameLoop
	; Can we move into the sky
	ld a, [starting_classic]
	cp a, 0
    ; here we stop player from using controls and shoot player and cactus up
    jr z, .canWeScroll
    ; Stop player control
    ld hl, player_cant_move
    ld [hl], 1
    ; Move player to center and up
    call MovePlayerAutoMiddle
    call MovePlayerAutoFlyUp
    ret
.canWeScroll:
	; Can we start scrolling into the sky
    ld a, [player_y]
    cp a, 30
	jr nc, .end
	ld a, 1
	ld [starting_classic], a
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
    ld hl, wEnemy2Balloon
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
	ld [wEnemy2Balloon], a

	; Here we animate
    ld a, [hand_waving_frame]
    cp a, 0
    jr nz, .frame1
.frame0:
    ld a, [global_timer]
    and 15
    jp nz, .end
    ld hl, wEnemy2Balloon+2
    ld [hl], $A2
    ld hl, hand_waving_frame
    ld [hl], 1
    ret
.frame1:
    ld a, [global_timer]
    and 15
    jp nz, .end
    ld hl, wEnemy2Balloon+2
    ld [hl], $A0
    ld hl, hand_waving_frame
    ld [hl], 0
.end:
	ret

IncrementScrollOffset::
	ld a, [global_timer]
	and %0000111
	jr nz, .end
	ld a, [cloud_scroll_offset]
	inc a
	ld [cloud_scroll_offset], a
.end:
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