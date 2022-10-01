INCLUDE "hardware.inc"
INCLUDE "playerConstants.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

SECTION "player vars", HRAM
  hPlayerY:: DB
  hPlayerX:: DB
  hPlayerY2:: DB
  hPlayerX2:: DB
  hPlayerAlive:: DB
  hPlayerPopping:: DB
  hPlayerPoppingFrame:: DB
  hPlayerPoppingTimer:: DB
  hPlayerFalling:: DB
  hPlayerFallSpeed:: DB
  hPlayerRespawnTimer:: DB
  hPlayerSpeed:: DB
  hPlayerLives:: DB
  hPlayerLookRight:: DB
  hPlayerBobbedUp:: DB
  hPlayerStunnedTimer:: DB

  ; Operate like timers
  hPlayerInvincible:: DB
  hPlayerBoost:: DB ; TODO it would be a lot more logical to make these increase instead of decrease
  hPlayerAttack:: DB

SECTION "player", ROM0

InitializeLives::
	ld a, PLAYER_START_LIVES
	ldh [hPlayerLives], a
  ret

InitializePlayer::
  xor a ; ld a, 0
  ldh [hPlayerPopping], a
  ldh [hPlayerPoppingFrame], a
  ldh [hPlayerPoppingTimer], a
  ldh [hPlayerFalling], a
  ldh [hPlayerRespawnTimer], a
  ldh [hPlayerInvincible], a
  ldh [hPlayerBoost], a
  ldh [hPlayerAttack], a
  ldh [hPlayerBobbedUp], a
  ldh [hPlayerStunnedTimer], a

  ld a, 1
  ldh [hPlayerAlive], a
  ldh [hPlayerFallSpeed], a
  ldh [hPlayerLookRight], a

  call SetPlayerPositionOpeningDefault

  ld a, PLAYER_DEFAULT_SPEED
  ldh [hPlayerSpeed], a
  ret

UpdateBalloonPosition:
.balloonLeft:
  ld hl, wPlayerBalloonOAM
  ldh a, [hPlayerY]
  ld [hli], a
  ldh a, [hPlayerX]
  ld [hli], a
  inc l
  inc l
.balloonRight:
  ldh a, [hPlayerY]
  ld [hli], a
  ldh a, [hPlayerX]
  add 8
  ld [hl], a
  ret

UpdateCactusPosition:
.cactusLeft:
  ld hl, wPlayerCactusOAM
  ldh a, [hPlayerY2]
  ld [hli], a
  ldh a, [hPlayerX2]
  ld [hli], a
  inc l
  inc l
.cactusRight:
  ldh a, [hPlayerY2]
  ld [hli], a
  ldh a, [hPlayerX2]
  add 8
  ld [hl], a
  ret

SetPlayerPosition:
  ; b = start x
  ; c = start y
  ld a, b
  ldh [hPlayerX], a
  ldh [hPlayerX2], a
  ld a, c
  ldh [hPlayerY], a
  add a, 16
  ldh [hPlayerY2], a
  call UpdateBalloonPosition
  call UpdateCactusPosition
  ret

SetPlayerPositionOpeningDefault:
  ld b, PLAYER_START_X
  ld c, PLAYER_START_Y
  call SetPlayerPosition
  ret

SetPlayerPositionBoss::
  ld b, PLAYER_START_X - 40
  ld c, PLAYER_START_Y
  call SetPlayerPosition
  ret

SetPlayerPositionOpeningCutscene::
  ld b, PLAYER_START_X
  ld c, 52
  call SetPlayerPosition
  ret

SetPlayerPositionEndingCutscene::
  ld b, PLAYER_START_X
  ld c, 90
  call SetPlayerPosition
  ret

SetPlayerCactusHappy::
  ld hl, wPlayerCactusOAM+2
  ld [hl], PLAYER_CACTUS_HAPPY_TILE
  ld hl, wPlayerCactusOAM+6
  ld [hl], PLAYER_CACTUS_HAPPY_TILE
  ret

BobPlayer::
  ldh a, [hGlobalTimer]
  and %00011111
  ld d, %00000000
  jr nz, .endWreckingBalloonCheck
  ld a, 1
  ldh [hPlayerSpeed], a
  ldh a, [hPlayerBobbedUp]
  cp a, 0
  jr z, .bobUp
