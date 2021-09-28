INCLUDE "constants.inc"
INCLUDE "hardware.inc"

HAND_WAVE_START_X EQU 120
HAND_WAVE_START_Y EQU 112

COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 50
COUNTDOWN_SPEED EQU %00011111
COUNTDOWN_BALLOON_POP_SPEED EQU %00000011

SECTION "classic", ROMX

InitializeClassicVars::
    xor a ; ld a, 0
	ld [fade_frame], a
    ret

ParkFadeOut:
    ld a, [classic_mode_stage]
	cp a, STAGE_CLASSIC_STARTING
	jr z, .fadeOut
    ; Can we start fading out (are we offscreen)
    ld a, [player_y]
    add 4 ; Buffer for extra time before screen switch
    ld b, a
    call OffScreenYEnemies
    jr nz, .startFadeOut
    ret
.startFadeOut:
    ld hl, classic_mode_stage
    ld [hl], STAGE_CLASSIC_STARTING
	ret
.fadeOut:
	call HasFadedOut
	cp a, 0
	jr nz, .hasFadedOut
	call FadeOutPalettes
	ret
.hasFadedOut:
	call PregameLoop
    ret

UpdatePark::
    call ParkFadeOut
    call HandWaveAnimation
    call IncrementScrollOffset
.moveUp:
    ld a, [player_y]
    add 16
    cp a, 80
    jr c, .flyUpFast
.flyUpNormal:
    ld a, [global_timer]
    and %00000011
    jr nz, .end
.flyUpFast:
    call MovePlayerAutoFlyUp
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

ParkEnteredClassic::
    push hl
    ld hl, classic_mode_stage
	ld [hl], STAGE_CLASSIC_PARK_ENTERED
    pop hl
    ret

StartedClassic::
    push hl
    ld hl, classic_mode_stage
	ld [hl], STAGE_CLASSIC_STARTED
    pop hl
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

SpawnCountdown::
    ld hl, wEnemyBalloon
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X
    ld [hli], a
    ld hl, wEnemyBalloon+4
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X+8
    ld [hli], a
	ret

CountdownAnimation::
    ; See if we go to faster-frames balloon pop
    ld a, [countdown_frame]
    cp a, 4
    jr nc, .balloonPop
.countdown:
    ld a, [global_timer]
    and COUNTDOWN_SPEED
    jp nz, .end
    jr .frames
.balloonPop:
    ld a, [global_timer]
    and COUNTDOWN_BALLOON_POP_SPEED
    jp nz, .end
.frames:
    ld a, [countdown_frame]
    cp a, 0
    jr z, .frame0
    cp a, 1
    jr z, .frame1
    cp a, 2
    jr z, .frame2
    cp a, 3
    jr z, .frame3
    cp a, 4
    jr z, .frame4
    cp a, 5
    jr z, .frame5
    cp a, 6
    jr z, .remove
    ret
.frame0:
    call PercussionSound
    ld hl, wEnemyBalloon+2
    ld [hl], $B8
    ld hl, wEnemyBalloon+6
    ld [hl], $BA
    ld hl, countdown_frame
    ld [hl], 1
    ret
.frame1:
    call PercussionSound
    ld hl, wEnemyBalloon+2
    ld [hl], $B4
    ld hl, wEnemyBalloon+6
    ld [hl], $B6
    ld hl, countdown_frame
    ld [hl], 2
    ret
.frame2:
    call PercussionSound
    ld hl, wEnemyBalloon+2
    ld [hl], $B0
    ld hl, wEnemyBalloon+6
    ld [hl], $B2
    ld hl, countdown_frame
    ld [hl], 3
    ret
.frame3:
    ld hl, wEnemyBalloon+2
    ld [hl], $BC
    ld hl, wEnemyBalloon+6
    ld [hl], $BC
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, countdown_frame
    ld [hl], 4
    ret
.frame4:
    call PopSound
    ld hl, wEnemyBalloon+2
    ld [hl], $88
    ld hl, wEnemyBalloon+6
    ld [hl], $88
    ld hl, countdown_frame
    ld [hl], 5
    ret
.frame5:
    ld hl, wEnemyBalloon+2
    ld [hl], $8A
    ld hl, wEnemyBalloon+6
    ld [hl], $8A
    ld hl, countdown_frame
    ld [hl], 6
    ret
.remove:
    ; todo make erase func for oam
    ld hl, wEnemyBalloon
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld hl, countdown_frame
    ld [hl], 7
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

ClassicGameManager:
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

UpdateClassic::
    ld a, [countdown_frame]
    cp a, 7 ; TODO dont hardcode in case we change it in CountdownAnimation
    jr nc, .countdownComplete
	call CountdownAnimation
    jr .countdownSkip
.countdownComplete:
	call TryToUnpause
	ld a, [paused_game]
	cp a, 1
	jr z, .end
	call CollisionUpdate
    call PlayerUpdate
.countdownSkip:
    call HorizontalScroll
	call ClassicGameManager
	call RefreshScore ; Might want to move somewhere to call less frequently
.end:
    ret