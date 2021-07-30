SECTION "enemy", ROMX

ENEMY_START_X EQU 20
ENEMY_START_Y EQU 50
ENEMY_BALLOON_START_Y EQU (ENEMY_START_Y-16)

UpdateBalloonPosition:
    ld hl, enemy_balloon
    ; Update Y
    ld a, [enemy_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_x]
    ld [hl], a
  
    ld hl, enemy_balloon+4
    ; Update Y
    ld a, [enemy_y]
    ld [hli], a
    ; Update X
    ld a, [enemy_x]
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
    ld hl, enemy_alive
    ld [hl], 1
    ld hl, enemy_popping
    ld [hl], a
    ld hl, enemy_popping_frame
    ld [hl], a
    ld hl, enemy_pop_timer
    ld [hl], a
    ld hl, enemy_x
    ld [hl], ENEMY_START_X
    ld hl, enemy_y
    ld [hl], ENEMY_BALLOON_START_Y
    ld hl, enemy_cactus_x
    ld [hl], ENEMY_START_X
    ld hl, enemy_cactus_y
    ld [hl], ENEMY_START_Y
    ; Balloon left
    ld hl, enemy_balloon
    ld [hl], ENEMY_BALLOON_START_Y
    inc l
    ld [hl], ENEMY_START_X
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00000000
    ; Balloon right
    ld hl, enemy_balloon+4
    ld [hl], ENEMY_BALLOON_START_Y
    inc l
    ld [hl], ENEMY_START_X+8
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00100000
    ; Cactus left
    ld hl, enemy_cactus
    ld [hl], ENEMY_START_Y
    inc l
    ld [hl], ENEMY_START_X
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00000000
    ; Cactus right
    ld hl, enemy_cactus+4
    ld [hl], ENEMY_START_Y
    inc l
    ld [hl], ENEMY_START_X+8
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00100000
    ret

MoveBalloonRight:
    ld hl, enemy_x
    ld a, 1
    call IncrementPosition
    ret 

MoveCactusRight:
    ld hl, enemy_cactus_x
    ld a, 1
    call IncrementPosition
    ret

MoveEnemy:
    ld a, [movement_timer]
	and	%00000111
	jr nz, .end
    call MoveBalloonRight
    call MoveCactusRight
    call UpdateEnemyPosition
.end:
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [enemy_popping_frame]
    cp a, 0
    jr z, .frame0

    ld a, [enemy_pop_timer]
	inc	a
	ld [enemy_pop_timer], a
    cp a, 30
    jp nz, .end

    ; Can do next frame
    ; Reset timer
    xor a ; ld a, 0
    ld [enemy_pop_timer], a
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

EnemyUpdate::
    ; Check if alive
    ld a, [enemy_alive]
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
    ; ld a, [point_balloon_respawn_timer]
    ; inc a
    ; ld [point_balloon_respawn_timer], a
    ; cp a, 150
    ; jr nz, .respawnSkip
    ; call SpawnPointBalloon
.respawnSkip:
    ; Check if we need to play popping animation
    ld a, [enemy_popping]
    and 1
    jr z, .end
    call PopBalloonAnimation
.end
    ret

DeathOfEnemy::
    ; Death
    xor a ; ld a, 0
    ld hl, enemy_alive
    ld [hl], a
    ; Animation trigger
    ld hl, enemy_popping
    ld [hl], 1
    ret