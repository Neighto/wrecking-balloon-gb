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
  wPlayerRight:: DB

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
  ld [wPlayerRight], a

  call SetPlayerPositionOpeningDefault
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

SetPlayerPosition:
  ; b = start x
  ; c = start y
  ld a, b
  ld [wPlayerX], a
  ld [wPlayerX2], a
  ld a, c
  ld [wPlayerY], a
  add a, 16
  ld [wPlayerY2], a
  call UpdateBalloonPosition
  call UpdateCactusPosition
  ret

SetPlayerPositionOpeningDefault:
  ld b, PLAYER_START_X
  ld c, PLAYER_START_Y
  call SetPlayerPosition
  ret

SetPlayerPositionOpeningCutscene::
  ld b, PLAYER_START_X
  ld c, PLAYER_START_Y - 30
  call SetPlayerPosition
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

MoveRight:
  INCREMENT_POS wPlayerX, [wPlayerSpeed]
  INCREMENT_POS wPlayerX2, [wPlayerSpeed]
.canCactusDriftLeft:
  ldh a, [hGlobalTimer]
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
  ldh a, [hGlobalTimer]
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
  ldh a, [hGlobalTimer]
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

PlayerControls:
  ; argument d = input directions down
  ; argument e = input directions pressed
  ; argument c = check boundaries (0 = no)
.right:
	ld a, d
  and PADF_RIGHT
	jr z, .endRight
  ; Check offscreen
  ld a, c
  cp a, 0
  jr z, .moveRight
  ld a, [wPlayerX]
  add 10
  ld b, a
  call OffScreenX
  cp a, 0
  jr nz, .endRight
.moveRight:
	call MoveRight
  ld a, 1
  ld [wPlayerRight], a
.endRight:

.left:
  ld a, d
  and PADF_LEFT
	jr z, .endLeft
  ; Check offscreen
  ld a, c
  cp a, 0
  jr z, .moveLeft
  ld a, [wPlayerX]
  sub 10
  ld b, a
  call OffScreenX
  cp a, 0
  jr nz, .endLeft
.moveLeft:
	call MoveLeft
  xor a ; ld a, 0
  ld [wPlayerRight], a
.endLeft:

.up:
  ld a, d
  and PADF_UP
	jr z, .endUp
  ; Check offscreen
  ld a, c
  cp a, 0
  jr z, .moveUp
  ld a, [wPlayerY]
  sub 18
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
  and PADF_DOWN
	jr z, .endDown
  ; Check offscreen
  ld a, c
  cp a, 0
  jr z, .moveDown
  ld a, [wPlayerY]
  add 16
  ld b, a
  call OffScreenY
  cp a, 0
  jr nz, .endDown
.moveDown:
	call MoveDown
.endDown:

.canCactusDriftCenterX:
  ld a, d
  and PADF_RIGHT
	jr nz, .endDriftToCenterX
  ld a, d
  and PADF_LEFT
  jr nz, .endDriftToCenterX
  ldh a, [hGlobalTimer]
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
  and PADF_UP
	jr nz, .endDriftToCenterY
  ld a, d
  and PADF_DOWN
  jr nz, .endDriftToCenterY
  ldh a, [hGlobalTimer]
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
  and PADF_START
  jr z, .endStart
  ld a, 1
  ld [wPaused], a
.endStart:

.AButton:
  ld a, d
	and PADF_A
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
  and PADF_B
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

MovePlayerUpForCutscene::
  ld d, %01000000
  ld e, 0
  ld c, 0
  call PlayerControls
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
  ld [wPlayerPoppingFrame], a
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

  ; When player respawns and has some invincibility
InvincibleBlink:
  ld a, [wPlayerInvincible]
  cp a, 0
  ret z
.isStillInvincible:
  dec a
  ld [wPlayerInvincible], a
  ; If at the end make sure we stop on default tileset
  cp a, 2
  jr c, .noBlink
  cp a, INVINCIBLE_BLINK_FASTER_TIME
  ldh a, [hGlobalTimer]
  jr c, .blinkFast
.blinkNormal:
	and INVINCIBLE_BLINK_NORMAL_SPEED
  jr z, .noBlink
  jr .blinkEnd
  ret
.blinkFast:
	and INVINCIBLE_BLINK_FAST_SPEED
  jr z, .noBlink
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
.noBlink:
  ld hl, wPlayerBalloonOAM+2
  ld [hl], PLAYER_BALLOON_TILE
  ld hl, wPlayerBalloonOAM+6
  ld [hl], PLAYER_BALLOON_TILE
  ld hl, wPlayerCactusOAM+2
  ld [hl], PLAYER_CACTUS_TILE
  ld hl, wPlayerCactusOAM+6
  ld [hl], PLAYER_CACTUS_TILE
  ret

PlayerUpdate::
.checkAlive:
  ld a, [wPlayerAlive]
  cp a, 0
  jr z, .popped
.isAlive:
  call InvincibleBlink

.checkMove:
  ldh a, [hGlobalTimer]
	and	PLAYER_MOVE_TIME
  jr nz, .endMove
.canMove:
  call ReadController
  ld a, [wControllerDown]
  ld d, a
  ld a, [wControllerPressed]
  ld e, a
  ld c, 1
  call PlayerControls
  call UpdateBalloonPosition
  call UpdateCactusPosition
.endMove:

.checkBoost:
  ldh a, [hGlobalTimer]
	and	PLAYER_BOOST_TIME
  jr nz, .endBoost
  ld a, [wPlayerBoost]
  cp a, PLAYER_BOOST_FULL
  jr z, .endBoost
.isChargingBoost:
  dec a
  ld [wPlayerBoost], a
  cp a, PLAYER_BOOST_EFFECT_ENDS
  jr nc, .endBoost
.resetBoost:
  ld hl, wPlayerSpeed
  ld [hl], PLAYER_DEFAULT_SPEED
.endBoost:

.checkAttack:
  ldh a, [hGlobalTimer]
	and	PLAYER_ATTACK_TIME
  jr nz, .endAttack
  ld a, [wPlayerAttack]
  cp a, PLAYER_ATTACK_FULL
  jr z, .endAttack
.isChargingAttack:
  dec a
  ld [wPlayerAttack], a
.endAttack:
  ret

.popped:

.checkRespawn:
  ld hl, wPlayerRespawnTimer
  inc [hl]
  ld a, [hl]
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
  cp a, 0
  jr z, .noMoreLives
.respawn:
  call StopSweepSound
  call InitializePlayer
  call InitializeBullet
  call SpawnPlayer
  ld a, INVINCIBLE_RESPAWN_TIME
  ld [wPlayerInvincible], a
  ret
.noMoreLives:
  call ClearSound
  call StopSweepSound
  jp Start ; change this so it leads to intermediate screen to say GAME OVER, maybe play small jingle + start to continue