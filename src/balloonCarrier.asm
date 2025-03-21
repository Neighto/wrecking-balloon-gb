INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "tileConstants.inc"

BALLOON_CARRIER_OAM_SPRITES EQU 4
BALLOON_CARRIER_OAM_BYTES EQU BALLOON_CARRIER_OAM_SPRITES * OAM_ATTRIBUTES_COUNT
BALLOON_CARRIER_MOVE_TIME EQU %00000001
BALLOON_CARRIER_COLLISION_TIME EQU %00000011
BALLOON_CARRIER_CACTUS_BOB_TIME EQU %00111111

BALLOON_CARRIER_COLLISION_Y EQU 1
BALLOON_CARRIER_COLLISION_X EQU 1
BALLOON_CARRIER_COLLISION_HEIGHT EQU 14
BALLOON_CARRIER_COLLISION_WIDTH EQU 14

BALLOON_CARRIER_CACTUS_COLLISION_Y EQU 14
BALLOON_CARRIER_CACTUS_COLLISION_X EQU 1
BALLOON_CARRIER_CACTUS_COLLISION_HEIGHT EQU 18
BALLOON_CARRIER_CACTUS_COLLISION_WIDTH EQU 14

PROJECTILE_RESPAWN_TIME EQU 54
PROJECTILE_RESPAWN_TIME_SPAWN EQU PROJECTILE_RESPAWN_TIME / 2
PROJECTILE_RESPAWN_FLICKER_TIME EQU 40

BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_MASK EQU ENEMY_FLAG_PARAM1_MASK
BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_BIT EQU ENEMY_FLAG_PARAM1_BIT

BALLOON_CARRIER_FLAG_BOBBING_INDEX_MASK EQU ENEMY_FLAG_PARAM2_MASK
BALLOON_CARRIER_FLAG_BOBBING_INDEX_BIT EQU ENEMY_FLAG_PARAM2_BIT

; hEnemyFlags = BIT #: [5=trigger carry] [6=bobbing index]
; hEnemyParam1 = Animation Frame
; hEnemyParam2 = Animation Timer
; hEnemyParam3 = Enemy Projectile Timer

SECTION "balloon carrier", ROMX

; *************************************************************
; SPAWN
; *************************************************************
SpawnBalloonCarrier::
    ld b, BALLOON_CARRIER_OAM_SPRITES
    call FindRAMAndOAMForEnemy ; hl = RAM space, b = OAM offset
    ret z
    ;
    ; Initialize
    ;
    call InitializeEnemyStructVars
    ld a, b
    ldh [hEnemyOAM], a
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_ACTIVE_BIT, a
    set ENEMY_FLAG_ALIVE_BIT, a
    ldh [hEnemyFlags], a
    ld a, PROJECTILE_RESPAWN_TIME_SPAWN
    ldh [hEnemyParam3], a
    ;
    ; Update direction
    ;
    ldh a, [hEnemyX]
    cp a, SCRN_X / 2
    jr c, .finishedUpdatingDirection
    cp a, SPAWN_ENEMY_LEFT_BUFFER
    jr nc, .finishedUpdatingDirection
    ldh a, [hEnemyFlags]
    set ENEMY_FLAG_DIRECTION_BIT, a
    ldh [hEnemyFlags], a
.finishedUpdatingDirection:
    ;
    ; Get hl pointing to OAM address
    ;
    LD_BC_HL ; bc now contains RAM address
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ;
    ; Get balloon visual by variant
    ;
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
    ;
    ; Balloon left OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
    ;
    ; Balloon right OAM
    ;
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    or OAMF_XFLIP
    ld [hli], a
    ;
    ; Get cactus visual by variant (left)
    ;
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
    ;
    ; Cactus left OAM
    ;
    ldh a, [hEnemyY]
    add 16
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
    ;
    ; Get cactus visual by variant (right)
    ;
    ldh a, [hEnemyVariant]
    cp a, CARRIER_ANVIL_VARIANT
    jr nz, .cactusVisualCarryRight
.anvilVisualCarryRight:
    ld d, ANVIL_TILE_2
    ld e, OAMF_PAL0
    jr .endVariantVisualCarryRight
.cactusVisualCarryRight:
    ld d, BALLOON_CACTUS_TILE_2
    ld e, OAMF_PAL0 | OAMF_XFLIP
.endVariantVisualCarryRight:
    ;
    ; Cactus right OAM
    ;
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
    ;
    ; Set struct
    ;
    LD_HL_BC
    jp SetEnemyStructWithHL

