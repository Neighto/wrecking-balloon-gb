INCLUDE "hardware.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "macro.inc"

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

SECTION "player vars", WRAM0
  player_x:: DB
  player_y:: DB
  player_cactus_x:: DB 
  player_cactus_y:: DB
  player_alive:: DB
  player_popping:: DB
  player_popping_frame:: DB
  player_falling:: DB
  player_fall_speed:: DB
  player_falling_timer:: DB
  player_pop_timer:: DB
  player_delay_falling_timer:: DB
  player_respawn_timer:: DB
  player_speed:: DB
  player_lives:: DB
  player_invincible:: DB ; Operates like a timer, when set, invincible immediately
  player_cant_move:: DB

SECTION "player", ROM0

UpdateBalloonPosition:
  ld hl, wPlayerBalloonOAM
  ; Update Y
  ld a, [player_y]
  ld [hli], a
  ; Update X
  ld a, [player_x]
  ld [hl], a

  ld hl, wPlayerBalloonOAM+4
  ; Update Y
  ld a, [player_y]
  ld [hli], a
  ; Update X
  ld a, [player_x]
  add 8
  ld [hl], a
  ret

UpdateCactusPosition:
  ld hl, wPlayerCactusOAM
  ; Update Y
  ld a, [player_cactus_y]
  ld [hli], a
  ; Update X
  ld a, [player_cactus_x]
  ld [hl], a

  ld hl, wPlayerCactusOAM+4
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
  ld [hl], 2

  ; Cactus left
  ld hl, wPlayerCactusOAM
  ld a, [player_cactus_y]
  ld [hli], a
  ld a, [player_cactus_x]
  ld [hli], a
  ld [hl], $82
  inc l
  ld [hl], OAMF_PAL0
  ; Cactus right
  inc l
  ld a, [player_cactus_y]
  ld [hli], a
  ld a, [player_cactus_x]
  add 8
  ld [hli], a
  ld [hl], $82
  inc l
  ld [hl], OAMF_PAL0 | OAMF_XFLIP

  ; Balloon left
  ld hl, wPlayerBalloonOAM
  ld a, [player_y]
  ld [hli], a
  ld a, [player_x]
  ld [hli], a
  ld [hl], $80
  inc l
  ld [hl], OAMF_PAL1
  ; Balloon right
  inc l
  ld a, [player_y]
  ld [hli], a
  ld a, [player_x]
  add 8
  ld [hli], a
  ld [hl], $80
  inc l
  ld [hl], OAMF_PAL1 | OAMF_XFLIP
  ret

ClearPlayerCactus:
  xor a ; ld a, 0
  ld hl, wPlayerCactusOAM
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hl], a
  ret

ClearPlayerBalloon:
  xor a ; ld a, 0
  ld hl, wPlayerBalloonOAM
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hl], a
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
  INCREMENT_POS player_x, [player_speed]
  INCREMENT_POS player_cactus_x, [player_speed]
  call MoveCactusDriftLeft
  ret

MoveLeft:
  DECREMENT_POS player_x, [player_speed]
  DECREMENT_POS player_cactus_x, [player_speed]
  call MoveCactusDriftRight
  ret

MoveDown:
  INCREMENT_POS player_y, [player_speed]
  INCREMENT_POS player_cactus_y, [player_speed]
  call MoveCactusDriftUp
  ret

MoveUp:
  DECREMENT_POS player_y, [player_speed]
  DECREMENT_POS player_cactus_y, [player_speed]
  ret

SpeedUp:
  ld hl, player_speed
  ld [hl], 1
  ret

ResetSpeedUp:
  ld hl, player_speed
  ld [hl], 2
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
  ld d, OAMF_XFLIP
.end:
  call PlayerControls
  ret

MovePlayerAutoFlyUp::
  DECREMENT_POS player_y, 1
  DECREMENT_POS player_cactus_y, 1
  call UpdatePlayerPosition
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
  INCREMENT_POS player_cactus_y, [player_fall_speed]
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
  ld hl, wPlayerBalloonOAM+2
  ld [hl], $88
  inc l
  ld [hl], %00000000
  ; Popped right - frame 0
  ld hl, wPlayerBalloonOAM+6
  ld [hl], $88
  inc l
  ld [hl], OAMF_XFLIP
  ld hl, player_popping_frame
  ld [hl], 1
  ret
.frame1:
  ; Popped left - frame 1
  ld hl, wPlayerBalloonOAM+2
  ld [hl], $8A
  inc l
  ld [hl], %00000000
  ; Popped right - frame 1
  ld hl, wPlayerBalloonOAM+6
  ld [hl], $8A
  inc l
  ld [hl], OAMF_XFLIP
  ld hl, player_popping_frame
  ld [hl], 2
  ret
.clear:
  ; Remove sprites
  call ClearPlayerBalloon
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
  ld hl, player_falling
  ld [hl], 0
  call ClearPlayerCactus
.end
  ret

NoMoreLives:
  call StopFallingSound
  ; Back to menu
  call Start ; change this so it leads to intermediate screen to say GAME OVER, maybe play small jingle + start to continue
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
  ; Animation trigger
  ld a, 1
  ld hl, player_popping
  ld [hl], a
  ld hl, player_falling
  ld [hl], a
  ; Screaming cactus
  ld hl, wPlayerCactusOAM+2
  ld [hl], $90
  ld hl, wPlayerCactusOAM+6
  ld [hl], $90
  ; Sound
  call PopSound ; Conflicts with explosion sound
  call FallingSound
  ret

InvincibleBlink::
  ; Check if invincible (like when respawning)
  ld a, [player_invincible] ; This acts more as a countdown timer
  cp a, 0
  jp z, .end
  dec a
  ld [player_invincible], a
  ; At the end make sure we stop on default tileset
  cp a, 3
  jp c, .defaultPalette
  ; Are we blinking normal or fast (faster at the end)
  cp a, INVINCIBLE_BLINK_FASTER_TIME
  ld a, [global_timer]
  jp c, .blinkFast
.blinkNormal:
	and INVINCIBLE_BLINK_NORMAL_SPEED
  jp z, .defaultPalette
  jp .blinkEnd
  ret
.blinkFast:
	and INVINCIBLE_BLINK_FAST_SPEED
  jp z, .defaultPalette
.blinkEnd:
  ld hl, wPlayerBalloonOAM+2
  ld [hl], $A2
  ld hl, wPlayerBalloonOAM+6
  ld [hl], $A2
  ld hl, wPlayerCactusOAM+2
  ld [hl], $A4
  ld hl, wPlayerCactusOAM+6
  ld [hl], $A4
  ret
.defaultPalette:
  ld hl, wPlayerBalloonOAM+2
  ld [hl], $80
  ld hl, wPlayerBalloonOAM+6
  ld [hl], $80
  ld hl, wPlayerCactusOAM+2
  ld [hl], $82
  ld hl, wPlayerCactusOAM+6
  ld [hl], $82
.end:
  ret