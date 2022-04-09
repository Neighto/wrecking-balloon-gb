INCLUDE "balloonConstants.inc"
INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BALLOON_CACTUS_OAM_SPRITES EQU 5
BALLOON_CACTUS_MOVE_TIME EQU %00000011
BALLOON_CACTUS_COLLISION_TIME EQU %00001000
BALLOON_CACTUS_SCREAMING_TILE EQU $16
BALLOON_CACTUS_TILE EQU $14

PROJECTILE_RESPAWN_TIME EQU %01111111

BALLOON_CACTUS_EASY_TILE EQU $5A
BALLOON_CACTUS_EASY_POINTS EQU 15

BALLOON_CACTUS_MEDIUM_TILE EQU ENEMY_BALLOON_TILE
BALLOON_CACTUS_MEDIUM_POINTS EQU 30

BALLOON_CACTUS_HARD_TILE EQU $22
BALLOON_CACTUS_HARD_POINTS EQU 50

SECTION "balloon cactus", ROMX

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
    ldh a, [hEnemyY2]
    ld [hli], a
    ldh a, [hEnemyX2]
    ld [hli], a
    ldh a, [hEnemySpeed]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Enemy Falling Flag
    ld [hli], a
    ldh a, [hEnemyParam2] ; Enemy Falling Timer
    ld [hli], a
    ldh a, [hEnemyParam3] ; Enemy Delay Falling Timer
    ld [hli], a
    ldh a, [hEnemyParam4] ; Enemy Projectile Timer
    ld [hli], a
    ldh a, [hEnemyDifficulty]
    ld [hl], a
    ret

SpawnBalloonCactus::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jp z, .end
.availableSpace:
    ld b, BALLOON_CACTUS_OAM_SPRITES
	call RequestOAMSpace ; b now contains OAM address
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
    ldh [hEnemySpeed], a
    ldh a, [hEnemyY]
    add 16
    ldh [hEnemyY2], a
    ldh a, [hEnemyX]
    ldh [hEnemyX2], a

.updateFacing:
    cp a, SCRN_X / 2
    jr c, .isLeftside
    ldh [hEnemyDirectionLeft], a
.isLeftside:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.difficultyVisual:
    ldh a, [hEnemyDifficulty]
.easyVisual:
    cp a, EASY
    jr nz, .mediumVisual
    ld d, BALLOON_CACTUS_EASY_TILE
    ld e, OAMF_PAL0
    jr .endDifficultyVisual
.mediumVisual:
    cp a, MEDIUM
    jr nz, .hardVisual
    ld d, BALLOON_CACTUS_MEDIUM_TILE
    ld e, OAMF_PAL1
    jr .endDifficultyVisual
.hardVisual:
    cp a, HARD
    jr nz, .endDifficultyVisual
    ld d, BALLOON_CACTUS_HARD_TILE
    ld e, OAMF_PAL0
.endDifficultyVisual:

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
.extraSpaceOAM:
    ld a, 1
    ld [hli], a
    ld [hli], a
    ld a, EMPTY_TILE
    ld [hli], a
    ld [hl], OAMF_PAL0
    inc l
.cactusLeftOAM:
    ldh a, [hEnemyY2]
    ld [hli], a
    ldh a, [hEnemyX2]
    ld [hli], a
    ld [hl], BALLOON_CACTUS_TILE
    inc l
    ld [hl], OAMF_PAL0
.cactusRightOAM:
    inc l
    ldh a, [hEnemyY2]
    ld [hli], a
    ldh a, [hEnemyX2]
    add 8
    ld [hli], a
    ld [hl], BALLOON_CACTUS_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

ClearBalloon:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

ClearExtraSpace:
    SET_HL_TO_ADDRESS wOAM+8, hEnemyOAM
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

ClearCactus:
    SET_HL_TO_ADDRESS wOAM+12, hEnemyOAM
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret 

; CactusFallingCollision:
    ; Costly and awkward operation but worth it for the fun
