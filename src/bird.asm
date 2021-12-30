INCLUDE "points.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

BIRD_SPRITE_MOVE_WAIT_TIME EQU %00000011
BIRD_SPRITE_DESCENDING_TIME EQU %00001111
BIRD_FALLING_WAIT_TIME EQU %00000001
BIRD_START_LEFT_X EQU 0
BIRD_START_RIGHT_X EQU 160
BIRD_SPAWN_A EQU 20
BIRD_SPAWN_B EQU 50
BIRD_SPAWN_C EQU 80
BIRD_SPAWN_D EQU 110
BIRD_HORIZONTAL_SPEED EQU 2
BIRD_VERTICAL_SPEED EQU 1
BIRD_FLAP_UP_SPEED EQU 5
BIRD_RESPAWN_TIME EQU 80

SECTION "bird vars", WRAM0
    wBirdOAM:: DB
    bird_x:: DB
    bird_y:: DB
    bird_flapping_frame:: DB
    bird_respawn_timer:: DB
    bird_falling:: DB
    bird_alive:: DB
    bird_spawn_right:: DB
    bird_speed:: DB

SECTION "bird", ROMX

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
    call RequestOAMSpace
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
    call RequestOAMSpace
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

BirdMovement:
    ld a, [global_timer]
    and	BIRD_SPRITE_MOVE_WAIT_TIME
    jr nz, .end
    ld a, [bird_spawn_right]
    cp a, 0
    jr z, .moveRight
.moveLeft:
    DECREMENT_POS bird_x, [bird_speed]
    jr .moveDown
.moveRight:
    INCREMENT_POS bird_x, [bird_speed]
.moveDown:
    ld a, [global_timer]
    and BIRD_SPRITE_DESCENDING_TIME
    jr nz, .moveEnd
    INCREMENT_POS bird_y, BIRD_VERTICAL_SPEED
.moveEnd:
    call BirdAnimate
    call UpdateBirdPosition
.end:
    ret

BirdFalling:
    ld a, [bird_falling]
    cp a, 0
    jr z, .end
    ld a, [global_timer]
    and BIRD_FALLING_WAIT_TIME
    jr nz, .end
    INCREMENT_POS bird_y, 2
    call UpdateBirdPosition
.checkOffscreenY:
    ld a, [bird_y]
    ld b, a
    call OffScreenYEnemies
    cp a, 0
    jr z, .end
    xor a ; ld a, 0
    ld [bird_falling], a
    call ClearBird
.end:
    ret

BirdUpdate:: ; I wonder if these updates should all have a timer cooldown?
    push hl
    push bc
    push af
.checkAlive:
    ld a, [bird_alive]
    cp a, 0
    jr z, .isDead
    call BirdMovement
.checkOffscreenX:
    ld a, [bird_x]
    ld b, a
    call OffScreenXEnemies
    cp a, 0
    jr z, .end
    call ClearBird
    xor a ; ld a, 0
    ld [bird_alive], a
    jr .end
.isDead:
    call BirdFalling
.respawning:
    ld a, [bird_falling]
    cp a, 0
    jr nz, .end
    ld a, [bird_respawn_timer]
    inc a
    ld [bird_respawn_timer], a
    cp a, BIRD_RESPAWN_TIME
    jr nz, .end
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
    ; Sound
    call ExplosionSound
    ; Screaming bird
    ld a, [bird_spawn_right]
    cp a, 0
    jr z, .facingRight
.facingLeft:
    SET_HL_TO_ADDRESS wOAM+2, wBirdOAM
    ld [hl], $A6
    SET_HL_TO_ADDRESS wOAM+6, wBirdOAM
    ld [hl], $A8
    SET_HL_TO_ADDRESS wOAM+10, wBirdOAM
    ld [hl], $AA
    jr .end
.facingRight:
    SET_HL_TO_ADDRESS wOAM+2, wBirdOAM
    ld [hl], $AA
    SET_HL_TO_ADDRESS wOAM+6, wBirdOAM
    ld [hl], $A8
    SET_HL_TO_ADDRESS wOAM+10, wBirdOAM
    ld [hl], $A6
.end:
    ret
