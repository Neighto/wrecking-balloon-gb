INCLUDE "hardware.inc"
INCLUDE "playerConstants.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "tileConstants.inc"

SECTION "player vars", HRAM
hPlayerFlags:: DB ; BIT #: [0=active] [1=alive] [2=dying] [3=direction] [4=bobbed] [5-7=generic]
hPlayerY:: DB
hPlayerX:: DB
hPlayerY2:: DB
hPlayerX2:: DB
hPlayerPoppingFrame:: DB
hPlayerPoppingTimer:: DB
hPlayerRespawnTimer:: DB
hPlayerSpeed:: DB
hPlayerLives:: DB
hPlayerInvincible:: DB ; Timer
hPlayerBoost:: DB ; Timer
hPlayerAttack:: DB ; Timer
hPlayerStunnedTimer:: DB
hPlayerCactusTile:: DB
hPlayerBalloonTile:: DB
hPlayerBalloonTurningTile:: DB
hPlayerBalloonTurningTile2:: DB

SECTION "player", ROM0

InitializeLivesClassic::
  ld a, PLAYER_START_LIVES_CLASSIC
	ldh [hPlayerLives], a
  ret

InitializeLivesEndless::
  ld a, PLAYER_START_LIVES_ENDLESS
	ldh [hPlayerLives], a
  ret

InitializePlayer::
  ; FLAGS
  xor a ; ld a, 0
  ldh [hPlayerFlags], a
  ldh a, [hPlayerFlags]
  set PLAYER_FLAG_ACTIVE_BIT, a
  set PLAYER_FLAG_ALIVE_BIT, a
  ldh [hPlayerFlags], a

  ; GENERAL
  xor a ; ld a, 0
  ; ldh [hPlayerY], a
  ; ldh [hPlayerX], a
  ; ldh [hPlayerY2], a
  ; ldh [hPlayerX2], a
  ldh [hPlayerPoppingFrame], a
  ldh [hPlayerPoppingTimer], a
  ldh [hPlayerRespawnTimer], a
  ldh [hPlayerInvincible], a
  ldh [hPlayerBoost], a
  ldh [hPlayerAttack], a
  ldh [hPlayerStunnedTimer], a

  ; SPEED
  ld a, PLAYER_DEFAULT_SPEED
  ldh [hPlayerSpeed], a

  ; POSITION
  call SetPlayerPositionOpeningDefault

  ; TILES
  ld a, [wSecret]
  cp a, 0
  jr z, .normalLook
.secretLook:
  ld a, PLAYER_SECRET_CACTUS_TILE
  ld b, PLAYER_SECRET_BALLOON_TILE
  ld c, PLAYER_SECRET_BALLOON_TURNING_TILE_1
  ld d, PLAYER_SECRET_BALLOON_TURNING_TILE_2
  jr .updateTiles
.normalLook:
  ld a, PLAYER_CACTUS_TILE
  ld b, PLAYER_BALLOON_TILE
  ld c, PLAYER_BALLOON_TURNING_TILE_1
  ld d, PLAYER_BALLOON_TURNING_TILE_2
.updateTiles:
  ldh [hPlayerCactusTile], a
  ld a, b
  ldh [hPlayerBalloonTile], a
  ld a, c
  ldh [hPlayerBalloonTurningTile], a
  ld a, d
  ldh [hPlayerBalloonTurningTile2], a
  ret

UpdateBalloonPosition:
  ld hl, wPlayerBalloonOAM
  ldh a, [hPlayerX]
  ld c, a
  ldh a, [hPlayerY]
  ld b, a
  ; Balloon Left
  ; ld a, b
  ld [hli], a
  ld a, c
  ld [hli], a
  inc l
  inc l
  ; Balloon Right
  ld a, b
  ld [hli], a
  ld a, c
  add 8
  ld [hl], a
  ret

UpdateCactusPosition:
  ld hl, wPlayerCactusOAM
  ldh a, [hPlayerX2]
  ld c, a
  ldh a, [hPlayerY2]
  ld b, a
  ; Cactus Left
  ; ld a, b
  ld [hli], a
  ld a, c
  ld [hli], a
  inc l
  inc l
  ; Cactus right
  ld a, b
  ld [hli], a
  ld a, c
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
  jp UpdateCactusPosition

SetPlayerPositionOpeningDefault:
  ld b, PLAYER_START_X
  ld c, PLAYER_START_Y
  jp SetPlayerPosition

SetPlayerPositionBoss::
  ld b, PLAYER_START_X - 40
  ld c, PLAYER_START_Y
  jp SetPlayerPosition

