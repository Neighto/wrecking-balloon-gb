INCLUDE "points.inc"
INCLUDE "constants.inc"

SECTION "enemy", ROMX

ENEMY_START_X EQU 0
ENEMY_START_Y EQU 55
ENEMY_BALLOON_START_Y EQU (ENEMY_START_Y-16)
ENEMY_SPAWN_A EQU 32
ENEMY_SPAWN_B EQU 64
ENEMY_SPAWN_C EQU 96
ENEMY_SPAWN_D EQU 128

UpdateBalloonPosition:
    ld hl, enemy_balloon
    ; Update Y
    ld a, [enemy_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_balloon_x]
    ld [hl], a
  
    ld hl, enemy_balloon+4
    ; Update Y
    ld a, [enemy_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_balloon_x]
    add 8
    ld [hl], a
    ret

UpdateCactusPosition:
    ld hl, enemy_cactus
    ; Update Y
    ld a, [enemy_cactus_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_cactus_x]
    ld [hl], a
  
    ld hl, enemy_cactus+4
    ; Update Y
    ld a, [enemy_cactus_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_cactus_x]
    add 8
    ld [hl], a
    ret
  
UpdateEnemyPosition:
    call UpdateBalloonPosition
    call UpdateCactusPosition
    ret

InitializeEnemy::
    ; Set variables
    xor a ; ld a, 0
    ld hl, enemy_popping
    ld [hl], a
    ld hl, enemy_popping_frame
    ld [hl], a
    ld hl, enemy_pop_timer
    ld [hl], a
    ld hl, enemy_falling
    ld [hl], a
    ld hl, enemy_delay_falling_timer
    ld [hl], a
    ld hl, enemy_falling_timer
    ld [hl], a
    ld hl, enemy_respawn_timer
    ld [hl], a
    ld hl, enemy_alive
    ld [hl], 1
    ld hl, enemy_fall_speed
    ld [hl], 1
    ld hl, enemy_balloon_x
    ld [hl], ENEMY_START_X
    ld hl, enemy_balloon_y
    ld [hl], ENEMY_BALLOON_START_Y
    ld hl, enemy_cactus_x
    ld [hl], ENEMY_START_X
    ld hl, enemy_cactus_y
    ld [hl], ENEMY_START_Y

    ; Randomize spawn
.nextSpawnPoint:
    ld hl, enemy_balloon_y
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
    ld [hl], ENEMY_SPAWN_A
    ld hl, enemy_cactus_y ; TODO: Could be cleaner and only specify this once
    ld [hl], ENEMY_SPAWN_A+16
    jr .endNextSpawnPoint
.spawnB:
    ld [hl], ENEMY_SPAWN_B
    ld hl, enemy_cactus_y
    ld [hl], ENEMY_SPAWN_B+16
    jr .endNextSpawnPoint
.spawnC:
    ld [hl], ENEMY_SPAWN_C
    ld hl, enemy_cactus_y
    ld [hl], ENEMY_SPAWN_C+16
    jr .endNextSpawnPoint
.spawnD:
    ld [hl], ENEMY_SPAWN_D
    ld hl, enemy_cactus_y
    ld [hl], ENEMY_SPAWN_D+16
