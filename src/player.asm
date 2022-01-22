INCLUDE "hardware.inc"
INCLUDE "balloonConstants.inc"
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

PLAYER_BALLOON_TILE EQU $00
PLAYER_CACTUS_TILE EQU $02
PLAYER_CACTUS_SCREAMING_TILE EQU $04
PLAYER_BALLOON_INVINCIBLE_TILE EQU $06
PLAYER_CACTUS_INVINCIBLE_TILE EQU $08

SECTION "player vars", WRAM0
  wPlayerY:: DB
  wPlayerX:: DB
  wPlayerY2:: DB
  wPlayerX2:: DB
  wPlayerAlive:: DB
  wPlayerPopping:: DB
  wPlayerPoppingFrame:: DB
  wPlayerPoppingTimer:: DB
  wPlayerFalling:: DB
  wPlayerFallSpeed:: DB
  wPlayerFallingTimer:: DB
  wPlayerDelayFallingTimer:: DB
  wPlayerRespawnTimer:: DB
  wPlayerSpeed:: DB
  wPlayerLives:: DB
  wPlayerInvincible:: DB ; Operates like a timer, when set, invincible immediately

SECTION "player", ROM0

UpdateBalloonPosition:
  ld hl, wPlayerBalloonOAM
  ; Update Y
  ld a, [wPlayerY]
  ld [hli], a
  ; Update X
  ld a, [wPlayerX]
  ld [hl], a

  ld hl, wPlayerBalloonOAM+4
  ; Update Y
  ld a, [wPlayerY]
  ld [hli], a
  ; Update X
  ld a, [wPlayerX]
  add 8
  ld [hl], a
  ret

UpdateCactusPosition:
  ld hl, wPlayerCactusOAM
  ; Update Y
  ld a, [wPlayerY2]
  ld [hli], a
  ; Update X
  ld a, [wPlayerX2]
  ld [hl], a

  ld hl, wPlayerCactusOAM+4
  ; Update Y
  ld a, [wPlayerY2]
  ld [hli], a
  ; Update X
  ld a, [wPlayerX2]
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
  ld [wPlayerPopping], a
  ld [wPlayerPoppingFrame], a
  ld [wPlayerPoppingTimer], a
  ld [wPlayerFalling], a
  ld [wPlayerDelayFallingTimer], a
  ld [wPlayerFallingTimer], a
  ld [wPlayerRespawnTimer], a
  ld [wPlayerInvincible], a
  ld a, 1
  ld [wPlayerAlive], a
  ld [wPlayerFallSpeed], a

  ld hl, wPlayerX
  ld [hl], PLAYER_START_X
  ld hl, wPlayerY
  ld [hl], PLAYER_BALLOON_START_Y
  ld hl, wPlayerX2
  ld [hl], PLAYER_START_X
  ld hl, wPlayerY2
  ld [hl], PLAYER_START_Y
  ld hl, wPlayerSpeed
  ld [hl], 2

  ; Cactus left
  ld hl, wPlayerCactusOAM
  ld a, [wPlayerY2]
  ld [hli], a
  ld a, [wPlayerX2]
  ld [hli], a
  ld [hl], PLAYER_CACTUS_TILE
  inc l
  ld [hl], OAMF_PAL0
  ; Cactus right
  inc l
  ld a, [wPlayerY2]
  ld [hli], a
  ld a, [wPlayerX2]
  add 8
  ld [hli], a
  ld [hl], PLAYER_CACTUS_TILE
  inc l
  ld [hl], OAMF_PAL0 | OAMF_XFLIP

  ; Balloon left
  ld hl, wPlayerBalloonOAM
  ld a, [wPlayerY]
  ld [hli], a
  ld a, [wPlayerX]
  ld [hli], a
  ld [hl], PLAYER_BALLOON_TILE
  inc l
  ld [hl], OAMF_PAL1
  ; Balloon right
  inc l
  ld a, [wPlayerY]
  ld [hli], a
  ld a, [wPlayerX]
  add 8
  ld [hli], a
  ld [hl], PLAYER_BALLOON_TILE
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
  ld [wPlayerRespawnTimer], a
  call InitializePlayer
  
  ld a, INVINCIBLE_RESPAWN_TIME
  ld [wPlayerInvincible], a
  call StopSweepSound
  ret

MoveCactusDriftLeft:
  ; Move left until limit is reached
  ld a, [wGlobalTimer]
  and	%00000001
  jr nz, .end
  ld hl, wPlayerX
  ld a, PLAYER_MAX_DRIFT_X
  cpl
  add [hl]
  ld hl, wPlayerX2
  cp a, [hl]
  jr nc, .end
  dec [hl]
.end:
  ret