SetPlayerPositionAndSpeedOpeningCutscene::
  ld a, 1
  ldh [hPlayerSpeed], a
  ld b, PLAYER_START_X
  ld c, 52
  jp SetPlayerPosition

SetPlayerPositionAndSpeedEndingCutscene::
  ld a, 1
  ldh [hPlayerSpeed], a
  ld b, PLAYER_START_X
  ld c, 38
  jp SetPlayerPosition

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
  ldh a, [hPlayerFlags]
  and PLAYER_FLAG_BOBBED_MASK
  ldh a, [hPlayerFlags]
  jr z, .bobUp
.bobDown:
  res PLAYER_FLAG_BOBBED_BIT, a
  ldh [hPlayerFlags], a
  ld d, %10000000
  jr .endWreckingBalloonCheck
.bobUp:
  set PLAYER_FLAG_BOBBED_BIT, a
  ldh [hPlayerFlags], a
  ld d, %01000000
.endWreckingBalloonCheck:
  ld e, 0
  ld c, 0
  call PlayerControls
  call UpdateBalloonPosition
  jp UpdateCactusPosition

MovePlayerAuto::
  ; d = input
.autoDown::
  ld d, %10000000
  jr .auto
.autoUp::
  ld d, %01000000
  ; jr .auto
.auto:
  ldh a, [hGlobalTimer]
  and %00000011
  ret nz
  ld e, 0
  ld c, 0
  call PlayerControls
  call UpdateBalloonPosition
  jp UpdateCactusPosition

; *************************************************************
; SPAWN
; *************************************************************
SpawnPlayer::
  ldh a, [hPlayerBalloonTile]
  ld b, a
  ldh a, [hPlayerCactusTile]
  ld c, a
  ; Cactus left OAM
  ld hl, wPlayerCactusOAM
  ldh a, [hPlayerY2]
  ld [hli], a
  ldh a, [hPlayerX2]
  ld [hli], a
  ld a, c
  ld [hli], a
  ld a, OAMF_PAL0
  ld [hli], a
  ; Cactus right OAM
  ldh a, [hPlayerY2]
  ld [hli], a
  ldh a, [hPlayerX2]
  add 8
  ld [hli], a
  ld a, c
  ld [hli], a
  ld a, OAMF_PAL0 | OAMF_XFLIP
  ld [hl], a
  ; Balloon left OAM
  ld hl, wPlayerBalloonOAM
  ldh a, [hPlayerY]
  ld [hli], a
  ldh a, [hPlayerX]
  ld [hli], a
  ld a, b
  ld [hli], a
  ld a, OAMF_PAL1
  ld [hli], a
  ; Balloon right OAM
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

; *************************************************************
; CONTROLS
; *************************************************************
PlayerControls:
  ; Arg: D = Input directions down
  ; Arg: E = Input directions pressed
  ; Arg: C = Check vertical boundaries (0 = no)

.checkHorizontal:

.right:
	ld a, d
  and PADF_RIGHT
	jr z, .endRight
.setFacingRight:
  ldh a, [hPlayerFlags]
  res PLAYER_FLAG_DIRECTION_BIT, a
  ldh [hPlayerFlags], a
.checkOffscreenRight:
  ldh a, [hPlayerX]
  ld b, SCRN_X - 8
  cp a, b
  jr c, .moveRight
.offscreenRight:
  ld a, b
  ldh [hPlayerX], a
  jr .canCactusDriftCenterX
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
  ldh a, [hPlayerBalloonTurningTile]
  ld [wPlayerBalloonOAM+2], a
  ldh a, [hPlayerBalloonTurningTile2]
  ld [wPlayerBalloonOAM+6], a
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
  ldh a, [hPlayerFlags]
  set PLAYER_FLAG_DIRECTION_BIT, a
  ldh [hPlayerFlags], a
.checkOffscreenLeft:
  ldh a, [hPlayerX]
  ld b, 8 ; x = 8 when player is at leftmost part of screen
  sub a, b
  dec a ; sub 1 more so if we are at leftmost part of screen value is past 0
  cp a, SCRN_X
  jr c, .moveLeft
.offscreenLeft:
  ld a, b
  ldh [hPlayerX], a
  jr .canCactusDriftCenterX
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
  ldh a, [hPlayerBalloonTurningTile2]
  ld [wPlayerBalloonOAM+2], a
  ldh a, [hPlayerBalloonTurningTile]
  ld [wPlayerBalloonOAM+6], a
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
  ldh a, [hPlayerBalloonTile]
  ld hl, wPlayerBalloonOAM+2
  ld [hl], a
  ld hl, wPlayerBalloonOAM+6
  ld [hl], a
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
  ld b, 16
  sub a, b
  dec a
  cp a, SCRN_Y - WINDOW_LAYER_HEIGHT
  jr c, .moveUp
