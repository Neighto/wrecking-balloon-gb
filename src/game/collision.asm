SECTION "collision", ROM0

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
    ; cactus_y[hl] > balloon_y[a]
    add 16
    cp a, [hl]
    jr c, .tryOtherY
    ; cactus_y[hl] < balloon_y'[a']
    jr .checkX

.tryOtherY
    ; Also check OR cactus_y'
    ld hl, player_cactus
    ld a, [hl]
    add 16
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
    ; cactus_x[hl] > balloon_x[a]
    add 16
    cp a, [hl]
    jr c, .tryOtherX
    ; cactus_x[hl] < balloon_x'[a']
    jr .collision

.tryOtherX:
    ; Also check OR cactus_x'
    ld hl, player_cactus+1
    ld a, [hl]
    add 16
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

.collision:
    call DeathOfPointBalloon
.end:
    ret