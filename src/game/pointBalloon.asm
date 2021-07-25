SECTION "point balloon", ROMX

; Balloons will spawn and fly upward AND can be popped
POINT_BALLOON_START_X EQU 120
POINT_BALLOON_START_Y EQU 156

; UpdatePointBalloonPosition:
;     ; Update Y
;     ld hl, point_balloon
;     ld a, [point_balloon_y]
;     ld [hli], a
;     ; Update X
;     ld a, [point_balloon_x]
;     ld [hl], a
;     ret

InitializePointBalloon::
    ; Initialize variables
    xor a ; ld a, 0
    ld hl, point_balloon_alive
    ld [hl], 1
    ld hl, point_balloon_popping
    ld [hl], a
    ld hl, point_balloon_y
    ld [hl], POINT_BALLOON_START_Y
    ld hl, point_balloon_x
    ld [hl], POINT_BALLOON_START_X
    ld hl, point_balloon_popping_frame
    ld [hl], a
    ld hl, balloon_pop_timer
    ld [hl], a
    
.nextSpawnPoint:
    ; TODO: weird to set point_balloon_x to update x, instead of vice-versa
    ld hl, point_balloon_x
    ld a, 4
    call RANDOM
    cp a, 0
    jp z, .spawn0
    cp a, 1
    jp z, .spawn1
    cp a, 2
    jp z, .spawn2
    cp a, 3
    jp z, .spawn3
.spawn0:
    ld [hl], 32
    jr .EndNextSpawnPoint
.spawn1:
    ld [hl], 64
    jr .EndNextSpawnPoint
.spawn2:
    ld [hl], 96
    jr .EndNextSpawnPoint
.spawn3:
    ld [hl], 128
.EndNextSpawnPoint:

    ; Balloon left
    ld hl, point_balloon
    ld [hl], POINT_BALLOON_START_Y
    inc l
    ld a, [point_balloon_x]
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00000000
    ; Balloon right
    ld hl, point_balloon+4
    ld [hl], POINT_BALLOON_START_Y
    inc l
    ld a, [point_balloon_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00100000
    ret

SpawnPointBalloon::
    xor a ; ld a, 0
    ld [point_balloon_respawn_timer], a    
    call InitializePointBalloon
    ret

FloatPointBalloonUp:
    ld hl, point_balloon
    ld bc, point_balloon_y
    ld a, [bc]
    dec a
    ld [hl], a
    ld [bc], a
    ld hl, point_balloon+4
    ld [hl], a
    ret

PointBalloonUpdate::
    ; Check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .popped
    ; Check if we can move
    ld a, [movement_timer]
    and	%00000011
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
.end
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [point_balloon_popping_frame]
    cp a, 0
    jp z, .frame0

    ld a, [balloon_pop_timer]
	inc	a
	ld [balloon_pop_timer], a
    cp a, 30
    jr z, .special
    ret

.special:
    ld a, 0
    ld [balloon_pop_timer], a

    ; Check what frame we are on
    ld a, [point_balloon_popping_frame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    ld HL, balloon_pop
    ld a, [point_balloon_y]
    ld [HL], a
    inc L
    ld a, [point_balloon_x]
    ld [HL], a
    inc L
    ld [HL], $88
    inc L
    ld [HL], %00000000
    ; Popped right - frame 0
    ld HL, balloon_pop+4
    ld a, [point_balloon_y]
    ld [HL], a
    inc L
    ld a, [point_balloon_x]
    add 8
    ld [HL], a
    inc L
    ld [HL], $88
    inc L
    ld [HL], %00100000
    ld hl, point_balloon_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    ld HL, balloon_pop
    ld a, [point_balloon_y]
    ld [HL], a
    inc L
    ld a, [point_balloon_x]
    ld [HL], a
    inc L
    ld [HL], $8A
    inc L
    ld [HL], %00000000
    ; Popped right - frame 1
    ld HL, balloon_pop+4
    ld a, [point_balloon_y]
    ld [HL], a
    inc L
    ld a, [point_balloon_x]
    add 8
    ld [HL], a
    inc L
    ld [HL], $8A
    inc L
    ld [HL], %00100000
    ld hl, point_balloon_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    ld a, 0
    ld hl, balloon_pop
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
    ld hl, balloon_pop_timer
    ld [hl], a
    ld hl, point_balloon_popping_frame
    ld [hl], a
.end:
    ret

DeathOfPointBalloon:
    ; Death
    xor a ; ld a, 0
    ld hl, point_balloon_alive
    ld [hl], a
    ; Animation trigger
    ld hl, point_balloon_popping
    ld [hl], 1
    ; Remove from sprites
    ld hl, point_balloon
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ; TODO: for some reason I don't have to clear from point_balloon+4 ??
    ret

CollisionCheck::
    ld a, [collision_timer]
	inc	a
	ld [collision_timer], a
	and	%00001100
    jr nz, .end

    ; Check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .end

    ; CHECK Y
    ld hl, point_balloon
    ld a, [hl]
    ld hl, player_cactus
    cp a, [hl]
    jr nc, .tryOtherY
    ; cactus_y > balloon_y
    add 16
    cp a, [hl]
    jr c, .tryOtherY
    ; cactus_y < balloon_y'
    jr .checkX

.tryOtherY
    ; Also check OR cactus_y' !!!
    ld hl, player_cactus
    ld a, [hl]
    add 16 ; a = cactus_y'
    ld c, a
    ld hl, point_balloon
    ld a, [hl]
    cp a, c
    jr nc, .end
    ; cactus_y'[c'] > balloon_y[a]
    add 16
    cp a, c
    jr c, .end
    ; cactus_y'[c'] < balloon_y'[a']

.checkX:
    ; CHECK X
    ld hl, point_balloon+1
    ld a, [hl]
    ld hl, player_cactus+1
    cp a, [hl]
    jr nc, .tryOtherX
    ; cactus_x > balloon_x
    add 16
    cp a, [hl]
    jr c, .tryOtherX
    ; cactus_x < balloon_x'
    jr .doSomething

.tryOtherX:
    ; Also check OR cactus_x' !!!
    ld hl, player_cactus+1
    ld a, [hl]
    add 16 ; a = cactus_y'
    ld c, a
    ld hl, point_balloon+1
    ld a, [hl]
    cp a, c
    jr nc, .end
    ; cactus_x'[c'] > balloon_x[a]
    add 16
    cp a, c
    jr c, .end
    ; cactus_x'[c'] < balloon_x'[a']

.doSomething:
    call DeathOfPointBalloon
.end:
    ret