.bobDown:
  xor a ; ld a, 0
  ldh [hPlayerBobbedUp], a
  ld d, %10000000
  jr .endWreckingBalloonCheck
.bobUp:
  ld a, 1
  ldh [hPlayerBobbedUp], a
  ld d, %01000000
.endWreckingBalloonCheck:
  ld e, 0
  ld c, 0
  call PlayerControls
  call UpdateBalloonPosition
  call UpdateCactusPosition
  ret

MovePlayerUp::
  ldh a, [hGlobalTimer]
  and %00000011
  ret nz
  ld d, %01000000
  ld e, 0
  ld c, 0
  call PlayerControls
  call UpdateBalloonPosition
  call UpdateCactusPosition
  ret

GetPlayerTiles::
  ; Returns b = balloon tile
  ; Returns c = cactus tile
  ld a, [wSecret]
  cp a, SECRET_AMOUNT
  jr c, .normalLook
.secretLook:
  ld b, PLAYER_SECRET_BALLOON_TILE
  ld c, PLAYER_SECRET_CACTUS_TILE
  ret
.normalLook:
  ld b, PLAYER_BALLOON_TILE
  ld c, PLAYER_CACTUS_TILE
  ret

SpawnPlayer::
  call GetPlayerTiles ; b = balloon tile, c = cactus tile
.cactusLeftOAM:
  ld hl, wPlayerCactusOAM
  ldh a, [hPlayerY2]
  ld [hli], a
  ldh a, [hPlayerX2]
  ld [hli], a
  ld a, c
  ld [hli], a
  ld a, OAMF_PAL0
  ld [hli], a
.cactusRightOAM:
  ldh a, [hPlayerY2]
  ld [hli], a
  ldh a, [hPlayerX2]
  add 8
  ld [hli], a
  ld a, c
  ld [hli], a
  ld a, OAMF_PAL0 | OAMF_XFLIP
  ld [hl], a
.balloonLeftOAM:
  ld hl, wPlayerBalloonOAM
  ldh a, [hPlayerY]
  ld [hli], a
  ldh a, [hPlayerX]
  ld [hli], a
  ld a, b
  ld [hli], a
  ld a, OAMF_PAL1
  ld [hli], a
.balloonRightOAM:
  ldh a, [hPlayerY]
  ld [hli], a
  ldh a, [hPlayerX]
  add 8
  ld [hli], a
  ld a, b
  ld [hli], a
  ld a, OAMF_PAL1 | OAMF_XFLIP
  ld [hl], a
  ret

PlayerControls:
  ; argument d = input directions down
  ; argument e = input directions pressed
  ; argument c = check boundaries (0 = no)

.checkHorizontal:

.right:
	ld a, d
  and PADF_RIGHT
	jr z, .endRight
.setFacingRight:
  ld a, 1
  ldh [hPlayerLookRight], a
.checkOffscreenRight:
  ld a, c
  cp a, 0
  jr z, .moveRight
.canCheckOffscreenRight:
  ldh a, [hPlayerX]
  ld b, a
  ld a, SCRN_X - 10
  cp a, b
  jr c, .canCactusDriftCenterX
.moveRight:
  ldh a, [hPlayerSpeed]
  ld b, a
  ldh a, [hPlayerX]
  add a, b
  ldh [hPlayerX], a
  ldh a, [hPlayerX2]
  add a, b
  ldh [hPlayerX2], a
.canCactusDriftLeft:
  ld hl, hPlayerX
  ld a, PLAYER_MAX_DRIFT_X
  cpl
  add [hl]
  ld hl, hPlayerX2
  cp a, [hl]
  jr c, .cactusDriftLeft
.cactusMaxDriftLeft:
  ; Update balloon turning tiles right
  ld hl, wPlayerBalloonOAM+2
  ld [hl], PLAYER_BALLOON_TURNING_TILE_1
  ld hl, wPlayerBalloonOAM+6
  ld [hl], PLAYER_BALLOON_TURNING_TILE_2
  jr .endCheckHorizontal
.cactusDriftLeft:
  dec [hl]
  jr .checkBalloonString
.endRight:

.left:
  ld a, d
  and PADF_LEFT
	jr z, .endLeft
.setFacingLeft:
  xor a ; ld a, 0
  ldh [hPlayerLookRight], a
