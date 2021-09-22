INCLUDE "hardware.inc"
INCLUDE "balloonCactusConstants.inc"

SECTION "player", ROMX

PLAYER_START_X EQU 80
PLAYER_START_Y EQU 100
PLAYER_BALLOON_START_Y EQU (PLAYER_START_Y-16)
PLAYER_MAX_DRIFT_X EQU 2
PLAYER_MAX_DRIFT_Y EQU 2

PLAYER_SPRITE_MOVE_WAIT_TIME EQU %00000001
PLAYER_RESPAWN_TIME EQU 150

INVINCIBLE_RESPAWN_TIME EQU 170
INVINCIBLE_BLINK_FASTER_TIME EQU 50
INVINCIBLE_BLINK_NORMAL_SPEED EQU %00001000
INVINCIBLE_BLINK_FAST_SPEED EQU %00000100

UpdateBalloonPosition:
  ld hl, wPlayerBalloon
  ; Update Y
  ld a, [player_y]
  ld [hli], a
  ; Update X
  ld a, [player_x]
  ld [hl], a

  ld hl, wPlayerBalloon+4
  ; Update Y
  ld a, [player_y]
  ld [hli], a
  ; Update X
  ld a, [player_x]
  add 8
  ld [hl], a
  ret

UpdateCactusPosition:
  ld hl, wPlayerCactus
  ; Update Y
  ld a, [player_cactus_y]
  ld [hli], a
  ; Update X
  ld a, [player_cactus_x]
  ld [hl], a

  ld hl, wPlayerCactus+4
  ; Update Y
  ld a, [player_cactus_y]
  ld [hli], a
  ; Update X
  ld a, [player_cactus_x]
  add 8
  ld [hl], a
  ret

UpdatePlayerPosition:
  call UpdateBalloonPosition
  call UpdateCactusPosition
  ret

InitializePlayer::
  ; Set variables
  xor a ; ld a, 0
  ld [player_popping], a
  ld [player_popping_frame], a
  ld [player_pop_timer], a
  ld [player_falling], a
  ld [player_delay_falling_timer], a
  ld [player_falling_timer], a
  ld [player_respawn_timer], a
  ld [player_invincible], a
  ld [player_cant_move], a
  ld a, 1
  ld [player_alive], a
  ld [player_fall_speed], a

  ld hl, player_x
  ld [hl], PLAYER_START_X
  ld hl, player_y
  ld [hl], PLAYER_BALLOON_START_Y
  ld hl, player_cactus_x
  ld [hl], PLAYER_START_X
  ld hl, player_cactus_y
  ld [hl], PLAYER_START_Y
  ld hl, player_speed
  ld [hl], 1
  ; Balloon left
  ld hl, wPlayerBalloon
  ld [hl], PLAYER_BALLOON_START_Y
  inc l
  ld [hl], PLAYER_START_X
  inc l
  ld [hl], $80
  inc l
  ld [hl], %00010000
  ; Balloon right
  ld hl, wPlayerBalloon+4
  ld [hl], PLAYER_BALLOON_START_Y
  inc l
  ld [hl], PLAYER_START_X+8
  inc l
  ld [hl], $80
  inc l
  ld [hl], %00110000
  ; Cactus left
  ld hl, wPlayerCactus
  ld [hl], PLAYER_START_Y
  inc l
  ld [hl], PLAYER_START_X
  inc l
  ld [hl], $82
  inc l
  ld [hl], %00010000
  ; Cactus right
  ld hl, wPlayerCactus+4
  ld [hl], PLAYER_START_Y
  inc l
  ld [hl], PLAYER_START_X+8
  inc l
  ld [hl], $82
  inc l
  ld [hl], %00110000
  ret

SpawnPlayer:
  ; Probably temporary
  xor a ; ld a, 0
  ld [player_respawn_timer], a
  call InitializePlayer
  
  ld a, INVINCIBLE_RESPAWN_TIME
  ld [player_invincible], a
  call StopFallingSound
  ret

MoveBalloonUp:
  ld hl, player_y
  ld a, [player_speed]
  call DecrementPosition
  ret

