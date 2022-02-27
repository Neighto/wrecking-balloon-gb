INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

COLLISION_UPDATE_TIME EQU %00000011
OFF_SCREEN_ENEMY_BUFFER EQU 16

SECTION "collision", ROM0

CollisionCheck::
    ; bc = argument for target colliding with player cactus
    ; hl = argument for collider
    ; d = unused
    ; e = argument for Y size check (ex: 16 for 16 pixels high)
    ; a = return result (0 = no collision)

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

.tryOtherY:
    ; Also check OR cactus_y'
    ld a, [hl]
    add a, e
    ld e, a ; We no longer need e

    ld a, [bc]
    cp a, e
    jr nc, .noCollision
    ; cactus_y'[c'] > balloon_y[a]
    add 16
    cp a, e
    jr c, .noCollision
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
    ld e, a

    ld a, [bc]
    cp a, e
    jr nc, .noCollision
    ; cactus_x'[c'] > balloon_x[a]
    add 16
    cp a, e
    jr c, .noCollision
    ; cactus_x'[c'] < balloon_x'[a']

.collision:
    ld a, 1 ; Success
    ret
.noCollision:
    xor a ; ld a, 0 ; Fail
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