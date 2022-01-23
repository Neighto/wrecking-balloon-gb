INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "tileConstants.inc"
INCLUDE "macro.inc"
INCLUDE "balloonConstants.inc"

HAND_WAVE_START_X EQU 120
HAND_WAVE_START_Y EQU 112
HAND_WAVE_TILE_1 EQU $3C
HAND_WAVE_TILE_2 EQU $3E

COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 50
COUNTDOWN_SPEED EQU %00011111
COUNTDOWN_BALLOON_POP_SPEED EQU %00000111
COUNTDOWN_3_TILE_1 EQU $34
COUNTDOWN_3_TILE_2 EQU $36
COUNTDOWN_2_TILE_1 EQU $30
COUNTDOWN_2_TILE_2 EQU $32
COUNTDOWN_1_TILE_1 EQU $2C
COUNTDOWN_1_TILE_2 EQU $2E
COUNTDOWN_NEUTRAL_BALLOON_TILE EQU $38

SECTION "game vars", WRAM0
    wHandWavingFrame:: DB
    wCountdownFrame:: DB
    wClassicModeStage:: DB ; Todo remove

SECTION "game", ROMX

InitializeGame::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a
	ld [wCountdownFrame], a
	ld [wClassicModeStage], a
    ret

UpdatePark::
.fadeIn:
    call FadeInPalettes
	cp a, 0
	ret z
.hasFadedIn:

    ld a, [wClassicModeStage]
	cp a, STAGE_CLASSIC_STARTING
	jr z, .fadeOut
    ld a, [wPlayerY]
    add 4 ; Buffer for extra time before screen switch
    ld b, a
    call OffScreenYEnemies
    jr z, .skipFade
    ld hl, wClassicModeStage
    ld [hl], STAGE_CLASSIC_STARTING
    jr .skipFade
.fadeOut:
	call FadeOutPalettes
	cp a, 0
	call nz, PreGameLoop
.skipFade:
    call HandWaveAnimation
    ; call IncrementScrollOffset
.moveUp:
    ld a, [wPlayerY]
    add 16
    cp a, 80
    jr c, .flyUpFast
.flyUpNormal:
    ld a, [wGlobalTimer]
    and %00000011
    ret nz
.flyUpFast:
    call MovePlayerAutoFlyUp
	ret

TryToUnpause::
	xor a ; ld a, 0
	ld hl, wPaused
	cp a, [hl]
	jr z, .end
	; Is paused
    call ClearSound
	call ReadInput
	ld a, [wControllerPressed]
	call JOY_START
	jr z, .end
	xor a ; ld a, 0
	ld [hl], a ; pause
.end:
	ret

ParkEnteredClassic::
    push hl
    ld hl, wClassicModeStage
	ld [hl], STAGE_CLASSIC_PARK_ENTERED
    pop hl
    ret

StartedClassic::
    push hl
    ld hl, wClassicModeStage
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
    ld [hl], HAND_WAVE_TILE_1
    inc l
    ld [hl], OAMF_PAL0
.end:
	ret

; NOTE if ram becomes a problem I could probably use modulo off global timer for frames
HandWaveAnimation::
    ld a, [wHandWavingFrame]
    cp a, 0
    jr nz, .frame1
.frame0:
    ld a, [wGlobalTimer]
    and 15
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], HAND_WAVE_TILE_2
    ld hl, wHandWavingFrame
    ld [hl], 1
    ret
.frame1:
    ld a, [wGlobalTimer]
    and 15
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], HAND_WAVE_TILE_1
    ld hl, wHandWavingFrame
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
    ld a, [wCountdownFrame]
    cp a, 4
    jr nc, .balloonPop
.countdown:
    ld a, [wGlobalTimer]
    and COUNTDOWN_SPEED
    jp nz, .end
    jr .frames
.balloonPop:
    ld a, [wGlobalTimer]
    and COUNTDOWN_BALLOON_POP_SPEED
    jp nz, .end
.frames:
    ld a, [wCountdownFrame]
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
    ld [hl], COUNTDOWN_3_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_3_TILE_2
    ld hl, wCountdownFrame
    ld [hl], 1
    ret
.frame1:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_2_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_2_TILE_2
    ld hl, wCountdownFrame
    ld [hl], 2
    ret
.frame2:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_1_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_1_TILE_2
    ld hl, wCountdownFrame
    ld [hl], 3
    ret
.frame3:
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_NEUTRAL_BALLOON_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_NEUTRAL_BALLOON_TILE
    inc l 
    ld [hl], OAMF_XFLIP
    ld hl, wCountdownFrame
    ld [hl], 4
    ret
.frame4:
    call PopSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_0_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_0_TILE
    ld hl, wCountdownFrame
    ld [hl], 5
    ret
.frame5:
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_1_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_1_TILE
    ld hl, wCountdownFrame
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
    ld hl, wCountdownFrame
    ld [hl], 7
.end:
    ret

IncrementScrollOffset::
.close:
    ld a, [wGlobalTimer]
	and %0000111
	jr nz, .far
    ld a, [wParallaxClose]
	inc a
	ld [wParallaxClose], a
.far:
    ld a, [wGlobalTimer]
	and %0001111
	jr nz, .end
    ld a, [wParallaxFar]
	inc a
	ld [wParallaxFar], a
.end:
	ret

SetGameMapStartPoint::
    ld a, BACKGROUND_VSCROLL_START
    ldh [rSCY], a
    ret

UpdateSprites:
    call PlayerUpdate
    call BulletUpdate
    call PointBalloonUpdate
    call BalloonCactusUpdate
    call BombUpdate
    call BirdUpdate
    call PorcupineUpdate
    ret

UpdateGameCountdown::
    ld a, [wCountdownFrame]
    cp a, 7 ; TODO dont hardcode in case we change it in CountdownAnimation
    jp nc, GameLoop
    call CountdownAnimation
    call RefreshWindow
    ; call HorizontalScroll
    call IncrementScrollOffset
    ; call MoveToNextTilemap
    ; call ReplaceTilemapHorizontal
    ret

UpdateGame::
	call TryToUnpause
	ld a, [wPaused]
	cp a, 1
	jr z, .end
    ; call MoveToNextTilemap
    ; call ReplaceTilemapHorizontal
    call UpdateSprites
    call LevelDataManager
    call RefreshWindow
    ; call HorizontalScroll
    call IncrementScrollOffset
    call _hUGE_dosound
.end:
    ret