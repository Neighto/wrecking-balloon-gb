SECTION "collision", ROM0

CollisionCheck:
    ; bc = argument for target colliding with player cactus
    ; de = argument for collider
    ; d = used for temporary value
    ; a = return result

    ld a, [collision_timer]
	inc	a
	ld [collision_timer], a
	and	%00001100
    jr nz, .end

    ; CHECK Y
    ld h, d
    ld l, e
    ld a, [bc]
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
    ld a, [hl]
    add 16
    ld [hl], a

    ld a, [bc]
    cp a, [hl]
    jr nc, .end
    ; cactus_y'[c'] > balloon_y[a]
    add 16
    cp a, [hl]
    jr c, .end
    ; cactus_y'[c'] < balloon_y'[a']

.checkX:
    ; CHECK X
    ld h, d
    ld l, e
    inc l ; collider+1
    inc c ; target+1
    ld a, [bc]
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
    ld a, [hl]
    add 16
    ld [hl], a

    ld a, [bc]
    cp a, [hl]
    jr nc, .end
    ; cactus_x'[c'] > balloon_x[a]
    add 16
    cp a, [hl]
    jr c, .end
    ; cactus_x'[c'] < balloon_x'[a']

.collision:
    ld a, 1 ; Success
    ret
.end:
    ld a, 0 ; Fail
    ret

CollisionUpdate::
    ; Point Balloon
    ; Check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .endPointBalloon
    ; Check collision
    ld bc, point_balloon
    ld de, player_cactus
    call CollisionCheck
    and 1
    jr z, .endPointBalloon
    ; Collided
    call DeathOfPointBalloon
.endPointBalloon:
    ; Enemy
    ; Check if alive
    ld a, [enemy_alive]
    and 1
    jr z, .endEnemy
    ; Check collision
    ld bc, enemy_balloon
    ld de, player_cactus
    call CollisionCheck
    and 1
    jr z, .endEnemy
    ; Collided
    call DeathOfEnemy
.endEnemy:
    ret