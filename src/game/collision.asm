INCLUDE "hardware.inc"

SECTION "collision", ROM0

CollisionCheck:
    ; bc = argument for target colliding with player cactus
    ; hl = argument for collider
    ; d = used for temporary value
    ; a = return result

    ld a, [collision_timer]
	inc	a
	ld [collision_timer], a
	and	%00001100
    jr nz, .end

    ; CHECK Y
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
    ld d, a

    ld a, [bc]
    cp a, d
    jr nc, .end
    ; cactus_y'[c'] > balloon_y[a]
    add 16
    cp a, d
    jr c, .end
    ; cactus_y'[c'] < balloon_y'[a']

.checkX:
    ; CHECK X
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
    ld d, a

    ld a, [bc]
    cp a, d
    jr nc, .end
    ; cactus_x'[c'] > balloon_x[a]
    add 16
    cp a, d
    jr c, .end
    ; cactus_x'[c'] < balloon_x'[a']

.collision:
    ld a, 1 ; Success
    ret
.end:
    ld a, 0 ; Fail
    ret

CollisionUpdate::
    ; Point balloon
    ; Check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .endPointBalloon
    ; Check collision
    ld bc, point_balloon
    ld hl, player_cactus
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
    ld hl, player_cactus
    call CollisionCheck
    and 1
    jr z, .endEnemy
    ; Collided
    call DeathOfEnemy
.endEnemy:
    ; Enemy 2
    ; Check if alive
    ld a, [enemy2_alive]
    and 1
    jr z, .endEnemy2
    ; Check collision
    ld bc, enemy2_balloon
    ld hl, player_cactus
    call CollisionCheck
    and 1
    jr z, .endEnemy2
    ; Collided
    call DeathOfEnemy2
.endEnemy2:
    ; Enemy colliding with player
    ; Check if alive
    ld a, [player_alive]
    and 1
    jr z, .endEnemyHitPlayer
    ; Check collision enemy 1
.checkCollisionEnemy1:
    ld bc, player_balloon
    ld hl, enemy_cactus
    call CollisionCheck
    and 1
    jr z, .checkCollisionEnemy2
    ; Collided
    jr .collisionWithPlayer
    ; Check collision enemy 2
.checkCollisionEnemy2:
    ld bc, player_balloon
    ld hl, enemy2_cactus
    call CollisionCheck
    and 1
    jr z, .endEnemyHitPlayer
    ; Collided
.collisionWithPlayer:
    ; Check if player is invincible
    ld a, [player_invincible]
    cp a, 0
    jr nz, .endEnemyHitPlayer
    call DeathOfPlayer
.endEnemyHitPlayer:
    ret

OffScreenRight::
    ; b = x value to check
    ; return a (1 = end of screen)
    ld a, SCRN_X
    cp a, b
    jr nc, .end
    ld a, 1
    ret
.end:
    xor a ; ld a, 0
    ret

OffScreenLeft::
    ; b = x value to check
    ; return a (1 = end of screen)
    ld a, SCRN_X
    cp a, b
    jr c, .end
    xor a ; ld a, 0
    ; cp a, b
    ; jr z, .end
    ret
.end:
    ld a, 1
    ret

OffScreenBottom::
    ; b = x value to check
    ; return a (1 = end of screen)
    ld a, SCRN_Y
    cp a, b
    jr nc, .end
    ld a, 1
    ret
.end:
    xor a ; ld a, 0
    ret

OffScreenTop::
    ; b = x value to check
    ; return a (1 = end of screen)
    ld a, SCRN_Y
    cp a, b
    jr c, .end
    xor a ; ld a, 0
    cp a, b
    jr z, .end
    ret
.end:
    ld a, 1
    ret