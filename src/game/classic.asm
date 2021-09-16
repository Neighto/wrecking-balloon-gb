INCLUDE "constants.inc"
INCLUDE "hardware.inc"

HAND_WAVE_START_X EQU 120
HAND_WAVE_START_Y EQU 112

COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 50

SECTION "classic", ROMX

HandleParkLoop::
    ; Are we done moving into the sky
    ld a, [player_y]
    ld b, a
    call OffScreenYEnemies
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

StartedClassic::
    push hl
    ld hl, started_classic
	ld [hl], 1
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
    ld a, [countdown_frame]
    cp a, 0
    jr z, .frame0
    cp a, 1
    jr z, .frame1
    cp a, 2
    jr z, .frame2
.frame0:
    ld a, [global_timer]
    and %00011111
    jp nz, .end
    ld hl, wEnemyBalloon+2
    ld [hl], $B8
    ld hl, wEnemyBalloon+6
    ld [hl], $BA
    ld hl, countdown_frame
    ld [hl], 1
    ret
.frame1:
    ld a, [global_timer]
    and %00011111
    jp nz, .end
    ld hl, wEnemyBalloon+2
    ld [hl], $B4
    ld hl, wEnemyBalloon+6
    ld [hl], $B6
    ld hl, countdown_frame
    ld [hl], 2
    ret
.frame2:
    ld a, [global_timer]
    and %00011111
    jp nz, .end
    ld hl, wEnemyBalloon+2
    ld [hl], $B0
    ld hl, wEnemyBalloon+6
    ld [hl], $B2
    ld hl, countdown_frame
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