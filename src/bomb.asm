INCLUDE "balloonConstants.inc"
INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BOMB_DEFAULT_SPEED EQU 1
BOMB_OAM_SPRITES EQU 3
BOMB_OAM_BYTES EQU BOMB_OAM_SPRITES * 4
BOMB_MOVE_TIME EQU %00000001
BOMB_COLLISION_TIME EQU %00001000

BOMB_EASY_TILE EQU $22
BOMB_EASY_POINTS EQU 10

BOMB_MEDIUM_TILE EQU $62
BOMB_MEDIUM_POINTS EQU 20

BOMB_HARD_TILE EQU $62
BOMB_HARD_POINTS EQU 30

SECTION "bomb", ROMX

SetStruct:
    ; Argument hl = start of free enemy struct
    ldh a, [wEnemyActive]
    ld [hli], a
    ldh a, [wEnemyNumber]
    ld [hli], a
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    ld [hli], a
    ldh a, [wEnemyOAM]
    ld [hli], a
    ldh a, [wEnemyAlive]
    ld [hli], a
    ldh a, [wEnemyPopping]
    ld [hli], a
    ldh a, [wEnemyPoppingFrame]
    ld [hli], a
    ldh a, [wEnemyPoppingTimer]
    ld [hli], a
    ldh a, [wEnemyDifficulty]
    ld [hl], a
    ret

SpawnBomb::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    cp a, 0
    jr z, .end
.availableSpace:
    ld b, BOMB_OAM_SPRITES
	call RequestOAMSpace ; b now contains OAM address
    cp a, 0
    jr z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ldh [wEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ldh [wEnemyActive], a
    ldh [wEnemyAlive], a
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM

.difficultyVisual:
    ldh a, [wEnemyDifficulty]
.easyVisual:
    cp a, EASY
    jr nz, .mediumVisual
    ld d, BOMB_EASY_TILE
    ld e, OAMF_PAL0
    jr .endDifficultyVisual
.mediumVisual:
    cp a, MEDIUM
    jr nz, .hardVisual
    ld d, BOMB_MEDIUM_TILE
    ld e, OAMF_PAL0
    jr .endDifficultyVisual
.hardVisual:
    cp a, HARD
    jr nz, .endDifficultyVisual
    ld d, BOMB_HARD_TILE
    ld e, OAMF_PAL0
.endDifficultyVisual:

.balloonLeftOAM:
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
.balloonRightOAM:
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    or a, OAMF_XFLIP
    ld [hli], a
.bombSpaceOAM:
    ld a, 1
    ld [hli], a
    ld [hli], a
    ld a, EMPTY_TILE
    ld [hli], a
    ld [hl], OAMF_PAL0
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
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

BombUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [wEnemyY], a
    ld a, [hli]
    ldh [wEnemyX], a
    ld a, [hli]
    ldh [wEnemyOAM], a
    ld a, [hli]
    ldh [wEnemyAlive], a
    ld a, [hli]
    ldh [wEnemyPopping], a
    ld a, [hli]
    ldh [wEnemyPoppingFrame], a
    ld a, [hli]
    ldh [wEnemyPoppingTimer], a
    ld a, [hl]
    ldh [wEnemyDifficulty], a

.checkAlive:
    ldh a, [wEnemyAlive]
    cp a, 0
    jp z, .popped
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	BOMB_MOVE_TIME
    jr nz, .endMove
.canMove:
    ld hl, wEnemyY
    ld a, BOMB_DEFAULT_SPEED
    cpl
    add [hl]
    ld [hl], a
.balloonLeftOAM:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    ld [hli], a
    inc l
    inc l
.balloonRightOAM:
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.bombSpaceOAM:
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    add 16
    ld [hl], a
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BOMB_COLLISION_TIME
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .checkHitByBullet
    call CollisionWithPlayer
    jr .deathOfBomb
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld d, 8
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet
.deathOfBomb:
    xor a ; ld a, 0
    ldh [wEnemyAlive], a
    ; Points
.difficultyPoints:
    ldh a, [wEnemyDifficulty]
.easyPoints:
    cp a, EASY
    jr nz, .mediumPoints
    ld d, BOMB_EASY_POINTS
    jr .endDifficultyPoints
.mediumPoints:
    cp a, MEDIUM
    jr nz, .hardPoints
    ld d, BOMB_MEDIUM_POINTS
    jr .endDifficultyPoints
.hardPoints:
    cp a, HARD
    jr nz, .endDifficultyPoints
    ld d, BOMB_HARD_POINTS
.endDifficultyPoints:
    call AddPoints
    ; Animation trigger
    ld a, 1
    ldh [wEnemyPopping], a
    ; Sound
    call ExplosionSound ; conflicts with the pop sound
.endCollision:

.checkOffscreen:
    ldh a, [wEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    call Clear
    jr .setStruct
.endOffscreen:
    jr .setStruct
    
.popped:
    ldh a, [wEnemyPopping]
    cp a, 0
    jr z, .clear
.animating:
    call ExplosionAnimation
    jr .setStruct
.clear:
    call Clear
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret