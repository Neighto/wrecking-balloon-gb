INCLUDE "points.inc"

SECTION "enemy 2", ROMX

ENEMY2_START_X EQU 160
ENEMY2_START_Y EQU 55
ENEMY2_BALLOON_START_Y EQU (ENEMY2_START_Y-16)
ENEMY2_SPAWN_A EQU 32
ENEMY2_SPAWN_B EQU 64
ENEMY2_SPAWN_C EQU 96
ENEMY2_SPAWN_D EQU 128

UpdateBalloonPosition:
    ld hl, enemy2_balloon
    ; Update Y
    ld a, [enemy2_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [enemy2_balloon_x]
    ld [hl], a
    
    ld hl, enemy2_balloon+4
    ; Update Y
    ld a, [enemy2_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [enemy2_balloon_x]
    add 8
    ld [hl], a
    ret

UpdateCactusPosition:
    ld hl, enemy2_cactus
    ; Update Y
    ld a, [enemy2_cactus_y]
    ld [hli], a
    ; Update X
    ld a, [enemy2_cactus_x]
    ld [hl], a
    
    ld hl, enemy2_cactus+4
    ; Update Y
    ld a, [enemy2_cactus_y]
    ld [hli], a
    ; Update X
    ld a, [enemy2_cactus_x]
    add 8
    ld [hl], a
    ret
    
UpdateEnemyPosition:
    call UpdateBalloonPosition
    call UpdateCactusPosition
    ret

InitializeEnemy2::
    ; Set variables
    xor a ; ld a, 0
    ld hl, enemy2_popping
    ld [hl], a
    ld hl, enemy2_popping_frame
    ld [hl], a
    ld hl, enemy2_pop_timer
    ld [hl], a
    ld hl, enemy2_falling
    ld [hl], a
    ld hl, enemy2_delay_falling_timer
    ld [hl], a
    ld hl, enemy2_falling_timer
    ld [hl], a
    ld hl, enemy2_respawn_timer
    ld [hl], a
    ld hl, enemy2_alive
    ld [hl], 1
    ld hl, enemy2_fall_speed
    ld [hl], 1
    ld hl, enemy2_balloon_x
    ld [hl], ENEMY2_START_X
    ld hl, enemy2_balloon_y
    ld [hl], ENEMY2_BALLOON_START_Y
    ld hl, enemy2_cactus_x
    ld [hl], ENEMY2_START_X
    ld hl, enemy2_cactus_y
    ld [hl], ENEMY2_START_Y

    ; Randomize spawn
.nextSpawnPoint:
    ld hl, enemy2_balloon_y
    ld a, 4
    call RANDOM
    cp a, 0
    jp z, .spawnA
    cp a, 1
    jp z, .spawnB
    cp a, 2
    jp z, .spawnC
    cp a, 3
    jp z, .spawnD
.spawnA:
    ld [hl], ENEMY2_SPAWN_A
    ld hl, enemy2_cactus_y ; TODO: Could be cleaner and only specify this once
    ld [hl], ENEMY2_SPAWN_A+16
    jr .endNextSpawnPoint
.spawnB:
    ld [hl], ENEMY2_SPAWN_B
    ld hl, enemy2_cactus_y
    ld [hl], ENEMY2_SPAWN_B+16
    jr .endNextSpawnPoint
.spawnC:
    ld [hl], ENEMY2_SPAWN_C
    ld hl, enemy2_cactus_y
    ld [hl], ENEMY2_SPAWN_C+16
    jr .endNextSpawnPoint
.spawnD:
    ld [hl], ENEMY2_SPAWN_D
    ld hl, enemy2_cactus_y
    ld [hl], ENEMY2_SPAWN_D+16
.endNextSpawnPoint:

    ; Balloon left
    ld hl, enemy2_balloon
    ld a, [enemy2_balloon_y]
    ld [hl], a
    inc l
    ld a, [enemy2_balloon_x]
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00000000
    ; Balloon right
    ld hl, enemy2_balloon+4
    ld a, [enemy2_balloon_y]
    ld [hl], a
    inc l
    ld a, [enemy2_balloon_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00100000
    ; Cactus left
    ld hl, enemy2_cactus
    ld a, [enemy2_cactus_y]
    ld [hl], a
    inc l
    ld a, [enemy2_cactus_x]
    ld [hl], a
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00000000
    ; Cactus right
    ld hl, enemy2_cactus+4
    ld a, [enemy2_cactus_y]
    ld [hl], a
    inc l
    ld a, [enemy2_cactus_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00100000
    ret

SpawnEnemy:
    xor a ; ld a, 0
    ld [enemy2_respawn_timer], a    
    call InitializeEnemy2
    ret

MoveBalloonLeft:
    ld hl, enemy2_balloon_x
    ld a, 1
    call DecrementPosition
    ret 

MoveCactusLeft:
    ld hl, enemy2_cactus_x
    ld a, 1
    call DecrementPosition
    ret

MoveBalloonDown:
    ld hl, enemy2_balloon_y
    ld a, 1
    call IncrementPosition
    ret

MoveCactusDown:
    ld hl, enemy2_cactus_y
    ld a, 1
    call IncrementPosition
    ret

MoveLeft:
    call MoveBalloonLeft
    call MoveCactusLeft
    ret

MoveDown:
    call MoveBalloonDown
    call MoveCactusDown
    ret

MoveEnemy:
    ld a, [movement_timer]
    and	%00000111
    jr nz, .end
    call MoveLeft
    call UpdateEnemyPosition
.end:
    ret

FallCactusDown:
    ld hl, enemy2_fall_speed
    ld a, [enemy2_delay_falling_timer]
    inc a
    ld [enemy2_delay_falling_timer], a
    cp a, 7
    jr c, .skipAcceleration
    xor a ; ld a, 0
    ld [enemy2_delay_falling_timer], a
    ld a, [hl]
    add a, a
    ld [hl], a
.skipAcceleration
    ld a, [hl]
    ld hl, enemy2_cactus_y
    call IncrementPosition
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [enemy2_popping_frame]
    cp a, 0
    jr z, .frame0

    ld a, [enemy2_pop_timer]
    inc	a
    ld [enemy2_pop_timer], a
    cp a, 30
    jp nz, .end

    ; Can do next frame
    ; Reset timer
    xor a ; ld a, 0
    ld [enemy2_pop_timer], a
    ; Check what frame we are on
    ld a, [enemy2_popping_frame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    ld hl, enemy2_balloon+2
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    ld hl, enemy2_balloon+6
    ld [hl], $88
    inc l
    ld [hl], %00100000
    ld hl, enemy2_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    ld hl, enemy2_balloon+2
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    ld hl, enemy2_balloon+6
    ld [hl], $8A
    inc l
    ld [hl], %00100000
    ld hl, enemy2_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    xor a ; ld a, 0
    ld hl, enemy2_balloon
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ; Reset variables
    ld hl, enemy2_popping
    ld [hl], a
    ld hl, enemy2_pop_timer
    ld [hl], a
    ld hl, enemy2_popping_frame
    ld [hl], a
.end:
    ret

CactusFalling:
    ld a, [enemy2_falling_timer]
    inc a
    ld [enemy2_falling_timer], a
    and %00000101
    jr nz, .end
    ; Can we move cactus down
    ld a, 160
    ld hl, enemy2_cactus_y
    cp a, [hl]
    jr c, .offScreen
    call FallCactusDown
    call UpdateCactusPosition
    ret
.offScreen:
    ; Reset variables
    ld hl, enemy2_falling
    ld [hl], 0
    ; Here I "could" clear the sprite info, but no point
.end
    ret

Enemy2Update::
    ; Check if alive
    ld a, [enemy2_alive]
    and 1
    jr z, .popped
    ; Check if we can move
    ld a, [movement_timer]
    and	%00000011
    jr nz, .end
    call MoveEnemy
    ret
.popped:
    ; Can we respawn
    ld a, [enemy2_respawn_timer]
    inc a
    ld [enemy2_respawn_timer], a
    cp a, 255
    jr nz, .respawnSkip
    call SpawnEnemy
.respawnSkip:
    ; Check if we need to play popping animation
    ld a, [enemy2_popping]
    and 1
    jr z, .notPopping
    call PopBalloonAnimation
.notPopping:
    ; Check if we need to drop the cactus
    ld a, [enemy2_falling]
    and 1
    jr z, .end
    call CactusFalling
.end
    ret

DeathOfEnemy2::
    ; Death
    xor a ; ld a, 0
    ld hl, enemy2_alive
    ld [hl], a
    ; Points
    ld b, ENEMY_CACTUS_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1
    ld hl, enemy2_popping
    ld [hl], a
    ld hl, enemy2_falling
    ld [hl], a
    ; Screaming cactus
    ld hl, enemy2_cactus+2
    ld [hl], $8E
    ld hl, enemy2_cactus+6
    ld [hl], $8E
    ; Sound
    call PopSound
    ret