.checkOffscreenLeft:
  ld a, c
  cp a, 0
  jr z, .moveLeft
.canCheckOffscreenLeft:
  ldh a, [hPlayerX]
  sub 10
  ld b, a
  ld a, SCRN_X
  cp a, b
  jr c, .canCactusDriftCenterX
.moveLeft:
  ldh a, [hPlayerSpeed]
  ld b, a
  ldh a, [hPlayerX]
  sub a, b
  ldh [hPlayerX], a
  ldh a, [hPlayerX2]
  sub a, b
  ldh [hPlayerX2], a
.canCactusDriftRight:
  ld hl, hPlayerX
  ld a, PLAYER_MAX_DRIFT_X
  add [hl]
  ld hl, hPlayerX2
  cp a, [hl]
  jr nc, .cactusDriftRight
.cactusMaxDriftRight:
  ; Update balloon turning tiles left
  ld hl, wPlayerBalloonOAM+2
  ld [hl], PLAYER_BALLOON_TURNING_TILE_2
  ld hl, wPlayerBalloonOAM+6
  ld [hl], PLAYER_BALLOON_TURNING_TILE_1
  jr .endCheckHorizontal
.cactusDriftRight:
  inc [hl]
  jr .checkBalloonString
.endLeft:

.canCactusDriftCenterX:
  ldh a, [hGlobalTimer]
  and	%00000001
  jr nz, .endDriftToCenterX
  ldh a, [hPlayerX]
  ld hl, hPlayerX2
  cp a, [hl]
  jr z, .endDriftToCenterX
  jr c, .driftCenterXLeft
.driftCenterXRight:
  inc [hl]
  jr .endDriftToCenterX
.driftCenterXLeft:
  dec [hl]
.endDriftToCenterX:

.checkBalloonString:
  ; TODO maybe check balloon state to prevent updating these tiles every time we check playercontrols
  ld hl, wPlayerBalloonOAM+2
  ld [hl], PLAYER_BALLOON_TILE
  ld hl, wPlayerBalloonOAM+6
  ld [hl], PLAYER_BALLOON_TILE
.endCheckBalloonString:

.endCheckHorizontal:

.checkVertical:

.up:
  ld a, d
  and PADF_UP
	jr z, .endUp
.checkOffscreenUp:
  ld a, c
  cp a, 0
  jr z, .moveUp
.canCheckOffscreenUp:
  ldh a, [hPlayerY]
  sub 18
  ld b, a
  ld a, SCRN_Y - WINDOW_LAYER_HEIGHT
  cp a, b
  jr c, .canCactusDriftCenterY
.moveUp:
  ldh a, [hPlayerSpeed]
  ld b, a
  ldh a, [hPlayerY]
  sub a, b
  ldh [hPlayerY], a
  ldh a, [hPlayerY2]
  sub a, b
  ldh [hPlayerY2], a
.canCactusDriftDown:
  ld hl, hPlayerY
  ld a, 15 ; player balloon height - 1
  add [hl]
  ld hl, hPlayerY2
  cp a, [hl]
  jr c, .endCheckVertical
.cactusDriftDown:
  inc [hl]
  jr .endCheckVertical
.endUp:

.down:
  ld a, d
  and PADF_DOWN
	jr z, .endDown
.checkOffscreenDown:
  ld a, c
  cp a, 0
  jr z, .moveDown
.canCheckOffscreenDown:
  ldh a, [hPlayerY]
  ld b, a
  ld a, SCRN_Y - 16 - WINDOW_LAYER_HEIGHT
  cp a, b
  jr c, .canCactusDriftCenterY
.moveDown:
  ldh a, [hPlayerSpeed]
  ld b, a
  ldh a, [hPlayerY]
  add a, b
  ldh [hPlayerY], a
  ldh a, [hPlayerY2]
  add a, b
  ldh [hPlayerY2], a
.canCactusDriftUp:
  ld hl, hPlayerY  
  ld a, PLAYER_MAX_DRIFT_Y - 16
  cpl
  add [hl]
  ld hl, hPlayerY2
  cp a, [hl]
  jr nc, .endCheckVertical
.cactusDriftUp:
  dec [hl]
  jr .endCheckVertical
.endDown:

