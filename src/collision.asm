INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"

COLLISION_UPDATE_TIME EQU %00000011

SECTION "collision", ROM0

; Arg: BC = Colliding target (16x16 pixels)
; Arg: HL = Collider
; Arg: D = X size check (ex: 8 for 8 pixels long collider)
; Arg: E = Y size check (ex: 16 for 16 pixels high collider)
; Ret: Z/NZ = No collision / collision respectively
CollisionCheck::

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
    or a, 1 ; Success
    ret
.noCollision:
    xor a ; ld a, 0 ; Fail
    ret