; *************************************************************
; UPDATE
; *************************************************************
BalloonCarrierUpdate::

    ;
    ; Check alive
    ;
    ldh a, [hEnemyFlags]
    ld b, a
    and ENEMY_FLAG_ALIVE_MASK
    jr nz, .isAlive
    ; Is popping
    ; Check spawn carry
    ld a, b
    and BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_MASK
    jr z, .endCheckSpawnCarry
    ld a, b
    ; Reset carry spawn trigger
    res BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_BIT, a
    ldh [hEnemyFlags], a
    ; Hide carry visual
    ld hl, wOAM + 10
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld a, WHITE_SPR_TILE
    ld [hli], a
    inc l
    inc l
    inc l
    ld [hl], a
    ; Set struct before spawn
    call SetEnemyStruct
    ; Hold onto enemy variant for checking spawn explosion
    ldh a, [hEnemyVariant]
    push af

    ; VARIANT SPAWN CARRY
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

    ; a is enemy variant
    pop af

    ; VARIANT SPAWN EXPLOSION
    cp a, CARRIER_BOMB_VARIANT
    jr nz, .endVariantSpawnExplosion
    ld a, EXPLOSION
    ldh [hEnemyNumber], a
    ld a, EXPLOSION_BOMB_VARIANT
    ldh [hEnemyVariant], a
    ldh a, [hEnemyX]
    sub 4
    ldh [hEnemyX], a
    ldh a, [hEnemyY]
    sub 16
    ldh [hEnemyY], a
    call SpawnExplosion
.endVariantSpawnExplosion:
    ; Since we messed with shared enemy struct vars we end here
    ; Plus we do this to mitigate a peak in cycles
    ret

.endCheckSpawnCarry:

    ld a, b
    and ENEMY_FLAG_DYING_MASK
    jr z, .clearPopping
.animatePopping:
    call PopBalloonAnimation
    jp SetEnemyStruct
.clearPopping:
    ld bc, BALLOON_CARRIER_OAM_BYTES
    call ClearEnemy
    jp SetEnemyStruct
.isAlive:

    ;
    ; Check projectile variant
    ;
    ldh a, [hEnemyVariant]
.projectileVariant:
    cp a, CARRIER_PROJECTILE_VARIANT
    jr nz, .endProjectileVariant
    ldh a, [hEnemyParam3]
    cp a, PROJECTILE_RESPAWN_TIME
    jr c, .skipResetSpawn
.resetSpawn:
    xor a ; ld a, 0
    jr .updateSpawn
.skipResetSpawn:
    inc a
.updateSpawn:
    ldh [hEnemyParam3], a
.checkSpawnProjectile:
    cp a, PROJECTILE_RESPAWN_FLICKER_TIME
    jr c, .endFlicker
    cp a, PROJECTILE_RESPAWN_TIME
    jr nc, .endFlicker
.canFlicker:
    ld hl, wOAM+3
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ldh a, [hEnemyParam3]
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
    ldh a, [hEnemyParam3]
    cp a, PROJECTILE_RESPAWN_TIME
    jr nz, .endSpawnProjectile
.setStructSpawnProjectile:
    call SetEnemyStruct
.spawnProjectile:
    ld a, PROJECTILE
    ldh [hEnemyNumber], a
    ldh a, [hEnemyY]
    add a, 4
    ldh [hEnemyY], a
    ldh a, [hEnemyX]
    add a, 4
    ldh [hEnemyX], a
    jp SpawnProjectile
.endSpawnProjectile:
.endProjectileVariant:

    ;
    ; Check move
    ;
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and BALLOON_CARRIER_MOVE_TIME
    jp nz, .endMove
    ; Can move

    ; Move horizontal variant
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

    ; Move vertical variant
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
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and %00011111
    jr nz, .endCheckBobbing
    ldh a, [hEnemyFlags]
    and BALLOON_CARRIER_FLAG_BOBBING_INDEX_MASK
    jr nz, .bobUp
.bobDown:
    ldh a, [hEnemyFlags]
    set BALLOON_CARRIER_FLAG_BOBBING_INDEX_BIT, a
    ldh [hEnemyFlags], a
    ldh a, [hEnemyY]
    inc a
    ldh [hEnemyY], a
    jr .endCheckBobbing
.bobUp:
    ldh a, [hEnemyFlags]
    res BALLOON_CARRIER_FLAG_BOBBING_INDEX_BIT, a
    ldh [hEnemyFlags], a
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
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
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

.checkCactusBob:
    ; Is time to check cactus bob
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and BALLOON_CARRIER_CACTUS_BOB_TIME
    jr nz, .endCheckCactusBob
    ; Is cactus variant
    ldh a, [hEnemyVariant]
    cp a, CARRIER_ANVIL_VARIANT
    jr z, .endCheckCactusBob
