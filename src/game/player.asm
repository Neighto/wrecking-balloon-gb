SECTION "player", ROMX

INCLUDE "hardware.inc"

PLAYER_START_X EQU (160 / 2 - 20)
PLAYER_START_Y EQU (144 / 2 + 16)
PLAYER_BALLOON_START_Y EQU (PLAYER_START_Y - 16)

player_sprite_init::
  ; Set variables
  ld HL, player_x
  ld [HL], PLAYER_START_X
  ld HL, player_y
  ld [HL], PLAYER_START_Y
  ; Set Attributes
  ; BALLOON *****
  ; Top left
  ld HL, wShadowOAM
  ld [HL], PLAYER_BALLOON_START_Y
  inc L
  ld [HL], PLAYER_START_X
  inc L
  ld [HL], $84
  inc L
  ld [HL], %00000000
  ; Top right
  ld HL, wShadowOAM+4
  ld [HL], PLAYER_BALLOON_START_Y
  inc L
  ld [HL], PLAYER_START_X + 8
  inc L
  ld [HL], $84
  inc L
  ld [HL], %00100000
  ; Bottom right
  ld HL, wShadowOAM+8
  ld [HL], PLAYER_BALLOON_START_Y + 8
  inc L
  ld [HL], PLAYER_START_X + 8
  inc L
  ld [HL], $83
  inc L
  ld [HL], %00100000
  ; Bottom left
  ld HL, wShadowOAM+12
  ld [HL], PLAYER_BALLOON_START_Y + 8
  inc L
  ld [HL], PLAYER_START_X
  inc L
  ld [HL], $83
  inc L
  ld [HL], %00000000
  ; CACTUS *****
  ; Top left
  ld HL, wShadowOAM+16
  ld [HL], PLAYER_START_Y
  inc L
  ld [HL], PLAYER_START_X
  inc L
  ld [HL], $82
  inc L
  ld [HL], %00000000
  ; Top right
  ld HL, wShadowOAM+20
  ld [HL], PLAYER_START_Y
  inc L
  ld [HL], PLAYER_START_X + 8
  inc L
  ld [HL], $82
  inc L
  ld [HL], %00100000
  ; Bottom right
  ld HL, wShadowOAM+24
  ld [HL], PLAYER_START_Y + 8
  inc L
  ld [HL], PLAYER_START_X + 8
  inc L
  ld [HL], $81
  inc L
  ld [HL], %00100000
  ; Bottom left
  ld HL, wShadowOAM+28
  ld [HL], PLAYER_START_Y + 8
  inc L
  ld [HL], PLAYER_START_X
  inc L
  ld [HL], $81
  inc L
  ld [HL], %00000000
  ret

  SECTION "player_vars", WRAM0
  player_x:: DS 1
  player_y:: DS 1