.canCactusDriftCenterY:
  ldh a, [hGlobalTimer]
  and	%00000001
  jr nz, .endDriftToCenterY
  ld hl, hPlayerY
  ld a, 16
  add [hl]
  ld hl, hPlayerY2
  cp a, [hl]
  jr z, .endDriftToCenterY
  jr nc, .driftCenterYDown
.driftCenterYUp:
  dec [hl]
  jr .endDriftToCenterY
.driftCenterYDown:
  inc [hl]
.endDriftToCenterY:

.endCheckVertical:

.start:
  ld a, e
  and PADF_START
  jr z, .endStart
  ld a, 1
  ldh [hPaused], a
.endStart:

.AButton:
  ld a, d
	and PADF_A
	jr z, .endA
  ldh a, [hPlayerAttack]
  cp a, PLAYER_ATTACK_FULL
  jr nz, .endA
.activateAttack:
  ld a, PLAYER_ATTACK_EMPTY
  ldh [hPlayerAttack], a
  call SpawnBullet
.endA:

.BButton:
  ld a, d
  and PADF_B
	jr z, .endB
  ldh a, [hPlayerBoost]
  cp a, PLAYER_BOOST_FULL
  jr nz, .endB
.activateBoost:
  ld a, PLAYER_BOOST_EMPTY
  ldh [hPlayerBoost], a
  ld hl, hPlayerSpeed
  ld [hl], PLAYER_DEFAULT_SPEED * 2
  call BoostSound
.endB:
  ret

PopPlayerBalloonAnimation:
  ldh a, [hPlayerPoppingFrame]
  cp a, 0
  jr z, .frame0
  ldh a, [hPlayerPoppingTimer]
  inc	a
  ldh [hPlayerPoppingTimer], a
  and PLAYER_POPPING_BALLOON_ANIMATION_TIME
  ret nz
.canSwitchFrames:
  ldh a, [hPlayerPoppingFrame]
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
.clearPlayerBalloon
  xor a ; ld a, 0
  ld hl, wPlayerBalloonOAM
  ld bc, PLAYER_BALLOON_OAM_BYTES
  call ResetHLInRange
  ; Reset variables
  ldh [hPlayerPopping], a
  ret
.endFrame:
  ldh a, [hPlayerPoppingFrame]
  inc a 
  ldh [hPlayerPoppingFrame], a
  ret

CollisionWithPlayer::
  ; Check if player is invincible
  ldh a, [hPlayerInvincible]
  cp a, 0
  ret nz
  ; Check if player is alive
  ldh a, [hPlayerAlive]
  cp a, 0
  ret z
.deathOfPlayer:
  xor a ; ld a, 0
  ldh [hPlayerAlive], a
  ldh a, [hPlayerLives]
  dec a
  ldh [hPlayerLives], a
  ; Animation trigger
  ld a, 1
  ldh [hPlayerPopping], a
  ldh [hPlayerFalling], a
  ; Screaming cactus
  ld hl, wPlayerCactusOAM+2
  ld [hl], PLAYER_CACTUS_SCREAMING_TILE
  ld hl, wPlayerCactusOAM+6
  ld [hl], PLAYER_CACTUS_SCREAMING_TILE
  ; Sound
  call PopSound
  call FallingSound
  ret

CollisionWithPlayerCactus::
  ; Check if player is invincible
  ldh a, [hPlayerInvincible]
  cp a, 0
  ret nz
  ldh a, [hPlayerAlive]
  cp a, 0
  ret z
.stunPlayer:
  ldh a, [hPlayerStunnedTimer]
  cp a, 0
  ret nz
  ld a, PLAYER_STUNNED_TIME
  ldh [hPlayerStunnedTimer], a
  call HitSound
  ret

PlayerUpdate::

.checkAlive:
  ldh a, [hPlayerAlive]
  cp a, 0
  jr nz, .isAlive
.popped:
.checkRespawn:
  ldh a, [hPlayerRespawnTimer]
  inc a
  ldh [hPlayerRespawnTimer], a
  cp a, PLAYER_RESPAWN_TIME
  jr z, .respawning
.popping:
  ldh a, [hPlayerPopping]
  cp a, 0
  call nz, PopPlayerBalloonAnimation
.falling:
  ldh a, [hPlayerFalling]
  cp a, 0
  ret z
.checkFallingOffscreen:
  ld a, SCRN_X
  ld hl, hPlayerY2
  cp a, [hl]
  jr c, .fellOffscreen
