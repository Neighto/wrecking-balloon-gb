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
BOMB_EXPLOSION_TILE_1 EQU $24
BOMB_EXPLOSION_TILE_2 EQU $26

SECTION "bomb", ROMX

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
    ld a, [wEnemyPopping]
    ld [hli], a
    ld a, [wEnemyPoppingFrame]
    ld [hli], a
    ld a, [wEnemyPoppingTimer]
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
    ld [wEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyAlive], a
    ld a, BOMB
    ld [wEnemyNumber], a
.balloonLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld a, BOMB_TILE
    ld [hl], a
    inc l
    ld [hl], OAMF_PAL0
.balloonRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
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
    ld [hl], a
    inc l
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

ExplosionAnimation:
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr z, .frame0
    ld a, [wEnemyPoppingTimer]
	inc	a
	ld [wEnemyPoppingTimer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    ret nz
.canSwitchFrames:
    ld a, [wEnemyPoppingFrame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .frame2
    cp a, 3
    jp z, .frame3
    cp a, 4
    jp z, .clear
    ret
.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jp .endFrame
.frame1:
    ; Explosion left
    SET_HL_TO_ADDRESS wOAM+1, wEnemyOAM
    ld a, [wEnemyX]
    sub 4
    ld [hli], a
    ld a, BOMB_EXPLOSION_TILE_1
    ld [hl], a
    ; Explosion middle
    SET_HL_TO_ADDRESS wOAM+5, wEnemyOAM
    ld a, [wEnemyX]
    add 4
    ld [hli], a
    ld a, BOMB_EXPLOSION_TILE_2
    ld [hl], a
    ; Explosion right
    SET_HL_TO_ADDRESS wOAM+9, wEnemyOAM
    ld a, [wEnemyX]
    add 12
    ld [hli], a
    ld a, BOMB_EXPLOSION_TILE_1
    ld [hli], a
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endFrame
.frame2:
    ; Flip palette
    SET_HL_TO_ADDRESS wOAM+3, wEnemyOAM
    ld [hl], OAMF_PAL1
    SET_HL_TO_ADDRESS wOAM+7, wEnemyOAM
    ld [hl], OAMF_PAL1
    SET_HL_TO_ADDRESS wOAM+11, wEnemyOAM
    ld [hl], OAMF_PAL1 | OAMF_XFLIP
    jr .endFrame
.frame3:
    ; Flip palette
    SET_HL_TO_ADDRESS wOAM+3, wEnemyOAM
    ld [hl], OAMF_PAL0
    SET_HL_TO_ADDRESS wOAM+7, wEnemyOAM
    ld [hl], OAMF_PAL0
    SET_HL_TO_ADDRESS wOAM+11, wEnemyOAM
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endFrame
.clear:
    call Clear
    ret 
.endFrame:
    ld a, [wEnemyPoppingFrame]
    inc a 
    ld [wEnemyPoppingFrame], a
.end:
    ret

BombUpdate::
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
    ld [wEnemyPopping], a
    ld a, [hli]
    ld [wEnemyPoppingFrame], a
    ld a, [hl]
    ld [wEnemyPoppingTimer], a

.checkAlive:
    ld a, [wEnemyAlive]
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
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    inc l
    inc l
.balloonRight:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.bombSpace:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
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
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet
.deathOfBomb:
    xor a ; ld a, 0
    ld [wEnemyAlive], a
    ; Animation trigger
    ld a, 1
    ld [wEnemyPopping], a
    ; Sound
    ; call ExplosionSound ; conflicts with the other sound
.endCollision:

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
    call Clear
    jr .setStruct
.endOffscreen:
    
.popped:
    ld a, [wEnemyPopping]
    cp a, 0
    call nz, ExplosionAnimation
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret