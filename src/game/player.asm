;-------------
; Player routines
;-------------
INCLUDE "hardware.inc"
SECTION "Player",ROM0

PlayerSpawnX    equ 126
PlayerSpawnY    equ 180
PlayerFlags     equ %00000000
PlayerTileBegin equ 44
PlayerTileEnd   equ 88
PlayerTilePad   equ 9
PlayerTileWidth equ 3
PlayerOAMEnd    equ 36
PlayerWidth     equ 24
PlayerHeight    equ 24
PlayerVelCap    equ 6
PlayerHP        equ 5

PlayerFSpeed    equ 8
PlayerFShoot    equ 1
PlayerFRunStart equ 2
PlayerFRunEnd   equ 6
PlayerFJump     equ 6
PlayerFIdle     equ 7
PlayerFShootAir equ 8
PlayerFShootRun equ 9

PLAYER_LOAD::
  ;init a load of crap
  ld  a,PlayerSpawnY
  ld  [player_y],a
  ld  a,PlayerSpawnX
  ld  [player_x],a
  ld  a,PlayerFJump
  ld  [player_frame],a
  ld  a,PlayerFRunStart
  ld  [player_fstart],a
  ld  a,PlayerFRunEnd
  ld  [player_fend],a
  xor a
  ld  [player_idle],a
  ld  [player_flags],a
  ld  [player_fcount],a
  ld  [player_gcount],a
  ld  [rSCX],a
  ld  [rSCY],a
  ld  a,1
  ld  [player_yvel],a
  ld  a,PlayerHP
  ld  [player_hp],a
  ret

; PLAYER_DIE:
;   ld  a,1
;   ld  [game_over],a
;   ret


PLAYER_CHECK_TOP:
  ;de = player_y/8
  xor a
  ld  d,a
  ld  b,a
  ld  a,[player_y]
  sub 8
  ld  e,a
  ld  c,8
  call DIVIDE
  
  ;y tile index
  push de

  ;de = player_x/8
  xor a
  ld  d,a
  ld  b,a
  ld  a,[player_x]
  ;sub 8
  ld  e,a
  ld  c,8
  call DIVIDE

  ;d = x, e = y tile index
  ld  d,e
  pop bc
  ld  e,c

  ;get tile value at index
  ld  c,0
  call GET_TILE
  ret

PLAYER_CHECK_SIDE:
  ;de = player_y/8
  xor a
  ld  d,a
  ld  b,a
  ld  a,[player_y]
  sub 2
  ld  e,a
  ld  c,8
  push hl
  call DIVIDE
  pop hl
  
  ;y tile index
  push de

  ;de = player_x/8
  xor a
  ld  d,a
  ld  b,a

  ;if l 0 then right else left
  ld  a,l
  cp  0
  jr  z,.right

  ld  a,[player_x]
  sub 2
  jr  .con

.right
  ld  a,[player_x]
  add 10

.con
  ld  e,a
  ld  c,8
  call DIVIDE

  ;d = x, e = y tile index
  ld  d,e
  pop bc
  ld  e,c

  ;get tile value at index
  ld  c,1
  call GET_TILE
  ret  

PLAYER_MOVE:
;   call PLAYER_SHOOT

  ;check dpad left
  ld  a,[joypad_down]
  call JOY_LEFT
  jr  z,.left

  ;check dpad left
  ld  a,[joypad_down]
  call JOY_RIGHT
  jr  z,.right

  ;set idle frame
  ld  a,1
  ld  [player_idle],a
  jr  .up

.left
  ;check left
  ld  l,1
  call PLAYER_CHECK_SIDE

  ;check if tile is empty
  cp  0
  jr  nz,.set_nonidle
  ld  a,b
  cp  0
  jr  nz,.set_nonidle

  ;move left
  ld  a,[player_x]
  sub 2
  ld  [player_x],a 
  ld  a,[player_flags]
  or  1
  ld  [player_flags],a
  jr  .set_nonidle

.right
  ;check right
  ld  l,0
  call PLAYER_CHECK_SIDE

  ;check if tile is empty
  cp  0
  jr  nz,.set_nonidle
  ld  a,b
  cp  0
  jr  nz,.set_nonidle

  ;move left
  ld  a,[player_x]
  add 2
  ld  [player_x],a
  ld  a,[player_flags]
  and 2
  ld  [player_flags],a

.set_nonidle
  xor a
  ld  [player_idle],a

.up
  ;check if grounded
  ld  a,[player_ground]
  cp  0
  jr  z,.end

  ;check dpad up
  ld  a,[joypad_pressed]
  call JOY_A
  jr  nz,.end

.end
  ret

PLAYER_UPDATE::
  ;check game won
;   ld  a,[game_won]
;   cp  0
;   jr  z,.update

;   ld  a,[joypad_pressed]
;   call JOY_START
;   jr  nz,.update

;   jp START

.update
  call PLAYER_MOVE

.end
  ret

PLAYER_OAM:
  ;load the first tile addr
  ld  a,PlayerTileBegin
  ld  [player_tile],a

  ;frame number
  ld  a,[player_frame]
  ld  b,a

.loop
  ;for each frame value
  ld  a,b
  dec a
  ld  b,a
  jr  nz,.next_frame
  jr  .check_flip

.next_frame
  ;add padding for each tile index
  ld  a,[player_tile]
  add a,PlayerTilePad
  ld  [player_tile],a
  jr  .loop

.check_flip
  ;check flags
  ld  a,[player_flags]
  and 1
  jr  z,.set_tiles

  ;offset tile value
  ld  a,[player_tile]
  add a,2
  ld  [player_tile],a

.set_tiles
  ;begin setting oam data
  ld  a,[player_tile]
  ld  b,a
  add PlayerTilePad
  ld  e,a

  ld  hl,my_sprites

  ;c is y counter
  ;d is x counter
  ld  c,0
  ld  d,0
  xor a
  ld [arb_counter],a

  ;set temp vars
  ld  a,[player_y]
  ld  [player_y_temp],a
  ld  a,[player_x]
  ld  [player_x_temp],a

.loop_set
  ;check if we are on a new row
  ld  a,c
  cp  PlayerTileWidth
  jr  nz,.set_y

  ;offset y
  ld  a,[player_y_temp]
  add a,8
  ld  [player_y_temp],a
  
  ;reset c
  xor a
  ld  c,a

.set_y
  ;y position
  ld  a,[player_y_temp]
  ld  [hli],a

  ;inc y counter
  ld  a,c
  inc a
  ld  c,a

  ld  a,d
  cp  PlayerTileWidth
  jr  nz,.set_x

  ld  d,0
  ld  a,[player_x]
  ld  [player_x_temp],a

.set_x
  ;x position
  ld  a,[player_x_temp]
  ld  [hli],a

  ;offset x
  ld  a,d
  inc a
  ld  d,a
  ld  a,[player_x_temp]
  add a,8
  ld  [player_x_temp],a

  ;check flags
  ld  a,[player_flags]
  and 1
  jr  z,.dont_flip

.flip
  ;tile
  ld  a,b
  ld  [hli],a
  dec a
  ld  b,a

  ;check if we need to reset
  ld  a,[arb_counter]
  inc a
  ld  [arb_counter],a
  cp  3
  jr  nz,.flip_flags

  ;reset?
  xor a
  ld  [arb_counter],a
  ld  a,b
  add 6
  ld  b,a

.flip_flags
  ;flags
  ld  a,%00100000
  ld  [hli],a
  jr  .end

.dont_flip
  ;tile
  ld  a,b
  ld  [hli],a
  inc a
  ld  b,a

  ;flags
  xor a
  ld  [hli],a

.end
  ;are we done yet?
  ld  a,b
  cp  e
  jr  nz,.loop_set

  ret