MoveBalloonRight:
  ld hl, player_x
  ld a, [player_speed]
  call IncrementPosition
  ret 

MoveBalloonLeft:
  ld hl, player_x
  ld a, [player_speed]
  call DecrementPosition
  ret

MoveBalloonDown:
  ld hl, player_y
  ld a, [player_speed]
  call IncrementPosition
  ret

MoveCactusUp:
  ld hl, player_cactus_y
  ld a, [player_speed]
  call DecrementPosition
  ret

MoveCactusRight:
  ld hl, player_cactus_x
  ld a, [player_speed]
  call IncrementPosition
  ret

MoveCactusLeft:
  ld hl, player_cactus_x
  ld a, [player_speed]
  call DecrementPosition
  ret

MoveCactusDown:
  ld hl, player_cactus_y
  ld a, [player_speed]
  call IncrementPosition
  ret

MoveCactusDriftLeft:
  ; Move left until limit is reached
  ld a, [global_timer]
  and	%00000001
  jr nz, .end
  ld hl, player_x
  ld a, PLAYER_MAX_DRIFT_X
  cpl
  add [hl]
  ld hl, player_cactus_x
  cp a, [hl]
  jr nc, .end
  dec [hl]
.end:
  ret

; TODO: Add basic deceleration so if you stop it keeps swinging
MoveCactusDriftRight:
  ; Move right until limit is reached
  ld a, [global_timer]
  and	%00000001
  jr nz, .end
  ld hl, player_x
  ld a, PLAYER_MAX_DRIFT_X
  add [hl]
  ld hl, player_cactus_x
  cp a, [hl]
  jr c, .end
  inc [hl]
.end:
  ret

MoveCactusDriftCenterX:
  ; Move back to center
  ld a, [global_timer]
  and	%00000001
  jr nz, .end
  ld a, [player_x]
  ld hl, player_cactus_x
  cp a, [hl]
  jr z, .end
  jr c, .moveLeft
.moveRight:
  inc [hl]
  ret
.moveLeft:
  dec [hl]
.end:
  ret

MoveCactusDriftUp:
  ; Move up until limit is reached
  ld a, [global_timer]
  and	%00000001
  jr nz, .end
  ld hl, player_y
  ld a, PLAYER_MAX_DRIFT_Y-16
  cpl
  add [hl]
  ld hl, player_cactus_y
  cp a, [hl]
  jr nc, .end
  dec [hl]
.end:
  ret

MoveCactusDriftCenterY:
  ; Move back to center
  ld a, [global_timer]
  and	%00000001
  jr nz, .end
  ; In what direction is cactus_y off from player_y
  ld hl, player_y
  ld a, 16
  add [hl]
  ld hl, player_cactus_y
  cp a, [hl]
  jr z, .end
  jr nc, .moveDown
.moveUp:
  dec [hl]
  ret
.moveDown:
  inc [hl]
.end:
  ret

MoveRight:
  call MoveBalloonRight
  call MoveCactusRight
  call MoveCactusDriftLeft
  ret

MoveLeft:
  call MoveBalloonLeft
  call MoveCactusLeft
  call MoveCactusDriftRight
  ret

MoveDown:
  call MoveBalloonDown
  call MoveCactusDown
  call MoveCactusDriftUp
  ret

MoveUp:
  call MoveBalloonUp
  call MoveCactusUp
  ret

SpeedUp:
  ld hl, player_speed
  ld [hl], 2
  ret

ResetSpeedUp:
  ld hl, player_speed
  ld [hl], 1
  ret

PlayerControls:
  ; argument d = input directions down
  ; arguemnt e = input directions pressed
  push bc
  push af
  ; Right
	ld a, d
	call JOY_RIGHT
	jr z, .endRight
  ; Right - are we offscreen?
  ld a, [player_x]
  add 8
  ld b, a
  call OffScreenX
  and 1
  jr nz, .endRight
	call MoveRight