.changeHandPositions:
    ld hl, wOAM+10
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ld a, [hl]
    cp a, BALLOON_CACTUS_TILE
    jr z, .leftHandUp
.rightHandUp:
    ld b, BALLOON_CACTUS_TILE
    ld c, BALLOON_CACTUS_TILE_2
    jr .updateCactusTile
.leftHandUp:
    ld b, BALLOON_CACTUS_TILE_2
    ld c, BALLOON_CACTUS_TILE
    ; jr .updateCactusTile
.updateCactusTile:
    ld a, b
    ld [hli], a
    inc l
    inc l
    inc l
    ld a, c
    ld [hl], a
.endCheckCactusBob:

    ;
    ; Check collision
    ;
    ; Is time to check collision
    ldh a, [hGlobalTimer]
    rrca ; Ignore first bit of timer that may always be 0 or 1 from EnemyUpdate
    and BALLOON_CARRIER_COLLISION_TIME
    jp nz, .endCollision
    ; Hit by enemy
    ldh a, [hEnemyFlags]
    and ENEMY_FLAG_HIT_ENEMY_MASK
    jr nz, .deathOfBalloonCarrier
    ; Is player alive
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    jr z, .checkHitByBullet

    ; Check hit player balloon
    SETUP_ENEMY_COLLIDER BALLOON_CARRIER_CACTUS_COLLISION_Y, BALLOON_CARRIER_CACTUS_COLLISION_HEIGHT, BALLOON_CARRIER_CACTUS_COLLISION_X, BALLOON_CARRIER_CACTUS_COLLISION_WIDTH
    call CollisionCheckPlayerBalloon
    call nz, CollisionWithPlayer

    ; Check hit player cactus
    SETUP_ENEMY_COLLIDER BALLOON_CARRIER_COLLISION_Y, BALLOON_CARRIER_COLLISION_HEIGHT, BALLOON_CARRIER_COLLISION_X, BALLOON_CARRIER_COLLISION_WIDTH
    call CollisionCheckPlayerCactus
    jr z, .checkHitByBullet
    ; Check hit bomb variant
    ldh a, [hEnemyVariant]
    cp a, CARRIER_BOMB_VARIANT
    call z, CollisionWithPlayer
    jr .deathOfBalloonCarrier
    ; Check hit bullet
.checkHitByBullet:
    call EnemyHitBullet
    jr z, .endCollision
.deathOfBalloonCarrier:
    ; Points
.variantPoints:
    ldh a, [hEnemyVariant]
.normalPoints:
    cp a, CARRIER_NORMAL_VARIANT
    jr nz, .followPoints
    ld a, BALLOON_CARRIER_NORMAL_POINTS
    jr .updatePoints
.followPoints:
    cp a, CARRIER_FOLLOW_VARIANT
    jr nz, .projectilePoints
    ld a, BALLOON_CARRIER_PROJECTILE_POINTS
    jr .updatePoints
.projectilePoints:
    cp a, CARRIER_PROJECTILE_VARIANT
    jr nz, .bombPoints
    ld a, BALLOON_CARRIER_FOLLOW_POINTS
    jr .updatePoints
.bombPoints:
    cp a, CARRIER_BOMB_VARIANT
    jr nz, .endVariantPoints
    ld a, BALLOON_CARRIER_BOMB_POINTS
.updatePoints:
    call AddPoints
.endVariantPoints:
    ; Only set the dying bit if not bomb carrier
    ; It sets the dying animation and we spawn explosion instead
    ldh a, [hEnemyVariant]
    cp a, CARRIER_BOMB_VARIANT
    ldh a, [hEnemyFlags] ; Load hEnemyFlags here
    jr nz, .setDying
.resDying:
    res ENEMY_FLAG_DYING_BIT, a
    jr .updatedDying
.setDying:
    set ENEMY_FLAG_DYING_BIT, a
    ; jr .updatedDying
.updatedDying:
    ; ldh a, [hEnemyFlags]
    res ENEMY_FLAG_ALIVE_BIT, a
    set BALLOON_CARRIER_FLAG_TRIGGER_SPAWN_BIT, a
    ldh [hEnemyFlags], a
    ; Sound
    call PopSound
.endCollision:

    ;
    ; Check offscreen
    ;
    ld bc, BALLOON_CARRIER_OAM_BYTES
    call HandleEnemyOffscreenHorizontal
    ; Enemy may be cleared, must do setStruct next

    ;
    ; Set struct
    ;
    jp SetEnemyStruct