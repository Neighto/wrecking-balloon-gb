INCLUDE "hardware.inc"

SECTION "collision", ROM0

CollisionCheck:
    ; bc = argument for target colliding with player cactus
    ; hl = argument for collider
    ; a = argument for 8x16 tile check (a = 0) or 8x8 tile check (a = 1) on hl
    ; a = return result
    push de
    ld e, a

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
    ld a, e ; Are we 8x16 or 8x8
    cp a, 0
    ld a, [hl]
    jr z, .skip8x8Adjustment
    sub 8
.skip8x8Adjustment:
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
    pop de
    ret
.end:
    ld a, 0 ; Fail
    pop de
    ret

; TODO: Separate collision checks, or check if spawned before checking
CollisionUpdate::
    ld a, [global_timer]
	and	%00000011
    jp nz, .end

    ; Point balloon
    ; Check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .endPointBalloon
    ; Check collision
    ld bc, point_balloon
    ld hl, player_cactus
    xor a ; ld a, 0
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
    xor a ; ld a, 0
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
    xor a ; ld a, 0
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
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .checkCollisionEnemy2
    ; Collided
    jr .collisionWithPlayer
    ; Check collision enemy 2
.checkCollisionEnemy2:
    ld bc, player_balloon
    ld hl, enemy2_cactus
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .checkCollisionBird
    ; Collided
    jr .collisionWithPlayer
    ; Check collision bird
.checkCollisionBird:
    ld bc, player_balloon
    ld hl, bird
    ld a, 1
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
.end:
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
    sub 8 ; Space for the window layer
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