;     push bc
; .checkBird:
;     xor a ; ld a, 0
;     ld [wEnemyOffset2], a
;     ld bc, 2 ; BIRD_STRUCT_AMOUNT
; .birdLoop:
;     SET_HL_TO_ADDRESS bird, wEnemyOffset2+4 ; Alive
;     ld a, [hl]
;     cp a, 0
;     jr z, .checkBirdLoop
; .isAlive:
;     push bc
;     SET_HL_TO_ADDRESS wOAM+12, hEnemyOAM
;     LD_BC_HL
;     SET_HL_TO_ADDRESS bird+3, wEnemyOffset2 ; OAM
;     ld a, [hl]
;     ld hl, wOAM
;     ADD_TO_HL a
;     ld e, 8
;     ld d, 16
;     call CollisionCheck
;     pop bc
;     cp a, 0
;     jr z, .checkBirdLoop
; .hitBird:
;     SET_HL_TO_ADDRESS bird+12, wEnemyOffset2 ; To Die
;     ld [hl], 1
; .checkBirdLoop:
;     ld a, [wEnemyOffset2]
;     add a, 9;BIRD_STRUCT_SIZE
;     ld [wEnemyOffset2], a
;     dec bc
;     ld a, b
;     or a, c
;     jr nz, .birdLoop
; .end:
;     pop bc
    ; ret

UpdateBalloonPosition:
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
.extraSpaceOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hl], a
    ret

UpdateCactusPosition:
.cactusLeftOAM:
    SET_HL_TO_ADDRESS wOAM+12, hEnemyOAM
    ldh a, [hEnemyY2]
    ld [hli], a
    ldh a, [hEnemyX2]
    ld [hli], a
    inc l
    inc l
.cactusRightOAM:
    ldh a, [hEnemyY2]
    ld [hli], a
    ldh a, [hEnemyX2]
    add 8
    ld [hl], a
    ret

BalloonCactusUpdate::
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
    ldh [hEnemyY2], a
    ld a, [hli]
    ldh [hEnemyX2], a
    ld a, [hli]
    ldh [hEnemySpeed], a 
    ld a, [hli]
    ldh [hEnemyParam1], a 
    ld a, [hli]
    ldh [hEnemyParam2], a
    ld a, [hli]
    ldh [hEnemyParam3], a
    ld a, [hli]
    ldh [hEnemyParam4], a
    ld a, [hl]
    ldh [hEnemyDifficulty], a

.checkAlive:
    ldh a, [hEnemyAlive]
    cp a, 0
    jp z, .popped
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	BALLOON_CACTUS_MOVE_TIME
    jr nz, .endMove
.canMove:

.moveVertical:
    ldh a, [hEnemyDifficulty]
.easyMove:
    cp a, EASY
    jr nz, .mediumMove
    ; Do nothing
    jr .endMoveVertical
.mediumMove:
    cp a, MEDIUM
    jr nz, .hardMove
    ; Follow player, maybe add random?
    ldh a, [hEnemyY2]
    ld hl, wPlayerY
    cp a, [hl]
    jr z, .endMoveVertical
    jr c, .moveDown
.moveUp:
    DECREMENT_POS hEnemyY, 1
    DECREMENT_POS hEnemyY2, 1
    jr .endMoveVertical
.moveDown:
    INCREMENT_POS hEnemyY, 1
    INCREMENT_POS hEnemyY2, 1
    jr .endMoveVertical
.hardMove:
    cp a, HARD
    jr nz, .endMoveVertical
    ; Do nothing
.endMoveVertical:

.moveHorizontal:
    ldh a, [hEnemyDirectionLeft]
    cp a, 0
    jr z, .isLeftside
    DECREMENT_POS hEnemyX, 1
    DECREMENT_POS hEnemyX2, 1
    jr .endMoveHorizontal
.isLeftside:
    INCREMENT_POS hEnemyX, 1
    INCREMENT_POS hEnemyX2, 1
.endMoveHorizontal:

.updatePosition:
    call UpdateBalloonPosition
    call UpdateCactusPosition
.endMove:

