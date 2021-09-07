INCLUDE "points.inc"

SECTION "bird", ROMX

BIRD_SPRITE_MOVE_WAIT_TIME EQU %00000011
BIRD_SPRITE_FALLING_TIME EQU %00001111
BIRD_START_LEFT_X EQU 0
BIRD_START_RIGHT_X EQU 160
BIRD_SPAWN_A EQU 20
BIRD_SPAWN_B EQU 50
BIRD_SPAWN_C EQU 80
BIRD_SPAWN_D EQU 110

UpdateBirdPosition:
    ld hl, wBird
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    ld [hl], a
  
    ld hl, wBird+4
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    add 8
    ld [hl], a

    ld hl, wBird+8
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    add 16
    ld [hl], a
    ret

SetSpawnPoint:
    ld hl, bird_y
    ld a, 4
    call RANDOM
    cp a, 0
    jr z, .spawnA
    cp a, 1
    jr z, .spawnB
    cp a, 2
    jr z, .spawnC
    cp a, 3
    jr z, .spawnD
.spawnA:
    ld [hl], BIRD_SPAWN_A
    ret
.spawnB:
    ld [hl], BIRD_SPAWN_B
    ret
.spawnC:
    ld [hl], BIRD_SPAWN_C
    ret
.spawnD:
    ld [hl], BIRD_SPAWN_D
    ret

InitializeBird::
    ; Set variables
    xor a ; ld a, 0
    ld [bird_flapping_frame], a
    ld [bird_alive], a
    ld [bird_respawn_timer], a
    ld [bird_spawn_right], a
    ld [bird_x], a
    ld [bird_y], a
    ret

SpawnBirdRight:
    ld hl, bird_x
    ld [hl], BIRD_START_RIGHT_X
    call SetSpawnPoint
    xor a ; ld a, 0
    ld [bird_flapping_frame], a
    ld [bird_respawn_timer], a
    ld a, 1
    ld [bird_alive], a
    ld [bird_spawn_right], a
    ; Bird left
    ld hl, wBird
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], %00000000
    ; Bird middle
    ld hl, wBird+4
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 8
    ld [hli], a
    ld [hl], $98
    inc l
    ld [hl], %00000000
    ; Bird right
    ld hl, wBird+8
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 16
    ld [hli], a
    ld [hl], $9A
    inc l
    ld [hl], %00000000
    ret

SpawnBirdLeft:
    ld hl, bird_x
    ld [hl], BIRD_START_LEFT_X
    call SetSpawnPoint
    xor a ; ld a, 0
    ld [bird_flapping_frame], a
    ld [bird_respawn_timer], a
    ld [bird_spawn_right], a
    ld a, 1
    ld [bird_alive], a
    ; Bird left
    ld hl, wBird
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    ld [hli], a
    ld [hl], $9A
    inc l
    ld [hl], %00100000
    ; Bird middle
    ld hl, wBird+4
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 8
    ld [hli], a
    ld [hl], $98
    inc l
    ld [hl], %00100000
    ; Bird right
    ld hl, wBird+8
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 16
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], %00100000
    ret

SpawnBird:
    ; TODO: Would be funny if it came from one side then the other - clearly just one bird
    ld a, 2
    call RANDOM
    cp a, 0
    call z, SpawnBirdLeft
    cp a, 1
    call z, SpawnBirdRight
    ret

MoveBirdLeft:
    ld hl, bird_x
    ld a, 2
    call DecrementPosition
    ret

MoveBirdRight:
    ld hl, bird_x
    ld a, 2
    call IncrementPosition
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
    ld hl, wBird+6
    ld [hl], $98
    ld a, [bird_spawn_right]
    cp a, 0
    jr nz, .frame0FacingLeft
    ld hl, wBird+2
    jr .frame0FacingEnd
.frame0FacingLeft:
    ld hl, wBird+10
.frame0FacingEnd:
    ld [hl], $9A
    ld hl, bird_flapping_frame
    ld [hl], 1
    ret
.frame1:
    ld a, [global_timer]
    and %00111111 ; bird_flapping_speed
    jp nz, .end
    ld hl, wBird+6
    ld [hl], $94
    ld a, [bird_spawn_right]
    cp a, 0
    jr nz, .frame1FacingLeft
    ld hl, wBird+2
    jr .frame1FacingEnd
.frame1FacingLeft:
    ld hl, wBird+10
.frame1FacingEnd:
    ld [hl], $96
    ld hl, bird_flapping_frame
    ld [hl], 0
    call MoveBirdUp
.end:
    ret

BirdUpdate::
    ; Check if alive
    ld a, [bird_alive]
    and 1
    jr z, .isDead
    ; Check if we can move
    ld a, [global_timer]
    and	BIRD_SPRITE_MOVE_WAIT_TIME
    jr nz, .end
    ld a, [bird_spawn_right]
    and 1
    jr z, .moveRight
.moveLeft:
    call MoveBirdLeft
    jr .moveDown
.moveRight:
    call MoveBirdRight
.moveDown:
    ld a, [global_timer]
    and BIRD_SPRITE_FALLING_TIME
    jr nz, .moveEnd
    call MoveBirdDown
.moveEnd:
    call BirdAnimate
    call UpdateBirdPosition
.checkOffscreen:
    ld a, [bird_x]
    ; TODO: Might want to adjust x for if facing left / right
    ld b, a
    call OffScreenXEnemies
    and 1
    jr z, .end
.died:
    xor a ; ld a, 0
    ld [bird_alive], a
    ret ; Maybe remove
.isDead:
    ; TODO add respawn timer
    call SpawnBird
.end:
    ret