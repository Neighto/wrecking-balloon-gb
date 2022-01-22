INCLUDE "hardware.inc"
INCLUDE "playerConstants.inc"
INCLUDE "balloonConstants.inc"
INCLUDE "macro.inc"

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

  ; Operate like timers
  wPlayerInvincible:: DB
  wPlayerBoost:: DB ; TODO it would be a lot more logical to make these increase instead of decrease
  wPlayerAttack:: DB

SECTION "player", ROM0

InitializePlayer::
  xor a ; ld a, 0
  ld [wPlayerPopping], a
  ld [wPlayerPoppingFrame], a
  ld [wPlayerPoppingTimer], a
  ld [wPlayerFalling], a
  ld [wPlayerDelayFallingTimer], a
  ld [wPlayerFallingTimer], a
  ld [wPlayerRespawnTimer], a
  ld [wPlayerInvincible], a
  ld [wPlayerBoost], a
  ld [wPlayerAttack], a

  ld a, 1
  ld [wPlayerAlive], a
  ld [wPlayerFallSpeed], a

  ld hl, wPlayerX
  ld [hl], PLAYER_START_X
  ld hl, wPlayerY
  ld [hl], PLAYER_START_Y
  ld hl, wPlayerX2
  ld [hl], PLAYER_START_X
  ld hl, wPlayerY2
  ld a, PLAYER_START_Y
  add a, 16
  ld [hl], a
  ld hl, wPlayerSpeed
  ld [hl], PLAYER_DEFAULT_SPEED
  ret

UpdateBalloonPosition:
.balloonLeft:
  ld hl, wPlayerBalloonOAM
  ld a, [wPlayerY]
  ld [hli], a
  ld a, [wPlayerX]
  ld [hli], a
  inc l
  inc l
.balloonRight:
  ld a, [wPlayerY]
  ld [hli], a
  ld a, [wPlayerX]
  add 8
  ld [hl], a
  ret

UpdateCactusPosition:
.cactusLeft:
  ld hl, wPlayerCactusOAM
  ld a, [wPlayerY2]
  ld [hli], a
  ld a, [wPlayerX2]
  ld [hli], a
  inc l
  inc l
.cactusRight:
  ld a, [wPlayerY2]
  ld [hli], a
  ld a, [wPlayerX2]
  add 8
  ld [hl], a
  ret

SpawnPlayer::
.cactusLeft:
  ld hl, wPlayerCactusOAM
  ld a, [wPlayerY2]
  ld [hli], a
  ld a, [wPlayerX2]
  ld [hli], a
  ld [hl], PLAYER_CACTUS_TILE
  inc l
  ld [hl], OAMF_PAL0
.cactusRight:
  inc l
  ld a, [wPlayerY2]
  ld [hli], a
  ld a, [wPlayerX2]
  add 8
  ld [hli], a
  ld [hl], PLAYER_CACTUS_TILE
  inc l
  ld [hl], OAMF_PAL0 | OAMF_XFLIP
.balloonLeft:
  ld hl, wPlayerBalloonOAM
  ld a, [wPlayerY]
  ld [hli], a
  ld a, [wPlayerX]
  ld [hli], a
  ld [hl], PLAYER_BALLOON_TILE
  inc l
  ld [hl], OAMF_PAL1
.balloonRight:
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

RespawnPlayer:
  xor a ; ld a, 0
  ld [wPlayerRespawnTimer], a
  call InitializePlayer
  call SpawnPlayer
  ld a, INVINCIBLE_RESPAWN_TIME
  ld [wPlayerInvincible], a
  call StopSweepSound
  ret

MoveRight:
  INCREMENT_POS wPlayerX, [wPlayerSpeed]
  INCREMENT_POS wPlayerX2, [wPlayerSpeed]
.canCactusDriftLeft:
  ld a, [wGlobalTimer]
  and	%00000001
  ret nz
  ld hl, wPlayerX
  ld a, PLAYER_MAX_DRIFT_X
  cpl
  add [hl]
  ld hl, wPlayerX2
  cp a, [hl]
  ret nc
.cactusDriftLeft:
  dec [hl]
  ret

MoveLeft:
  DECREMENT_POS wPlayerX, [wPlayerSpeed]
  DECREMENT_POS wPlayerX2, [wPlayerSpeed]