.continueFalling:
  ldh a, [hGlobalTimer]
  and %00000001
  ret nz
  ldh a, [hPlayerFallSpeed]
  inc a 
  ldh [hPlayerFallSpeed], a
  ld b, 4
  call DIVISION
  ld b, a
  ldh a, [hPlayerY2]
  add a, b
  ldh [hPlayerY2], a
  call UpdateCactusPosition
  ret
.fellOffscreen:
  xor a ; ld a, 0
  ldh [hPlayerFalling], a
.clearPlayerCactus:
  ld hl, wPlayerCactusOAM
  ld bc, PLAYER_CACTUS_OAM_BYTES
  call ResetHLInRange
  ret
.respawning:
  ldh a, [hPlayerLives]
  cp a, 0
  jr nz, .respawn
.noMoreLives:
  jp GameOver
.respawn:
  call StopSweepSound
  call InitializePlayer
  call InitializeBullet
  call SpawnPlayer
  ld a, INVINCIBLE_RESPAWN_TIME
  ldh [hPlayerInvincible], a
  ret
.isAlive:

.checkStunned:
  ldh a, [hPlayerStunnedTimer]
  cp a, 0
  jr z, .endCheckStunned
.isStunned:
  dec a
  ldh [hPlayerStunnedTimer], a
  and PLAYER_STUNNED_SLOW_TIME
  jr nz, .endCheckStunned
.blinking:
  ld hl, wPlayerCactusOAM + 2
  ld a, [hl]
  cp a, EMPTY_TILE
  jr z, .blinkOn
.blinkOff:
  ld a, EMPTY_TILE
  ld [hli], a
  inc l
  inc l
  inc l
  ld [hli], a
  jr .endCheckStunned
.blinkOn:
  call GetPlayerTiles ; b = balloon tile, c = cactus tile
  ld a, c
  ld [hli], a
  inc l
  inc l
  inc l
  ld [hli], a
.endCheckStunned:

.checkInvincible:
  ldh a, [hPlayerInvincible]
  cp a, 0
  jr z, .endInvincible
.isInvincible:
  dec a
  ldh [hPlayerInvincible], a
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
.blinkFast:
	and INVINCIBLE_BLINK_FAST_SPEED
  jr z, .noBlink
.blinkEnd:
  ld a, EMPTY_TILE
  ld hl, wPlayerBalloonOAM+2
  ld [hli], a
  inc l
  inc l
  inc l
  ld [hl], a
  ld hl, wPlayerCactusOAM+2
  ld [hli], a
  inc l
  inc l
  inc l
  ld [hl], a
  jr .endInvincible
.noBlink:
  call GetPlayerTiles ; b = balloon tile, c = cactus tile
  ld a, b
  ld hl, wPlayerBalloonOAM+2
  ld [hli], a
  inc l
  inc l
  inc l
  ld [hl], a
  ld a, c
  ld hl, wPlayerCactusOAM+2
  ld [hli], a
  inc l
  inc l
  inc l
  ld [hl], a
.endInvincible:

.checkMove:
  ldh a, [hGlobalTimer]
	and	PLAYER_MOVE_TIME
  jr nz, .endMove
  ldh a, [hPlayerStunnedTimer]
  cp a, 0
  jr nz, .endMove
.canMove:
  call ReadController
  ldh a, [hControllerDown]
  ld d, a
  ldh a, [hControllerPressed]
  ld e, a
  ld c, 1
  call PlayerControls
  call UpdateBalloonPosition
  call UpdateCactusPosition
.endMove:

.checkBoost:
  ldh a, [hPlayerBoost]
  cp a, PLAYER_BOOST_FULL
  jr z, .endBoost
.isChargingBoost:
  dec a
  ldh [hPlayerBoost], a
  cp a, PLAYER_BOOST_EFFECT_ENDS
  jr nz, .endBoost
.resetBoost:
  ld a, PLAYER_DEFAULT_SPEED
  ldh [hPlayerSpeed], a
.endBoost:

.checkAttack:
  ldh a, [hPlayerAttack]
  cp a, PLAYER_ATTACK_FULL
  jr z, .endAttack
.isChargingAttack:
  dec a
  ldh [hPlayerAttack], a
.endAttack:
  ret