.endRight:
  ; Left
  ld a, d
	call JOY_LEFT
	jr z, .endLeft
  ; Left - are we offscreen?
  ld a, [player_x]
  sub 8
  ld b, a
  call OffScreenX
  and 1
  jr nz, .endLeft
	call MoveLeft
.endLeft:
  ; Up
  ld a, d
	call JOY_UP
	jr z, .endUp
  ; Up - are we offscreen?
  ld a, [player_y]
  sub 16 ; unusual I have to do this??
  ld b, a
  call OffScreenY
  and 1
  jr nz, .endUp
	call MoveUp
.endUp:
  ; Down
  ld a, d
	call JOY_DOWN
	jr z, .endDown
  ; Down - are we offscreen?
  ld a, [player_y]
  add 16
  ld b, a
  call OffScreenY
  and 1
  jr nz, .endDown
	call MoveDown
.endDown:
  ; Drift to center if Left / Right not held
  ; TODO: clean up quite inefficient
  ld a, d
	call JOY_RIGHT
	jr nz, .endDriftToCenterX
  ld a, d
	call JOY_LEFT
  jr nz, .endDriftToCenterX
  call MoveCactusDriftCenterX
.endDriftToCenterX:
  ; Drift to center if Up / Down not held
  ld a, d
	call JOY_UP
	jr nz, .endDriftToCenterY
  ld a, d
	call JOY_DOWN
  jr nz, .endDriftToCenterY
  call MoveCactusDriftCenterY
.endDriftToCenterY:
  ; START
  ld a, e
  call JOY_START
  jr z, .endStart
  ld a, 1
  ld [paused_game], a ; pause
.endStart:
  ; A
  ld a, d
	call JOY_A
	jr z, .endA
  ; Do something
.endA:
  ; B
  ld a, d
	call JOY_B
	jr z, .endB
  call SpeedUp
  jr .end
.endB:
  call ResetSpeedUp
.end:
  call UpdatePlayerPosition
  pop bc
  pop af
  ret

MovePlayer:
  call ReadInput
  ld a, [joypad_down]
  ld d, a
  ld a, [joypad_pressed]
  ld e, a
  call PlayerControls
  ret

MovePlayerAutoMiddle::
  ld d, 0
  ld e, 0
  ld a, [player_x]
  cp a, SCRN_X/2
  jr z, .end
  jr nc, .moveLeft
.moveRight:
  ld d, %00010000 ; TODO make these constants
  jr .end
.moveLeft:
  ld d, %00100000
.end:
  call PlayerControls
  ret

MovePlayerAutoFlyUp::
  ld a, [player_y]
  add 16
  ld b, a
  call OffScreenY
  and 1
  jr nz, .end
  call MoveUp
  call UpdatePlayerPosition
.end:
  ret

FallCactusDown:
  ld hl, player_fall_speed
  ld a, [player_delay_falling_timer]
  inc a
  ld [player_delay_falling_timer], a
  cp a, CACTUS_DELAY_FALLING_TIME
  jr c, .skipAcceleration
  xor a ; ld a, 0
  ld [player_delay_falling_timer], a
  ld a, [hl]
  add a, a
  ld [hl], a
.skipAcceleration
  ld a, [hl]
  ld hl, player_cactus_y
  call IncrementPosition
  ret

PopBalloonAnimation:
  ; Check what frame we are on
  ld a, [player_popping_frame]
  cp a, 0
  jr z, .frame0

  ld a, [player_pop_timer]
  inc	a
  ld [player_pop_timer], a
  and POPPING_BALLOON_ANIMATION_SPEED
  jp nz, .end
  ; Can do next frame
  ; Check what frame we are on
  ld a, [player_popping_frame]
  cp a, 1
  jp z, .frame1
  cp a, 2
  jp z, .clear
  ret

.frame0:
  ; Popped left - frame 0
  ld hl, wPlayerBalloon+2
  ld [hl], $88
  inc l
  ld [hl], %00000000
  ; Popped right - frame 0
  ld hl, wPlayerBalloon+6
  ld [hl], $88
  inc l
  ld [hl], %00100000
  ld hl, player_popping_frame
  ld [hl], 1
  ret
