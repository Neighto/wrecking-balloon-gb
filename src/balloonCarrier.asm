INCLUDE "balloonConstants.inc"
INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BALLOON_CARRIER_OAM_SPRITES EQU 4
BALLOON_CARRIER_OAM_BYTES EQU BALLOON_CARRIER_OAM_SPRITES * 4
BALLOON_CARRIER_MOVE_TIME EQU %00000011
BALLOON_CARRIER_COLLISION_TIME EQU %00001000

PROJECTILE_RESPAWN_TIME EQU %01011111

BALLOON_CACTUS_TILE EQU $14

BALLOON_CACTUS_EASY_TILE EQU $44
BALLOON_CACTUS_EASY_POINTS EQU 15

BALLOON_CACTUS_MEDIUM_TILE EQU ENEMY_BALLOON_TILE
BALLOON_CACTUS_MEDIUM_POINTS EQU 30

BALLOON_CACTUS_HARD_TILE EQU $22
BALLOON_CACTUS_HARD_POINTS EQU 50

SECTION "balloon carrier", ROMX

SetStruct:
    ; Argument hl = start of free enemy struct
    ldh a, [hEnemyActive]
    ld [hli], a
    ldh a, [hEnemyNumber]
    ld [hli], a
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ldh a, [hEnemyOAM]
    ld [hli], a
    ldh a, [hEnemyAlive]
    ld [hli], a
    ldh a, [hEnemyDying]
    ld [hli], a
    ldh a, [hEnemyAnimationFrame]
    ld [hli], a
    ldh a, [hEnemyAnimationTimer]
    ld [hli], a
    ldh a, [hEnemyDirectionLeft]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Trigger Carry
    ld [hli], a
    ldh a, [hEnemyParam2] ; Enemy Projectile Timer
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hl], a
    ret

SpawnBalloonCarrier::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jp z, .end
.availableSpace:
    ld b, BALLOON_CARRIER_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    jp z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ldh [hEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ldh [hEnemyActive], a
    ldh [hEnemyAlive], a

.updateDirection:
    ldh a, [hEnemyX]
    cp a, SCRN_X / 2
    jr c, .endUpdateDirection
    ld a, 1
    ldh [hEnemyDirectionLeft], a
.endUpdateDirection:

    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.variantVisualBalloon:
    ldh a, [hEnemyVariant]
.followVisualBalloon:
    cp a, FOLLOW_VARIANT
    jr nz, .projectileVisualBalloon
    ld d, BALLOON_CACTUS_MEDIUM_TILE
    ld e, OAMF_PAL1
    jr .endVariantVisualBalloon
.projectileVisualBalloon:
    cp a, PROJECTILE_VARIANT
    jr nz, .bombVisualBalloon
    ld d, BALLOON_CACTUS_EASY_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisualBalloon
.bombVisualBalloon:
    cp a, BOMB_VARIANT
    jr nz, .anvilVisualBalloon
    ld d, BALLOON_CACTUS_HARD_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisualBalloon
.anvilVisualBalloon:
    ld d, $3A
    ld e, OAMF_PAL0
.endVariantVisualBalloon:

.balloonLeftOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
.balloonRightOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    or a, OAMF_XFLIP
    ld [hli], a

.variantVisualCarryLeft:
    ldh a, [hEnemyVariant]
.followVisualCarryLeft:
    cp a, FOLLOW_VARIANT
    jr z, .cactusVisualCarryLeft
.projectileVisualCarryLeft:
    cp a, PROJECTILE_VARIANT
    jr z, .cactusVisualCarryLeft
.bombVisualCarryLeft:
    cp a, BOMB_VARIANT
    jr nz, .anvilVisualCarryLeft
.cactusVisualCarryLeft:
    ld d, BALLOON_CACTUS_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisualCarryLeft
.anvilVisualCarryLeft:
    ld d, $48
    ld e, OAMF_PAL0
.endVariantVisualCarryLeft:

.cactusLeftOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a

.variantVisualCarryRight:
    ldh a, [hEnemyVariant]
.followVisualCarryRight:
    cp a, FOLLOW_VARIANT
    jr z, .cactusVisualCarryRight
.projectileVisualCarryRight:
    cp a, PROJECTILE_VARIANT
    jr z, .cactusVisualCarryRight
.bombVisualCarryRight:
    cp a, BOMB_VARIANT
    jr nz, .anvilVisualCarryRight
.cactusVisualCarryRight:
    ld d, BALLOON_CACTUS_TILE
    ld e, OAMF_PAL0 | OAMF_XFLIP
    jr .endVariantVisualCarryRight
.anvilVisualCarryRight:
    ld d, $4A
    ld e, OAMF_PAL0
.endVariantVisualCarryRight:

.cactusRightOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

BalloonCarrierUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ldh [hEnemyOAM], a
    ld a, [hli]
    ldh [hEnemyAlive], a
    ld a, [hli]
    ldh [hEnemyDying], a
    ld a, [hli]
    ldh [hEnemyAnimationFrame], a
    ld a, [hli]
    ldh [hEnemyAnimationTimer], a
    ld a, [hli]
    ldh [hEnemyDirectionLeft], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hli]
    ldh [hEnemyParam2], a
    ld a, [hl]
    ldh [hEnemyVariant], a

