INCLUDE "points.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "enemy 2", ROMX

ENEMY2_START_X EQU 160
ENEMY2_START_Y EQU 55
ENEMY2_BALLOON_START_Y EQU (ENEMY2_START_Y-16)
ENEMY2_SPAWN_A EQU 41
ENEMY2_SPAWN_B EQU 59
ENEMY2_SPAWN_C EQU 77
ENEMY2_SPAWN_D EQU 95

UpdateBalloonPosition:
    SET_HL_TO_ADDRESS wOAM, wEnemy2BalloonOAM
    ; Update Y
    ld a, [enemy2_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [enemy2_balloon_x]
    ld [hl], a
    
    SET_HL_TO_ADDRESS wOAM+4, wEnemy2BalloonOAM
    ; Update Y
    ld a, [enemy2_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [enemy2_balloon_x]
    add 8
    ld [hl], a
    ret

UpdateCactusPosition:
    SET_HL_TO_ADDRESS wOAM, wEnemy2CactusOAM
    ; Update Y
    ld a, [enemy2_cactus_y]
    ld [hli], a
    ; Update X
    ld a, [enemy2_cactus_x]
    ld [hl], a
    
    SET_HL_TO_ADDRESS wOAM+4, wEnemy2CactusOAM
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
    ld [hl], a
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
    ret

ClearEnemy2Cactus:
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wEnemy2CactusOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret 

ClearEnemy2Balloon:
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wEnemy2BalloonOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

SpawnEnemy:
    xor a ; ld a, 0
    ld [enemy2_respawn_timer], a
    call InitializeEnemy2
    ld a, 1
    ld [enemy2_alive], a

    ; Request OAM
    ld b, 2
    call RequestOAMSpaceOffset
    ld [wEnemy2BalloonOAM], a

    ; Balloon left
    SET_HL_TO_ADDRESS wOAM, wEnemy2BalloonOAM
    ld a, [enemy2_balloon_y]
    ld [hl], a
    inc l
    ld a, [enemy2_balloon_x]
    ld [hl], a
    inc l
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1
    ; Balloon right
    SET_HL_TO_ADDRESS wOAM+4, wEnemy2BalloonOAM
    ld a, [enemy2_balloon_y]
    ld [hl], a
    inc l
    ld a, [enemy2_balloon_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1 | OAMF_XFLIP

    ; Request OAM
    ld b, 2
    call RequestOAMSpaceOffset
    ld [wEnemy2CactusOAM], a

    ; Cactus left
    SET_HL_TO_ADDRESS wOAM, wEnemy2CactusOAM
    ld a, [enemy2_cactus_y]
    ld [hl], a
    inc l
    ld a, [enemy2_cactus_x]
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00000000
    ; Cactus right
    inc l
    ld a, [enemy2_cactus_y]
    ld [hl], a
    inc l
    ld a, [enemy2_cactus_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], OAMF_XFLIP
    ret

MoveLeft:
    DECREMENT_POS enemy2_balloon_x, 1
    DECREMENT_POS enemy2_cactus_x, 1
    ret

MoveDown:
    INCREMENT_POS enemy2_balloon_y, 1
    INCREMENT_POS enemy2_cactus_y, 1
    ret

MoveEnemy:
    call MoveLeft
    call UpdateEnemyPosition
    ret

FallCactusDown:
    ld hl, enemy2_fall_speed
    ld a, [enemy2_delay_falling_timer]
    inc a
    ld [enemy2_delay_falling_timer], a
    cp a, CACTUS_DELAY_FALLING_TIME
    jr c, .skipAcceleration
    xor a ; ld a, 0
    ld [enemy2_delay_falling_timer], a
    ld a, [hl]
    add a, a
    ld [hl], a
.skipAcceleration
    INCREMENT_POS enemy2_cactus_y, [enemy2_fall_speed]
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [enemy2_popping_frame]
    cp a, 0
    jr z, .frame0

    ld a, [enemy2_pop_timer]
    inc	a
    ld [enemy2_pop_timer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    jp nz, .end
    ; Can do next frame
    ; Check what frame we are on
    ld a, [enemy2_popping_frame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, wEnemy2BalloonOAM
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, wEnemy2BalloonOAM
    ld [hl], $88
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, enemy2_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    SET_HL_TO_ADDRESS wOAM+2, wEnemy2BalloonOAM
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    SET_HL_TO_ADDRESS wOAM+6, wEnemy2BalloonOAM
    ld [hl], $8A
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, enemy2_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    call ClearEnemy2Balloon
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
    and CACTUS_FALLING_TIME
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
    call ClearEnemy2Cactus
.end
    ret

Enemy2Update::
    ; Check if alive
    ld a, [enemy2_alive]
    and 1
    jr z, .popped
    ; Check if we can move
    ld a, [global_timer]
    and	ENEMY_SPRITE_MOVE_WAIT_TIME
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
    ld d, ENEMY_CACTUS_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1
    ld hl, enemy2_popping
    ld [hl], a
    ld hl, enemy2_falling
    ld [hl], a
    ; Screaming cactus
    SET_HL_TO_ADDRESS wOAM+2, wEnemy2CactusOAM
    ld [hl], $8E
    SET_HL_TO_ADDRESS wOAM+6, wEnemy2CactusOAM
    ld [hl], $8E
    ; Sound
    call PopSound
    ret