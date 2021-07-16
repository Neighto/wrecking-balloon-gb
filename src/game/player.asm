SECTION "player", ROMX

INCLUDE "hardware.inc"

PLAYER_START_X EQU (160 / 2 - 20)
PLAYER_START_Y EQU (144 / 2 + 16)
PLAYER_BALLOON_START_Y EQU (PLAYER_START_Y - 16)

InitializePlayer::
  ; Set variables
  ld HL, player_x
  ld [HL], PLAYER_START_X
  ld HL, player_y
  ld [HL], PLAYER_START_Y
  ld HL, player_speed
  ld [HL], 1
  ; Set Attributes
  ; BALLOON *****
  ; Top left
  ld HL, wShadowOAM
  ld [HL], PLAYER_BALLOON_START_Y
  inc L
  ld [HL], PLAYER_START_X
  inc L
  ld [HL], $82
  inc L
  ld [HL], %00000000
  ; Top right
  ld HL, wShadowOAM+4
  ld [HL], PLAYER_BALLOON_START_Y
  inc L
  ld [HL], PLAYER_START_X + 8
  inc L
  ld [HL], $82
  inc L
  ld [HL], %00100000
  ; CACTUS *****
  ; Top left
  ld HL, wShadowOAM+8
  ld [HL], PLAYER_START_Y
  inc L
  ld [HL], PLAYER_START_X
  inc L
  ld [HL], $80
  inc L
  ld [HL], %00000000
  ; Top right
  ld HL, wShadowOAM+12
  ld [HL], PLAYER_START_Y
  inc L
  ld [HL], PLAYER_START_X + 8
  inc L
  ld [HL], $80
  inc L
  ld [HL], %00100000
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

MoveRight:
  ld hl, wShadowOAM+1
  call IncrementPosition
  ld hl, wShadowOAM+5
  call IncrementPosition
  ld hl, wShadowOAM+9
  call IncrementPosition
  ld hl, wShadowOAM+13
  call IncrementPosition
  ret

MoveLeft:
  ld hl, wShadowOAM+1
  call DecrementPosition
  ld hl, wShadowOAM+5
  call DecrementPosition
  ld hl, wShadowOAM+9
  call DecrementPosition
  ld hl, wShadowOAM+13
  call DecrementPosition
  ret

MoveDown:
  ld hl, wShadowOAM
  call IncrementPosition
  ld hl, wShadowOAM+4
  call IncrementPosition
  ld hl, wShadowOAM+8
  call IncrementPosition
  ld hl, wShadowOAM+12
  call IncrementPosition
  ret

MoveUp:
  ld hl, wShadowOAM
  call DecrementPosition
  ld hl, wShadowOAM+4
  call DecrementPosition
  ld hl, wShadowOAM+8
  call DecrementPosition
  ld hl, wShadowOAM+12
  call DecrementPosition
  ret

SpeedUp:
  ld hl, player_speed
  ld [hl], 2
  ret

ResetSpeedUp:
  ld hl, player_speed
  ld [hl], 1
  ret

MoveCactusUp:
  ld hl, wShadowOAM+8
  call DecrementPosition
  ld hl, wShadowOAM+12
  call DecrementPosition
  ret

MoveCactusDown:
  ld hl, wShadowOAM+8
  call IncrementPosition
  ld hl, wShadowOAM+12
  call IncrementPosition
  ret

PlayerMovement::
  ; Timer (Stall by every 4th vblank)
  ld a, [movement_timer]
	inc	a
	ld [movement_timer], a
	and	%00000011
	jr nz, .end
	call ReadInput
  ; Right
	ld  a, [joypad_down]
	call JOY_RIGHT
	jr  z, .endRight
	call MoveRight
.endRight:
  ; Left
  ld  a, [joypad_down]
	call JOY_LEFT
	jr  z, .endLeft
	call MoveLeft
.endLeft:
  ; Up
  ld  a, [joypad_down]
	call JOY_UP
	jr  z, .endUp
	call MoveUp
.endUp:
  ; Down
  ld  a, [joypad_down]
	call JOY_DOWN
	jr  z, .endDown
	call MoveDown
.endDown:
  ; A
  ld  a, [joypad_down]
	call JOY_A
	jr  z, .endA
  call SpeedUp
  ret ; TODO: sloppy
.endA:
  call ResetSpeedUp
.end:
  ret

PlayerAnimate::
  ; Lift Up and Down Slowly
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

SECTION "player_vars", WRAM0
  player_x:: DS 1
  player_y:: DS 1