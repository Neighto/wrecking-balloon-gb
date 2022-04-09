INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

BIRD_OAM_SPRITES EQU 3
BIRD_MOVE_TIME EQU %00000011
BIRD_COLLISION_TIME EQU %00001000

BIRD_VERTICAL_MOVE_TIME EQU %00000011
BIRD_FALLING_WAIT_TIME EQU %00000001
BIRD_HORIZONTAL_SPEED EQU 2
BIRD_VERTICAL_SPEED EQU 1
BIRD_FLAP_UP_SPEED EQU 3

BIRD_TILE_1 EQU $18
BIRD_TILE_2 EQU $1A
BIRD_TILE_2_ALT EQU $1E
BIRD_TILE_3 EQU $1C
BIRD_TILE_3_ALT EQU $20

BIRD_DEAD_TILE_1 EQU $28
BIRD_DEAD_TILE_2 EQU $2A
BIRD_DEAD_TILE_3 EQU $2C

BIRD_POINTS EQU 100

SECTION "bird", ROMX

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
    ldh a, [hEnemyDirectionLeft]
    ld [hli], a
    ldh a, [hEnemyDying]
    ld [hli], a
    ldh a, [hEnemyAnimationFrame]
    ld [hli], a
    ldh a, [hEnemyParam1] ; Enemy Marked to Die
    ld [hli], a
    ldh a, [hEnemyDifficulty]
    ld [hl], a
    ret

SpawnBird::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jp z, .end
.availableSpace:
    ld b, BIRD_OAM_SPRITES
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
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.difficultyVisual:
    ldh a, [hEnemyDifficulty]
.easyVisual:
    cp a, EASY
    jr nz, .mediumVisual
    ld e, OAMF_PAL0
    jr .endDifficultyVisual
.mediumVisual:
    cp a, MEDIUM
    jr nz, .hardVisual
    ld e, OAMF_PAL1
    jr .endDifficultyVisual
.hardVisual:
    cp a, HARD
    jr nz, .endDifficultyVisual
    ld e, OAMF_PAL0
.endDifficultyVisual:

.setupByDirection:
    ldh a, [hEnemyX]
    cp a, SCRN_X / 2
    jr c, .isLeftside
.isRightside:
    ld a, 1
    ldh [hEnemyDirectionLeft], a
    
.birdLeft:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld [hl], BIRD_TILE_1
    inc l
    ld a, e
    ld [hli], a
.birdMiddle:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld a, e
    ld [hli], a
.birdRight:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld [hl], BIRD_TILE_3
    inc l
    ld a, e
    ld [hl], a
    jr .setStruct
.isLeftside:
.leftBirdLeft:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld [hl], BIRD_TILE_3
    inc l
    ld a, e
    or a, OAMF_XFLIP
    ld [hli], a
.leftBirdMiddle:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld a, e
    or a, OAMF_XFLIP
    ld [hli], a
.leftBirdRight:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hli], a
    ld [hl], BIRD_TILE_1
    inc l
    ld a, e
    or a, OAMF_XFLIP
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

Clear:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    call InitializeEnemyStructVars
    ret

UpdateBirdPosition:
.birdLeft:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    inc l
    inc l
.birdMiddle:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.birdRight:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    add 16
    ld [hl], a
    ret

BirdFall:
    INCREMENT_POS hEnemyY, 2
    call UpdateBirdPosition
.checkOffscreen:
    ldh a, [hEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    xor a ; ld a, 0
    ldh [hEnemyDying], a
    call Clear
.endOffscreen:
    ret

BirdUpdate::
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
    ldh [hEnemyDirectionLeft], a
    ld a, [hli]
    ldh [hEnemyDying], a
    ld a, [hli]
    ldh [hEnemyAnimationFrame], a
    ld a, [hli]
    ldh [hEnemyParam1], a
    ld a, [hl]
    ldh [hEnemyDifficulty], a

.checkAlive:
    ldh a, [hEnemyAlive]
    cp a, 0
    jp z, .isDead
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	BIRD_MOVE_TIME
    jp nz, .endMove
.canMove:
    ldh a, [hEnemyDirectionLeft]
    cp a, 0
    jr z, .isLeftside
.isRightside:
    DECREMENT_POS hEnemyX, BIRD_HORIZONTAL_SPEED
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    jr .verticalMovement
.isLeftside:
    INCREMENT_POS hEnemyX, BIRD_HORIZONTAL_SPEED
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
.verticalMovement:
    ldh a, [hGlobalTimer]
    and BIRD_VERTICAL_MOVE_TIME
    jp nz, .endVerticalMovement
.moveDifficulty:
    ldh a, [hEnemyDifficulty]    
.moveEasy:
    cp a, EASY 
    jr nz, .moveMedium
    ld b, BIRD_VERTICAL_SPEED
    ld c, BIRD_FLAP_UP_SPEED
    ldh a, [hEnemyAnimationFrame]
    cp a, 0
    jr z, .soar
    cp a, 6
    jr c, .moveDown
    jr z, .flap
    cp a, 7
    jr z, .moveUp
    xor a
    ldh [hEnemyAnimationFrame], a
    jr .endVerticalMovement
.moveMedium:
    cp a, MEDIUM 
    jr nz, .endVerticalMovement
    ld b, BIRD_VERTICAL_SPEED * 2
    ld c, BIRD_FLAP_UP_SPEED * 2
    ldh a, [hEnemyAnimationFrame]
    cp a, 0
    jr z, .soar
    cp a, 12
    jr c, .moveDown
    jr z, .flap
    cp a, 16
    jr c, .moveUp
    xor a
    ldh [hEnemyAnimationFrame], a
    jr .endVerticalMovement
.soar:
    ld [hl], BIRD_TILE_3_ALT
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], BIRD_TILE_2_ALT
.moveDown:
    INCREMENT_POS hEnemyY, b
    jr .endFrame
.flap:
    ld [hl], BIRD_TILE_3
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], BIRD_TILE_2
.moveUp:
    DECREMENT_POS hEnemyY, c
.endFrame:
    ldh a, [hEnemyAnimationFrame]
    inc a
    ldh [hEnemyAnimationFrame], a
.endVerticalMovement:
    call UpdateBirdPosition
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BIRD_COLLISION_TIME
    jp nz, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 24
    ld e, 8
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
    jr .endCollision
.checkHitBySomething:
    ldh a, [hEnemyParam1]
    cp a, 0
    jr z, .endCollision
.deathOfBird:
    xor a ; ld a, 0
    ldh [hEnemyAlive], a
    ; Points
    ld d, BIRD_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1
    ldh [hEnemyDying], a
    ; Sound
    call ExplosionSound
    ; Screaming bird
    ldh a, [hEnemyDirectionLeft]
    cp a, 0
    jr z, .facingRight
.facingLeft:
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_3
    jr .endCollision
.facingRight:
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_3
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, hEnemyOAM
    ld [hl], BIRD_DEAD_TILE_1
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
    call Clear
    jr z, .setStruct
.endOffscreen:
    jr .setStruct

.isDead:
    ldh a, [hEnemyDying]
    cp a, 0
    jr z, .setStruct
    ldh a, [hGlobalTimer]
    and BIRD_FALLING_WAIT_TIME
    jr nz, .setStruct
.animating:
    INCREMENT_POS hEnemyY, 2
    call UpdateBirdPosition
.checkOffscreenY:
    ldh a, [hEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .setStruct
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .setStruct
.offscreenY:
    call Clear
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret