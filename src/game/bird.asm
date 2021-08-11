INCLUDE "points.inc"
INCLUDE "constants.inc"

SECTION "bird", ROMX

BIRD_START_X EQU 135
BIRD_START_Y EQU 120

UpdateBirdPosition:
    ld hl, bird
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    ld [hl], a
  
    ld hl, bird+4
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    add 8
    ld [hl], a

    ld hl, bird+8
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    add 16
    ld [hl], a
    ret

InitializeBird::
    ; Set variables
    xor a ; ld a, 0
    ld hl, bird_flapping_frame
    ld [hl], a
    ld hl, bird_x
    ld [hl], BIRD_START_X
    ld hl, bird_y
    ld [hl], BIRD_START_Y

    ; Bird left
    ld hl, bird
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], %00000000
    ; Bird middle
    ld hl, bird+4
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 8
    ld [hli], a
    ld [hl], $94
    inc l
    ld [hl], %00000000
    ; Bird top
    ld hl, bird+8
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 16
    ld [hli], a
    ld [hl], $96
    inc l
    ld [hl], %00000000
    ret

SpawnBird:
    xor a ; ld a, 0
    ld [bird_respawn_timer], a    
    call InitializeBird
    ret

MoveBirdLeft:
    ld hl, bird_x
    ld a, 1
    call DecrementPosition
    ret 

MoveBird:
    call MoveBirdLeft
    call UpdateBirdPosition
    ret

BirdAnimate:
    ld a, [global_timer]
    and 15
    jr nz, .frame1 ;should be .end

    ; Can do next frame
    ; Check what frame we are on
    ; ld a, [enemy_popping_frame]
    ; cp a, 1
    ; jp z, .frame1
    ; cp a, 2
    ; jp z, .clear
    ; ret

.frame0:
    ld hl, bird+6
    ld [hl], $98
    ld hl, bird+10
    ld [hl], $9A
    ret
.frame1:
    ld hl, bird+6
    ld [hl], $94
    ld hl, bird+10
    ld [hl], $96
.end:
    ret

BirdUpdate::
    ; Check if we can move
    ld a, [global_timer]
    and	ENEMY_SPRITE_MOVE_WAIT_TIME
    jr nz, .end
    call MoveBird
    call BirdAnimate
.end
    ret