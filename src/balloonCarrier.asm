INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BALLOON_CARRIER_OAM_SPRITES EQU 4
BALLOON_CARRIER_OAM_BYTES EQU BALLOON_CARRIER_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
BALLOON_CARRIER_MOVE_TIME EQU %00000011
BALLOON_CARRIER_COLLISION_TIME EQU %00000111

PROJECTILE_RESPAWN_TIME EQU %01111111
PROJECTILE_RESPAWN_FLICKER_TIME EQU %01101111

BALLOON_CACTUS_TILE EQU $14

BALLOON_CARRIER_NORMAL_TILE EQU $64
BALLOON_CARRIER_NORMAL_POINTS EQU 10

BALLOON_CARRIER_PROJECTILE_TILE EQU $44
BALLOON_CARRIER_PROJECTILE_POINTS EQU 15

BALLOON_CARRIER_FOLLOW_TILE EQU ENEMY_BALLOON_TILE
BALLOON_CARRIER_FOLLOW_POINTS EQU 30

BALLOON_CARRIER_BOMB_TILE EQU $22
BALLOON_CARRIER_BOMB_POINTS EQU 50

BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_MASK EQU ENEMY_FLAG_PARAM1_MASK
BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_BIT EQU ENEMY_FLAG_PARAM1_BIT

SECTION "balloon carrier", ROMX

SetStruct:
    ; Argument hl = start of free enemy struct
    ldh a, [hEnemyFlags] ; BIT #: [5=trigger carry]
    ld [hli], a
    ldh a, [hEnemyNumber]
    ld [hli], a
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ldh a, [hEnemyOAM]
    ld [hli], a
    ldh a, [hEnemyAnimationFrame]
    ld [hli], a
    ldh a, [hEnemyAnimationTimer]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Enemy Projectile Timer / Bobbing Index
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hl], a
    ret

SpawnBalloonCarrier::
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
.availableSpace:
    ld b, BALLOON_CARRIER_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    ret z
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ldh [hEnemyOAM], a
    LD_BC_DE
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    set ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a

.updateDirection:
    ldh a, [hEnemyX]
    cp a, SCRN_X / 2
    jr c, .endUpdateDirection
    cp a, SPAWN_ENEMY_LEFT_BUFFER
    jr nc, .endUpdateDirection
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DIRECTION_BIT, a
    ldh [hEnemyFlags], a
.endUpdateDirection:

    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.variantVisualBalloon:
    ldh a, [hEnemyVariant]
.followVisualBalloon:
    cp a, CARRIER_FOLLOW_VARIANT
    jr nz, .projectileVisualBalloon
    ld d, BALLOON_CARRIER_FOLLOW_TILE
    ld e, OAMF_PAL1
    jr .endVariantVisualBalloon
.projectileVisualBalloon:
    cp a, CARRIER_PROJECTILE_VARIANT
    jr nz, .bombVisualBalloon
    ld d, BALLOON_CARRIER_PROJECTILE_TILE
    ld e, OAMF_PAL0
    jr .endVariantVisualBalloon
.bombVisualBalloon:
    cp a, CARRIER_BOMB_VARIANT
    jr nz, .normalVisualBalloon
    ld d, BALLOON_CARRIER_BOMB_TILE
.bombVisualBalloonCheckNightSprite:
    ldh a, [rOBP1]
    cp a, NIGHT_SPRITE_PAL1
    jr nz, .bombVisualBalloonIsNotNightSprite
.bombVisualBalloonIsNightSprite:
    ld e, OAMF_PAL0
    jr .endCheckNightSprite
.bombVisualBalloonIsNotNightSprite:
    ld e, OAMF_PAL1
.endCheckNightSprite:
    jr .endVariantVisualBalloon
.normalVisualBalloon:
    ld d, BALLOON_CARRIER_NORMAL_TILE
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
    cp a, CARRIER_ANVIL_VARIANT
    jr nz, .cactusVisualCarryLeft
.anvilVisualCarryLeft:
    ld d, ANVIL_TILE_1
    ld e, OAMF_PAL0
    jr .endVariantVisualCarryLeft
.cactusVisualCarryLeft:
    ld d, BALLOON_CACTUS_TILE
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
    cp a, CARRIER_ANVIL_VARIANT
    jr nz, .cactusVisualCarryRight
.anvilVisualCarryRight:
    ld d, ANVIL_TILE_2
    ld e, OAMF_PAL0
    jr .endVariantVisualCarryRight
.cactusVisualCarryRight:
    ld d, BALLOON_CACTUS_TILE
    ld e, OAMF_PAL0 | OAMF_XFLIP
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
    ret

BalloonCarrierUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyAnimationFrame], a
    ld a, [hli]
    ldh [hEnemyAnimationTimer], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hl]
    ldh [hEnemyVariant], a

.checkAlive:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_ALIVE_MASK
    jr nz, .isAlive
.isPopping:
    ldh a, [hEnemyFlags]
    res BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_BIT, a
    ldh [hEnemyFlags], a
    and ENEMY_FLAG_DYING_MASK
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

.moveHorizontalVariant:
    ldh a, [hEnemyVariant]
.anvilMoveHorizontal:
    cp a, CARRIER_ANVIL_VARIANT
    jr z, .endMoveHorizontalVariant
