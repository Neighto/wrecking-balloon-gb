INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

COLLISION_UPDATE_TIME EQU %00000011
OFF_SCREEN_ENEMY_BUFFER EQU 16

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
	and	COLLISION_UPDATE_TIME
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
    SET_HL_TO_ADDRESS wOAM, wPointBalloonOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wPlayerCactusOAM
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
    SET_HL_TO_ADDRESS wOAM, wEnemyBalloonOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wPlayerCactusOAM
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .checkEnemyHitPlayer
    call DeathOfEnemy
    jr .endEnemy
.checkEnemyHitPlayer:
    SET_HL_TO_ADDRESS wOAM, wPlayerBalloonOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wEnemyCactusOAM
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .endEnemy
    jp .collisionWithPlayer
.endEnemy:
    ; Enemy 2
    ; Check if alive
    ld a, [enemy2_alive]
    and 1
    jr z, .endEnemy2
    ; Check collision
    SET_HL_TO_ADDRESS wOAM, wEnemy2BalloonOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wPlayerCactusOAM
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .checkEnemy2HitPlayer
    ; Collided
    call DeathOfEnemy2
    jr .endEnemy2
.checkEnemy2HitPlayer:
    SET_HL_TO_ADDRESS wOAM, wPlayerBalloonOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wEnemy2CactusOAM
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .endEnemy2
    jp .collisionWithPlayer
.endEnemy2:
    ; BOMB
    ; Check if alive
    ld a, [bomb_alive]
    and 1
    jr z, .endBomb
    ; Check collision
    SET_HL_TO_ADDRESS wOAM, wBombOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wPlayerCactusOAM
    xor a ; ld a, 0
    call CollisionCheck
    and 1
    jr z, .endBomb
    call DeathOfBomb
    jp .collisionWithPlayer
.endBomb:
    ; Bird
    ; Check if alive
    ld a, [bird_alive]
    and 1
    jr z, .endBird
    ; Check collision bird
    SET_HL_TO_ADDRESS wOAM, wPlayerBalloonOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wBirdOAM
    ld a, 1
    call CollisionCheck
    and 1
    jr z, .endBird
    jp .collisionWithPlayer
.endBird:
    ; Enemy cactus hit bird
    ; Check if alive
    ld a, [bird_alive]
    cp a, 0
    jr z, .endCactusHitBird
    ; Check if falling
    ld a, [enemy_falling]
    cp a, 0
    jr z, .endCactusHitBird
    SET_HL_TO_ADDRESS wOAM, wEnemyCactusOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wBirdOAM
    ld a, 1
    call CollisionCheck
    and 1
    jr z, .endCactusHitBird
    call DeathOfBird
.endCactusHitBird
    ; Enemy cactus 2 hit bird
    ; Check if alive
    ld a, [bird_alive]
    cp a, 0
    jr z, .endCactus2HitBird
    ; Check if falling
    ld a, [enemy2_falling]
    cp a, 0
    jr z, .endCactus2HitBird
    SET_HL_TO_ADDRESS wOAM, wEnemy2CactusOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wBirdOAM
    ld a, 1
    call CollisionCheck
    and 1
    jr z, .endCactus2HitBird
    call DeathOfBird
.endCactus2HitBird
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