.endNextSpawnPoint:

    ; Balloon left
    ld hl, enemy_balloon
    ld a, [enemy_balloon_y]
    ld [hl], a
    inc l
    ld a, [enemy_balloon_x]
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00000000
    ; Balloon right
    ld hl, enemy_balloon+4
    ld a, [enemy_balloon_y]
    ld [hl], a
    inc l
    ld a, [enemy_balloon_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00100000
    ; Cactus left
    ld hl, enemy_cactus
    ld a, [enemy_cactus_y]
    ld [hl], a
    inc l
    ld a, [enemy_cactus_x]
    ld [hl], a
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00000000
    ; Cactus right
    ld hl, enemy_cactus+4
    ld a, [enemy_cactus_y]
    ld [hl], a
    inc l
    ld a, [enemy_cactus_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00100000
    ret

SpawnEnemy:
    xor a ; ld a, 0
    ld [enemy_respawn_timer], a    
    call InitializeEnemy
    ret

MoveBalloonRight:
    ld hl, enemy_balloon_x
    ld a, 1
    call IncrementPosition
    ret 

MoveCactusRight:
    ld hl, enemy_cactus_x
    ld a, 1
    call IncrementPosition
    ret

MoveBalloonDown:
    ld hl, enemy_balloon_y
    ld a, 1
    call IncrementPosition
    ret

MoveCactusDown:
    ld hl, enemy_cactus_y
    ld a, 1
    call IncrementPosition
    ret

MoveRight:
    call MoveBalloonRight
    call MoveCactusRight
    ret

MoveDown:
    call MoveBalloonDown
    call MoveCactusDown
    ret

MoveEnemy:
    ld a, [global_timer]
	and	%00000111
	jr nz, .end
    call MoveRight
    call UpdateEnemyPosition
.end:
    ret

FallCactusDown:
    ld hl, enemy_fall_speed
    ld a, [enemy_delay_falling_timer]
    inc a
    ld [enemy_delay_falling_timer], a
    cp a, 7
    jr c, .skipAcceleration
    xor a ; ld a, 0
    ld [enemy_delay_falling_timer], a
    ld a, [hl]
    add a, a
    ld [hl], a
.skipAcceleration
    ld a, [hl]
    ld hl, enemy_cactus_y
    call IncrementPosition
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [enemy_popping_frame]
    cp a, 0
    jr z, .frame0

    ld a, [enemy_pop_timer]
	inc	a
	ld [enemy_pop_timer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    jp nz, .end
    ; Can do next frame
    ; Check what frame we are on
    ld a, [enemy_popping_frame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    ld hl, enemy_balloon+2
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    ld hl, enemy_balloon+6
    ld [hl], $88
    inc l
    ld [hl], %00100000
    ld hl, enemy_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    ld hl, enemy_balloon+2
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    ld hl, enemy_balloon+6
    ld [hl], $8A
    inc l
    ld [hl], %00100000
    ld hl, enemy_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    xor a ; ld a, 0
    ld hl, enemy_balloon
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ; Reset variables
    ld hl, enemy_popping
    ld [hl], a
    ld hl, enemy_pop_timer
    ld [hl], a
    ld hl, enemy_popping_frame
    ld [hl], a
.end:
    ret

CactusFalling:
    ld a, [enemy_falling_timer]
    inc a
    ld [enemy_falling_timer], a
    and %00000101
    jr nz, .end
    ; Can we move cactus down
    ld a, 160
    ld hl, enemy_cactus_y
    cp a, [hl]
    jr c, .offScreen
    call FallCactusDown
    call UpdateCactusPosition
    ret
.offScreen:
    ; Reset variables
    ld hl, enemy_falling
    ld [hl], 0
    ; Here I "could" clear the sprite info, but no point
.end
    ret

EnemyUpdate::
    ; Check if alive
    ld a, [enemy_alive]
    and 1
    jr z, .popped
    ; Check if we can move
    ld a, [global_timer]
    and	%00000011
    jr nz, .end
    call MoveEnemy
    ret
.popped:
    ; Can we respawn
    ld a, [enemy_respawn_timer]
    inc a
    ld [enemy_respawn_timer], a
    cp a, 255
    jr nz, .respawnSkip
    call SpawnEnemy
.respawnSkip:
    ; Check if we need to play popping animation
    ld a, [enemy_popping]
    and 1
    jr z, .notPopping
    call PopBalloonAnimation
.notPopping:
    ; Check if we need to drop the cactus
    ld a, [enemy_falling]
    and 1
    jr z, .end
    call CactusFalling
.end
    ret

DeathOfEnemy::
    ; Death
    xor a ; ld a, 0
    ld hl, enemy_alive
    ld [hl], a
    ; Points
    ld b, ENEMY_CACTUS_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1
    ld hl, enemy_popping
    ld [hl], a
    ld hl, enemy_falling
    ld [hl], a
    ; Screaming cactus
    ld hl, enemy_cactus+2
    ld [hl], $8E
    ld hl, enemy_cactus+6
    ld [hl], $8E
    ; Sound
    call PopSound
    ret