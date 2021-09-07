INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "collision", ROM0

OFF_SCREEN_ENEMY_BUFFER EQU 16

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

    ; Check if alive
    ld a, [player_alive]
    and 1
    jp z, .end

    ; Point balloon
    ; Check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .endPointBalloon
    ; Check collision
    ld bc, wPointBalloon
    ld hl, wPlayerCactus
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
    ld bc, wEnemyBalloon
    ld hl, wPlayerCactus
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .checkEnemyHitPlayer
    call DeathOfEnemy
    jr .endEnemy
.checkEnemyHitPlayer:
    ld bc, wPlayerBalloon
    ld hl, wEnemyCactus
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .endEnemy
    jr .collisionWithPlayer
.endEnemy:
    ; Enemy 2
    ; Check if alive
    ld a, [enemy2_alive]
    and 1
    jr z, .endEnemy2
    ; Check collision
    ld bc, wEnemy2Balloon
    ld hl, wPlayerCactus
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .checkEnemy2HitPlayer
    ; Collided
    call DeathOfEnemy2
    jr .endEnemy2
.checkEnemy2HitPlayer:
    ld bc, wPlayerBalloon
    ld hl, wEnemy2Cactus
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .endEnemy2
    jr .collisionWithPlayer
.endEnemy2:
    ; Bird
    ; Check if alive
    ld a, [bird_alive]
    and 1
    jr z, .endBird
    ; Check collision bird
.checkBirdHitPlayer:
    ld bc, wPlayerBalloon
    ld hl, wBird
    ld a, 1
    call CollisionCheck
    and 1
    jr z, .endEnemyHitPlayer
    jr .collisionWithPlayer
.endBird:
    ret
.collisionWithPlayer:
    ; Check if player is invincible
    ld a, [player_invincible]
    cp a, 0
    jr nz, .endEnemyHitPlayer
    call DeathOfPlayer
.endEnemyHitPlayer:
.end:
    ret

OffScreenXEnemies::
    ; b = x value to check
    ; return a (1 = end of screen)
    ld a, SCRN_X
    add OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .end
    ld a, SCRN_VX
    sub OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .end
    ld a, 1
    ret
.end:
    xor a ; ld a, 0
    ret

OffScreenYEnemies::
    ; b = x value to check
    ; return a (1 = end of screen)
    ld a, SCRN_Y
    add OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .end
    ld a, SCRN_VY
    sub OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .end
    ld a, 1
    ret
.end:
    xor a ; ld a, 0
    ret

OffScreenX::
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

OffScreenY::
    ; b = x value to check
    ; return a (1 = end of screen)
    ld a, SCRN_Y
    sub WINDOW_LAYER_HEIGHT
    cp a, b
    jr nc, .end
    ld a, 1
    ret
.end:
    xor a ; ld a, 0
    ret