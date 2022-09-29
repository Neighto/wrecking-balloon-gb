INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

PROJECTILE_OAM_SPRITES EQU 1
PROJECTILE_OAM_BYTES EQU PROJECTILE_OAM_SPRITES * 4
PROJECTILE_COLLISION_TIME EQU %00000011
PROJECTILE_FLICKER_TIME EQU %00000011
PROJECTILE_VERTICAL_SPEED EQU 1
PROJECTILE_HORIZONTAL_SPEED EQU 2
PROJECTILE_TILE EQU $46

; hEnemyParam1 = Add to Y
; hEnemyParam2 = Add to X

SECTION "enemy projectile", ROM0

SpawnProjectile::
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
.availableSpace:
    ld b, PROJECTILE_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    ret z
.availableOAMSpace:
    call InitializeEnemyStructVars
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
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
.projectileOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, PROJECTILE_TILE
    ld [hli], a
    ld [hl], OAMF_PAL0
.setStruct:
    LD_HL_BC
    call SetEnemyStruct
.end:
    call ProjectileSound
    ret

ProjectileUpdate::

.checkFlicker:
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	PROJECTILE_FLICKER_TIME
    jr nz, .endFlicker
.canFlicker:
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
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
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
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
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and	PROJECTILE_COLLISION_TIME
    jr nz, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 8
    ld e, 8
    call CollisionCheck
    jr z, .checkHitCactus
    call CollisionWithPlayer
    jr .deathOfProjectile
.checkHitCactus:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 8
    ld e, 8
    call CollisionCheck
    jr z, .endCollision
    call CollisionWithPlayerCactus
.deathOfProjectile:
    ld bc, PROJECTILE_OAM_BYTES
    call ClearEnemy
    jr .setStruct
.endCollision:

.checkOffscreenY:
    ldh a, [hEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreenY
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreenY
.offscreenY:
    ld bc, PROJECTILE_OAM_BYTES
    call ClearEnemy
.endOffscreenY:
    
.checkOffscreenX:
    ldh a, [hEnemyX]
    ld b, a
    ld a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreenX
    ld a, SCRN_VX - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreenX
.offscreenX:
    ld bc, PROJECTILE_OAM_BYTES
    call ClearEnemy
.endOffscreenX:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    jp SetEnemyStruct