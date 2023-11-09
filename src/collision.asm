INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "playerConstants.inc"

COLLISION_UPDATE_TIME EQU %00000011

SECTION "collision vars", WRAM0[COLLISION_VAR_ADDRESS]
wColliderA:: DS 4
wColliderB:: DS 4

SECTION "collision", ROM0

; TODO: Call it somewhere
; InitializeCollision:: 
;     ld bc, wColliderA
;     call ResetHLInRange
;     ld bc, wColliderB
;     jp ResetHLInRange

CollisionCheckBoss::
    SETUP_BOSS_COLLIDER 0, 32, 2, 28
    jr CollisionCheck

CollisionCheckBullet::
    SETUP_BULLET_COLLIDER BULLET_COLLISION_Y, BULLET_COLLISION_HEIGHT, BULLET_COLLISION_X, BULLET_COLLISION_WIDTH
    jr CollisionCheck

CollisionCheckPlayerCactus::
    SETUP_PLAYER_CACTUS_COLLIDER 1, 14, 1, 14
    jr CollisionCheck

CollisionCheckPlayerBalloon::
    SETUP_PLAYER_BALLOON_COLLIDER 1, 12, 1, 14
    ; jr CollisionCheck

; Must set collider vars before calling
; Ret: Z/NZ = No collision / collision respectively
CollisionCheck::
    ld hl, wColliderA
    ld bc, wColliderB

.checkY:
    ld a, [bc]
    cp a, [hl] ; cp C_A_Y1, C_B_Y1
    jr c, .tryAY2
.tryBY2:
    inc l
    ld a, [bc]
    cp a, [hl] ; cp C_A_Y1, C_B_Y2
    jr nc, .noCollision
    inc c
    jr .checkX
.tryAY2:
    inc c
    ld a, [bc]
    cp a, [hl] ; cp C_A_Y2, C_B_Y1
    inc l
    jr c, .noCollision
    ; jr .checkX

.checkX:
    inc c
    inc l
    ld a, [bc]
    cp a, [hl] ; cp C_A_X1, C_B_X1
    jr c, .tryAX2
.tryBX2:
    inc l
    ld a, [bc]
    cp a, [hl] ; cp C_A_X1, C_B_X2
    jr nc, .noCollision
    jr .collision
.tryAX2:
    inc c
    ld a, [bc]
    cp a, [hl] ; cp C_A_X2, C_B_X1
    inc l
    jr c, .noCollision
    ; jr .collision

.collision:
    or a, 1 ; Success
    ret
.noCollision:
    xor a ; ld a, 0 ; Fail
    ret