SECTION "enemy", ROMX

ENEMY_START_X EQU 20
ENEMY_START_Y EQU 50
ENEMY_BALLOON_START_Y EQU (ENEMY_START_Y-16)

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

EnemyUpdate::
    ; Check if alive
    ld a, [enemy_alive]
    and 1
    jr z, .popped
    ; Check if we can move
    ld a, [movement_timer]
    and	%00000011
    jr nz, .end
    ; call FloatPointBalloonUp
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
    ; Remove from sprites
    ld hl, enemy_balloon
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ; TODO: for some reason I don't have to clear from point_balloon+4 ??
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [enemy_popping_frame]
    cp a, 0
    jp z, .frame0

    ld a, [enemy_pop_timer]
	inc	a
	ld [enemy_pop_timer], a
    cp a, 30
    jr z, .special
    ret

.special:
    ld a, 0
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
    ld HL, balloon_pop
    ld a, [enemy_y]
    ld [HL], a
    inc L
    ld a, [enemy_x]
    ld [HL], a
    inc L
    ld [HL], $88
    inc L
    ld [HL], %00000000
    ; Popped right - frame 0
    ld HL, balloon_pop+4
    ld a, [enemy_y]
    ld [HL], a
    inc L
    ld a, [enemy_x]
    add 8
    ld [HL], a
    inc L
    ld [HL], $88
    inc L
    ld [HL], %00100000
    ld hl, enemy_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    ld HL, balloon_pop
    ld a, [enemy_y]
    ld [HL], a
    inc L
    ld a, [enemy_x]
    ld [HL], a
    inc L
    ld [HL], $8A
    inc L
    ld [HL], %00000000
    ; Popped right - frame 1
    ld HL, balloon_pop+4
    ld a, [enemy_y]
    ld [HL], a
    inc L
    ld a, [enemy_x]
    add 8
    ld [HL], a
    inc L
    ld [HL], $8A
    inc L
    ld [HL], %00100000
    ld hl, enemy_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    ld a, 0
    ld hl, balloon_pop ; might cause issues when popping multiple!
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