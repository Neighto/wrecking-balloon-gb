INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "tileConstants.inc"

PROJECTILE_OAM_SPRITES EQU 1
PROJECTILE_OAM_BYTES EQU PROJECTILE_OAM_SPRITES * 4
PROJECTILE_COLLISION_TIME EQU %00000011
PROJECTILE_FLICKER_TIME EQU %00000011
PROJECTILE_WAIT_TO_KILL_DURATION EQU 7

PROJECTILE_WIDTH EQU 8
PROJECTILE_HEIGHT EQU 8

PROJECTILE_VERTICAL_SPEED EQU 1
PROJECTILE_HORIZONTAL_SPEED EQU 2

; hEnemyParam1 = Add to Y
; hEnemyParam2 = Add to X
; hEnemyParam3 = Can Kill Timer

SECTION "enemy projectile", ROMX

; SPAWN
SpawnProjectile::
    ld b, PROJECTILE_OAM_SPRITES
    call FindRAMAndOAMForEnemy ; hl = RAM space, b = OAM offset
    ret z
    ; Initialize
    ld a, b
    ldh [hEnemyOAM], a
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    ldh [hEnemyFlags], a
.setupY2:
    ldh a, [hPlayerY]
    ld d, a
    ldh a, [hEnemyY]
    sub a, 8
    cp a, d
    jr nc, .up
    add a, 16
    cp a, d
    jr c, .down
.middleY:
    xor a ; ld a, 0
    jr .endY
.up:
    ld a, -PROJECTILE_VERTICAL_SPEED
    jr .endY
.down:
    ld a, PROJECTILE_VERTICAL_SPEED
.endY:
    ldh [hEnemyParam1], a
.endSetupY2:
.setupX2:
    ldh a, [hPlayerX]
    ld d, a
    ldh a, [hEnemyX]
    cp a, d
    jr c, .right
.left:
    ld a, -PROJECTILE_HORIZONTAL_SPEED
    jr .endX
.right:
    ld a, PROJECTILE_HORIZONTAL_SPEED
.endX:
    ldh [hEnemyParam2], a
.endSetupX2:
    ; Get hl pointing to OAM address
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
.projectileOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, PROJECTILE_TILE
    ld [hli], a
    ld [hl], OAMF_PAL0
.projectileSound:
    call ProjectileSound
.setStruct:
    LD_HL_BC
    jp SetEnemyStruct

; UPDATE
ProjectileUpdate::

.checkFlicker:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	PROJECTILE_FLICKER_TIME
    jr nz, .endFlicker
.canFlicker:
    ld hl, wOAM+3
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld a, [hl]
    cp a, OAMF_PAL0
    jr z, .palette1
.palette0:
    ld [hl], OAMF_PAL0
    jr .endFlicker
.palette1:
    ld [hl], OAMF_PAL1
.endFlicker:

.checkMove:
.projectileOAM:
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ldh a, [hEnemyY]
    ld b, a
    ldh a, [hEnemyParam1]
    add a, b
    ldh [hEnemyY], a
    ld [hli], a
    ldh a, [hEnemyX]
    ld b, a
    ldh a, [hEnemyParam2]
    add a, b
    ldh [hEnemyX], a
    ld [hl], a
.endMove:

.checkCollision:
    ; Has been alive long enough (prevent some cheap kills / stuns)
    ldh a, [hEnemyParam3]
    cp a, PROJECTILE_WAIT_TO_KILL_DURATION
    jr nc, .checkCollisionContinue
    inc a
    ldh [hEnemyParam3], a
    jr .endCollision
.checkCollisionContinue:
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	PROJECTILE_COLLISION_TIME
    jr nz, .endCollision
    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld d, PROJECTILE_WIDTH
    ld e, PROJECTILE_HEIGHT
    call CollisionCheck
    jr z, .checkHitCactus
    call CollisionWithPlayer
    jr .deathOfProjectile
.checkHitCactus:
    ld bc, wPlayerCactusOAM
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld d, PROJECTILE_WIDTH
    ld e, PROJECTILE_HEIGHT
    call CollisionCheck
    jr z, .endCollision
    call CollisionWithPlayerCactus
.deathOfProjectile:
    ld bc, PROJECTILE_OAM_BYTES
    call ClearEnemy
    jr .setStruct
.endCollision:

.checkOffscreenX:
    ld bc, PROJECTILE_OAM_BYTES
    call HandleEnemyOffscreenHorizontal
    ; Enemy may be cleared, must do setStruct next
.endOffscreenX:

.setStruct:
    ld hl, wEnemies
    ldh a, [hEnemyOffset]
    ADD_A_TO_HL
    jp SetEnemyStruct