.canCactusDriftRight:
  ld a, [wGlobalTimer]
  and	%00000001
  ret nz
  ld hl, wPlayerX
  ld a, PLAYER_MAX_DRIFT_X
  add [hl]
  ld hl, wPlayerX2
  cp a, [hl]
  ret c
.cactusDriftRight:
  inc [hl]
  ret

MoveDown:
  INCREMENT_POS wPlayerY, [wPlayerSpeed]
  INCREMENT_POS wPlayerY2, [wPlayerSpeed]
.canCactusDriftUp:
  ld a, [wGlobalTimer]
  and	%00000001
  ret nz
  ld hl, wPlayerY  
  ld a, PLAYER_MAX_DRIFT_Y-16
  cpl
  add [hl]
  ld hl, wPlayerY2
  cp a, [hl]
  ret nc
.cactusDriftUp:
  dec [hl]
  ret

ChargeBoost:
  ld a, [wPlayerBoost]
  cp a, PLAYER_BOOST_FULL
  ret z
.isCharging:
  dec a
  ld [wPlayerBoost], a
  cp a, PLAYER_BOOST_EFFECT_ENDS
  ret nc
.resetBoost:
  ld hl, wPlayerSpeed
  ld [hl], PLAYER_DEFAULT_SPEED
  ret

ChargeAttack:
  ld a, [wPlayerAttack]
  cp a, PLAYER_ATTACK_FULL
  ret z
.isCharging:
  dec a
  ld [wPlayerAttack], a
  cp a, PLAYER_ATTACK_EFFECT_ENDS
  ret nc
.resetAttack:
  ; if applicable
  ret

SpawnBullet:

  ret 



PlayerControls:
  ; argument d = input directions down
  ; argument e = input directions pressed
.right:
	ld a, d
	call JOY_RIGHT
	jr z, .endRight
  ; Check offscreen
  ld a, [wPlayerX]
  add 8
  ld b, a
  call OffScreenX
  cp a, 0
  jr nz, .endRight
.moveRight:
	call MoveRight
.endRight:

.left:
  ld a, d
	call JOY_LEFT
	jr z, .endLeft
  ; Check offscreen
  ld a, [wPlayerX]
  sub 8
  ld b, a
  call OffScreenX
  cp a, 0
  jr nz, .endLeft
	call MoveLeft
.endLeft:

.up:
  ld a, d
	call JOY_UP
	jr z, .endUp
  ; Check offscreen
  ld a, [wPlayerY]
  sub 16 ; unusual I have to do this??
  ld b, a
  call OffScreenY
  cp a, 0
  jr nz, .endUp
.moveUp:
  DECREMENT_POS wPlayerY, [wPlayerSpeed]
  DECREMENT_POS wPlayerY2, [wPlayerSpeed]
.endUp:

.down:
  ld a, d
	call JOY_DOWN
	jr z, .endDown
  ; Check offscreen
  ld a, [wPlayerY]
  add 16
  ld b, a
  call OffScreenY
  cp a, 0
  jr nz, .endDown
	call MoveDown
.endDown:

.canCactusDriftCenterX:
  ld a, d
	call JOY_RIGHT
	jr nz, .endDriftToCenterX
  ld a, d
	call JOY_LEFT
  jr nz, .endDriftToCenterX
  ld a, [wGlobalTimer]
  and	%00000001
  jr nz, .endDriftToCenterX
  ld a, [wPlayerX]
  ld hl, wPlayerX2
  cp a, [hl]
  jr z, .endDriftToCenterX
  jr c, .driftCenterXLeft
.driftCenterXRight:
  inc [hl]
  jr .endDriftToCenterX
.driftCenterXLeft:
  dec [hl]
.endDriftToCenterX:

.canCactusDriftCenterY:
  ld a, d
	call JOY_UP
	jr nz, .endDriftToCenterY
  ld a, d
	call JOY_DOWN
  jr nz, .endDriftToCenterY
  ld a, [wGlobalTimer]
  and	%00000001
  jr nz, .endDriftToCenterY
  ld hl, wPlayerY
  ld a, 16
  add [hl]
  ld hl, wPlayerY2
  cp a, [hl]
  jr z, .endDriftToCenterY
  jr nc, .driftCenterYDown
.driftCenterYUp:
  dec [hl]
  jr .endDriftToCenterY
.driftCenterYDown:
  inc [hl]
.endDriftToCenterY:

.start:
  ld a, e
  call JOY_START
  jr z, .endStart
  ld a, 1
  ld [wPaused], a
.endStart:

.AButton:
  ld a, d
	call JOY_A
	jr z, .endA
  ld a, [wPlayerAttack]
  cp a, PLAYER_ATTACK_FULL
  jr nz, .endA
.activateAttack:
  ld a, PLAYER_ATTACK_EMPTY
  ld [wPlayerAttack], a
  call SpawnBullet
.endA:

.BButton:
  ld a, e
	call JOY_B
	jr z, .endB
  ld a, [wPlayerBoost]
  cp a, PLAYER_BOOST_FULL
  jr nz, .endB
.activateBoost:
  ld a, PLAYER_BOOST_EMPTY
  ld [wPlayerBoost], a
  ld hl, wPlayerSpeed
  ld [hl], PLAYER_DEFAULT_SPEED * 2
.endB:
  ret

MovePlayer:
  call ReadInput
  ld a, [wControllerDown]
  ld d, a
  ld a, [wControllerPressed]
  ld e, a
  call PlayerControls
  call UpdateBalloonPosition
  call UpdateCactusPosition
  ret

; MovePlayerAutoMiddle::
;   xor a ; ld a, 0
;   ld d, a
;   ld e, a
;   ld a, [wPlayerX]
;   cp a, SCRN_X/2
;   jr z, .end
;   jr nc, .moveLeft
; .moveRight:
;   ld d, %00010000 ; TODO make these constants
;   jr .end
; .moveLeft:
;   ld d, OAMF_XFLIP
; .end:
;   call PlayerControls
;   call UpdateBalloonPosition
;   call UpdateCactusPosition
;   ret

MovePlayerAutoFlyUp::
  DECREMENT_POS wPlayerY, 1
  DECREMENT_POS wPlayerY2, 1
  call UpdateBalloonPosition
  call UpdateCactusPosition
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
  ld a, [wPlayerPoppingFrame]
  cp a, 0
  jr z, .frame0
  ld a, [wPlayerPoppingTimer]
  inc	a
  ld [wPlayerPoppingTimer], a
  and POPPING_BALLOON_ANIMATION_SPEED
  ret nz
.canSwitchFrames:
  ld a, [wPlayerPoppingFrame]
  cp a, 1
  jr z, .frame1
  cp a, 2
  jr z, .clear
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
  jr .endFrame
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
  jr .endFrame
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
  ret
.endFrame:
  inc a 
  ld [wPlayerPoppingFrame], a
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
  jp Start ; change this so it leads to intermediate screen to say GAME OVER, maybe play small jingle + start to continue
  ret

PlayerUpdate::
  ; Check alive
  ld a, [wPlayerAlive]
  cp a, 0
  jr z, .popped
.isAlive:
  call InvincibleBlink
  ; Check if we can move
  ld a, [wGlobalTimer]
	and	PLAYER_MOVE_TIME
	call z, MovePlayer
  ; Check if we can charge boost
  ld a, [wGlobalTimer]
	and	PLAYER_BOOST_TIME
  call z, ChargeBoost
  ; Check if we can charge attack
  ld a, [wGlobalTimer]
	and	PLAYER_ATTACK_TIME
  call z, ChargeAttack
  ret
.popped:
  ; Can we respawn
  ld a, [wPlayerRespawnTimer]
  inc a
  ld [wPlayerRespawnTimer], a
  cp a, PLAYER_RESPAWN_TIME
  jr z, .respawning
.popping:
  ld a, [wPlayerPopping]
  cp a, 0
  call nz, PopBalloonAnimation
.falling:
  ld a, [wPlayerFalling]
  cp a, 0
  call nz, CactusFalling
  ret
.respawning:
  ld a, [wPlayerLives]
  or a, 0
  jr nz, .respawn
.noMoreLives:
  call NoMoreLives
  ret
.respawn:
  call RespawnPlayer
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

InvincibleBlink:
  ld a, [wPlayerInvincible]
  cp a, 0
  ret z
.isStillInvincible:
  dec a
  ld [wPlayerInvincible], a
  ; At the end make sure we stop on default tileset
  cp a, 3 ; TODO: Dangerous way to do this
  jr c, .defaultPalette
  cp a, INVINCIBLE_BLINK_FASTER_TIME
  ld a, [wGlobalTimer]
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
  ret