.offscreenUp:
  ld a, b
  ldh [hPlayerY], a
  jr .canCactusDriftCenterY
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
  ld b, SCRN_Y - 16 + 2 - WINDOW_LAYER_HEIGHT ; 16 = height of 2 sprites, 2 = free space bottom of cactus
  cp a, b
  jr c, .moveDown
.offscreenDown:
  ld a, b
  ldh [hPlayerY], a
  jr .canCactusDriftCenterY
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
  ; No pausing if screen is white
  ldh a, [rBGP]
  cp a, 0
  jr z, .endStart
  ld a, PAUSE_TOGGLED
  ldh [hPaused], a
  call ShowPlayerBalloon
  call ShowPlayerCactus
.endStart:

.AButton:
  ld a, d
	and PADF_A
	jr z, .endA
  ldh a, [hPlayerAttack]
  cp a, PLAYER_SPECIAL_FULL
  jr nz, .endA
.activateAttack:
  ld a, PLAYER_SPECIAL_EMPTY
  ldh [hPlayerAttack], a
  call SpawnBullet
.endA:

.BButton:
  ld a, d
  and PADF_B
	; jr z, .endB ; last button in controls, just ret
  ret z
  ldh a, [hPlayerBoost]
  cp a, PLAYER_SPECIAL_FULL
  ; jr nz, .endB ; last button in controls, just ret
  ret nz
.activateBoost:
  ld a, PLAYER_SPECIAL_EMPTY
  ldh [hPlayerBoost], a
  ld hl, hPlayerSpeed
  ld [hl], PLAYER_DEFAULT_SPEED * 2
  ; call BoostSound ; last button in controls, just jp
  jp BoostSound
.endB:
  ; ret ; never reaches here

PopPlayerBalloonAnimation:
  ldh a, [hPlayerPoppingTimer]
  inc	a
  ldh [hPlayerPoppingTimer], a
  dec a
  and PLAYER_POPPING_BALLOON_ANIMATION_TIME
  ret nz
  ; Find our frame
  ldh a, [hPlayerPoppingFrame]
.frame0:
  cp a, 0
  jr nz, .frame1
  ld b, POP_BALLOON_FRAME_0_TILE
  jr .updateFrame
.frame1:
  cp a, 1
  jr nz, .frame2
  ld b, POP_BALLOON_FRAME_1_TILE
  jr .updateFrame
.frame2:
  ; Reset variables
  ldh a, [hPlayerFlags]
  res PLAYER_FLAG_DYING_BIT, a
  ldh [hPlayerFlags], a
  ; Clear player balloon
  xor a ; ld a, 0
  ld hl, wPlayerBalloonOAM
  ld bc, PLAYER_BALLOON_OAM_BYTES
  jp ResetHLInRange
.updateFrame:
  ; Point hl to enemy oam
  ld hl, wPlayerBalloonOAM + 2
  ; Left sprite
  ld a, b
  ld [hli], a
  ld a, OAMF_PAL0
  ld [hli], a
  inc l
  inc l
  ; Right sprite
  ld a, b
  ld [hli], a
  ld a, OAMF_PAL0 | OAMF_XFLIP
  ld [hl], a
  ; Next frame
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
  ldh a, [hPlayerFlags]
  and PLAYER_FLAG_ALIVE_MASK
  ret z
  ; Death of player
  ldh a, [hPlayerFlags]
  res PLAYER_FLAG_ALIVE_BIT, a
  set PLAYER_FLAG_DYING_BIT, a
  ldh [hPlayerFlags], a
  ldh a, [hPlayerLives]
  dec a
  ldh [hPlayerLives], a
  ; Speed now for falling speed
  ld a, 1
  ldh [hPlayerSpeed], a
  ; Screaming cactus
  ld hl, wPlayerCactusOAM+2
  ld [hl], PLAYER_CACTUS_SCREAMING_TILE
  ld hl, wPlayerCactusOAM+6
  ld [hl], PLAYER_CACTUS_SCREAMING_TILE
  ; Sound
  call PopSound
  jp FallingSound

CollisionWithPlayerCactus::
  ; Check if player is invincible
  ldh a, [hPlayerInvincible]
  cp a, 0
  ret nz
  ldh a, [hPlayerFlags]
  and PLAYER_FLAG_ALIVE_MASK
  ret z
  ; Stun player
  ldh a, [hPlayerStunnedTimer]
  cp a, 0
  ret nz
  ld a, PLAYER_STUNNED_TIME
  ldh [hPlayerStunnedTimer], a
  jp HitSound