.checkAlive:
    ldh a, [hEnemyAlive]
    cp a, 0
    jr nz, .isAlive
.isPopping:
    xor a ; ld a, 0
    ldh [hEnemyParam1], a
    ldh a, [hEnemyDying]
    cp a, 0
    jr z, .clearPopping
.animatePopping:
    call PopBalloonAnimation
    jp .setStruct
.clearPopping:
    ld bc, BALLOON_CARRIER_OAM_BYTES
    call ClearEnemy
    jp .setStruct
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	BALLOON_CARRIER_MOVE_TIME
    jp nz, .endMove
.canMove:

.moveHorizontal:
    ldh a, [hEnemyDirectionLeft]
    cp a, 0
    jr z, .isLeftside
    DECREMENT_POS hEnemyX, 1
    jr .endMoveHorizontal
.isLeftside:
    INCREMENT_POS hEnemyX, 1
.endMoveHorizontal:

.moveVerticalVariant:
    ldh a, [hEnemyVariant]
.followMoveVertical:
    cp a, FOLLOW_VARIANT
    jr nz, .endMoveVerticalVariant
    ; Follow player
    ldh a, [hEnemyY]
    add 16
    ld hl, hPlayerY
    cp a, [hl]
    jr z, .endMoveVerticalVariant
    jr c, .moveDown
.moveUp:
    DECREMENT_POS hEnemyY, 1
    jr .endMoveVerticalVariant
.moveDown:
    INCREMENT_POS hEnemyY, 1
.endMoveVerticalVariant:

.updatePosition:
.balloonLeftOAM:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    inc l
    inc l
.balloonRightOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.carryLeftOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    inc l
    inc l
.carryRightOAM:
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.endMove:

.checkProjectileVariant:
    ldh a, [hEnemyVariant]
.projectileVariant:
    cp a, PROJECTILE_VARIANT 
    jr nz, .endProjectileVariant
    ldh a, [hEnemyParam2]
    inc a
    ldh [hEnemyParam2], a
    cp a, PROJECTILE_RESPAWN_TIME + 1
    jr c, .endProjectileVariant
    xor a ; ld a, 0
    ldh [hEnemyParam2], a
.endProjectileVariant:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BALLOON_CARRIER_COLLISION_TIME
    jp nz, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+12, hEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 16
    ld e, 12
    call CollisionCheck
    cp a, 0
    jr z, .checkHitByBullet
.checkHitVariant:
    ldh a, [hEnemyVariant]
    cp a, BOMB_VARIANT 
    call z, CollisionWithPlayer
