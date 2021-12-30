INCLUDE "points.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

ENEMY_START_X EQU 0
ENEMY_START_Y EQU 55
ENEMY_BALLOON_START_Y EQU (ENEMY_START_Y-16)
ENEMY_SPAWN_A EQU 32
ENEMY_SPAWN_B EQU 50
ENEMY_SPAWN_C EQU 68
ENEMY_SPAWN_D EQU 86

SECTION "enemy vars", WRAM0
    wEnemyCactusOAM:: DB
    wEnemyBalloonOAM:: DB
    enemy_balloon_x:: DB
    enemy_balloon_y:: DB
    enemy_cactus_x:: DB 
    enemy_cactus_y:: DB
    enemy_alive:: DB
    enemy_popping:: DB
    enemy_popping_frame:: DB
    enemy_falling:: DB
    enemy_fall_speed:: DB
    enemy_falling_timer:: DB
    enemy_pop_timer:: DB
    enemy_delay_falling_timer:: DB
    enemy_respawn_timer:: DB

SECTION "enemy", ROMX

UpdateBalloonPosition:
    SET_HL_TO_ADDRESS wOAM, wEnemyBalloonOAM
    ; Update Y
    ld a, [enemy_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_balloon_x]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+4, wEnemyBalloonOAM
    ; Update Y
    ld a, [enemy_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_balloon_x]
    add 8
    ld [hl], a
    ret

UpdateCactusPosition:
    SET_HL_TO_ADDRESS wOAM, wEnemyCactusOAM
    ; Update Y
    ld a, [enemy_cactus_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_cactus_x]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+4, wEnemyCactusOAM
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
    ld [hl], a
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
    ret

ClearEnemyCactus:
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wEnemyCactusOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret 

ClearEnemyBalloon:
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wEnemyBalloonOAM
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
    ld [enemy_respawn_timer], a    
    call InitializeEnemy
    ld a, 1
    ld [enemy_alive], a

    ; Request OAM
    ld b, 2
    call RequestOAMSpace
    ld [wEnemyBalloonOAM], a

    ; Balloon left
    SET_HL_TO_ADDRESS wOAM, wEnemyBalloonOAM
    ld a, [enemy_balloon_y]
    ld [hl], a
    inc l
    ld a, [enemy_balloon_x]
    ld [hl], a
    inc l
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1
    ; Balloon right
    inc l
    ld a, [enemy_balloon_y]
    ld [hl], a
    inc l
    ld a, [enemy_balloon_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1 | OAMF_XFLIP

    ; Request OAM
    ld b, 2
    call RequestOAMSpace
    ld [wEnemyCactusOAM], a

    ; Cactus left
    SET_HL_TO_ADDRESS wOAM, wEnemyCactusOAM
    ld a, [enemy_cactus_y]
    ld [hl], a
    inc l
    ld a, [enemy_cactus_x]
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00000000
    ; Cactus right
    inc l
    ld a, [enemy_cactus_y]
    ld [hl], a
    inc l
    ld a, [enemy_cactus_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], OAMF_XFLIP
    ret

MoveBalloonDown:
    ld hl, enemy_balloon_y
    ld a, 1
    INCREMENT_POS enemy_balloon_y, 1
    ret

MoveRight:
    INCREMENT_POS enemy_balloon_x, 1
    INCREMENT_POS enemy_cactus_x, 1
    ret

MoveDown:
    INCREMENT_POS enemy_balloon_y, 1
    INCREMENT_POS enemy_cactus_y, 1
    ret

MoveEnemy:
    call MoveRight
    call UpdateEnemyPosition
    ret

FallCactusDown:
    ld hl, enemy_fall_speed
    ld a, [enemy_delay_falling_timer]
    inc a
    ld [enemy_delay_falling_timer], a
    cp a, CACTUS_DELAY_FALLING_TIME
    jr c, .skipAcceleration
    xor a ; ld a, 0
    ld [enemy_delay_falling_timer], a
    ld a, [hl]
    add a, a
    ld [hl], a
.skipAcceleration
    INCREMENT_POS enemy_cactus_y, [enemy_fall_speed]
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
    SET_HL_TO_ADDRESS wOAM+2, wEnemyBalloonOAM
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, wEnemyBalloonOAM
    ld [hl], $88
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, enemy_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    SET_HL_TO_ADDRESS wOAM+2, wEnemyBalloonOAM
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    SET_HL_TO_ADDRESS wOAM+6, wEnemyBalloonOAM
    ld [hl], $8A
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, enemy_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    call ClearEnemyBalloon
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
    and CACTUS_FALLING_TIME
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
    call ClearEnemyCactus
.end
    ret

EnemyUpdate::
    ; Check if alive
    ld a, [enemy_alive]
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
    ld [enemy_alive], a
    ; Points
    ld d, ENEMY_CACTUS_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1
    ld [enemy_popping], a
    ld [enemy_falling], a
    ; Screaming cactus
    SET_HL_TO_ADDRESS wOAM+2, wEnemyCactusOAM
    ld [hl], $8E
    SET_HL_TO_ADDRESS wOAM+6, wEnemyCactusOAM
    ld [hl], $8E
    ; Sound
    call PopSound
    ret