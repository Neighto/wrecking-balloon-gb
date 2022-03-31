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
BOMB_TILE EQU $22

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
.balloonLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    ld [hli], a
    ld a, BOMB_TILE
    ld [hl], a
    inc l
    ld [hl], OAMF_PAL0
.balloonRight:
    inc l
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    add 8
    ld [hli], a
    ld a, BOMB_TILE
    ld [hl], a
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.bombSpace:
    inc l
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
.balloonLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    ld [hli], a
    inc l
    inc l
.balloonRight:
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.bombSpace:
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