.endHitVariant:
    jr .deathOfBalloonCarrier
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld d, 8
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet

.deathOfBalloonCarrier:
    ld d, 0
.variantPoints:
    ldh a, [hEnemyVariant]
.followPoints:
    cp a, FOLLOW_VARIANT
    jr nz, .projectilePoints
    ld d, BALLOON_CACTUS_EASY_POINTS
    jr .endVariantPoints
.projectilePoints:
    cp a, PROJECTILE_VARIANT
    jr nz, .bombPoints
    ld d, BALLOON_CACTUS_MEDIUM_POINTS
    jr .endVariantPoints
.bombPoints:
    cp a, BOMB_VARIANT
    jr nz, .endVariantPoints
    ld d, BALLOON_CACTUS_HARD_POINTS
.endVariantPoints:
    call AddPoints

    xor a ; ld a, 0
    ld [hEnemyAlive], a
    ; Hide carry visual
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    ld a, EMPTY_TILE
    ld [hli], a
    inc hl
    inc hl
    inc hl
    ld [hl], a
    ; Animation trigger
    ld a, 1
    ldh [hEnemyDying], a
    ldh [hEnemyParam1], a
    ; Sound
    call PopSound
.endCollision:

.checkOffscreen:
    ldh a, [hEnemyX]
    ld b, a
    ld a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VX - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    ld bc, BALLOON_CARRIER_OAM_BYTES
    call ClearEnemy
.endOffscreen:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct

.checkSpawnCarry:
    ldh a, [hEnemyParam1]
    cp a, 0
    jr z, .variantEndSpawnCarry
.variantSpawnExplosion:
    ldh a, [hEnemyVariant]
    cp a, BOMB_VARIANT
    jr nz, .endVariantSpawnExplosion
    ld a, EXPLOSION
    ldh [hEnemyNumber], a
    ld a, NONE
    ldh [hEnemyVariant], a
    ldh a, [hEnemyX]
    sub 4
    ldh [hEnemyX], a
    call SpawnExplosion
    ldh a, [hEnemyX]
    add 4
    ldh [hEnemyX], a
.endVariantSpawnExplosion:
.variantSpawnCarry:
    ldh a, [hEnemyVariant]
.anvilSpawnCarry:
    cp a, ANVIL_VARIANT
    jr nz, .cactusSpawnCarry
    ld a, NONE
    ldh [hEnemyVariant], a
    jr .spawnCarryEnd
.cactusSpawnCarry:
    ld a, CACTUS_VARIANT
    ldh [hEnemyVariant], a
.spawnCarryEnd:
    ld a, ANVIL
    ldh [hEnemyNumber], a
    ldh a, [hEnemyY]
    add 16
    ldh [hEnemyY], a
    call SpawnAnvil
.variantEndSpawnCarry:

.checkSpawnProjectile:
    ldh a, [hEnemyParam2]
    cp a, PROJECTILE_RESPAWN_TIME - 20
    jr c, .endFlicker
    cp a, PROJECTILE_RESPAWN_TIME
    jr nc, .endFlicker
.canFlicker:
    and	%00000001
    jr nz, .flickerOff
.flickerOn:
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hli], a
    jr .endFlicker
.flickerOff:
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
    ld a, OAMF_PAL1
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, OAMF_PAL1 | OAMF_XFLIP
    ld [hli], a
.endFlicker:
    ldh a, [hEnemyParam2]
    cp a, PROJECTILE_RESPAWN_TIME
    jr nz, .endSpawnProjectile
.spawnProjectile:
    ld a, PROJECTILE
    ldh [hEnemyNumber], a
    ldh a, [hEnemyY]
    add a, 4
    ldh [hEnemyY], a
    ldh a, [hEnemyX]
    add a, 4
    ldh [hEnemyX], a
    call SpawnProjectile
.endSpawnProjectile:
    ret