INCLUDE "points.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "bird", ROMX

BIRD_SPRITE_MOVE_WAIT_TIME EQU %00000011
BIRD_SPRITE_FALLING_TIME EQU %00001111
BIRD_START_LEFT_X EQU 0
BIRD_START_RIGHT_X EQU 160
BIRD_SPAWN_A EQU 20
BIRD_SPAWN_B EQU 50
BIRD_SPAWN_C EQU 80
BIRD_SPAWN_D EQU 110
BIRD_HORIZONTAL_SPEED EQU 2
BIRD_VERTICAL_SPEED EQU 1
BIRD_FLAP_UP_SPEED EQU 5

UpdateBirdPosition:
    push hl
    push af
    SET_HL_TO_ADDRESS wOAM, wBirdOAM
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+4, wBirdOAM
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    add 8
    ld [hl], a

    SET_HL_TO_ADDRESS wOAM+8, wBirdOAM
    ; Update Y
    ld a, [bird_y]
    ld [hli], a
    ; Update X
    ld a, [bird_x]
    add 16
    ld [hl], a
    pop af
    pop hl
    ret

SetSpawnPoint:
    push hl
    push af
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
    jr .end
.spawnB:
    ld [hl], BIRD_SPAWN_B
    jr .end
.spawnC:
    ld [hl], BIRD_SPAWN_C
    jr .end
.spawnD:
    ld [hl], BIRD_SPAWN_D
.end:
    pop af
    pop hl
    ret

InitializeBird::
    push af
    xor a ; ld a, 0
    ld [bird_flapping_frame], a
    ld [bird_alive], a
    ld [bird_respawn_timer], a
    ld [bird_falling], a
    ld [bird_spawn_right], a
    ld [bird_x], a
    ld [bird_y], a
    ld a, BIRD_HORIZONTAL_SPEED
    ld [bird_speed], a
    pop af
    ret

SpawnBirdRight:
    push hl
    push af
    ld hl, bird_x
    ld [hl], BIRD_START_RIGHT_X
    call SetSpawnPoint
    xor a ; ld a, 0
    ld [bird_flapping_frame], a
    ld [bird_respawn_timer], a
    ld [bird_falling], a
    ld a, 1
    ld [bird_alive], a
    ld [bird_spawn_right], a

    ; Request OAM
    ld b, 3
    call RequestOAMSpaceOffset
    ld [wBirdOAM], a

    ; Bird left
    SET_HL_TO_ADDRESS wOAM, wBirdOAM
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], %00000000
    ; Bird middle
    inc l
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 8
    ld [hli], a
    ld [hl], $98
    inc l
    ld [hl], %00000000
    ; Bird right
    inc l
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 16
    ld [hli], a
    ld [hl], $9A
    inc l
    ld [hl], %00000000
    pop af
    pop hl
    ret

SpawnBirdLeft:
    push hl
    push af
    ld hl, bird_x
    ld [hl], BIRD_START_LEFT_X
    call SetSpawnPoint
    xor a ; ld a, 0
    ld [bird_flapping_frame], a
    ld [bird_respawn_timer], a
    ld [bird_falling], a
    ld [bird_spawn_right], a
    ld a, 1
    ld [bird_alive], a

    ; Request OAM
    ld b, 3
    call RequestOAMSpaceOffset
    ld [wBirdOAM], a

    ; Bird left
    SET_HL_TO_ADDRESS wOAM, wBirdOAM
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    ld [hli], a
    ld [hl], $9A
    inc l
    ld [hl], OAMF_XFLIP
    ; Bird middle
    inc l
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 8
    ld [hli], a
    ld [hl], $98
    inc l
    ld [hl], OAMF_XFLIP
    ; Bird right
    inc l
    ld a, [bird_y]
    ld [hli], a
    ld a, [bird_x]
    add 16
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], OAMF_XFLIP
    pop af
    pop hl
    ret

SpawnBird:
    ; TODO: Would be funny if it came from one side then the other - clearly just one bird
    push af
    ld a, 2
    call RANDOM
    cp a, 0
    call z, SpawnBirdLeft
    cp a, 1
    call z, SpawnBirdRight
    pop af
    ret

BirdAnimate:
    push hl
    push af
    ld a, [bird_flapping_frame]
    cp a, 0
    jr nz, .frame1
.frame0:
    ld a, [global_timer]
    and 7 ; bird_flapping_speed
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+6, wBirdOAM
    ld [hl], $98
    ld a, [bird_spawn_right]
    cp a, 0
    jr nz, .frame0FacingLeft
    SET_HL_TO_ADDRESS wOAM+2, wBirdOAM
    jr .frame0FacingEnd
.frame0FacingLeft:
    SET_HL_TO_ADDRESS wOAM+10, wBirdOAM
.frame0FacingEnd:
    ld [hl], $9A
    ld hl, bird_flapping_frame
    ld [hl], 1
    jr .end
.frame1:
    ld a, [global_timer]
    and %00111111 ; bird_flapping_speed
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+6, wBirdOAM
    ld [hl], $94
    ld a, [bird_spawn_right]
    cp a, 0
    jr nz, .frame1FacingLeft
    SET_HL_TO_ADDRESS wOAM+2, wBirdOAM
    jr .frame1FacingEnd
.frame1FacingLeft:
    SET_HL_TO_ADDRESS wOAM+10, wBirdOAM
.frame1FacingEnd:
    ld [hl], $96
    ld hl, bird_flapping_frame
    ld [hl], 0
    DECREMENT_POS bird_y, BIRD_FLAP_UP_SPEED
.end:
    pop af
    pop hl
    ret

ClearBird:
    ; todo make a clear function or macro
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wBirdOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

BirdUpdate::
    push hl
    push bc
    push af
    ; Check if alive
    ld a, [bird_alive]
    and 1
    jr z, .isDead
    ; Check if we can move
    ld a, [global_timer]
    and	BIRD_SPRITE_MOVE_WAIT_TIME
    jp nz, .end
    ld a, [bird_spawn_right]
    and 1
    jr z, .moveRight
.moveLeft:
    DECREMENT_POS bird_x, [bird_speed]
    jr .moveDown
.moveRight:
    INCREMENT_POS bird_x, [bird_speed]
.moveDown:
    ld a, [global_timer]
    and BIRD_SPRITE_FALLING_TIME
    jr nz, .moveEnd
    INCREMENT_POS bird_y, BIRD_VERTICAL_SPEED
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
.offscreen:
    xor a ; ld a, 0
    ld [bird_alive], a
.isDead:
    ; Fall
    ld a, [bird_falling]
    cp a, 0
    jr z, .respawning
    ld a, [global_timer]
    and	%00000001
    jr nz, .respawning
    INCREMENT_POS bird_y, 2
    call UpdateBirdPosition
.respawning:
    ; Can we respawn
    ld a, [bird_respawn_timer]
    inc a
    ld [bird_respawn_timer], a
    cp a, 120
    jr nz, .end
    call ClearBird
    call SpawnBird
.end:
    pop af
    pop bc
    pop hl
    ret

DeathOfBird::
    ; Death
    xor a ; ld a, 0
    ld [bird_alive], a
    ld a, 1
    ld [bird_falling], a
    ; Screaming bird
    SET_HL_TO_ADDRESS wOAM+2, wBirdOAM
    ld [hl], $A6
    SET_HL_TO_ADDRESS wOAM+6, wBirdOAM
    ld [hl], $A8
    SET_HL_TO_ADDRESS wOAM+10, wBirdOAM
    ld [hl], $AA
    ; Sound
    call ExplosionSound
    ret