ShowPlayerCactus:
  ldh a, [hPlayerCactusTile]
  ld hl, wPlayerCactusOAM+2
  ld [hl], a
  ld hl, wPlayerCactusOAM+6
  ld [hl], a
  ret

ShowPlayerBalloon:
  ldh a, [hPlayerBalloonTile]
  ld hl, wPlayerBalloonOAM+2
  ld [hl], a
  ld hl, wPlayerBalloonOAM+6
  ld [hl], a
  ret

HidePlayerCactus:
  ld a, WHITE_SPR_TILE
  ld hl, wPlayerCactusOAM+2
  ld [hl], a
  ld hl, wPlayerCactusOAM+6
  ld [hl], a
  ret

HidePlayerBalloon:
  ld a, WHITE_SPR_TILE
  ld hl, wPlayerBalloonOAM+2
  ld [hl], a
  ld hl, wPlayerBalloonOAM+6
  ld [hl], a
  ret

; *************************************************************
; UPDATE
; *************************************************************
PlayerUpdate::

  ;
  ; Check alive
  ;
  ldh a, [hPlayerFlags]
  and PLAYER_FLAG_ALIVE_MASK
  jr nz, .isAlive
  ; Is popped
  ;
  ; Check respawn
  ;
  ldh a, [hPlayerRespawnTimer]
  inc a
  ldh [hPlayerRespawnTimer], a
  cp a, PLAYER_RESPAWN_TIME
  jr z, .respawning
  ; Is popping (animating still)
  ; -- Balloon
  ldh a, [hPlayerFlags]
  and PLAYER_FLAG_DYING_MASK
  call nz, PopPlayerBalloonAnimation
  ; -- Cactus
  ld a, SCRN_X
  ld hl, hPlayerY2
  cp a, [hl]
  ret c
  ; -- Cactus continue falling
  ldh a, [hGlobalTimer]
  and %00000001
  ret nz
  ldh a, [hPlayerSpeed]
  inc a 
  ldh [hPlayerSpeed], a
  ld b, 4
  call DIVISION
  ld b, a
  ldh a, [hPlayerY2]
  add a, b
  ldh [hPlayerY2], a
  jp UpdateCactusPosition
.respawning:
  ldh a, [hPlayerLives]
  cp a, 0
  jr nz, .respawn
  ; No more lives => Game Over
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

  ;
  ; Check stunned
  ;
  ldh a, [hPlayerStunnedTimer]
  cp a, 0
  jr z, .endCheckStunned
  ; Is stunned
  dec a
  ldh [hPlayerStunnedTimer], a
  and PLAYER_STUNNED_SLOW_TIME
  jr nz, .endCheckStunned
.blinking:
  ld hl, wPlayerCactusOAM + 2
  ld a, [hl]
  cp a, WHITE_SPR_TILE
  jr z, .blinkOn
.blinkOff:
  call HidePlayerCactus
  jr .endCheckStunned
.blinkOn:
  call ShowPlayerCactus
.endCheckStunned:

  ;
  ; Check invincible
  ;
  ldh a, [hPlayerInvincible]
  cp a, 0
  jr z, .endInvincible
  ; Is invincible
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
  call HidePlayerBalloon
  call HidePlayerCactus
  jr .endInvincible
.noBlink:
  call ShowPlayerBalloon
  call ShowPlayerCactus
.endInvincible:

  ;
  ; Check move
  ;
  ldh a, [hGlobalTimer]
	and	PLAYER_MOVE_TIME
  jr nz, .endMove
  ldh a, [hPlayerStunnedTimer]
  cp a, 0
  jr nz, .endMove
  ; Can move
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

  ;
  ; Check boost
  ;
  ldh a, [hPlayerBoost]
  cp a, PLAYER_SPECIAL_FULL
  jr z, .endBoost
  ; Is charging
  dec a
  ldh [hPlayerBoost], a
  cp a, PLAYER_BOOST_EFFECT_ENDS
  jr nz, .endBoost
  ; Reset boost
  ld a, PLAYER_DEFAULT_SPEED
  ldh [hPlayerSpeed], a
.endBoost:

  ;
  ; Check attack
  ;
  ldh a, [hPlayerAttack]
  cp a, PLAYER_SPECIAL_FULL
  jr z, .endAttack
  ; Is charging
  dec a
  ldh [hPlayerAttack], a
.endAttack:
  ret