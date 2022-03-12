INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

BIRD_OAM_SPRITES EQU 3
BIRD_MOVE_TIME EQU %00000011
BIRD_COLLISION_TIME EQU %00001000

BIRD_SOARING_TIME EQU %00000111
BIRD_FLAPPING_TIME EQU %00111111
BIRD_SPRITE_DESCENDING_TIME EQU %00001111
BIRD_FALLING_WAIT_TIME EQU %00000001
BIRD_HORIZONTAL_SPEED EQU 2
BIRD_VERTICAL_SPEED EQU 1
BIRD_FLAP_UP_SPEED EQU 5

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
    ld a, [wEnemyActive]
    ld [hli], a
    ld a, [wEnemyNumber]
    ld [hli], a
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld a, [wEnemyOAM]
    ld [hli], a
    ld a, [wEnemyAlive]
    ld [hli], a
    ld a, [wEnemyRightside]
    ld [hli], a
    ld a, [wEnemyFalling]
    ld [hli], a
    ld a, [wEnemyPoppingFrame]
    ld [hli], a
    ld a, [wEnemyToDie]
    ld [hl], a
    ret

SpawnBird::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    cp a, 0
    jp z, .end
.availableSpace:
    ld b, BIRD_OAM_SPRITES
	call RequestOAMSpace ; b now contains OAM address
    cp a, 0
    jp z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ld [wEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyAlive], a
    ld a, [wEnemyX]
    cp a, SCRN_X / 2
    jr c, .isLeftside
.isRightside:
    ld a, 1
    ld [wEnemyRightside], a
.birdLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], BIRD_TILE_1
    inc l
    ld [hl], OAMF_PAL0
.birdMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld [hl], OAMF_PAL0
.birdRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], BIRD_TILE_3
    inc l
    ld [hl], OAMF_PAL0
    jr .setStruct
.isLeftside:
.leftBirdLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], BIRD_TILE_3
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.leftBirdMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.leftBirdRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], BIRD_TILE_1
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

BirdRightsideFlap:
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr nz, .flapping
.soaring:
    ldh a, [hGlobalTimer]
    and BIRD_SOARING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_TILE_2_ALT
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], BIRD_TILE_3_ALT
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    ret
.flapping:
    ldh a, [hGlobalTimer]
    and BIRD_FLAPPING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], BIRD_TILE_3
    ld hl, wEnemyPoppingFrame
    ld [hl], 0
    DECREMENT_POS wEnemyY, BIRD_FLAP_UP_SPEED
    ret

BirdLeftsideFlap:
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr nz, .flapping
.soaring:
    ldh a, [hGlobalTimer]
    and BIRD_SOARING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_TILE_2_ALT
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], BIRD_TILE_3_ALT
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    ret
.flapping:
    ldh a, [hGlobalTimer]
    and BIRD_FLAPPING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_TILE_2
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], BIRD_TILE_3
    ld hl, wEnemyPoppingFrame
    ld [hl], 0
    DECREMENT_POS wEnemyY, BIRD_FLAP_UP_SPEED
    ret

Clear:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
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
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    inc l
    inc l
.birdMiddle:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.birdRight:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hl], a
    ret

BirdFall:
    INCREMENT_POS wEnemyY, 2
    call UpdateBirdPosition
.checkOffscreen:
    ld a, [wEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    xor a ; ld a, 0
    ld [wEnemyFalling], a
    call Clear
.endOffscreen:
    ret

BirdUpdate::
    ; Get rest of struct
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, [hli]
    ld [wEnemyOAM], a
    ld a, [hli]
    ld [wEnemyAlive], a
    ld a, [hli]
    ld [wEnemyRightside], a
    ld a, [hli]
    ld [wEnemyFalling], a
    ld a, [hli]
    ld [wEnemyPoppingFrame], a ; flapping frame
    ld a, [hl]
    ld [wEnemyToDie], a

.checkAlive:
    ld a, [wEnemyAlive]
    cp a, 0
    jp z, .isDead
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	BIRD_MOVE_TIME
    jr nz, .endMove
.canMove:
    ld a, [wEnemyRightside]
    cp a, 0
    jr z, .isLeftside
.isRightside:
    DECREMENT_POS wEnemyX, BIRD_HORIZONTAL_SPEED
    call BirdRightsideFlap
    jr .moveDown
.isLeftside:
    INCREMENT_POS wEnemyX, BIRD_HORIZONTAL_SPEED
    call BirdLeftsideFlap
.moveDown:
    ldh a, [hGlobalTimer]
    and BIRD_SPRITE_DESCENDING_TIME
    jr nz, .skipMoveDown
    INCREMENT_POS wEnemyY, BIRD_VERTICAL_SPEED
.skipMoveDown:
    call UpdateBirdPosition
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BIRD_COLLISION_TIME
    jp nz, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+4, wEnemyOAM
    ld e, 8
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
    jr .endCollision
.checkHitBySomething:
    ld a, [wEnemyToDie]
    cp a, 0
    jr z, .endCollision
.deathOfBird:
    xor a ; ld a, 0
    ld [wEnemyAlive], a
    ; Points
    ld d, BIRD_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1
    ld [wEnemyFalling], a
    ; Sound
    call ExplosionSound
    ; Screaming bird
    ld a, [wEnemyRightside]
    cp a, 0
    jr z, .facingRight
.facingLeft:
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_3
    jr .endCollision
.facingRight:
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_3
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_1
.endCollision:

.checkOffscreen:
    ld a, [wEnemyX]
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

.isDead:
    ld a, [wEnemyFalling]
    cp a, 0
    jr z, .setStruct
    ldh a, [hGlobalTimer]
    and BIRD_FALLING_WAIT_TIME
    call z, BirdFall
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret