INCLUDE "points.inc"
INCLUDE "constants.inc"

SECTION "bird", ROMX

BIRD_START_X EQU 135
BIRD_START_Y EQU 80

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
    ld [hl], $98
    inc l
    ld [hl], %00000000
    ; Bird top
    ld hl, bird+8
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 16
    ld [hli], a
    ld [hl], $9A
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
    ld a, 2
    call DecrementPosition
    ret 

MoveBirdDown:
    ld hl, bird_y
    ld a, 1
    call IncrementPosition
    ret

MoveBirdUp:
    ld hl, bird_y
    ld a, 5
    call DecrementPosition
    ret

BirdAnimate:
    ld a, [bird_flapping_frame]
    cp a, 0
    jr nz, .frame1
.frame0:
    ld a, [global_timer]
    and 7 ; bird_flapping_speed
    jp nz, .end
    ld hl, bird+6
    ld [hl], $98
    ld hl, bird+10
    ld [hl], $9A
    ld hl, bird_flapping_frame
    ld [hl], 1
    ret
.frame1:
    ld a, [global_timer]
    and %00111111 ; bird_flapping_speed
    jp nz, .end
    ld hl, bird+6
    ld [hl], $94
    ld hl, bird+10
    ld [hl], $96
    ld hl, bird_flapping_frame
    ld [hl], 0
    ; call MoveBirdUp
.end:
    ret

BirdUpdate::
    ; Check if we can move
    ld a, [global_timer]
    and	BIRD_SPRITE_MOVE_WAIT_TIME
    jr nz, .end
    call MoveBirdLeft
    call BirdAnimate
    ld a, [global_timer]
    and BIRD_SPRITE_FALLING_TIME
    jr nz, .end
    ; call MoveBirdDown
.end
    call UpdateBirdPosition
    ret