; TODO: Add basic deceleration so if you stop it keeps swinging
MoveCactusDriftRight:
  ; Move right until limit is reached
  ld a, [wGlobalTimer]
  and	%00000001
  jr nz, .end
  ld hl, wPlayerX
  ld a, PLAYER_MAX_DRIFT_X
  add [hl]
  ld hl, wPlayerX2
  cp a, [hl]
  jr c, .end
  inc [hl]
.end:
  ret

MoveCactusDriftCenterX:
  ; Move back to center
  ld a, [wGlobalTimer]
  and	%00000001
  jr nz, .end
  ld a, [wPlayerX]
  ld hl, wPlayerX2
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
  ld a, [wGlobalTimer]
  and	%00000001
  jr nz, .end
  ld hl, wPlayerY
  ld a, PLAYER_MAX_DRIFT_Y-16
  cpl
  add [hl]
  ld hl, wPlayerY2
  cp a, [hl]
  jr nc, .end
  dec [hl]
.end:
  ret

MoveCactusDriftCenterY:
  ; Move back to center
  ld a, [wGlobalTimer]
  and	%00000001
  jr nz, .end
  ; In what direction is cactus_y off from wPlayerY
  ld hl, wPlayerY
  ld a, 16
  add [hl]
  ld hl, wPlayerY2
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
  INCREMENT_POS wPlayerX, [wPlayerSpeed]
  INCREMENT_POS wPlayerX2, [wPlayerSpeed]
  call MoveCactusDriftLeft
  ret

MoveLeft:
  DECREMENT_POS wPlayerX, [wPlayerSpeed]
  DECREMENT_POS wPlayerX2, [wPlayerSpeed]
  call MoveCactusDriftRight
  ret

MoveDown:
  INCREMENT_POS wPlayerY, [wPlayerSpeed]
  INCREMENT_POS wPlayerY2, [wPlayerSpeed]
  call MoveCactusDriftUp
  ret

MoveUp:
  DECREMENT_POS wPlayerY, [wPlayerSpeed]
  DECREMENT_POS wPlayerY2, [wPlayerSpeed]
  ret

SpeedUp:
  ld hl, wPlayerSpeed
  ld [hl], 1
  ret

ResetSpeedUp:
  ld hl, wPlayerSpeed
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
  ld a, [wPlayerX]
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
  ld a, [wPlayerX]
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
  ld a, [wPlayerY]
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
  ld a, [wPlayerY]
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
  ld [wPaused], a ; pause
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
  ld a, [wControllerDown]
  ld d, a
  ld a, [wControllerPressed]
  ld e, a
  call PlayerControls
  ret

MovePlayerAutoMiddle::
  ld d, 0
  ld e, 0
  ld a, [wPlayerX]
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
  DECREMENT_POS wPlayerY, 1
  DECREMENT_POS wPlayerY2, 1
  call UpdatePlayerPosition
  ret

FallCactusDown:
  ld hl, wPlayerFallSpeed
  ld a, [wPlayerDelayFallingTimer]
  inc a
  ld [wPlayerDelayFallingTimer], a
  cp a, CACTUS_DELAY_FALLING_TIME
  jr c, .skipAcceleration
  xor a ; ld a, 0
  ld [wPlayerDelayFallingTimer], a
  ld a, [hl]
  add a, a
  ld [hl], a
.skipAcceleration
  INCREMENT_POS wPlayerY2, [wPlayerFallSpeed]
  ret

PopBalloonAnimation:
  ; Check what frame we are on
  ld a, [wPlayerPoppingFrame]
  cp a, 0
  jr z, .frame0

  ld a, [wPlayerPoppingTimer]
  inc	a
  ld [wPlayerPoppingTimer], a
  and POPPING_BALLOON_ANIMATION_SPEED
  jp nz, .end
  ; Can do next frame
  ; Check what frame we are on
  ld a, [wPlayerPoppingFrame]
  cp a, 1
  jp z, .frame1
  cp a, 2
  jp z, .clear
  ret

.frame0:
  ; Popped left - frame 0
  ld hl, wPlayerBalloonOAM+2
  ld [hl], POP_BALLOON_FRAME_0_TILE
  inc l
  ld [hl], %00000000
  ; Popped right - frame 0
  ld hl, wPlayerBalloonOAM+6
  ld [hl], POP_BALLOON_FRAME_0_TILE
  inc l
  ld [hl], OAMF_XFLIP
  ld hl, wPlayerPoppingFrame
  ld [hl], 1
  ret