.checkProjectile:
    ldh a, [hEnemyDifficulty]
    cp a, EASY 
    jr nz, .endProjectile
    ldh a, [hEnemyParam4]
    inc a
    ldh [hEnemyParam4], a
    cp a, PROJECTILE_RESPAWN_TIME + 1
    jr c, .endProjectile
    xor a ; ld a, 0
    ldh [hEnemyParam4], a
.endProjectile:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BALLOON_CACTUS_COLLISION_TIME
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
    ldh a, [hEnemyDifficulty]
    cp a, HARD 
    call z, CollisionWithPlayer
    jr .deathOfBalloonCactus
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld d, 16
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet
.deathOfBalloonCactus:
    xor a ; ld a, 0
    ld [hEnemyAlive], a
    ; Points
.difficultyPoints:
    ldh a, [hEnemyDifficulty]
.easyPoints:
    cp a, EASY
    jr nz, .mediumPoints
    ld d, BALLOON_CACTUS_EASY_POINTS
    jr .endDifficultyPoints
.mediumPoints:
    cp a, MEDIUM
    jr nz, .hardPoints
    ld d, BALLOON_CACTUS_MEDIUM_POINTS
    jr .endDifficultyPoints
.hardPoints:
    cp a, HARD
    jr nz, .endDifficultyPoints
    ld d, BALLOON_CACTUS_HARD_POINTS
.endDifficultyPoints:
    call AddPoints
    ; Animation trigger
    ld a, 1
    ldh [hEnemyDying], a
    ldh [hEnemyParam1], a
    ; Screaming cactus
    SET_HL_TO_ADDRESS wOAM+14, hEnemyOAM
    ld [hl], BALLOON_CACTUS_SCREAMING_TILE
    SET_HL_TO_ADDRESS wOAM+18, hEnemyOAM
    ld [hl], BALLOON_CACTUS_SCREAMING_TILE
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
    call ClearBalloon
    call ClearExtraSpace
    call ClearCactus
    call InitializeEnemyStructVars
    jr .setStruct
.endOffscreen:
    jr .setStruct

.popped:
    ldh a, [hEnemyDying]
    cp a, 0
    jr z, .clearPopping
.animatePopping:
    ld a, [hEnemyDifficulty]
    cp a, HARD
    jr z, .bombBalloon
.normalBalloon:
    call PopBalloonAnimation
    jr .endPopped
.bombBalloon:
    call ExplosionAnimation
    jr .endPopped
.clearPopping:
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    xor a ; ld a, 0
    ld [hli], a
    inc hl
    inc hl
    inc hl
    ld [hli], a
    inc hl
    inc hl
    inc hl
    ld [hl], a
.endPopped:

.falling:
    ldh a, [hEnemyParam1]
    cp a, 0
    jr z, .clearFalling
.animateFalling:
    ld hl, hEnemyParam2
    inc [hl]
    ld a, [hl]
    and CACTUS_FALLING_TIME
    jr nz, .endFalling
    ; Check offscreen
    ld a, SCRN_X
    ld hl, hEnemyY2
    cp a, [hl]
    jr c, .offScreen
.canFall:
    ; call CactusFallingCollision
    ld hl, hEnemyParam3
    inc [hl]
    ld a, [hl]
    cp a, CACTUS_DELAY_FALLING_TIME
    jr c, .skipAcceleration
.accelerate:
    xor a ; ld a, 0
    ld [hEnemyParam3], a
    ld a, [hEnemySpeed]
    add a, a
    ld [hEnemySpeed], a
.skipAcceleration:
    INCREMENT_POS hEnemyY2, [hEnemySpeed]
    call UpdateCactusPosition
    jr .endFalling
.offScreen:
    xor a
    ld [hEnemyParam1], a
    jr .endFalling
.clearFalling:
    call ClearBalloon
    call ClearExtraSpace
    call ClearCactus
    call InitializeEnemyStructVars
.endFalling:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct

; Handle spawning projectile AFTER SetStruct because it messes up the current struct
.checkSpawnProjectile:

.flickerToSignalProjectile:
    ldh a, [hEnemyParam4]
    cp a, PROJECTILE_RESPAWN_TIME - 10
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
    ldh a, [hEnemyParam4]
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