.moveHorizontal:
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_DIRECTION_MASK
    ld hl, hEnemyX
    jr z, .isLeftside
    dec [hl]
    jr .endMoveHorizontalVariant
.isLeftside:
    inc [hl]
.endMoveHorizontalVariant:

.moveVerticalVariant:
    ldh a, [hEnemyVariant]
.anvilMoveVertical:
    cp a, CARRIER_ANVIL_VARIANT
    jr nz, .followMoveVertical
    ldh a, [hEnemyY]
    cp a, 28
    jr c, .moveDown
    cp a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    jr nc, .moveDown
.checkBobbing:
    ldh a, [hGlobalTimer]
    and %00111111
    jr nz, .endCheckBobbing
    ldh a, [hEnemyParam1]
    cp a, 0
    jr nz, .bobUp
.bobDown:
    ld a, 1
    ldh [hEnemyParam1], a
    ldh a, [hEnemyY]
    inc a
    ldh [hEnemyY], a
    jr .endCheckBobbing
.bobUp:
    ld a, 0
    ldh [hEnemyParam1], a
    ldh a, [hEnemyY]
    dec a
    ldh [hEnemyY], a
.endCheckBobbing:
    jr .endMoveVerticalVariant

.followMoveVertical:
    cp a, CARRIER_FOLLOW_VARIANT
    jr nz, .endMoveVerticalVariant
    ; Follow player
    ldh a, [hEnemyY]
    add 16
    ld hl, hPlayerY
    cp a, [hl]
    jr z, .endMoveVerticalVariant
    jr c, .moveDown
.moveUp:
    ld hl, hEnemyY
    dec [hl]
    jr .endMoveVerticalVariant
.moveDown:
    ld hl, hEnemyY
    inc [hl]
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
    cp a, CARRIER_PROJECTILE_VARIANT 
    jr nz, .endProjectileVariant
    ldh a, [hEnemyParam1]
    cp a, PROJECTILE_RESPAWN_TIME + 1
    jr c, .skipResetSpawn
.resetSpawn:
    xor a ; ld a, 0
    ldh [hEnemyParam1], a
    jr .endProjectileVariant
.skipResetSpawn:
    inc a
    ldh [hEnemyParam1], a
.endProjectileVariant:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BALLOON_CARRIER_COLLISION_TIME
    jp nz, .endCollision
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .deathOfBalloonCarrier
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+8, hEnemyOAM
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
    cp a, CARRIER_BOMB_VARIANT 
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
.normalPoints:
    cp a, CARRIER_NORMAL_VARIANT
    jr nz, .followPoints
    ld d, BALLOON_CARRIER_NORMAL_POINTS
    jr .endVariantPoints
.followPoints:
    cp a, CARRIER_FOLLOW_VARIANT
    jr nz, .projectilePoints
    ld d, BALLOON_CARRIER_PROJECTILE_POINTS
    jr .endVariantPoints
.projectilePoints:
    cp a, CARRIER_PROJECTILE_VARIANT
    jr nz, .bombPoints
    ld d, BALLOON_CARRIER_FOLLOW_POINTS
    jr .endVariantPoints
.bombPoints:
    cp a, CARRIER_BOMB_VARIANT
    jr nz, .endVariantPoints
    ld d, BALLOON_CARRIER_BOMB_POINTS
.endVariantPoints:
    call AddPoints

    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_ALIVE_BIT, a
    ld [hEnemyFlags], a
    ; Hide carry visual
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    ld a, EMPTY_TILE
    ld [hli], a
    inc hl
    inc hl
    inc hl
    ld [hl], a
    ; Animation trigger
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DYING_BIT, a
    set BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_BIT, a
    ldh [hEnemyFlags], a
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
    ldh a, [hEnemyFlags]
    and BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_MASK
    jr z, .variantEndSpawnCarry
.variantSpawnExplosion:
    ldh a, [hEnemyVariant]
    cp a, CARRIER_BOMB_VARIANT
    jr nz, .endVariantSpawnExplosion
    ld a, EXPLOSION
    ldh [hEnemyNumber], a
    ld a, EXPLOSION_BOMB_VARIANT
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
    cp a, CARRIER_ANVIL_VARIANT
    jr nz, .cactusSpawnCarry
    ld a, ANVIL_NORMAL_VARIANT
    ldh [hEnemyVariant], a
    jr .spawnCarryEnd
.cactusSpawnCarry:
    ld a, ANVIL_CACTUS_VARIANT
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
    ldh a, [hEnemyParam1]
    cp a, PROJECTILE_RESPAWN_FLICKER_TIME
    jr c, .endFlicker
    cp a, PROJECTILE_RESPAWN_TIME
    jr nc, .endFlicker
.canFlicker:
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
    ldh a, [hEnemyParam1]
    and	%00000011
    jr nz, .flickerOn
.flickerOff:
    ld a, OAMF_PAL1
    jr .flickerCommon
.flickerOn:
    ld a, OAMF_PAL0
.flickerCommon:
    ld [hli], a
    inc l
    inc l
    inc l
    or a, OAMF_XFLIP
    ld [hli], a
.endFlicker:
    ldh a, [hEnemyParam1]
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