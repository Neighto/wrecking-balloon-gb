INCLUDE "points.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

SECTION "point balloon", ROMX

; Balloons will spawn and fly upward AND can be popped
POINT_BALLOON_START_X EQU 120
POINT_BALLOON_START_Y EQU 156
POINT_BALLOON_SPAWN_A EQU 32
POINT_BALLOON_SPAWN_B EQU 64
POINT_BALLOON_SPAWN_C EQU 96
POINT_BALLOON_SPAWN_D EQU 128

PB_SPRITE_MOVE_WAIT_TIME EQU %00000001

UpdateBalloonPosition:
    
    SET_HL_TO_ADDRESS wOAM, wPointBalloon
    ; Update Y
    ld a, [point_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [point_balloon_x]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+4, wPointBalloon
    ; Update Y
    ld a, [point_balloon_y]
    ld [hli], a
    ; Update X
    ld a, [point_balloon_x]
    add 8
    ld [hl], a
    ret

InitializePointBalloon::
    ; Initialize variables
    xor a ; ld a, 0
    ld hl, point_balloon_alive
    ld [hl], a
    ld hl, point_balloon_popping
    ld [hl], a
    ld hl, point_balloon_y
    ld [hl], POINT_BALLOON_START_Y
    ld hl, point_balloon_x
    ld [hl], POINT_BALLOON_START_X
    ld hl, point_balloon_popping_frame
    ld [hl], a
    ld hl, point_balloon_pop_timer
    ld [hl], a
    ld [point_balloon_respawn_timer], a
    
    ; Randomize spawn
.nextSpawnPoint:
    ld hl, point_balloon_x
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
    ld [hl], POINT_BALLOON_SPAWN_A
    jr .endNextSpawnPoint
.spawnB:
    ld [hl], POINT_BALLOON_SPAWN_B
    jr .endNextSpawnPoint
.spawnC:
    ld [hl], POINT_BALLOON_SPAWN_C
    jr .endNextSpawnPoint
.spawnD:
    ld [hl], POINT_BALLOON_SPAWN_D
.endNextSpawnPoint:
    ret

SpawnPointBalloon:
    push af

    ld b, 2
	call RequestOAMSpaceOffset
	ld [wPointBalloon], a

    xor a ; ld a, 0
    ld [point_balloon_respawn_timer], a
    call InitializePointBalloon
    ld a, 1
    ld [point_balloon_alive], a
.balloonLeft:
    ; Balloon left
    SET_HL_TO_ADDRESS wOAM, wPointBalloon
    ld a, [point_balloon_y]
    ld [hl], a
    inc l
    ld a, [point_balloon_x]
    ld [hl], a
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00000000
.balloonRight:
    ; Balloon right
    inc l
    ld a, [point_balloon_y]
    ld [hl], a
    inc l
    ld a, [point_balloon_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $84
    inc l
    ld [hl], OAMF_XFLIP
.end:
    pop af
    ret

FloatPointBalloonUp:
    ld hl, point_balloon_y
    ld a, [hl]
    dec a
    ld [hl], a
    call UpdateBalloonPosition
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [point_balloon_popping_frame]
    cp a, 0
    jr z, .frame0

    ld a, [point_balloon_pop_timer]
	inc	a
	ld [point_balloon_pop_timer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    jp nz, .end
    ; Can do next frame
    ; Check what frame we are on
    ld a, [point_balloon_popping_frame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, wPointBalloon
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, wPointBalloon
    ld [hl], $88
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, point_balloon_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    SET_HL_TO_ADDRESS wOAM+2, wPointBalloon
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    SET_HL_TO_ADDRESS wOAM+6, wPointBalloon
    ld [hl], $8A
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, point_balloon_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wPointBalloon
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ; Reset variables
    ld hl, point_balloon_popping
    ld [hl], a
    ld hl, point_balloon_pop_timer
    ld [hl], a
    ld hl, point_balloon_popping_frame
    ld [hl], a
.end:
    ret

PointBalloonUpdate::
    ; Check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .popped
    ; Check if we can move
    ld a, [global_timer]
    and	PB_SPRITE_MOVE_WAIT_TIME
    jr nz, .end
    call FloatPointBalloonUp
    ret
.popped:
    ; Can we respawn
    ld a, [point_balloon_respawn_timer]
    inc a
    ld [point_balloon_respawn_timer], a
    cp a, 150
    jr nz, .respawnSkip
    call SpawnPointBalloon
.respawnSkip:
    ; Check if we need to play popping animation
    ld a, [point_balloon_popping]
    and 1
    jr z, .end
    call PopBalloonAnimation
.end:
    ret

DeathOfPointBalloon::
    ; Death
    xor a ; ld a, 0
    ld hl, point_balloon_alive
    ld [hl], a
    ; Points
    ld d, POINT_BALLOON_POINTS
    call AddPoints
    ; Animation trigger
    ld hl, point_balloon_popping
    ld [hl], 1
    ; Sound
    call PopSound
    ret