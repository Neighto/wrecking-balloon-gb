INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

COLLISION_UPDATE_TIME EQU %00000011

SECTION "collision", ROM0

CollisionCheck::
    ; bc = argument for colliding target (16x16 pixels)
    ; hl = argument for collider
    ; d = argument for X size check (ex: 8 for 8 pixels long collider)
    ; e = argument for Y size check (ex: 16 for 16 pixels high collider)
    ; a = return result (0 = no collision)

.checkY:
    ld a, [bc]
    cp a, [hl]
    jr nc, .tryColliderY
    ; Target y < collider y
    add 16
    cp a, [hl]
    jr nc, .checkX
    ; Target y' < collider y
    jr .noCollision

.tryColliderY:
    ld a, [hl]
    add a, e ; e no longer needed for Y size check after this
    ld e, a

    ld a, [bc]
    cp a, e
    jr nc, .noCollision
    ; Target y < collider y'

.checkX:
    inc l ; collider+1
    inc c ; target+1
    ld a, [bc]
    cp a, [hl]
    jr nc, .tryColliderX
    ; Target x < collider x
    add 16
    cp a, [hl]
    jr nc, .collision
    ; Target x' < collider x
    jr .noCollision

.tryColliderX:
    ld a, [hl]
    add a, d ; d no longer needed for X size check after this
    ld d, a

    ld a, [bc]
    cp a, d
    jr nc, .noCollision
    ; Target x < collider x'

.collision:
    ld a, 1 ; Success
    ret
.noCollision:
    xor a ; ld a, 0 ; Fail
    ret