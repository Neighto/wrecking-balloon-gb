SECTION "player", ROMX

INCLUDE "hardware.inc"

PLAYER_START_X EQU 80
PLAYER_START_Y EQU 80
PLAYER_BALLOON_START_Y EQU (PLAYER_START_Y-16)

InitializePlayer::
  ; Set variables
  ld hl, player_x
  ld [hl], PLAYER_START_X
  ld hl, player_y
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
  ld a, [player_speed]
  add [hl]
  ld [hl], a
  ret

DecrementPosition:
  ; hl = address
  ld a, [player_speed]
  cpl 
  inc a
  add [hl]
  ld [hl], a
  ret

MoveBalloonUp:
  ld hl, player_balloon
  call DecrementPosition
  ld hl, player_balloon+4
  call DecrementPosition
  ret

MoveBalloonRight:
  ld hl, player_balloon+1
  call IncrementPosition
  ld hl, player_balloon+5
  call IncrementPosition
  ret 

MoveBalloonLeft:
  ld hl, player_balloon+1
  call DecrementPosition
  ld hl, player_balloon+5
  call DecrementPosition
  ret

MoveBalloonDown:
  ld hl, player_balloon
  call IncrementPosition
  ld hl, player_balloon+4
  call IncrementPosition
  ret

MoveCactusUp:
  ld hl, player_cactus
  call DecrementPosition
  ld hl, player_cactus+4
  call DecrementPosition
  ret

MoveCactusRight:
  ld hl, player_cactus+1
  call IncrementPosition
  ld hl, player_cactus+5
  call IncrementPosition
  ret

MoveCactusLeft:
  ld hl, player_cactus+1
  call DecrementPosition
  ld hl, player_cactus+5
  call DecrementPosition
  ret

MoveCactusDown:
  ld hl, player_cactus
  call IncrementPosition
  ld hl, player_cactus+4
  call IncrementPosition
  ret

MoveRight:
  call MoveBalloonRight
  call MoveCactusRight
  ret

MoveLeft:
  call MoveBalloonLeft
  call MoveCactusLeft
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
	inc	a
	ld [movement_timer], a
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
  ret
.endB:
  call ResetSpeedUp
.end:
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
  call MoveCactusUp
  ret
.bobDown:
  ld a, 0
  ld [player_bobbed_up], a
  call MoveCactusDown
.end
  ret

PlayerUpdate::
  call PlayerMovement
  call PlayerAnimate
  ret