.frame1:
  ; Popped left - frame 1
  ld hl, wPlayerBalloonOAM+2
  ld [hl], POP_BALLOON_FRAME_1_TILE
  inc l
  ld [hl], %00000000
  ; Popped right - frame 1
  ld hl, wPlayerBalloonOAM+6
  ld [hl], POP_BALLOON_FRAME_1_TILE
  inc l
  ld [hl], OAMF_XFLIP
  ld hl, wPlayerPoppingFrame
  ld [hl], 2
  ret
.clear:
  ; Remove sprites
  call ClearPlayerBalloon
  ; Reset variables
  ld hl, wPlayerPopping
  ld [hl], a
  ld hl, wPlayerPoppingTimer
  ld [hl], a
  ld hl, wPlayerPoppingFrame
  ld [hl], a
.end:
  ret

CactusFalling:
  ld a, [wPlayerFallingTimer]
  inc a
  ld [wPlayerFallingTimer], a
  and CACTUS_FALLING_TIME
  jr nz, .end
  ; Can we move cactus down
  ld a, 160
  ld hl, wPlayerY2
  cp a, [hl]
  jr c, .offScreen
  call FallCactusDown
  call UpdateCactusPosition
  ret
.offScreen:
  ; Reset variables
  ld hl, wPlayerFalling
  ld [hl], 0
  call ClearPlayerCactus
.end
  ret

NoMoreLives:
  call ClearSound
  call StopSweepSound
  ; Back to menu
  call Start ; change this so it leads to intermediate screen to say GAME OVER, maybe play small jingle + start to continue
  ret

PlayerUpdate::
  ; Check if alive
  ld a, [wPlayerAlive]
  and 1
  jr z, .popped
  ; Check if invincible (like when respawning)
  call InvincibleBlink
  ; Get movement
  ld a, [wGlobalTimer]
	and	PLAYER_SPRITE_MOVE_WAIT_TIME
	call z, MovePlayer
  ret
.popped:
  ; Can we respawn
  ld a, [wPlayerRespawnTimer]
  inc a
  ld [wPlayerRespawnTimer], a
  cp a, PLAYER_RESPAWN_TIME
  jr nz, .respawnSkip
  ; And do we have enough lives to respawn
  ld a, [wPlayerLives]
  or a, 0
  jr nz, .respawn
  call NoMoreLives
.respawn:
  call SpawnPlayer
.respawnSkip:
  ; Check if we need to play popping animation
  ld a, [wPlayerPopping]
  and 1
  jr z, .notPopping
  call PopBalloonAnimation
.notPopping:
  ; Check if we need to drop the cactus
  ld a, [wPlayerFalling]
  and 1
  jr z, .end
  call CactusFalling
.end
  ret

DeathOfPlayer::
  ; Death
  xor a ; ld a, 0
  ld hl, wPlayerAlive
  ld [hl], a
  ; Remove life
  ld hl, wPlayerLives
  dec [hl]
  ; Animation trigger
  ld a, 1
  ld hl, wPlayerPopping
  ld [hl], a
  ld hl, wPlayerFalling
  ld [hl], a
  ; Screaming cactus
  ld hl, wPlayerCactusOAM+2
  ld [hl], PLAYER_CACTUS_SCREAMING_TILE
  ld hl, wPlayerCactusOAM+6
  ld [hl], PLAYER_CACTUS_SCREAMING_TILE
  ; Sound
  call PopSound ; Conflicts with explosion sound
  call FallingSound
  ret

InvincibleBlink::
  ; Check if invincible (like when respawning)
  ld a, [wPlayerInvincible]
  cp a, 0
  jp z, .end
  dec a
  ld [wPlayerInvincible], a
  ; At the end make sure we stop on default tileset
  cp a, 3
  jp c, .defaultPalette
  ; Are we blinking normal or fast (faster at the end)
  cp a, INVINCIBLE_BLINK_FASTER_TIME
  ld a, [wGlobalTimer]
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
  ld [hl], PLAYER_BALLOON_INVINCIBLE_TILE
  ld hl, wPlayerBalloonOAM+6
  ld [hl], PLAYER_BALLOON_INVINCIBLE_TILE
  ld hl, wPlayerCactusOAM+2
  ld [hl], PLAYER_CACTUS_INVINCIBLE_TILE
  ld hl, wPlayerCactusOAM+6
  ld [hl], PLAYER_CACTUS_INVINCIBLE_TILE
  ret
.defaultPalette:
  ld hl, wPlayerBalloonOAM+2
  ld [hl], PLAYER_BALLOON_TILE
  ld hl, wPlayerBalloonOAM+6
  ld [hl], PLAYER_BALLOON_TILE
  ld hl, wPlayerCactusOAM+2
  ld [hl], PLAYER_CACTUS_TILE
  ld hl, wPlayerCactusOAM+6
  ld [hl], PLAYER_CACTUS_TILE
.end:
  ret