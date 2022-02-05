INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "tileConstants.inc"
INCLUDE "macro.inc"
INCLUDE "balloonConstants.inc"

HAND_WAVE_START_X EQU 120
HAND_WAVE_START_Y EQU 112
HAND_WAVE_TILE_1 EQU $3E
HAND_WAVE_TILE_2 EQU $40

COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 50
COUNTDOWN_SPEED EQU %00011111
COUNTDOWN_BALLOON_POP_SPEED EQU %00000111
COUNTDOWN_3_TILE_1 EQU $36
COUNTDOWN_3_TILE_2 EQU $38
COUNTDOWN_2_TILE_1 EQU $32
COUNTDOWN_2_TILE_2 EQU $34
COUNTDOWN_1_TILE_1 EQU $2E
COUNTDOWN_1_TILE_2 EQU $30
COUNTDOWN_NEUTRAL_BALLOON_TILE EQU $3A

SECTION "game vars", WRAM0
    wHandWavingFrame:: DB
    wCountdownFrame:: DB

SECTION "game", ROMX

InitializeGame::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a
	ld [wCountdownFrame], a
    ret

UpdatePark::
.fadeIn:
    call FadeInPalettes
	cp a, 0
	ret z
.hasFadedIn:
    ld a, [wTriggerFadeOut]
	cp a, 0
	jr nz, .fadeOut
    ld a, [wPlayerY]
    add 4 ; Buffer for extra time before screen switch
    ld b, a
    call OffScreenYEnemies
    jr z, .skipFade
    ld a, 1 
    ld [wTriggerFadeOut], a
    jr .skipFade
.fadeOut:
	call FadeOutPalettes
	cp a, 0
	jp nz, SetupNextLevel
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

Countdown::
    ld a, [wCountdownFrame]
    cp a, 7
    jr c, .countdown
.hasCountedDown:
    ld a, 1
    ret
.countdown:
    ld a, [wCountdownFrame]
    cp a, 4
    jr nc, .balloonPop
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
    jp .end
.frame0:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_3_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_3_TILE_2
    jp .endFrame
.frame1:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_2_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_2_TILE_2
    jp .endFrame
.frame2:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_1_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_1_TILE_2
    jr .endFrame
.frame3:
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_NEUTRAL_BALLOON_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_NEUTRAL_BALLOON_TILE
    inc l 
    ld [hl], OAMF_XFLIP
    jr .endFrame
.frame4:
    call PopSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_0_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_0_TILE
    jr .endFrame
.frame5:
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_1_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_1_TILE
    jr .endFrame
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
.endFrame:
    ld a, [wCountdownFrame]
    inc a 
    ld [wCountdownFrame], a
.end:
    xor a ; ld a, 0
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
    call RefreshWindow
    call IncrementScrollOffset
    call FadeInPalettes
	cp a, 0
	ret z
    call Countdown
    cp a, 0
    jp nz, GameLoop
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
    call IncrementScrollOffset
    call _hUGE_dosound
.end:
    ret