.frame1:
  ; Popped left - frame 1
  ld hl, wPlayerBalloon+2
  ld [hl], $8A
  inc l
  ld [hl], %00000000
  ; Popped right - frame 1
  ld hl, wPlayerBalloon+6
  ld [hl], $8A
  inc l
  ld [hl], %00100000
  ld hl, player_popping_frame
  ld [hl], 2
  ret
.clear:
  ; Remove sprites
  xor a ; ld a, 0
  ld hl, wPlayerBalloon
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hl], a
  ; Reset variables
  ld hl, player_popping
  ld [hl], a
  ld hl, player_pop_timer
  ld [hl], a
  ld hl, player_popping_frame
  ld [hl], a
.end:
  ret

CactusFalling:
  ld a, [player_falling_timer]
  inc a
  ld [player_falling_timer], a
  and CACTUS_FALLING_TIME
  jr nz, .end
  ; Can we move cactus down
  ld a, 160
  ld hl, player_cactus_y
  cp a, [hl]
  jr c, .offScreen
  call FallCactusDown
  call UpdateCactusPosition
  ret
.offScreen:
  ; Reset variables
  ld hl, enemy_falling
  ld [hl], 0
  ; Here I "could" clear the sprite info, but no point
.end
  ret

NoMoreLives:
  call StopFallingSound
  ; Back to menu
  call Start
  ret

PlayerUpdate::
  ; Check if alive
  ld a, [player_alive]
  and 1
  jr z, .popped
  ; Check if invincible (like when respawning)
  call InvincibleBlink
  ; Get movement
  ld a, [player_cant_move]
  cp a, 0
  jp nz, .end
  ld a, [global_timer]
	and	PLAYER_SPRITE_MOVE_WAIT_TIME
	call z, MovePlayer
  ret
.popped:
  ; Can we respawn
  ld a, [player_respawn_timer]
  inc a
  ld [player_respawn_timer], a
  cp a, PLAYER_RESPAWN_TIME
  jr nz, .respawnSkip
  ; And do we have enough lives to respawn
  ld a, [player_lives]
  or a, 0
  jr nz, .respawn
  call NoMoreLives
.respawn:
  call SpawnPlayer
.respawnSkip:
  ; Check if we need to play popping animation
  ld a, [player_popping]
  and 1
  jr z, .notPopping
  call PopBalloonAnimation
.notPopping:
  ; Check if we need to drop the cactus
  ld a, [player_falling]
  and 1
  jr z, .end
  call CactusFalling
.end
  ret

DeathOfPlayer::
  ; Death
  xor a ; ld a, 0
  ld hl, player_alive
  ld [hl], a
  ; Remove life
  ld hl, player_lives
  dec [hl]
  call RefreshLives
  ; Animation trigger
  ld a, 1
  ld hl, player_popping
  ld [hl], a
  ld hl, player_falling
  ld [hl], a
  ; Screaming cactus
  ld hl, wPlayerCactus+2
  ld [hl], $90
  ld hl, wPlayerCactus+6
  ld [hl], $90
  ; Sound
  call PopSound
  call FallingSound
  ret

InvincibleBlink::
  ; Check if invincible (like when respawning)
  ld a, [player_invincible] ; This acts more as a countdown timer
  cp a, 0
  jr z, .end
  dec a
  ld [player_invincible], a
  ; At the end make sure we stop on default palette
  cp a, 3
  jr c, .defaultPalette
  ; Are we blinking normal or fast (faster at the end)
  cp a, INVINCIBLE_BLINK_FASTER_TIME
  ld a, [global_timer]
  jr c, .blinkFast
.blinkNormal:
	and INVINCIBLE_BLINK_NORMAL_SPEED
  jr z, .defaultPalette
  jr .blinkEnd
  ret
.blinkFast:
	and INVINCIBLE_BLINK_FAST_SPEED
  jr z, .defaultPalette
.blinkEnd:
  ld a, %11011000
	ldh [rOBP1], a
  ret
.defaultPalette:
  ld a, %11100100
	ldh [rOBP1], a
.end:
  ret