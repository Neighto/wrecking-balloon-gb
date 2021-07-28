INCLUDE "hardware.inc"

SECTION "player", ROMX

PLAYER_START_X EQU 80
PLAYER_START_Y EQU 80
PLAYER_BALLOON_START_Y EQU (PLAYER_START_Y-16)
PLAYER_MAX_DRIFT_X EQU 2

UpdateBalloonPosition:
  ld hl, player_balloon
  ; Update Y
  ld a, [player_y]
  ld [hli], a
  ; Update X
  ld a, [player_x]
  ld [hl], a

  ld hl, player_balloon+4
  ; Update Y
  ld a, [player_y]
  ld [hli], a
  ; Update X
  ld a, [player_x]
  add 8
  ld [hl], a
  ret

UpdateCactusPosition:
  ld hl, player_cactus
  ; Update Y
  ld a, [player_cactus_y]
  ld [hli], a
  ; Update X
  ld a, [player_cactus_x]
  ld [hl], a

  ld hl, player_cactus+4
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
  ld hl, player_balloon
  ld [hl], PLAYER_BALLOON_START_Y
  inc l
  ld [hl], PLAYER_START_X
  inc l
  ld [hl], $82
  inc l
  ld [hl], %00000000
  ; Balloon right
  ld hl, player_balloon+4
  ld [hl], PLAYER_BALLOON_START_Y
  inc l
  ld [hl], PLAYER_START_X+8
  inc l
  ld [hl], $82
  inc l
  ld [hl], %00100000
  ; Cactus left
  ld hl, player_cactus
  ld [hl], PLAYER_START_Y
  inc l
  ld [hl], PLAYER_START_X
  inc l
  ld [hl], $80
  inc l
  ld [hl], %00000000
  ; Cactus right
  ld hl, player_cactus+4
  ld [hl], PLAYER_START_Y
  inc l
  ld [hl], PLAYER_START_X+8
  inc l
  ld [hl], $80
  inc l
  ld [hl], %00100000
  ret

IncrementPosition:
  ; hl = address
  ; a = amount
  add [hl]
  ld [hl], a
  ret

DecrementPosition:
  ; hl = address
  ; a = amount
  cpl 
  inc a
  add [hl]
  ld [hl], a
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

MoveCactusDriftLeft:
  ; Move left until limit is reached
  ld a, [player_drift_timer]
  inc	a
  ld [player_drift_timer], a
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

MoveCactusDriftRight:
  ; Move right until limit is reached
  ld a, [player_drift_timer]
  inc	a
  ld [player_drift_timer], a
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

MoveCactusDriftCenter:
  ; Move back to center
  ld a, [player_drift_timer]
  inc	a
  ld [player_drift_timer], a
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

BobCactusUp:
  ld hl, player_cactus_y
  ld a, 1
  call DecrementPosition
  ret

BobCactusDown:
  ld hl, player_cactus_y
  ld a, 1
  call IncrementPosition
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

PlayerMovement:
  ld a, [movement_timer]
	and	%00000011
	jr nz, .end
	call ReadInput
  ; Right
	ld a, [joypad_down]
	call JOY_RIGHT
	jr z, .endRight
	call MoveRight
.endRight:
  ; Left
  ld a, [joypad_down]
	call JOY_LEFT
	jr z, .endLeft
	call MoveLeft
.endLeft:
  ; Up
  ld a, [joypad_down]
	call JOY_UP
	jr z, .endUp
	call MoveUp
.endUp:
  ; Down
  ld a, [joypad_down]
	call JOY_DOWN
	jr z, .endDown
	call MoveDown
.endDown:
  ; Drift to center if Left / Right not held
  ; TODO: clean up quite inefficient
  ld a, [joypad_down]
	call JOY_RIGHT
	jr nz, .endDriftToCenter
  ld a, [joypad_down]
	call JOY_LEFT
  jr nz, .endDriftToCenter
  call MoveCactusDriftCenter
.endDriftToCenter:
  ; A
  ld a, [joypad_down]
	call JOY_A
	jr z, .endA
  ; Do something
.endA:
  ; B
  ld a, [joypad_down]
	call JOY_B
	jr z, .endB
  call SpeedUp
  jr .end
.endB:
  call ResetSpeedUp
.end:
  call UpdatePlayerPosition
  ret

PlayerAnimate:
  ; Lift up and down slowly
  ld a, [player_bob_timer]
  inc	a
  ld [player_bob_timer], a
  and	%01111111
  jr nz, .end
  ld a, [player_bobbed_up]
  and 1
  jr nz, .bobDown
.bobUp:
  ld a, 1
  ld [player_bobbed_up], a
  call BobCactusUp
  ret
.bobDown:
  ld a, 0
  ld [player_bobbed_up], a
  call BobCactusDown
.end
  ret

PlayerUpdate::
  call PlayerMovement
  call PlayerAnimate
  ret