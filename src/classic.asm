INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "tileConstants.inc"
INCLUDE "macro.inc"
INCLUDE "balloonConstants.inc"

HAND_WAVE_START_X EQU 120
HAND_WAVE_START_Y EQU 112

COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 50
COUNTDOWN_SPEED EQU %00011111
COUNTDOWN_BALLOON_POP_SPEED EQU %00000111

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
    ld a, [wPlayerY]
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
	call PreGameLoop
    ret

UpdatePark::
    call ParkFadeOut
    call HandWaveAnimation
    call IncrementScrollOffset
.moveUp:
    ld a, [wPlayerY]
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
    call ClearSound
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
	ld b, 1
	call RequestOAMSpace
    cp a, 0
    jr z, .end
    ld a, b
	ld [wOAMGeneral1], a
	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
    ld a, HAND_WAVE_START_Y
    ld [hli], a
    ld a, HAND_WAVE_START_X
    ld [hli], a
    ld [hl], $3A
    inc l
    ld [hl], OAMF_PAL1
.end:
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
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], $3C
    ld hl, hand_waving_frame
    ld [hl], 1
    ret
.frame1:
    ld a, [global_timer]
    and 15
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], $3A
    ld hl, hand_waving_frame
    ld [hl], 0
.end:
	ret

SpawnCountdown::
	ld b, 2
	call RequestOAMSpace
    cp a, 0
    jr z, .end
    ld a, b
	ld [wOAMGeneral1], a
	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X
    ld [hli], a
    ld [hl], EMPTY_TILE
    inc l
    inc l
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X+8
    ld [hli], a
    ld [hl], EMPTY_TILE
.end:
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
    jp z, .frame0
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .frame2
    cp a, 3
    jp z, .frame3
    cp a, 4
    jp z, .frame4
    cp a, 5
    jp z, .frame5
    cp a, 6
    jp z, .remove
    ret
.frame0:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], $32
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], $34
    ld hl, countdown_frame
    ld [hl], 1
    ret
.frame1:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], $2E
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], $30
    ld hl, countdown_frame
    ld [hl], 2
    ret
.frame2:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], $2A
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], $2C
    ld hl, countdown_frame
    ld [hl], 3
    ret
.frame3:
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], $36
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], $36
    inc l 
    ld [hl], OAMF_XFLIP
    ld hl, countdown_frame
    ld [hl], 4
    ret
.frame4:
    call PopSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_0_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_0_TILE
    ld hl, countdown_frame
    ld [hl], 5
    ret
.frame5:
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_1_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_1_TILE
    ld hl, countdown_frame
    ld [hl], 6
    ret
.remove:
    ; todo make erase func for oam
    SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
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

UpdateSprites:
    call PlayerUpdate
    call PointBalloonUpdate
    call BalloonCactusUpdate
    call BombUpdate
    call BirdUpdate
    call PorcupineUpdate
    ret

UpdateClassicCountdown::
    ld a, [countdown_frame]
    cp a, 7 ; TODO dont hardcode in case we change it in CountdownAnimation
    jp nc, GameLoop
    call CountdownAnimation
    call RefreshWindow
    call HorizontalScroll
    call MoveToNextTilemap
    call ReplaceTilemapHorizontal
    ret

UpdateClassic::
	call TryToUnpause
	ld a, [paused_game]
	cp a, 1
	jr z, .end
    call MoveToNextTilemap
    call ReplaceTilemapHorizontal
    call UpdateSprites
    call LevelDataManager
    call RefreshWindow
    call HorizontalScroll
    call _hUGE_dosound
.end:
    ret